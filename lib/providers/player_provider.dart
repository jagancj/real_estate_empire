import 'package:flutter/foundation.dart';
import '../models/player_model.dart';
import '../services/database_service.dart';

class PlayerProvider with ChangeNotifier {
  Player? _player;
  final DatabaseService _databaseService;
  
  PlayerProvider(this._databaseService) {
    _initializePlayer();
  }
  
  Player get player => _player!;
  
  bool get isPlayerInitialized => _player != null;
  
  Future<void> _initializePlayer() async {
    try {
      final playerData = await _databaseService.getPlayer();
      if (playerData != null) {
        _player = Player.fromJson(playerData);
      } else {
        // Create a new player if none exists
        _player = Player();
        await _savePlayer();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing player: $e');
      // Create a default player in case of error
      _player = Player();
      notifyListeners();
    }
  }
  
  Future<void> _savePlayer() async {
    if (_player == null) return;
    
    try {
      await _databaseService.savePlayer(_player!.toJson());
    } catch (e) {
      debugPrint('Error saving player: $e');
    }
  }
  
  // Update player data
  Future<void> updatePlayerData({
    String? name,
    double? cash,
    int? experience,
    bool? tutorialCompleted,
  }) async {
    if (_player == null) return;
    
    if (name != null) _player!.name = name;
    if (cash != null) _player!.cash = cash;
    if (experience != null) {
      _player!.addExperience(experience);
    }
    if (tutorialCompleted != null) {
      _player!.tutorialCompleted = tutorialCompleted;
    }
    
    _player!.lastPlayed = DateTime.now();
    await _savePlayer();
    notifyListeners();
  }
  
  // Add experience and possibly level up
  Future<bool> addExperience(int amount) async {
    if (_player == null) return false;
    
    final leveledUp = _player!.addExperience(amount);
    await _savePlayer();
    notifyListeners();
    return leveledUp;
  }
  
  // Spend money if player has enough
  Future<bool> spendMoney(double amount) async {
    if (_player == null) return false;
    
    final success = _player!.spend(amount);
    if (success) {
      await _savePlayer();
      notifyListeners();
    }
    return success;
  }
  
  // Add money to player
  Future<void> addMoney(double amount) async {
    if (_player == null) return;
    
    _player!.earn(amount);
    await _savePlayer();
    notifyListeners();
  }
  
  // Check if player can afford a purchase
  bool canAfford(double amount) {
    if (_player == null) return false;
    return _player!.canAfford(amount);
  }
  
  // Update last played time
  Future<void> updateLastPlayed() async {
    if (_player == null) return;
    
    _player!.lastPlayed = DateTime.now();
    await _savePlayer();
    // Don't notify here as this is a background update
  }
}