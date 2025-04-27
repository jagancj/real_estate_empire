import 'package:flutter/foundation.dart';
import 'package:real_estate_empire/models/building_model.dart';
import 'package:real_estate_empire/models/land_model.dart';
import 'package:real_estate_empire/models/property_model.dart';
import '../services/database_service.dart';
import '../models/game_constants.dart';
import 'player_provider.dart';
import 'property_provider.dart';

class GameProvider with ChangeNotifier {
  final DatabaseService _databaseService;
  PlayerProvider playerProvider;
  PropertyProvider propertyProvider;
  
  bool _isFirstLaunch = false;
  Map<String, bool> _unlockedFeatures = {};
  DateTime _lastUpdateTime = DateTime.now();
  
  GameProvider({
    required this.playerProvider,
    required this.propertyProvider,
    required DatabaseService databaseService,
  }) : _databaseService = databaseService {
    _initialize();
  }
  
  // Update references to providers
  void update(PlayerProvider playerProvider, PropertyProvider propertyProvider) {
    this.playerProvider = playerProvider;
    this.propertyProvider = propertyProvider;
  }
  
  // Getters
  bool get isFirstLaunch => _isFirstLaunch;
  Map<String, bool> get unlockedFeatures => _unlockedFeatures;
  
  // Initialize game state
  Future<void> _initialize() async {
    await _loadGameState();
    await _processOfflineProgress();
    _updateFeatureUnlocks();
    notifyListeners();
  }
  
  // Load game state from database
  Future<void> _loadGameState() async {
    try {
      final gameState = await _databaseService.getGameState();
      
      if (gameState == null || gameState.isEmpty) {
        // First time playing
        _isFirstLaunch = true;
        _unlockedFeatures = {};
        
        // Unlock initial features
        _unlockedFeatures['smallHouse'] = true;
        _unlockedFeatures['studioApartment'] = true;
      } else {
        _isFirstLaunch = gameState['isFirstLaunch'] == 1;
        
        // Load unlocked features
        final unlockedFeaturesStr = gameState['unlockedFeatures'] as String;
        _unlockedFeatures = {};
        
        if (unlockedFeaturesStr.isNotEmpty) {
          final features = unlockedFeaturesStr.split(',');
          for (final feature in features) {
            _unlockedFeatures[feature] = true;
          }
        }
        
        _lastUpdateTime = DateTime.parse(gameState['lastUpdateTime']);
      }
    } catch (e) {
      debugPrint('Error loading game state: $e');
      // Default values on error
      _isFirstLaunch = true;
      _unlockedFeatures = {
        'smallHouse': true,
        'studioApartment': true,
      };
    }
  }
  
  // Process progress that occurred while app was closed
  Future<void> _processOfflineProgress() async {
    if (!playerProvider.isPlayerInitialized) return;
    
    final now = DateTime.now();
    final timeDiff = now.difference(_lastUpdateTime);
    
    if (timeDiff.inMinutes < 1) return; // Skip if less than a minute passed
    
    // Update construction progress
    await propertyProvider.updateConstructionProgress();
    
    // Calculate offline income
    final offlineIncome = propertyProvider.calculatePendingIncome();
    if (offlineIncome > 0) {
      await playerProvider.addMoney(offlineIncome);
    }
    
    // Update last update time
    _lastUpdateTime = now;
    await _saveGameState();
  }
  
  // Update feature unlocks based on player level
  void _updateFeatureUnlocks() {
    if (!playerProvider.isPlayerInitialized) return;
    
    final playerLevel = playerProvider.player.level;
    
    // Check each feature unlock
    for (final entry in GameConstants.featureUnlockLevels.entries) {
      final feature = entry.key;
      final requiredLevel = entry.value;
      
      if (playerLevel >= requiredLevel && !_unlockedFeatures.containsKey(feature)) {
        _unlockedFeatures[feature] = true;
      }
    }
  }
  
  // Mark first launch as completed
  Future<void> completeFirstLaunch() async {
    _isFirstLaunch = false;
    await _saveGameState();
    notifyListeners();
  }
  
  // Save game state to database
  Future<void> _saveGameState() async {
    // Create features string
    final featuresStr = _unlockedFeatures.keys.join(',');
    
    final gameState = {
      'isFirstLaunch': _isFirstLaunch ? 1 : 0,
      'unlockedFeatures': featuresStr,
      'lastUpdateTime': _lastUpdateTime.toIso8601String(),
    };
    
    await _databaseService.saveGameState(gameState);
  }
  
  // Game update loop - call this regularly to update game state
  Future<void> gameLoop() async {
    final now = DateTime.now();
    
    // Update player's last played time
    await playerProvider.updateLastPlayed();
    
    // Update construction progress
    await propertyProvider.updateConstructionProgress();
    
    // Update last update time and save
    _lastUpdateTime = now;
    await _saveGameState();
    
    notifyListeners();
  }
  
  // Handle property purchase
  Future<bool> purchaseProperty(String propertyId) async {
    final property = propertyProvider.marketProperties
        .firstWhere((p) => p.id == propertyId, orElse: () => null as Property);
    
    if (property == null) return false;
    
    // Check if player can afford
    if (!playerProvider.canAfford(property.purchasePrice)) return false;
    
    // Process purchase
    final success = await propertyProvider.purchaseProperty(propertyId);
    if (success) {
      // Deduct cost from player
      await playerProvider.spendMoney(property.purchasePrice);
      
      // Award experience
      await playerProvider.addExperience(GameConstants.experienceForPropertyPurchase);
      
      // Update feature unlocks based on new level
      _updateFeatureUnlocks();
      notifyListeners();
    }
    
    return success;
  }
  
  // Handle land purchase
  Future<bool> purchaseLand(String landId) async {
    final land = propertyProvider.marketLandParcels
        .firstWhere((l) => l.id == landId, orElse: () => null as Land);
    
    if (land == null) return false;
    
    // Check if player can afford
    if (!playerProvider.canAfford(land.purchasePrice)) return false;
    
    // Check if land development feature is unlocked
    if (!_unlockedFeatures.containsKey('landDevelopment')) return false;
    
    // Process purchase
    final success = await propertyProvider.purchaseLand(landId);
    if (success) {
      // Deduct cost from player
      await playerProvider.spendMoney(land.purchasePrice);
      
      // Award experience
      await playerProvider.addExperience(GameConstants.experienceForLandPurchase);
      
      // Update feature unlocks based on new level
      _updateFeatureUnlocks();
      notifyListeners();
    }
    
    return success;
  }
  
  // Handle starting construction
  Future<bool> startConstruction(
    String landId, 
    BuildingType buildingType, 
    String designId, 
    String buildingName
  ) async {
    // Check if relevant building type is unlocked
    String featureKey;
    switch (buildingType) {
      case BuildingType.smallHouse:
        featureKey = 'smallHouse';
        break;
      case BuildingType.apartment:
        featureKey = 'apartment';
        break;
      case BuildingType.office:
        featureKey = 'officeBuilding';
        break;
      case BuildingType.retail:
        featureKey = 'retailStore';
        break;
    }
    
    if (!_unlockedFeatures.containsKey(featureKey)) return false;
    
    // Check if custom designs are unlocked if not using default design
    if (designId != 'default' && !_unlockedFeatures.containsKey('customDesigns')) {
      return false;
    }
    
    // Find the land
    final land = propertyProvider.ownedLand
        .firstWhere((l) => l.id == landId, orElse: () => null as Land);
    
    if (land == null || land.buildingId != null) return false; // Land not owned or already has building
    
    // Find the design data to calculate cost
    final designData = GameConstants.buildingDesigns.firstWhere(
      (d) => d['id'] == designId && d['buildingType'] == buildingType,
      orElse: () => {},
    );
    
    if (designData.isEmpty) return false;
    
    // Calculate cost
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
    
    // Total construction cost
    final totalCost = land.squareFeet * costPerSqFt;
    
    // Check if player can afford
    if (!playerProvider.canAfford(totalCost)) return false;
    
    // Start construction
    final success = await propertyProvider.startConstruction(
      landId, buildingType, designId, buildingName
    );
    
    if (success) {
      // Deduct cost from player
      await playerProvider.spendMoney(totalCost);
      
      notifyListeners();
    }
    
    return success;
  }
  
  // Handle building completion
  Future<bool> completeBuilding(String buildingId) async {
    final building = propertyProvider.buildings
        .firstWhere((b) => b.id == buildingId, orElse: () => null as Building);
    
    if (building == null || building.status != BuildingStatus.complete) return false;
    
    // Occupy the building (find tenants)
    final success = await propertyProvider.occupyBuilding(buildingId);
    
    if (success) {
      // Award experience for completing a building
      await playerProvider.addExperience(GameConstants.experienceForBuildingCompletion);
      
      // Update feature unlocks
      _updateFeatureUnlocks();
      notifyListeners();
    }
    
    return success;
  }
  
  // Collect all pending income
  Future<double> collectAllIncome() async {
    final income = await propertyProvider.collectAllIncome();
    
    if (income > 0) {
      await playerProvider.addMoney(income);
    }
    
    return income;
  }
  
  // Handle property upgrade
  Future<bool> upgradeProperty(String propertyId, String upgradeType) async {
    final property = propertyProvider.ownedProperties
        .firstWhere((p) => p.id == propertyId, orElse: () => null as Property);
    
    if (property == null) return false;
    
    // Find upgrade data to get cost
    final propertyType = property.type.toString().split('.').last;
    final upgradeList = GameConstants.propertyUpgrades[propertyType] ?? [];
    
    final upgradeData = upgradeList.firstWhere(
      (upgrade) => upgrade['name'] == upgradeType,
      orElse: () => {},
    );
    
    if (upgradeData.isEmpty) return false;
    
    // Calculate upgrade cost
    final costMultiplier = upgradeData['costMultiplier'] as double;
    final upgradeCost = property.currentValue * costMultiplier;
    
    // Check if player can afford
    if (!playerProvider.canAfford(upgradeCost)) return false;
    
    // Process upgrade
    final success = await propertyProvider.upgradeProperty(propertyId, upgradeType);
    
    if (success) {
      // Deduct cost
      await playerProvider.spendMoney(upgradeCost);
      
      // Award experience
      await playerProvider.addExperience(GameConstants.experienceForUpgrade);
      
      // Update feature unlocks
      _updateFeatureUnlocks();
      notifyListeners();
    }
    
    return success;
  }
  
  // Get player stats for dashboard
  Map<String, dynamic> getPlayerStats() {
    if (!playerProvider.isPlayerInitialized) {
      return {
        'level': 1,
        'experience': 0,
        'nextLevelExp': 100,
        'cash': 10000.0,
        'netWorth': 10000.0,
        'properties': 0,
        'buildings': 0,
        'dailyIncome': 0.0,
        'pendingIncome': 0.0,
      };
    }
    
    final player = playerProvider.player;
    final propertiesCount = propertyProvider.ownedProperties.length;
    final buildingsCount = propertyProvider.buildings
        .where((b) => b.status != BuildingStatus.underConstruction).length;
    final netWorth = propertyProvider.calculateTotalPortfolioValue() + player.cash;
    final dailyIncome = propertyProvider.calculateDailyIncome();
    final pendingIncome = propertyProvider.calculatePendingIncome();
    
    return {
      'level': player.level,
      'experience': player.experience,
      'nextLevelExp': player.experienceToNextLevel,
      'cash': player.cash,
      'netWorth': netWorth,
      'properties': propertiesCount,
      'buildings': buildingsCount,
      'dailyIncome': dailyIncome,
      'pendingIncome': pendingIncome,
    };
  }
  
  // Check if a feature is unlocked
  bool isFeatureUnlocked(String feature) {
    return _unlockedFeatures.containsKey(feature) && _unlockedFeatures[feature] == true;
  }
  
  // Get newly unlocked features since last check
  List<String> getNewUnlocks() {
    // Implementation would track which features were newly unlocked
    // For MVP, just return empty list
    return [];
  }
}