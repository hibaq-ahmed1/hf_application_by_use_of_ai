import 'features.dart';

class UserPreferences {
  final String id;
  final String userId;
  final String? preferredLocation;
  final String? preferredArea;
  final double? minimumBudget;
  final double? maximumBudget;
  final String? houseType;
  final int? bedrooms;
  final int? bathrooms;
  final double? maximumDistance;
  final bool? parking;
  final String? security;
  final bool? furnished;
  final FacilityFeatures wantedFacilities;

  const UserPreferences({
    required this.id,
    required this.userId,
    this.preferredLocation,
    this.preferredArea,
    this.minimumBudget,
    this.maximumBudget,
    this.houseType,
    this.bedrooms,
    this.bathrooms,
    this.maximumDistance,
    this.parking,
    this.security,
    this.furnished,
    this.wantedFacilities = const FacilityFeatures(
      water: false,
      electricity: false,
      wifi: false,
      cctv: false,
      gatedCompound: false,
    ),
  });

  bool get nearbySchools => wantedFacilities.nearbySchools;
  bool get nearbyHospitals => wantedFacilities.nearbyHospitals;
  bool get nearbyShopping => wantedFacilities.nearbyShopping;

  bool get hasAnyPreference =>
      (preferredLocation != null && preferredLocation!.isNotEmpty) ||
      (preferredArea != null && preferredArea!.isNotEmpty) ||
      minimumBudget != null ||
      maximumBudget != null ||
      (houseType != null && houseType!.isNotEmpty) ||
      bedrooms != null ||
      bathrooms != null ||
      maximumDistance != null ||
      parking == true ||
      (security != null && security!.isNotEmpty) ||
      furnished != null ||
      wantedFacilities.activeLabels.isNotEmpty;

  UserPreferences copyWith({
    String? preferredLocation,
    String? preferredArea,
    double? minimumBudget,
    double? maximumBudget,
    String? houseType,
    int? bedrooms,
    int? bathrooms,
    double? maximumDistance,
    bool? parking,
    String? security,
    bool? furnished,
    FacilityFeatures? wantedFacilities,
  }) {
    return UserPreferences(
      id: id,
      userId: userId,
      preferredLocation: preferredLocation ?? this.preferredLocation,
      preferredArea: preferredArea ?? this.preferredArea,
      minimumBudget: minimumBudget ?? this.minimumBudget,
      maximumBudget: maximumBudget ?? this.maximumBudget,
      houseType: houseType ?? this.houseType,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      maximumDistance: maximumDistance ?? this.maximumDistance,
      parking: parking ?? this.parking,
      security: security ?? this.security,
      furnished: furnished ?? this.furnished,
      wantedFacilities: wantedFacilities ?? this.wantedFacilities,
    );
  }
}
