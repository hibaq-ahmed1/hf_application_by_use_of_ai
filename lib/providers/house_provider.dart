import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';

import '../data/sample_data.dart';
import '../models/features.dart';
import '../models/house.dart';
import '../models/preferences.dart';
import '../services/recommendation_service.dart';
import '../utils/geo_utils.dart';

class HouseProvider extends ChangeNotifier {
  final List<House> _houses = List.from(SampleData.houses);
  final Set<String> _favorites = {};
  final List<String> _recentlyViewed = [];
  final List<Inquiry> _inquiries = [];
  final List<SearchHistoryEntry> _searchHistory = [];
  final List<UserInteraction> _interactions = [];
  final Map<String, int> _favoriteCounts = {};
  final List<String> _categories = List.from(SampleData.categories);
  final Map<String, int> _locationSearchCounts = {
    'Kitengela': 18,
    'Rongai': 14,
    'Ngong': 9,
    'Kajiado': 7,
    'Nairobi': 12,
    'Athi River': 5,
  };

  HouseFilter _filter = const HouseFilter();
  HouseSort _sort = HouseSort.aiMatch;
  double _userLat = GeoUtils.demoLat;
  double _userLng = GeoUtils.demoLng;
  String _searchQuery = '';
  StreamSubscription<Position>? _positionSub;
  bool _liveLocationActive = false;
  String? _locationStatus;

  bool get liveLocationActive => _liveLocationActive;
  String? get locationStatus => _locationStatus;

  List<House> get houses => List.unmodifiable(_houses);
  HouseFilter get filter => _filter;
  HouseSort get sort => _sort;
  String get searchQuery => _searchQuery;
  Set<String> get favoriteIds => Set.unmodifiable(_favorites);
  double get userLat => _userLat;
  double get userLng => _userLng;
  List<Inquiry> get inquiries => List.unmodifiable(_inquiries);
  List<SearchHistoryEntry> get searchHistory => List.unmodifiable(_searchHistory);
  List<UserInteraction> get interactions => List.unmodifiable(_interactions);
  List<String> get categories => List.unmodifiable(_categories);
  int get inquiryCount => _inquiries.length;

  List<House> get availableHouses =>
      _houses.where((h) => h.isAvailable && h.approved).toList();

  List<House> get favoriteHouses =>
      _houses.where((h) => _favorites.contains(h.id)).toList();

  List<House> get reportedHouses =>
      _houses.where((h) => h.reported).toList();

  List<House> get pendingApproval =>
      _houses.where((h) => !h.approved).toList();

  List<House> get popularHouses {
    final list = List<House>.from(_houses)
      ..sort((a, b) => b.viewCount.compareTo(a.viewCount));
    return list.take(8).toList();
  }

  House? get mostViewedHouse {
    if (_houses.isEmpty) return null;
    return _houses.reduce((a, b) => a.viewCount >= b.viewCount ? a : b);
  }

  House? get mostFavoritedHouse {
    if (_favoriteCounts.isEmpty) return null;
    final topId = _favoriteCounts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    return byId(topId);
  }

  List<House> get newestHouses {
    final list = List<House>.from(_houses)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list.take(5).toList();
  }

  List<House> similarTo(House house, {int limit = 4}) {
    final scored = availableHouses.where((h) => h.id != house.id).map((h) {
      var score = 0;
      if (h.town == house.town) score += 40;
      if (h.houseType == house.houseType) score += 25;
      if ((h.bedrooms - house.bedrooms).abs() <= 1) score += 15;
      final priceDiff = (h.price - house.price).abs() / house.price;
      if (priceDiff <= 0.25) score += 15;
      if (h.parking == house.parking) score += 5;
      return MapEntry(h, score);
    }).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return scored.take(limit).map((e) => e.key).toList();
  }

  void recordInteraction({
    required String userId,
    required String type,
    String? houseId,
  }) {
    _interactions.insert(
      0,
      UserInteraction(
        id: const Uuid().v4(),
        userId: userId,
        houseId: houseId,
        interactionType: type,
        createdAt: DateTime.now(),
      ),
    );
  }

  Map<String, int> get mostSearchedLocations {
    final entries = _locationSearchCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(entries);
  }

  List<House> get recentlyViewedHouses {
    return _recentlyViewed
        .map((id) => _houses.cast<House?>().firstWhere(
              (h) => h!.id == id,
              orElse: () => null,
            ))
        .whereType<House>()
        .toList();
  }

  House? byId(String id) {
    try {
      return _houses.firstWhere((h) => h.id == id);
    } catch (_) {
      return null;
    }
  }

  List<House> listingsForOwner(String ownerId) =>
      _houses.where((h) => h.ownerId == ownerId).toList();

  void setUserLocation(double lat, double lng) {
    _userLat = lat;
    _userLng = lng;
    notifyListeners();
  }

  /// Starts GPS streaming for the realtime map. Falls back to demo coords.
  Future<void> startLiveLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _locationStatus = 'Location services off — using demo position';
        notifyListeners();
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _locationStatus = 'Location permission denied — using demo position';
        notifyListeners();
        return;
      }

      final current = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      setUserLocation(current.latitude, current.longitude);
      _liveLocationActive = true;
      _locationStatus = 'Live GPS active';

      await _positionSub?.cancel();
      _positionSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 15,
        ),
      ).listen((pos) {
        setUserLocation(pos.latitude, pos.longitude);
      });
      notifyListeners();
    } catch (_) {
      _locationStatus = 'GPS unavailable — using demo position near Kitengela';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
  }

  void setSearchQuery(String q, {bool record = false}) {
    _searchQuery = q;
    if (record && q.trim().isNotEmpty) {
      recordSearch(q.trim(), location: _filter.location);
    }
    notifyListeners();
  }

  void setSort(HouseSort sort) {
    _sort = sort;
    notifyListeners();
  }

  void setFilter(HouseFilter filter) {
    _filter = filter;
    if (filter.location != null && filter.location!.isNotEmpty) {
      _locationSearchCounts[filter.location!] =
          (_locationSearchCounts[filter.location!] ?? 0) + 1;
    }
    notifyListeners();
  }

  void clearFilter() {
    _filter = const HouseFilter();
    _searchQuery = '';
    _sort = HouseSort.aiMatch;
    notifyListeners();
  }

  void recordSearch(String query, {String? location, String? userId}) {
    _searchHistory.removeWhere(
      (e) => e.query.toLowerCase() == query.toLowerCase(),
    );
    _searchHistory.insert(
      0,
      SearchHistoryEntry(
        id: const Uuid().v4(),
        query: query,
        location: location,
        createdAt: DateTime.now(),
      ),
    );
    if (_searchHistory.length > 20) {
      _searchHistory.removeRange(20, _searchHistory.length);
    }
    if (userId != null) {
      recordInteraction(userId: userId, type: 'search');
    }
    notifyListeners();
  }

  void clearSearchHistory() {
    _searchHistory.clear();
    notifyListeners();
  }

  double distanceTo(House house) =>
      GeoUtils.distanceKm(_userLat, _userLng, house.latitude, house.longitude);

  List<House> filtered({UserPreferences? prefs, bool nearbyOnly = false}) {
    var list = availableHouses;

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((h) =>
              h.title.toLowerCase().contains(q) ||
              h.town.toLowerCase().contains(q) ||
              h.county.toLowerCase().contains(q) ||
              h.address.toLowerCase().contains(q) ||
              (h.area ?? '').toLowerCase().contains(q) ||
              h.houseType.toLowerCase().contains(q) ||
              h.category.toLowerCase().contains(q) ||
              h.id.toLowerCase().contains(q))
          .toList();
    }

    final f = _filter;
    if (f.location != null && f.location!.isNotEmpty) {
      final loc = f.location!.toLowerCase();
      list = list
          .where((h) =>
              h.town.toLowerCase().contains(loc) ||
              h.county.toLowerCase().contains(loc) ||
              (h.area ?? '').toLowerCase().contains(loc))
          .toList();
    }
    if (f.minPrice != null) {
      list = list.where((h) => h.price >= f.minPrice!).toList();
    }
    if (f.maxPrice != null) {
      list = list.where((h) => h.price <= f.maxPrice!).toList();
    }
    if (f.houseType != null && f.houseType!.isNotEmpty) {
      list = list
          .where((h) =>
              h.houseType.toLowerCase() == f.houseType!.toLowerCase())
          .toList();
    }
    if (f.category != null && f.category!.isNotEmpty) {
      list = list
          .where((h) =>
              h.category.toLowerCase() == f.category!.toLowerCase())
          .toList();
    }
    if (f.bedrooms != null) {
      list = list.where((h) => h.bedrooms >= f.bedrooms!).toList();
    }
    if (f.bathrooms != null) {
      list = list.where((h) => h.bathrooms >= f.bathrooms!).toList();
    }
    if (f.parking != null) {
      list = list.where((h) => h.parking == f.parking).toList();
    }
    if (f.security != null && f.security!.isNotEmpty) {
      list = list
          .where((h) =>
              h.security.toLowerCase().contains(f.security!.toLowerCase()))
          .toList();
    }
    if (f.furnished != null) {
      list = list.where((h) => h.furnished == f.furnished).toList();
    }

    if (nearbyOnly || f.maxDistanceKm != null) {
      final maxKm = f.maxDistanceKm ?? 25;
      list = list.where((h) => distanceTo(h) <= maxKm).toList();
    }

    return _applySort(list, prefs);
  }

  List<House> _applySort(List<House> list, UserPreferences? prefs) {
    final sorted = List<House>.from(list);
    switch (_sort) {
      case HouseSort.aiMatch:
        return RecommendationService.rank(
          sorted,
          prefs,
          distanceOf: distanceTo,
          favoriteIds: _favorites,
          recentlyViewedIds: _recentlyViewed,
          inquiredHouseIds: _inquiredHouseIds,
        );
      case HouseSort.priceLow:
        sorted.sort((a, b) => a.price.compareTo(b.price));
      case HouseSort.priceHigh:
        sorted.sort((a, b) => b.price.compareTo(a.price));
      case HouseSort.distance:
        sorted.sort((a, b) => distanceTo(a).compareTo(distanceTo(b)));
      case HouseSort.newest:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return sorted;
  }

  List<House> nearby({double maxKm = 25}) {
    final list = availableHouses
        .where((h) => distanceTo(h) <= maxKm)
        .toList()
      ..sort((a, b) => distanceTo(a).compareTo(distanceTo(b)));
    return list;
  }

  List<House> byTown(String town) {
    return availableHouses
        .where((h) => h.town.toLowerCase() == town.toLowerCase())
        .toList();
  }

  List<House> recommendations(UserPreferences? prefs, {int limit = 6}) {
    return RecommendationService.rank(
      availableHouses,
      prefs,
      distanceOf: distanceTo,
      favoriteIds: _favorites,
      recentlyViewedIds: _recentlyViewed,
      inquiredHouseIds: _inquiredHouseIds,
    ).take(limit).toList();
  }

  Set<String> get _inquiredHouseIds =>
      _inquiries.map((i) => i.houseId).toSet();

  AiMatchResult matchResult(House house, UserPreferences? prefs) =>
      RecommendationService.evaluate(
        house: house,
        prefs: prefs,
        distanceKm: distanceTo(house),
        favoriteIds: _favorites,
        recentlyViewedIds: _recentlyViewed,
        inquiredHouseIds: _inquiredHouseIds,
      );

  int matchFor(House house, UserPreferences? prefs) =>
      matchResult(house, prefs).percent;

  void toggleFavorite(String houseId, {String? userId}) {
    if (_favorites.contains(houseId)) {
      _favorites.remove(houseId);
      _favoriteCounts[houseId] = ((_favoriteCounts[houseId] ?? 1) - 1).clamp(0, 9999);
      if (userId != null) {
        recordInteraction(userId: userId, type: 'unfavorite', houseId: houseId);
      }
    } else {
      _favorites.add(houseId);
      _favoriteCounts[houseId] = (_favoriteCounts[houseId] ?? 0) + 1;
      if (userId != null) {
        recordInteraction(userId: userId, type: 'favorite', houseId: houseId);
      }
    }
    notifyListeners();
  }

  bool isFavorite(String houseId) => _favorites.contains(houseId);

  void recordView(String houseId, {String? userId}) {
    _recentlyViewed.remove(houseId);
    _recentlyViewed.insert(0, houseId);
    if (_recentlyViewed.length > 12) {
      _recentlyViewed.removeRange(12, _recentlyViewed.length);
    }
    final house = byId(houseId);
    if (house != null) {
      updateHouse(house.copyWith(viewCount: house.viewCount + 1), silent: true);
    }
    if (userId != null) {
      recordInteraction(userId: userId, type: 'view', houseId: houseId);
    }
    notifyListeners();
  }

  void addInquiry({
    required String houseId,
    required String seekerId,
    required String seekerName,
    required String message,
  }) {
    _inquiries.insert(
      0,
      Inquiry(
        id: const Uuid().v4(),
        houseId: houseId,
        seekerId: seekerId,
        seekerName: seekerName,
        message: message,
        createdAt: DateTime.now(),
        status: 'open',
      ),
    );
    recordInteraction(userId: seekerId, type: 'inquiry', houseId: houseId);
    notifyListeners();
  }

  void recordContact(String userId, String houseId, String channel) {
    recordInteraction(userId: userId, type: channel, houseId: houseId);
    notifyListeners();
  }

  void replyToInquiry(String inquiryId, String reply) {
    final i = _inquiries.indexWhere((e) => e.id == inquiryId);
    if (i < 0) return;
    _inquiries[i] = _inquiries[i].copyWith(
      ownerReply: reply,
      repliedAt: DateTime.now(),
      status: 'replied',
    );
    notifyListeners();
  }

  List<Inquiry> inquiriesForOwner(String ownerId) {
    return _inquiries.where((i) {
      final h = byId(i.houseId);
      return h?.ownerId == ownerId;
    }).toList();
  }

  List<Inquiry> inquiriesForSeeker(String seekerId) =>
      _inquiries.where((i) => i.seekerId == seekerId).toList();

  void addHouse(House house) {
    _houses.insert(0, house);
    notifyListeners();
  }

  void updateHouse(House house, {bool silent = false}) {
    final i = _houses.indexWhere((h) => h.id == house.id);
    if (i >= 0) {
      _houses[i] = house;
      if (!silent) notifyListeners();
    }
  }

  void deleteHouse(String houseId) {
    _houses.removeWhere((h) => h.id == houseId);
    _favorites.remove(houseId);
    _recentlyViewed.remove(houseId);
    notifyListeners();
  }

  void setAvailability(String houseId, HouseAvailability availability) {
    final house = byId(houseId);
    if (house == null) return;
    updateHouse(house.copyWith(availability: availability));
  }

  void setApproved(String houseId, bool approved) {
    final house = byId(houseId);
    if (house == null) return;
    updateHouse(house.copyWith(approved: approved));
  }

  void reportHouse(String houseId, String reason) {
    final house = byId(houseId);
    if (house == null) return;
    updateHouse(house.copyWith(reported: true, reportReason: reason));
  }

  void clearReport(String houseId) {
    final house = byId(houseId);
    if (house == null) return;
    updateHouse(house.copyWith(reported: false, reportReason: ''));
  }

  void addCategory(String name) {
    if (name.trim().isEmpty || _categories.contains(name.trim())) return;
    _categories.add(name.trim());
    notifyListeners();
  }

  void removeCategory(String name) {
    _categories.remove(name);
    notifyListeners();
  }

  int get totalListings => _houses.length;
  int get availableCount =>
      _houses.where((h) => h.availability == HouseAvailability.available).length;
  int get rentedCount =>
      _houses.where((h) => h.availability == HouseAvailability.rented).length;
  int get favoriteCount => _favorites.length;
  int get reportedCount => reportedHouses.length;

  Map<String, int> get listingsByTown {
    final map = <String, int>{};
    for (final h in _houses) {
      map[h.town] = (map[h.town] ?? 0) + 1;
    }
    return map;
  }

  Map<String, int> get listingsByType {
    final map = <String, int>{};
    for (final h in _houses) {
      map[h.houseType] = (map[h.houseType] ?? 0) + 1;
    }
    return map;
  }

  double get averagePrice {
    if (_houses.isEmpty) return 0;
    return _houses.map((h) => h.price).reduce((a, b) => a + b) / _houses.length;
  }

  List<double> get priceTrendSample => [12, 18, 15, 22, 28, 24, 31];
}
