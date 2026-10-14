import '../models/house.dart';
import '../models/preferences.dart';
import '../utils/geo_utils.dart';

/// One human-readable reason shown under “Why we recommend this house”.
class MatchReason {
  final String text;
  final bool matched;

  const MatchReason({required this.text, required this.matched});
}

/// Full AI compatibility result for presentation & ranking.
class AiMatchResult {
  final int percent;
  final double budgetScore;
  final double locationScore;
  final double houseTypeScore;
  final double bedroomScore;
  final double amenitiesScore;
  final double behaviourScore;
  final List<MatchReason> reasons;
  final double? distanceKm;

  const AiMatchResult({
    required this.percent,
    required this.budgetScore,
    required this.locationScore,
    required this.houseTypeScore,
    required this.bedroomScore,
    required this.amenitiesScore,
    required this.behaviourScore,
    required this.reasons,
    this.distanceKm,
  });

  List<MatchReason> get matchedReasons =>
      reasons.where((r) => r.matched).toList();
}

/// Personalized house recommendation engine.
///
/// AI Score =
///   Budget × 25% + Location/Distance × 20% + House Type × 15%
///   + Bedrooms × 15% + Amenities × 15% + User Behaviour × 10%
class RecommendationService {
  static const double wBudget = 0.25;
  static const double wLocation = 0.20;
  static const double wHouseType = 0.15;
  static const double wBedrooms = 0.15;
  static const double wAmenities = 0.15;
  static const double wBehaviour = 0.10;

  static AiMatchResult evaluate({
    required House house,
    UserPreferences? prefs,
    double? distanceKm,
    Set<String> favoriteIds = const {},
    List<String> recentlyViewedIds = const [],
    Set<String> inquiredHouseIds = const {},
  }) {
    if (prefs == null || !prefs.hasAnyPreference) {
      return _baseline(house, distanceKm);
    }

    final dist = distanceKm;
    final budget = _budgetScore(house, prefs);
    final location = _locationScore(house, prefs, dist);
    final type = _houseTypeScore(house, prefs);
    final beds = _bedroomScore(house, prefs);
    final amenities = _amenitiesScore(house, prefs);
    final behaviour = _behaviourScore(
      house,
      prefs,
      favoriteIds: favoriteIds,
      recentlyViewedIds: recentlyViewedIds,
      inquiredHouseIds: inquiredHouseIds,
    );

    final raw = budget.score * wBudget +
        location.score * wLocation +
        type.score * wHouseType +
        beds.score * wBedrooms +
        amenities.score * wAmenities +
        behaviour.score * wBehaviour;

    final percent = (raw * 100).round().clamp(20, 99);

    final reasons = <MatchReason>[
      ...budget.reasons,
      ...location.reasons,
      ...type.reasons,
      ...beds.reasons,
      ...amenities.reasons,
      ...behaviour.reasons,
    ];

    return AiMatchResult(
      percent: percent,
      budgetScore: budget.score,
      locationScore: location.score,
      houseTypeScore: type.score,
      bedroomScore: beds.score,
      amenitiesScore: amenities.score,
      behaviourScore: behaviour.score,
      reasons: reasons,
      distanceKm: dist,
    );
  }

  static int matchPercentage({
    required House house,
    UserPreferences? prefs,
    double? distanceKm,
    Set<String> favoriteIds = const {},
    List<String> recentlyViewedIds = const [],
    Set<String> inquiredHouseIds = const {},
  }) {
    return evaluate(
      house: house,
      prefs: prefs,
      distanceKm: distanceKm,
      favoriteIds: favoriteIds,
      recentlyViewedIds: recentlyViewedIds,
      inquiredHouseIds: inquiredHouseIds,
    ).percent;
  }

  static List<House> rank(
    List<House> houses,
    UserPreferences? prefs, {
    required double Function(House) distanceOf,
    Set<String> favoriteIds = const {},
    List<String> recentlyViewedIds = const [],
    Set<String> inquiredHouseIds = const {},
  }) {
    final scored = houses
        .map(
          (h) => MapEntry(
            h,
            evaluate(
              house: h,
              prefs: prefs,
              distanceKm: distanceOf(h),
              favoriteIds: favoriteIds,
              recentlyViewedIds: recentlyViewedIds,
              inquiredHouseIds: inquiredHouseIds,
            ).percent,
          ),
        )
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return scored.map((e) => e.key).toList();
  }

  // —— Component scorers (0.0 – 1.0) ——

  static _Part _budgetScore(House house, UserPreferences prefs) {
    final min = prefs.minimumBudget;
    final max = prefs.maximumBudget;
    if (min == null && max == null) {
      return const _Part(1.0, []);
    }
    final lo = min ?? 0;
    final hi = max ?? double.infinity;
    if (house.price >= lo && house.price <= hi) {
      return const _Part(1.0, [
        MatchReason(text: 'It is within your budget', matched: true),
      ]);
    }
    // Soft penalty outside range
    if (house.price < lo) {
      final gap = (lo - house.price) / lo;
      final s = (1.0 - gap * 2).clamp(0.0, 0.7);
      return _Part(s, [
        MatchReason(
          text: 'Price is below your minimum budget',
          matched: false,
        ),
      ]);
    }
    final gap = (house.price - hi) / hi;
    final s = (1.0 - gap * 2).clamp(0.0, 0.55);
    return _Part(s, [
      const MatchReason(
        text: 'Price is above your maximum budget',
        matched: false,
      ),
    ]);
  }

  static _Part _locationScore(
    House house,
    UserPreferences prefs,
    double? distanceKm,
  ) {
    final reasons = <MatchReason>[];
    double townScore = 0.5;
    final preferred = prefs.preferredLocation;

    if (preferred != null && preferred.isNotEmpty) {
      final match =
          house.town.toLowerCase() == preferred.toLowerCase() ||
          house.town.toLowerCase().contains(preferred.toLowerCase()) ||
          house.county.toLowerCase().contains(preferred.toLowerCase());
      townScore = match ? 1.0 : 0.25;
      reasons.add(
        MatchReason(
          text: match
              ? 'It is in $preferred'
              : 'Location differs from your preferred $preferred',
          matched: match,
        ),
      );
    }

    double distScore = 0.7;
    final maxDist = prefs.maximumDistance;
    if (distanceKm != null) {
      if (maxDist != null) {
        if (distanceKm <= maxDist) {
          distScore = 1.0 - (distanceKm / (maxDist * 2)).clamp(0.0, 0.35);
          reasons.add(
            MatchReason(
              text: 'It is only ${GeoUtils.formatDistance(distanceKm)}',
              matched: true,
            ),
          );
        } else {
          distScore = (1.0 - (distanceKm - maxDist) / maxDist).clamp(0.0, 0.4);
          reasons.add(
            MatchReason(
              text:
                  'Distance (${GeoUtils.formatDistance(distanceKm)}) exceeds your ${maxDist.toStringAsFixed(0)} km limit',
              matched: false,
            ),
          );
        }
      } else if (distanceKm <= 10) {
        distScore = 1.0;
        reasons.add(
          MatchReason(
            text: 'It is only ${GeoUtils.formatDistance(distanceKm)}',
            matched: true,
          ),
        );
      }
    }

    // Blend town + distance equally within the 20% location weight
    final score = preferred == null || preferred.isEmpty
        ? distScore
        : (townScore * 0.55 + distScore * 0.45);
    return _Part(score, reasons);
  }

  static _Part _houseTypeScore(House house, UserPreferences prefs) {
    if (prefs.houseType == null || prefs.houseType!.isEmpty) {
      return const _Part(1.0, []);
    }
    final match =
        house.houseType.toLowerCase() == prefs.houseType!.toLowerCase();
    return _Part(
      match ? 1.0 : 0.2,
      [
        MatchReason(
          text: match
              ? 'House type matches your preferred ${prefs.houseType}'
              : 'House type is ${house.houseType}, you preferred ${prefs.houseType}',
          matched: match,
        ),
      ],
    );
  }

  static _Part _bedroomScore(House house, UserPreferences prefs) {
    if (prefs.bedrooms == null) return const _Part(1.0, []);
    final want = prefs.bedrooms!;
    if (house.bedrooms == want) {
      return _Part(1.0, [
        MatchReason(
          text: 'It has your preferred $want bedrooms',
          matched: true,
        ),
      ]);
    }
    if (house.bedrooms > want) {
      return _Part(0.85, [
        MatchReason(
          text: 'It has ${house.bedrooms} bedrooms (you wanted $want+)',
          matched: true,
        ),
      ]);
    }
    final s = (house.bedrooms / want).clamp(0.0, 0.5);
    return _Part(s, [
      MatchReason(
        text: 'It has ${house.bedrooms} bedrooms (you wanted $want)',
        matched: false,
      ),
    ]);
  }

  static _Part _amenitiesScore(House house, UserPreferences prefs) {
    final checks = <({bool care, bool ok, String yes, String no})>[];
    final want = prefs.wantedFacilities;
    final have = house.facilities;

    void feature(bool cares, bool ok, String yes, String no) {
      if (!cares) return;
      checks.add((care: true, ok: ok, yes: yes, no: no));
    }

    if (prefs.parking == true) {
      feature(true, house.parking, 'Parking is available', 'Parking is not available');
    }
    if (prefs.security != null && prefs.security!.isNotEmpty) {
      final ok = _securityMatches(house.security, prefs.security!);
      feature(
        true,
        ok,
        'Security matches your preference',
        'Security may not match your preference (${prefs.security})',
      );
    }
    if (prefs.furnished != null) {
      feature(
        true,
        house.furnished == prefs.furnished,
        prefs.furnished!
            ? 'It is furnished as you prefer'
            : 'It is unfurnished as you prefer',
        house.furnished
            ? 'It is furnished (you preferred unfurnished)'
            : 'It is unfurnished (you preferred furnished)',
      );
    }

    feature(want.water, have.water, 'Reliable water available', 'Water not confirmed');
    feature(want.electricity, have.electricity, 'Electricity available', 'Electricity not confirmed');
    feature(want.wifi, have.wifi, 'Wi‑Fi available', 'Wi‑Fi not available');
    feature(want.cctv, have.cctv, 'CCTV security present', 'CCTV not listed');
    feature(want.gatedCompound, have.gatedCompound || house.security.toLowerCase().contains('gated'), 'Gated compound', 'Not a gated compound');
    feature(want.garden, have.garden, 'Garden available', 'No garden listed');
    feature(want.balcony, have.balcony, 'Balcony available', 'No balcony listed');
    feature(want.petFriendly, have.petFriendly, 'Pet friendly', 'Not marked pet friendly');
    feature(want.familyFriendly, have.familyFriendly, 'Family friendly', 'Not marked family friendly');
    feature(want.nearbySchools, have.nearbySchools, 'Near schools', 'Not marked near schools');
    feature(want.nearbyHospitals, have.nearbyHospitals, 'Near hospitals', 'Not marked near hospitals');
    feature(
      want.nearbyShopping,
      have.nearbyShopping,
      'Near shopping centers',
      'Not marked near shopping centers',
    );
    feature(
      want.publicTransport,
      have.publicTransport,
      'Near public transport',
      'Public transport not listed nearby',
    );
    feature(
      want.religiousFacility,
      have.religiousFacility,
      'Near a religious facility',
      'Religious facility not listed nearby',
    );

    if (prefs.preferredArea != null && prefs.preferredArea!.isNotEmpty) {
      final areaMatch = (house.area ?? '')
          .toLowerCase()
          .contains(prefs.preferredArea!.toLowerCase());
      feature(
        true,
        areaMatch,
        'It is in your preferred area (${prefs.preferredArea})',
        'Area differs from ${prefs.preferredArea}',
      );
    }

    if (checks.isEmpty) {
      var soft = 0.55;
      if (house.parking) soft += 0.1;
      if (_isHighSecurity(house.security)) soft += 0.15;
      if (have.nearbyShopping) soft += 0.1;
      return _Part(soft.clamp(0.0, 1.0), const []);
    }

    final hits = checks.where((c) => c.ok).length;
    final score = hits / checks.length;
    final reasons = checks
        .map((c) => MatchReason(text: c.ok ? c.yes : c.no, matched: c.ok))
        .toList();
    return _Part(score, reasons);
  }

  static _Part _behaviourScore(
    House house,
    UserPreferences prefs, {
    required Set<String> favoriteIds,
    required List<String> recentlyViewedIds,
    required Set<String> inquiredHouseIds,
  }) {
    double score = 0.35;
    final reasons = <MatchReason>[];

    if (favoriteIds.contains(house.id)) {
      score += 0.35;
      reasons.add(
        const MatchReason(
          text: 'You saved this house to favorites',
          matched: true,
        ),
      );
    }
    if (recentlyViewedIds.contains(house.id)) {
      score += 0.2;
      reasons.add(
        const MatchReason(
          text: 'Based on houses you recently viewed',
          matched: true,
        ),
      );
    }
    if (inquiredHouseIds.contains(house.id)) {
      score += 0.25;
      reasons.add(
        const MatchReason(
          text: 'You previously inquired about this listing',
          matched: true,
        ),
      );
    }

    // Affinity: user prefers this town/type from prefs (behavioural signal)
    if (prefs.preferredLocation != null &&
        house.town.toLowerCase() ==
            prefs.preferredLocation!.toLowerCase()) {
      score += 0.1;
    }

    return _Part(score.clamp(0.0, 1.0), reasons);
  }

  static bool _securityMatches(String houseSecurity, String preferred) {
    final h = houseSecurity.toLowerCase();
    final p = preferred.toLowerCase();
    if (p == 'high') {
      return _isHighSecurity(houseSecurity);
    }
    return h.contains(p) || p.contains(h);
  }

  static bool _isHighSecurity(String security) {
    final s = security.toLowerCase();
    return s.contains('gated') ||
        s.contains('24') ||
        s.contains('guard') ||
        s.contains('electric');
  }

  static AiMatchResult _baseline(House house, double? distanceKm) {
    var base = 0.55;
    if (house.isAvailable) base += 0.1;
    if (house.parking) base += 0.05;
    if (_isHighSecurity(house.security)) base += 0.08;
    if (house.nearbyShopping) base += 0.05;
    final percent = (base * 100).round().clamp(40, 78);
    return AiMatchResult(
      percent: percent,
      budgetScore: 0.6,
      locationScore: 0.6,
      houseTypeScore: 0.6,
      bedroomScore: 0.6,
      amenitiesScore: 0.6,
      behaviourScore: 0.4,
      distanceKm: distanceKm,
      reasons: const [
        MatchReason(
          text: 'Set your preferences for personalized AI matching',
          matched: false,
        ),
      ],
    );
  }
}

class _Part {
  final double score;
  final List<MatchReason> reasons;
  const _Part(this.score, this.reasons);
}
