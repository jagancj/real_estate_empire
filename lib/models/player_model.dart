import 'package:uuid/uuid.dart';

class Player {
  final String id;
  String name;
  double cash;
  int level;
  int experience;
  int experienceToNextLevel;
  DateTime lastPlayed;
  DateTime accountCreated;
  bool tutorialCompleted;

  Player({
    String? id,
    this.name = 'Real Estate Mogul',
    this.cash = 10000.0, // Starting cash
    this.level = 1,
    this.experience = 0,
    this.experienceToNextLevel = 100,
    DateTime? lastPlayed,
    DateTime? accountCreated,
    this.tutorialCompleted = false,
  }) : 
    id = id ?? const Uuid().v4(),
    lastPlayed = lastPlayed ?? DateTime.now(),
    accountCreated = accountCreated ?? DateTime.now();

  // Level up logic
  bool addExperience(int amount) {
    experience += amount;
    if (experience >= experienceToNextLevel) {
      levelUp();
      return true;
    }
    return false;
  }

  void levelUp() {
    level += 1;
    experience = experience - experienceToNextLevel;
    experienceToNextLevel = (experienceToNextLevel * 1.5).round();
  }

  // Cash operations
  bool canAfford(double amount) => cash >= amount;
  
  bool spend(double amount) {
    if (canAfford(amount)) {
      cash -= amount;
      return true;
    }
    return false;
  }
  
  void earn(double amount) {
    cash += amount;
  }

  // Convert to and from JSON for database storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cash': cash,
      'level': level,
      'experience': experience,
      'experienceToNextLevel': experienceToNextLevel,
      'lastPlayed': lastPlayed.toIso8601String(),
      'accountCreated': accountCreated.toIso8601String(),
      'tutorialCompleted': tutorialCompleted ? 1 : 0,
    };
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      name: json['name'],
      cash: json['cash'],
      level: json['level'],
      experience: json['experience'],
      experienceToNextLevel: json['experienceToNextLevel'],
      lastPlayed: DateTime.parse(json['lastPlayed']),
      accountCreated: DateTime.parse(json['accountCreated']),
      tutorialCompleted: json['tutorialCompleted'] == 1,
    );
  }
}
