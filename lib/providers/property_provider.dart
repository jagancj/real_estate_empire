import 'package:flutter/foundation.dart';
import '../models/property_model.dart';
import '../models/land_model.dart';
import '../models/building_model.dart';
import '../services/database_service.dart';
import '../models/game_constants.dart';

class PropertyProvider with ChangeNotifier {
  final DatabaseService _databaseService;
  List<Property> _properties = [];
  List<Land> _landParcels = [];
  List<Building> _buildings = [];
  List<Property> _marketProperties = [];
  List<Land> _marketLandParcels = [];
  
  PropertyProvider(this._databaseService) {
    _initializeData();
  }
  
  // Getters
  List<Property> get ownedProperties => _properties.where((p) => p.isOwned).toList();
  List<Land> get ownedLand => _landParcels.where((l) => l.isOwned).toList();
  List<Building> get buildings => _buildings;
  List<Property> get marketProperties => _marketProperties;
  List<Land> get marketLandParcels => _marketLandParcels;
  
  // Initialize all property data
  Future<void> _initializeData() async {
    await _loadProperties();
    await _loadLand();
    await _loadBuildings();
    _initializeMarket();
    notifyListeners();
  }
  
  // Load properties from database
  Future<void> _loadProperties() async {
    try {
      final propertiesData = await _databaseService.getProperties();
      _properties = propertiesData.map((data) => Property.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Error loading properties: $e');
      _properties = [];
    }
  }
  
  // Load land parcels from database
  Future<void> _loadLand() async {
    try {
      final landData = await _databaseService.getLandParcels();
      _landParcels = landData.map((data) => Land.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Error loading land parcels: $e');
      _landParcels = [];
    }
  }
  
  // Load buildings from database
  Future<void> _loadBuildings() async {
    try {
      final buildingsData = await _databaseService.getBuildings();
      _buildings = buildingsData.map((data) => Building.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Error loading buildings: $e');
      _buildings = [];
    }
  }
  
  // Initialize the market with properties for sale
  void _initializeMarket() {
    // If no owned properties, create initial market offerings
    if (_properties.isEmpty) {
      for (var propData in GameConstants.initialProperties) {
        final property = Property(
          type: propData['type'] as PropertyType,
          name: propData['name'] as String,
          description: propData['description'] as String,
          imageAsset: propData['imageAsset'] as String,
          purchasePrice: propData['purchasePrice'] as double,
          baseRent: propData['baseRent'] as double,
        );
        _properties.add(property);
        _marketProperties.add(property);
      }
    } else {
      // Add non-owned properties to market
      _marketProperties = _properties.where((p) => !p.isOwned).toList();
    }
    
    // If no land parcels, create initial market offerings
    if (_landParcels.isEmpty) {
      for (var landData in GameConstants.initialLandParcels) {
        final land = Land(
          size: landData['size'] as LandSize,
          zoneType: landData['zoneType'] as ZoneType,
          location: landData['location'] as String,
          imageAsset: landData['imageAsset'] as String,
          purchasePrice: landData['purchasePrice'] as double,
        );
        _landParcels.add(land);
        _marketLandParcels.add(land);
      }
    } else {
      // Add non-owned land to market
      _marketLandParcels = _landParcels.where((l) => !l.isOwned).toList();
    }
  }
  
  // Purchase a property
  Future<bool> purchaseProperty(String propertyId) async {
    final propertyIndex = _properties.indexWhere((p) => p.id == propertyId);
    if (propertyIndex == -1) return false;
    
    final property = _properties[propertyIndex];
    property.purchase();
    property.occupy(); // Automatically find a tenant
    
    // Update lists
    _properties[propertyIndex] = property;
    _marketProperties.removeWhere((p) => p.id == propertyId);
    
    // Save to database
    await _databaseService.saveProperty(property.toJson());
    
    notifyListeners();
    return true;
  }
  
  // Purchase a land parcel
  Future<bool> purchaseLand(String landId) async {
    final landIndex = _landParcels.indexWhere((l) => l.id == landId);
    if (landIndex == -1) return false;
    
    final land = _landParcels[landIndex];
    land.purchase();
    
    // Update lists
    _landParcels[landIndex] = land;
    _marketLandParcels.removeWhere((l) => l.id == landId);
    
    // Save to database
    await _databaseService.saveLandParcel(land.toJson());
    
    notifyListeners();
    return true;
  }
  
  // Start building construction on a land parcel
  Future<bool> startConstruction(
    String landId, 
    BuildingType buildingType, 
    String designId, 
    String buildingName
  ) async {
    final landIndex = _landParcels.indexWhere((l) => l.id == landId && l.isOwned);
    if (landIndex == -1) return false;
    
    final land = _landParcels[landIndex];
    if (land.buildingId != null) return false; // Land already has a building
    
    // Find the design
    final designData = GameConstants.buildingDesigns.firstWhere(
      (d) => d['id'] == designId && d['buildingType'] == buildingType,
      orElse: () => {},
    );
    if (designData.isEmpty) return false;
    
    // Calculate construction time based on building type
    int constructionTime;
    switch (buildingType) {
      case BuildingType.smallHouse:
        constructionTime = GameConstants.smallHouseConstructionTime;
        break;
      case BuildingType.apartment:
        constructionTime = GameConstants.apartmentConstructionTime;
        break;
      case BuildingType.office:
        constructionTime = GameConstants.officeConstructionTime;
        break;
      case BuildingType.retail:
        constructionTime = GameConstants.retailConstructionTime;
        break;
    }
    
    // Calculate construction cost based on land size and building type
    double costPerSqFt;
    switch (buildingType) {
      case BuildingType.smallHouse:
        costPerSqFt = GameConstants.smallHouseCostPerSqFt;
        break;
      case BuildingType.apartment:
        costPerSqFt = GameConstants.apartmentCostPerSqFt;
        break;
      case BuildingType.office:
        costPerSqFt = GameConstants.officeCostPerSqFt;
        break;
      case BuildingType.retail:
        costPerSqFt = GameConstants.retailCostPerSqFt;
        break;
    }
    
    // Apply design cost multiplier
    costPerSqFt *= (designData['costMultiplier'] as double);
    
    // Calculate total construction cost
    final totalCost = land.squareFeet * costPerSqFt;
    
    // Calculate base rent
    double rentMultiplier;
    switch (buildingType) {
      case BuildingType.smallHouse:
      case BuildingType.apartment:
        rentMultiplier = GameConstants.residentialRentMultiplier;
        break;
      case BuildingType.office:
      case BuildingType.retail:
        rentMultiplier = GameConstants.commercialRentMultiplier;
        break;
    }
    
    // Apply design rent multiplier
    rentMultiplier *= (designData['rentMultiplier'] as double);
    
    // Calculate daily rent
    final baseRent = totalCost * rentMultiplier;
    
    // Create new building
    final building = Building(
      type: buildingType,
      designId: designId,
      name: buildingName,
      landId: landId,
      constructionCost: totalCost,
      baseRent: baseRent,
      constructionDurationHours: constructionTime,
    );
    
    // Associate building with land
    land.assignBuilding(building.id);
    
    // Add building to list
    _buildings.add(building);
    
    // Update land in list
    _landParcels[landIndex] = land;
    
    // Save to database
    await _databaseService.saveBuilding(building.toJson());
    await _databaseService.saveLandParcel(land.toJson());
    
    notifyListeners();
    return true;
  }
  
  // Update construction progress for all buildings
  Future<void> updateConstructionProgress() async {
    final now = DateTime.now();
    bool changes = false;
    
    for (int i = 0; i < _buildings.length; i++) {
      if (_buildings[i].status == BuildingStatus.underConstruction) {
        _buildings[i].updateConstructionProgress(now);
        await _databaseService.saveBuilding(_buildings[i].toJson());
        changes = true;
      }
    }
    
    if (changes) {
      notifyListeners();
    }
  }
  
  // Occupy a completed building
  Future<bool> occupyBuilding(String buildingId) async {
    final buildingIndex = _buildings.indexWhere((b) => b.id == buildingId);
    if (buildingIndex == -1) return false;
    
    final building = _buildings[buildingIndex];
    if (building.status != BuildingStatus.complete) return false;
    
    building.occupy(DateTime.now());
    _buildings[buildingIndex] = building;
    
    await _databaseService.saveBuilding(building.toJson());
    
    notifyListeners();
    return true;
  }
  
  // Collect income from all properties and buildings
  Future<double> collectAllIncome() async {
    final now = DateTime.now();
    double totalIncome = 0;
    bool changes = false;
    
    // Collect from properties
    for (int i = 0; i < _properties.length; i++) {
      if (_properties[i].isOwned && _properties[i].status == PropertyStatus.occupied) {
        final income = _properties[i].collectRent(now);
        totalIncome += income;
        await _databaseService.saveProperty(_properties[i].toJson());
        changes = true;
      }
    }
    
    // Collect from buildings
    for (int i = 0; i < _buildings.length; i++) {
      if (_buildings[i].status == BuildingStatus.occupied) {
        final income = _buildings[i].collectRent(now);
        totalIncome += income;
        await _databaseService.saveBuilding(_buildings[i].toJson());
        changes = true;
      }
    }
    
    if (changes) {
      notifyListeners();
    }
    
    return totalIncome;
  }
  
  // Calculate pending income from all sources
  double calculatePendingIncome() {
    final now = DateTime.now();
    double totalPending = 0;
    
    // Calculate from properties
    for (final property in _properties) {
      if (property.isOwned && property.status == PropertyStatus.occupied) {
        totalPending += property.calculateIncome(now);
      }
    }
    
    // Calculate from buildings
    for (final building in _buildings) {
      if (building.status == BuildingStatus.occupied) {
        totalPending += building.calculateIncome(now);
      }
    }
    
    return totalPending;
  }
  
  // Upgrade a property
  Future<bool> upgradeProperty(String propertyId, String upgradeType) async {
    final propertyIndex = _properties.indexWhere((p) => p.id == propertyId && p.isOwned);
    if (propertyIndex == -1) return false;
    
    final property = _properties[propertyIndex];
    property.upgrade(upgradeType);
    _properties[propertyIndex] = property;
    
    await _databaseService.saveProperty(property.toJson());
    
    notifyListeners();
    return true;
  }
  
  // Upgrade a building
  Future<bool> upgradeBuilding(String buildingId, String upgradeType) async {
    final buildingIndex = _buildings.indexWhere((b) => b.id == buildingId);
    if (buildingIndex == -1) return false;
    
    final building = _buildings[buildingIndex];
    building.upgrade(upgradeType);
    _buildings[buildingIndex] = building;
    
    await _databaseService.saveBuilding(building.toJson());
    
    notifyListeners();
    return true;
  }
  
  // Calculate total portfolio value
  double calculateTotalPortfolioValue() {
    double totalValue = 0;
    
    // Add property values
    for (final property in _properties) {
      if (property.isOwned) {
        totalValue += property.currentValue;
      }
    }
    
    // Add land values
    for (final land in _landParcels) {
      if (land.isOwned) {
        totalValue += land.currentValue;
      }
    }
    
    // Add building values
    for (final building in _buildings) {
      if (building.status != BuildingStatus.underConstruction) {
        totalValue += building.currentValue;
      }
    }
    
    return totalValue;
  }
  
  // Calculate daily income
  double calculateDailyIncome() {
    double dailyIncome = 0;
    
    // Add property income
    for (final property in _properties.where((p) => p.isOwned && p.status == PropertyStatus.occupied)) {
      dailyIncome += property.currentRent;
    }
    
    // Add building income
    for (final building in _buildings.where((b) => b.status == BuildingStatus.occupied)) {
      dailyIncome += building.currentRent;
    }
    
    return dailyIncome;
  }
  // Add this method to save property state directly
Future<void> savePropertyState(Property property) async {
  final propertyIndex = _properties.indexWhere((p) => p.id == property.id);
  if (propertyIndex == -1) return;
  
  // Update in the list
  _properties[propertyIndex] = property;
  
  // Save to database
  await _databaseService.saveProperty(property.toJson());
  
  notifyListeners();
}
}
