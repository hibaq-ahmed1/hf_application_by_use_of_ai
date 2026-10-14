/// Amenity and nearby-facility flags used by houses and AI preferences.
class FacilityFeatures {
  final bool water;
  final bool electricity;
  final bool wifi;
  final bool cctv;
  final bool gatedCompound;
  final bool garden;
  final bool balcony;
  final bool petFriendly;
  final bool familyFriendly;
  final bool nearbySchools;
  final bool nearbyHospitals;
  final bool nearbyShopping;
  final bool publicTransport;
  final bool religiousFacility;

  const FacilityFeatures({
    this.water = true,
    this.electricity = true,
    this.wifi = false,
    this.cctv = false,
    this.gatedCompound = false,
    this.garden = false,
    this.balcony = false,
    this.petFriendly = false,
    this.familyFriendly = false,
    this.nearbySchools = false,
    this.nearbyHospitals = false,
    this.nearbyShopping = false,
    this.publicTransport = false,
    this.religiousFacility = false,
  });

  FacilityFeatures copyWith({
    bool? water,
    bool? electricity,
    bool? wifi,
    bool? cctv,
    bool? gatedCompound,
    bool? garden,
    bool? balcony,
    bool? petFriendly,
    bool? familyFriendly,
    bool? nearbySchools,
    bool? nearbyHospitals,
    bool? nearbyShopping,
    bool? publicTransport,
    bool? religiousFacility,
  }) {
    return FacilityFeatures(
      water: water ?? this.water,
      electricity: electricity ?? this.electricity,
      wifi: wifi ?? this.wifi,
      cctv: cctv ?? this.cctv,
      gatedCompound: gatedCompound ?? this.gatedCompound,
      garden: garden ?? this.garden,
      balcony: balcony ?? this.balcony,
      petFriendly: petFriendly ?? this.petFriendly,
      familyFriendly: familyFriendly ?? this.familyFriendly,
      nearbySchools: nearbySchools ?? this.nearbySchools,
      nearbyHospitals: nearbyHospitals ?? this.nearbyHospitals,
      nearbyShopping: nearbyShopping ?? this.nearbyShopping,
      publicTransport: publicTransport ?? this.publicTransport,
      religiousFacility: religiousFacility ?? this.religiousFacility,
    );
  }

  List<String> get activeLabels {
    final list = <String>[];
    if (water) list.add('Water');
    if (electricity) list.add('Electricity');
    if (wifi) list.add('Wi‑Fi');
    if (cctv) list.add('CCTV');
    if (gatedCompound) list.add('Gated compound');
    if (garden) list.add('Garden');
    if (balcony) list.add('Balcony');
    if (petFriendly) list.add('Pet friendly');
    if (familyFriendly) list.add('Family friendly');
    if (nearbySchools) list.add('Near schools');
    if (nearbyHospitals) list.add('Near hospitals');
    if (nearbyShopping) list.add('Near shopping');
    if (publicTransport) list.add('Public transport');
    if (religiousFacility) list.add('Religious facility');
    return list;
  }
}

enum HouseSort {
  aiMatch,
  priceLow,
  priceHigh,
  distance,
  newest,
}

extension HouseSortLabel on HouseSort {
  String get label {
    switch (this) {
      case HouseSort.aiMatch:
        return 'Best AI match';
      case HouseSort.priceLow:
        return 'Price: low to high';
      case HouseSort.priceHigh:
        return 'Price: high to low';
      case HouseSort.distance:
        return 'Nearest first';
      case HouseSort.newest:
        return 'Newest';
    }
  }
}

/// Canonical search towns for manual location mode.
const kSearchTowns = [
  'Kitengela',
  'Kajiado',
  'Nairobi',
  'Rongai',
  'Ngong',
  'Athi River',
];

const kHouseTypes = [
  'Bedsitter',
  'Studio',
  'Apartment',
  'Maisonette',
  'Bungalow',
  'Villa',
  'Townhouse',
];

const kPriceRanges = [
  (label: 'KSh 10k–20k', min: 10000.0, max: 20000.0),
  (label: 'KSh 20k–30k', min: 20000.0, max: 30000.0),
  (label: 'KSh 30k–50k', min: 30000.0, max: 50000.0),
];

const kNearbyRadiiKm = [1.0, 5.0, 10.0, 20.0, 50.0];
