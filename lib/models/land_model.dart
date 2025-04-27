import 'package:uuid/uuid.dart';

enum LandSize {
  small,   // 0.25 acres
  medium,  // 0.5 acres
  large,   // 1 acre
}

enum ZoneType {
  residential,
  commercial,
  mixedUse,
}

class Land {
  final String id;
  final LandSize size;
  final ZoneType zoneType;
  final String location;
  final String imageAsset;
  final double purchasePrice;
  double currentValue;
  String? buildingId; // ID of building constructed on this land, if any
  bool isOwned;
  DateTime? acquiredDate;

  Land({
    String? id,
    required this.size,
    required this.zoneType,
    required this.location,
    required this.imageAsset,
    required this.purchasePrice,
    this.currentValue = 0,
    this.buildingId,
    this.isOwned = false,
    this.acquiredDate,
  }) : 
    id = id ?? const Uuid().v4() {
      currentValue = currentValue > 0 ? currentValue : purchasePrice;
    }

  // Calculate size in square feet
  int get squareFeet {
    switch (size) {
      case LandSize.small:
        return 10890; // 0.25 acres
      case LandSize.medium:
        return 21780; // 0.5 acres
      case LandSize.large:
        return 43560; // 1 acre
    }
  }

  // Check if land can support a specific building type
  bool canSupportBuilding(String buildingType) {
    // Basic implementation - to be expanded with more rules
    switch (zoneType) {
      case ZoneType.residential:
        return buildingType == 'smallHouse' || 
               buildingType == 'apartment';
      case ZoneType.commercial:
        return buildingType == 'office' || 
               buildingType == 'retail';
      case ZoneType.mixedUse:
        return true; // Can support any building type
    }
  }

  // Purchase land
  void purchase() {
    isOwned = true;
    acquiredDate = DateTime.now();
  }

  // Assign building to this land
  void assignBuilding(String id) {
    buildingId = id;
  }

  // Convert to and from JSON for database storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'size': size.index,
      'zoneType': zoneType.index,
      'location': location,
      'imageAsset': imageAsset,
      'purchasePrice': purchasePrice,
      'currentValue': currentValue,
      'buildingId': buildingId,
      'isOwned': isOwned ? 1 : 0,
      'acquiredDate': acquiredDate?.toIso8601String(),
    };
  }

  factory Land.fromJson(Map<String, dynamic> json) {
    return Land(
      id: json['id'],
      size: LandSize.values[json['size']],
      zoneType: ZoneType.values[json['zoneType']],
      location: json['location'],
      imageAsset: json['imageAsset'],
      purchasePrice: json['purchasePrice'],
      currentValue: json['currentValue'],
      buildingId: json['buildingId'],
      isOwned: json['isOwned'] == 1,
      acquiredDate: json['acquiredDate'] != null 
          ? DateTime.parse(json['acquiredDate']) 
          : null,
    );
  }
}