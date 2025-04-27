import 'package:uuid/uuid.dart';

enum PropertyType {
  studioApartment,
  smallHouse,
  duplex,
  smallOffice,
  retailStore,
}

enum PropertyStatus {
  vacant,
  occupied,
  underMaintenance,
}

class Property {
  final String id;
  final PropertyType type;
  final String name;
  final String description;
  final String imageAsset;
  final double purchasePrice;
  double currentValue;
  double baseRent;
  double currentRent;
  int upgradeLevel;
  Map<String, int> upgrades; // Map of upgrade types to their levels
  PropertyStatus status;
  DateTime lastCollected;
  DateTime acquiredDate;
  bool isOwned;

  Property({
    String? id,
    required this.type,
    required this.name,
    required this.description,
    required this.imageAsset,
    required this.purchasePrice,
    required this.baseRent,
    this.currentValue = 0,
    this.currentRent = 0,
    this.upgradeLevel = 0,
    Map<String, int>? upgrades,
    this.status = PropertyStatus.vacant,
    DateTime? lastCollected,
    DateTime? acquiredDate,
    this.isOwned = false,
  }) : 
    id = id ?? const Uuid().v4(),
    upgrades = upgrades ?? {},
    lastCollected = lastCollected ?? DateTime.now(),
    acquiredDate = acquiredDate ?? DateTime.now() {
      currentValue = currentValue > 0 ? currentValue : purchasePrice;
      currentRent = currentRent > 0 ? currentRent : baseRent;
    }

  // Calculate income based on time passed
  double calculateIncome(DateTime now) {
    if (status != PropertyStatus.occupied) return 0;
    
    final hoursSinceCollection = now.difference(lastCollected).inHours;
    // Cap at 24 hours to prevent excessive accumulation
    final cappedHours = hoursSinceCollection > 24 ? 24 : hoursSinceCollection;
    
    // Hourly rate (rent is per day, so divide by 24)
    return (currentRent / 24) * cappedHours;
  }

  // Collect rent
  double collectRent(DateTime now) {
    final income = calculateIncome(now);
    lastCollected = now;
    return income;
  }

  // Upgrade property
  void upgrade(String upgradeType) {
    if (!upgrades.containsKey(upgradeType)) {
      upgrades[upgradeType] = 1;
    } else {
      upgrades[upgradeType] = (upgrades[upgradeType] ?? 0) + 1;
    }
    
    upgradeLevel++;
    
    // Increase rent and value based on upgrade
    currentRent = baseRent * (1 + upgradeLevel * 0.15);
    currentValue = purchasePrice * (1 + upgradeLevel * 0.2);
  }

  // Purchase property
  void purchase() {
    isOwned = true;
    acquiredDate = DateTime.now();
    status = PropertyStatus.vacant;
  }

  // Occupy property (find tenant)
  void occupy() {
    status = PropertyStatus.occupied;
    lastCollected = DateTime.now();
  }

  // Convert to and from JSON for database storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'name': name,
      'description': description,
      'imageAsset': imageAsset,
      'purchasePrice': purchasePrice,
      'currentValue': currentValue,
      'baseRent': baseRent,
      'currentRent': currentRent,
      'upgradeLevel': upgradeLevel,
      'upgrades': upgrades.toString(), // Simple serialization for demo
      'status': status.index,
      'lastCollected': lastCollected.toIso8601String(),
      'acquiredDate': acquiredDate.toIso8601String(),
      'isOwned': isOwned ? 1 : 0,
    };
  }

  factory Property.fromJson(Map<String, dynamic> json) {
    // Simple deserialization for upgrades - in production use proper JSON
    final upgradesStr = json['upgrades'].toString();
    final Map<String, int> upgrades = {};
    
    if (upgradesStr.isNotEmpty && upgradesStr != '{}') {
      final items = upgradesStr
          .replaceAll('{', '')
          .replaceAll('}', '')
          .split(',');
          
      for (var item in items) {
        final parts = item.trim().split(':');
        if (parts.length == 2) {
          upgrades[parts[0].trim()] = int.parse(parts[1].trim());
        }
      }
    }

    return Property(
      id: json['id'],
      type: PropertyType.values[json['type']],
      name: json['name'],
      description: json['description'],
      imageAsset: json['imageAsset'],
      purchasePrice: json['purchasePrice'],
      currentValue: json['currentValue'],
      baseRent: json['baseRent'],
      currentRent: json['currentRent'],
      upgradeLevel: json['upgradeLevel'],
      upgrades: upgrades,
      status: PropertyStatus.values[json['status']],
      lastCollected: DateTime.parse(json['lastCollected']),
      acquiredDate: DateTime.parse(json['acquiredDate']),
      isOwned: json['isOwned'] == 1,
    );
  }
}