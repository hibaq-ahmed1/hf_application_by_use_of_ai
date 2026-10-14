import 'features.dart';

enum HouseAvailability { available, rented, pending }

class House {
  final String id;
  final String ownerId;
  final String title;
  final String description;
  final double price;
  final String town;
  final String county;
  final String address;
  final String? area;
  final double latitude;
  final double longitude;
  final String houseType;
  final String category;
  final int bedrooms;
  final int bathrooms;
  final bool parking;
  final String security;
  final bool furnished;
  final HouseAvailability availability;
  final String ownerName;
  final String ownerPhone;
  final String ownerEmail;
  final List<String> images;
  final List<String> amenities;
  final FacilityFeatures facilities;
  final bool approved;
  final bool reported;
  final String? reportReason;
  final int viewCount;
  final DateTime createdAt;

  const House({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.price,
    required this.town,
    required this.county,
    required this.address,
    this.area,
    required this.latitude,
    required this.longitude,
    required this.houseType,
    this.category = 'Residential',
    required this.bedrooms,
    required this.bathrooms,
    required this.parking,
    required this.security,
    required this.furnished,
    required this.availability,
    required this.ownerName,
    required this.ownerPhone,
    required this.ownerEmail,
    required this.images,
    required this.amenities,
    this.facilities = const FacilityFeatures(),
    this.approved = true,
    this.reported = false,
    this.reportReason,
    this.viewCount = 0,
    required this.createdAt,
  });

  /// Backward-compatible alias used across search UI.
  String get location => town;

  bool get nearbySchools => facilities.nearbySchools;
  bool get nearbyHospitals => facilities.nearbyHospitals;
  bool get nearbyShopping => facilities.nearbyShopping;

  String get fullLocationLabel {
    final parts = [
      if (area != null && area!.isNotEmpty) area!,
      town,
      county,
    ];
    return parts.join(', ');
  }

  House copyWith({
    String? title,
    String? description,
    double? price,
    String? town,
    String? county,
    String? address,
    String? area,
    double? latitude,
    double? longitude,
    String? houseType,
    String? category,
    int? bedrooms,
    int? bathrooms,
    bool? parking,
    String? security,
    bool? furnished,
    HouseAvailability? availability,
    String? ownerName,
    String? ownerPhone,
    String? ownerEmail,
    List<String>? images,
    List<String>? amenities,
    FacilityFeatures? facilities,
    bool? approved,
    bool? reported,
    String? reportReason,
    int? viewCount,
  }) {
    return House(
      id: id,
      ownerId: ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      town: town ?? this.town,
      county: county ?? this.county,
      address: address ?? this.address,
      area: area ?? this.area,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      houseType: houseType ?? this.houseType,
      category: category ?? this.category,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      parking: parking ?? this.parking,
      security: security ?? this.security,
      furnished: furnished ?? this.furnished,
      availability: availability ?? this.availability,
      ownerName: ownerName ?? this.ownerName,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      images: images ?? this.images,
      amenities: amenities ?? this.amenities,
      facilities: facilities ?? this.facilities,
      approved: approved ?? this.approved,
      reported: reported ?? this.reported,
      reportReason: reportReason ?? this.reportReason,
      viewCount: viewCount ?? this.viewCount,
      createdAt: createdAt,
    );
  }

  String get availabilityLabel {
    switch (availability) {
      case HouseAvailability.available:
        return 'Available';
      case HouseAvailability.rented:
        return 'Rented';
      case HouseAvailability.pending:
        return 'Pending';
    }
  }

  bool get isAvailable => availability == HouseAvailability.available;
}

class HouseFilter {
  final String? location;
  final double? minPrice;
  final double? maxPrice;
  final String? houseType;
  final String? category;
  final int? bedrooms;
  final int? bathrooms;
  final bool? parking;
  final String? security;
  final bool? furnished;
  final double? maxDistanceKm;

  const HouseFilter({
    this.location,
    this.minPrice,
    this.maxPrice,
    this.houseType,
    this.category,
    this.bedrooms,
    this.bathrooms,
    this.parking,
    this.security,
    this.furnished,
    this.maxDistanceKm,
  });

  HouseFilter copyWith({
    String? location,
    double? minPrice,
    double? maxPrice,
    String? houseType,
    String? category,
    int? bedrooms,
    int? bathrooms,
    bool? parking,
    String? security,
    bool? furnished,
    double? maxDistanceKm,
    bool clearLocation = false,
    bool clearHouseType = false,
    bool clearSecurity = false,
    bool clearCategory = false,
    bool clearPrice = false,
    bool clearBedrooms = false,
    bool clearDistance = false,
  }) {
    return HouseFilter(
      location: clearLocation ? null : (location ?? this.location),
      minPrice: clearPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearPrice ? null : (maxPrice ?? this.maxPrice),
      houseType: clearHouseType ? null : (houseType ?? this.houseType),
      category: clearCategory ? null : (category ?? this.category),
      bedrooms: clearBedrooms ? null : (bedrooms ?? this.bedrooms),
      bathrooms: bathrooms ?? this.bathrooms,
      parking: parking ?? this.parking,
      security: clearSecurity ? null : (security ?? this.security),
      furnished: furnished ?? this.furnished,
      maxDistanceKm: clearDistance ? null : (maxDistanceKm ?? this.maxDistanceKm),
    );
  }

  bool get hasActiveFilters =>
      (location != null && location!.isNotEmpty) ||
      minPrice != null ||
      maxPrice != null ||
      (houseType != null && houseType!.isNotEmpty) ||
      (category != null && category!.isNotEmpty) ||
      bedrooms != null ||
      bathrooms != null ||
      parking != null ||
      (security != null && security!.isNotEmpty) ||
      furnished != null ||
      maxDistanceKm != null;
}

class Inquiry {
  final String id;
  final String houseId;
  final String seekerId;
  final String seekerName;
  final String message;
  final DateTime createdAt;
  final String status;
  final String? ownerReply;
  final DateTime? repliedAt;

  const Inquiry({
    required this.id,
    required this.houseId,
    required this.seekerId,
    required this.seekerName,
    required this.message,
    required this.createdAt,
    this.status = 'open',
    this.ownerReply,
    this.repliedAt,
  });

  Inquiry copyWith({String? ownerReply, DateTime? repliedAt, String? status}) {
    return Inquiry(
      id: id,
      houseId: houseId,
      seekerId: seekerId,
      seekerName: seekerName,
      message: message,
      createdAt: createdAt,
      status: status ?? this.status,
      ownerReply: ownerReply ?? this.ownerReply,
      repliedAt: repliedAt ?? this.repliedAt,
    );
  }
}

class UserInteraction {
  final String id;
  final String userId;
  final String? houseId;
  final String interactionType;
  final DateTime createdAt;

  const UserInteraction({
    required this.id,
    required this.userId,
    this.houseId,
    required this.interactionType,
    required this.createdAt,
  });
}

class SearchHistoryEntry {
  final String id;
  final String query;
  final String? location;
  final DateTime createdAt;

  const SearchHistoryEntry({
    required this.id,
    required this.query,
    this.location,
    required this.createdAt,
  });
}
