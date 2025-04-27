import 'package:real_estate_empire/models/building_model.dart';
import 'package:real_estate_empire/models/land_model.dart';
import 'package:real_estate_empire/models/property_model.dart';

class GameConstants {
  // Experience values
  static const int experienceForPropertyPurchase = 10;
  static const int experienceForUpgrade = 5;
  static const int experienceForLandPurchase = 15;
  static const int experienceForBuildingCompletion = 25;
  
  // Time constants (in hours)
  static const int smallHouseConstructionTime = 4;
  static const int apartmentConstructionTime = 12;
  static const int officeConstructionTime = 8;
  static const int retailConstructionTime = 6;
  
  // Building costs per square foot
  static const double smallHouseCostPerSqFt = 150.0;
  static const double apartmentCostPerSqFt = 200.0;
  static const double officeCostPerSqFt = 250.0;
  static const double retailCostPerSqFt = 220.0;
  
  // Rent multipliers (daily rent as percentage of property value)
  static const double residentialRentMultiplier = 0.0005; // 0.05% per day
  static const double commercialRentMultiplier = 0.0007; // 0.07% per day
  
  // Upgrade costs (as percentage of property value)
  static const double minorUpgradeCost = 0.05; // 5% of property value
  static const double majorUpgradeCost = 0.15; // 15% of property value
  
  // Level thresholds
  static List<int> levelExperienceThresholds = [
    0,     // Level 1
    100,   // Level 2
    250,   // Level 3
    500,   // Level 4
    1000,  // Level 5
    2000,  // Level 6
    4000,  // Level 7
    8000,  // Level 8
    16000, // Level 9
    32000, // Level 10
  ];
  
  // Feature unlock levels
  static const Map<String, int> featureUnlockLevels = {
    'smallHouse': 1,
    'duplex': 2,
    'retailStore': 3,
    'apartment': 4,
    'officeBuilding': 5,
    'landDevelopment': 3,
    'customDesigns': 6,
    'secondNeighborhood': 7,
  };
  
  // Starting properties available in the market
  static const List<Map<String, dynamic>> initialProperties = [
    {
      'type': PropertyType.studioApartment,
      'name': 'Cozy Studio',
      'description': 'A small but comfortable studio apartment',
      'imageAsset': 'assets/images/properties/studio.png',
      'purchasePrice': 75000.0,
      'baseRent': 40.0,
    },
    {
      'type': PropertyType.smallHouse,
      'name': 'Starter Home',
      'description': 'Perfect first property for new investors',
      'imageAsset': 'assets/images/properties/small_house.png',
      'purchasePrice': 120000.0,
      'baseRent': 60.0,
    },
    {
      'type': PropertyType.duplex,
      'name': 'Twin Homes',
      'description': 'Two rental units in one property',
      'imageAsset': 'assets/images/properties/duplex.png',
      'purchasePrice': 200000.0,
      'baseRent': 110.0,
    },
    {
      'type': PropertyType.smallOffice,
      'name': 'Corner Office',
      'description': 'Small office space for professionals',
      'imageAsset': 'assets/images/properties/small_office.png',
      'purchasePrice': 180000.0,
      'baseRent': 100.0,
    },
    {
      'type': PropertyType.retailStore,
      'name': 'Shop Space',
      'description': 'Retail location perfect for small businesses',
      'imageAsset': 'assets/images/properties/retail.png',
      'purchasePrice': 250000.0,
      'baseRent': 140.0,
    },
  ];
  
  // Starting land parcels available
  static const List<Map<String, dynamic>> initialLandParcels = [
    {
      'size': LandSize.small,
      'zoneType': ZoneType.residential,
      'location': 'Sunrise Heights',
      'imageAsset': 'assets/images/land/small_residential.png',
      'purchasePrice': 50000.0,
    },
    {
      'size': LandSize.medium,
      'zoneType': ZoneType.residential,
      'location': 'Green Valley',
      'imageAsset': 'assets/images/land/medium_residential.png',
      'purchasePrice': 120000.0,
    },
    {
      'size': LandSize.small,
      'zoneType': ZoneType.commercial,
      'location': 'Business District',
      'imageAsset': 'assets/images/land/small_commercial.png',
      'purchasePrice': 80000.0,
    },
    {
      'size': LandSize.medium,
      'zoneType': ZoneType.mixedUse,
      'location': 'Downtown',
      'imageAsset': 'assets/images/land/medium_mixed.png',
      'purchasePrice': 150000.0,
    },
  ];
  
  // Building designs
  static const List<Map<String, dynamic>> buildingDesigns = [
    {
      'id': 'modern_house',
      'name': 'Modern House',
      'buildingType': BuildingType.smallHouse,
      'imageAsset': 'assets/images/designs/modern_house.png',
      'costMultiplier': 1.0,
      'rentMultiplier': 1.0,
    },
    {
      'id': 'traditional_house',
      'name': 'Traditional House',
      'buildingType': BuildingType.smallHouse,
      'imageAsset': 'assets/images/designs/traditional_house.png',
      'costMultiplier': 0.9,
      'rentMultiplier': 0.9,
    },
    {
      'id': 'small_apartment',
      'name': 'Small Apartment Complex',
      'buildingType': BuildingType.apartment,
      'imageAsset': 'assets/images/designs/small_apartment.png',
      'costMultiplier': 1.0,
      'rentMultiplier': 1.0,
    },
    {
      'id': 'glass_office',
      'name': 'Glass Office Building',
      'buildingType': BuildingType.office,
      'imageAsset': 'assets/images/designs/glass_office.png',
      'costMultiplier': 1.2,
      'rentMultiplier': 1.1,
    },
    {
      'id': 'strip_mall',
      'name': 'Strip Mall',
      'buildingType': BuildingType.retail,
      'imageAsset': 'assets/images/designs/strip_mall.png',
      'costMultiplier': 1.0,
      'rentMultiplier': 1.0,
    },
  ];
  
  // Property upgrade types
  static const Map<String, List<Map<String, dynamic>>> propertyUpgrades = {
    'studioApartment': [
      {
        'name': 'New Appliances',
        'description': 'Install modern appliances',
        'costMultiplier': 0.05,
        'rentIncrease': 0.1,
      },
      {
        'name': 'Renovate Bathroom',
        'description': 'Update bathroom fixtures',
        'costMultiplier': 0.07,
        'rentIncrease': 0.12,
      },
      {
        'name': 'Hardwood Floors',
        'description': 'Replace carpet with hardwood',
        'costMultiplier': 0.06,
        'rentIncrease': 0.08,
      },
    ],
    'smallHouse': [
      {
        'name': 'Kitchen Remodel',
        'description': 'Modern kitchen update',
        'costMultiplier': 0.08,
        'rentIncrease': 0.15,
      },
      {
        'name': 'Add Deck',
        'description': 'Build an outdoor deck',
        'costMultiplier': 0.06,
        'rentIncrease': 0.1,
      },
      {
        'name': 'Landscaping',
        'description': 'Improve curb appeal',
        'costMultiplier': 0.04,
        'rentIncrease': 0.05,
      },
    ],
    // More upgrades for other property types...
  };
}