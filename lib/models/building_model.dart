import 'package:uuid/uuid.dart';

enum BuildingType {
  smallHouse,
  apartment,
  office,
  retail,
}

enum BuildingStatus {
  underConstruction,
  complete,
  occupied,
  underMaintenance,
}

class Building {
  final String id;
  final BuildingType type;
  final String designId;
  final String name;
  final String landId; // The land this building is constructed on
  double constructionCost;
  double currentValue;
  double baseRent;
  double currentRent;
  BuildingStatus status;
  DateTime constructionStarted;
  DateTime? constructionCompleted;
  DateTime? lastCollected;
  int constructionDurationHours;
  int completionPercentage;
  int upgradeLevel;
  Map<String, int> upgrades;

  Building({
    String? id,
    required this.type,
    required this.designId,
    required this.name,
    required this.landId,
    required this.constructionCost,
    this.currentValue = 0,
    required this.baseRent,
    this.currentRent = 0,
    this.status = BuildingStatus.underConstruction,
    DateTime? constructionStarted,
    this.constructionCompleted,
    this.lastCollected,
    required this.constructionDurationHours,
    this.completionPercentage = 0,
    this.upgradeLevel = 0,
    Map<String, int>? upgrades,
  }) : 
    id = id ?? const Uuid().v4(),
    constructionStarted = constructionStarted ?? DateTime.now(),
    upgrades = upgrades ?? {} {
      currentValue = currentValue > 0 ? currentValue : constructionCost * 1.2;
      currentRent = currentRent > 0 ? currentRent : baseRent;
    }

  // Calculate construction progress
  void updateConstructionProgress(DateTime now) {
    if (status != BuildingStatus.underConstruction) return;
    
    final hoursPassed = now.difference(constructionStarted).inHours;
    completionPercentage = ((hoursPassed / constructionDurationHours) * 100).round();
    
    if (completionPercentage >= 100) {
      completeConstruction(now);
    } else {
      completionPercentage = completionPercentage.clamp(0, 100);
    }
  }

  // Complete construction
  void completeConstruction(DateTime now) {
    status = BuildingStatus.complete;
    constructionCompleted = now;
    completionPercentage = 100;
  }

  // Occupy building (find tenant)
  void occupy(DateTime now) {
    status = BuildingStatus.occupied;
    lastCollected = now;
  }

  // Calculate income based on time passed
  double calculateIncome(DateTime now) {
    if (status != BuildingStatus.occupied || lastCollected == null) return 0;
    
    final hoursSinceCollection = now.difference(lastCollected!).inHours;
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

  // Upgrade building
  void upgrade(String upgradeType) {
    if (!upgrades.containsKey(upgradeType)) {
      upgrades[upgradeType] = 1;
    } else {
      upgrades[upgradeType] = (upgrades[upgradeType] ?? 0) + 1;
    }
    
    upgradeLevel++;
    
    // Increase rent and value based on upgrade
    currentRent = baseRent * (1 + upgradeLevel * 0.15);
    currentValue = constructionCost * (1 + upgradeLevel * 0.25);
  }

  // Convert to and from JSON for database storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'designId': designId,
      'name': name,
      'landId': landId,
      'constructionCost': constructionCost,
      'currentValue': currentValue,
      'baseRent': baseRent,
      'currentRent': currentRent,
      'status': status.index,
      'constructionStarted': constructionStarted.toIso8601String(),
      'constructionCompleted': constructionCompleted?.toIso8601String(),
      'lastCollected': lastCollected?.toIso8601String(),
      'constructionDurationHours': constructionDurationHours,
      'completionPercentage': completionPercentage,
      'upgradeLevel': upgradeLevel,
      'upgrades': upgrades.toString(), // Simple serialization for demo
    };
  }

  factory Building.fromJson(Map<String, dynamic> json) {
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

    return Building(
      id: json['id'],
      type: BuildingType.values[json['type']],
      designId: json['designId'],
      name: json['name'],
      landId: json['landId'],
      constructionCost: json['constructionCost'],
      currentValue: json['currentValue'],
      baseRent: json['baseRent'],
      currentRent: json['currentRent'],
      status: BuildingStatus.values[json['status']],
      constructionStarted: DateTime.parse(json['constructionStarted']),
      constructionCompleted: json['constructionCompleted'] != null
          ? DateTime.parse(json['constructionCompleted'])
          : null,
      lastCollected: json['lastCollected'] != null
          ? DateTime.parse(json['lastCollected'])
          : null,
      constructionDurationHours: json['constructionDurationHours'],
      completionPercentage: json['completionPercentage'],
      upgradeLevel: json['upgradeLevel'],
      upgrades: upgrades,
    );
  }
}