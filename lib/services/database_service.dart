import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static const String databaseName = 'real_estate_empire.db';
  static const int databaseVersion = 2; // Incremented version for schema change
  
  // Table names
  static const String tablePlayer = 'player';
  static const String tableProperties = 'properties';
  static const String tableLandParcels = 'land_parcels';
  static const String tableBuildings = 'buildings';
  static const String tableGameState = 'game_state';
  static const String tableLoans = 'loans'; // New table for loans
  
  Database? _database;
  
  // Initialize database
  Future<void> initialize() async {
    _database = await _openDatabase();
  }
  
  // Open database
  Future<Database> _openDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);
    
    return await openDatabase(
      path,
      version: databaseVersion,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }
  
  // Create database tables
  Future<void> _createDatabase(Database db, int version) async {
    // Player table
    await db.execute('''
      CREATE TABLE $tablePlayer (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        cash REAL NOT NULL,
        level INTEGER NOT NULL,
        experience INTEGER NOT NULL,
        experienceToNextLevel INTEGER NOT NULL,
        lastPlayed TEXT NOT NULL,
        accountCreated TEXT NOT NULL,
        tutorialCompleted INTEGER NOT NULL
      )
    ''');
    
    // Properties table
    await db.execute('''
      CREATE TABLE $tableProperties (
        id TEXT PRIMARY KEY,
        type INTEGER NOT NULL,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        imageAsset TEXT NOT NULL,
        purchasePrice REAL NOT NULL,
        currentValue REAL NOT NULL,
        baseRent REAL NOT NULL,
        currentRent REAL NOT NULL,
        upgradeLevel INTEGER NOT NULL,
        upgrades TEXT NOT NULL,
        status INTEGER NOT NULL,
        lastCollected TEXT NOT NULL,
        acquiredDate TEXT NOT NULL,
        isOwned INTEGER NOT NULL
      )
    ''');
    
    // Land parcels table
    await db.execute('''
      CREATE TABLE $tableLandParcels (
        id TEXT PRIMARY KEY,
        size INTEGER NOT NULL,
        zoneType INTEGER NOT NULL,
        location TEXT NOT NULL,
        imageAsset TEXT NOT NULL,
        purchasePrice REAL NOT NULL,
        currentValue REAL NOT NULL,
        buildingId TEXT,
        isOwned INTEGER NOT NULL,
        acquiredDate TEXT
      )
    ''');
    
    // Buildings table
    await db.execute('''
      CREATE TABLE $tableBuildings (
        id TEXT PRIMARY KEY,
        type INTEGER NOT NULL,
        designId TEXT NOT NULL,
        name TEXT NOT NULL,
        landId TEXT NOT NULL,
        constructionCost REAL NOT NULL,
        currentValue REAL NOT NULL,
        baseRent REAL NOT NULL,
        currentRent REAL NOT NULL,
        status INTEGER NOT NULL,
        constructionStarted TEXT NOT NULL,
        constructionCompleted TEXT,
        lastCollected TEXT,
        constructionDurationHours INTEGER NOT NULL,
        completionPercentage INTEGER NOT NULL,
        upgradeLevel INTEGER NOT NULL,
        upgrades TEXT NOT NULL,
        FOREIGN KEY (landId) REFERENCES $tableLandParcels (id)
      )
    ''');
    
    // Game state table
    await db.execute('''
      CREATE TABLE $tableGameState (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        isFirstLaunch INTEGER NOT NULL,
        unlockedFeatures TEXT NOT NULL,
        lastUpdateTime TEXT NOT NULL
      )
    ''');
    
    // Loans table
    await db.execute('''
      CREATE TABLE $tableLoans (
        id TEXT PRIMARY KEY,
        bankName TEXT NOT NULL,
        originalAmount REAL NOT NULL,
        remainingAmount REAL NOT NULL,
        interestRate REAL NOT NULL,
        totalMonths INTEGER NOT NULL,
        remainingMonths INTEGER NOT NULL,
        monthlyPayment REAL NOT NULL,
        startDate TEXT NOT NULL,
        dueDate TEXT NOT NULL
      )
    ''');
  }
  
  // Upgrade database
  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add loans table if upgrading from version 1
      await db.execute('''
        CREATE TABLE $tableLoans (
          id TEXT PRIMARY KEY,
          bankName TEXT NOT NULL,
          originalAmount REAL NOT NULL,
          remainingAmount REAL NOT NULL,
          interestRate REAL NOT NULL,
          totalMonths INTEGER NOT NULL,
          remainingMonths INTEGER NOT NULL,
          monthlyPayment REAL NOT NULL,
          startDate TEXT NOT NULL,
          dueDate TEXT NOT NULL
        )
      ''');
    }
  }
  
  // PLAYER OPERATIONS
  
  // Get player data
  Future<Map<String, dynamic>?> getPlayer() async {
    final db = _database;
    if (db == null) return null;
    
    final results = await db.query(tablePlayer);
    if (results.isEmpty) return null;
    
    return results.first;
  }
  
  // Save player data
  Future<void> savePlayer(Map<String, dynamic> playerData) async {
    final db = _database;
    if (db == null) return;
    
    await db.insert(
      tablePlayer,
      playerData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  // PROPERTY OPERATIONS
  
  // Get all properties
  Future<List<Map<String, dynamic>>> getProperties() async {
    final db = _database;
    if (db == null) return [];
    
    return await db.query(tableProperties);
  }
  
  // Save property
  Future<void> saveProperty(Map<String, dynamic> propertyData) async {
    final db = _database;
    if (db == null) return;
    
    await db.insert(
      tableProperties,
      propertyData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  // Delete property
  Future<void> deleteProperty(String id) async {
    final db = _database;
    if (db == null) return;
    
    await db.delete(
      tableProperties,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // LAND OPERATIONS
  
  // Get all land parcels
  Future<List<Map<String, dynamic>>> getLandParcels() async {
    final db = _database;
    if (db == null) return [];
    
    return await db.query(tableLandParcels);
  }
  
  // Save land parcel
  Future<void> saveLandParcel(Map<String, dynamic> landData) async {
    final db = _database;
    if (db == null) return;
    
    await db.insert(
      tableLandParcels,
      landData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  // Delete land parcel
  Future<void> deleteLandParcel(String id) async {
    final db = _database;
    if (db == null) return;
    
    await db.delete(
      tableLandParcels,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // BUILDING OPERATIONS
  
  // Get all buildings
  Future<List<Map<String, dynamic>>> getBuildings() async {
    final db = _database;
    if (db == null) return [];
    
    return await db.query(tableBuildings);
  }
  
  // Save building
  Future<void> saveBuilding(Map<String, dynamic> buildingData) async {
    final db = _database;
    if (db == null) return;
    
    await db.insert(
      tableBuildings,
      buildingData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  // Delete building
  Future<void> deleteBuilding(String id) async {
    final db = _database;
    if (db == null) return;
    
    await db.delete(
      tableBuildings,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // GAME STATE OPERATIONS
  
  // Get game state
  Future<Map<String, dynamic>?> getGameState() async {
    final db = _database;
    if (db == null) return null;
    
    final results = await db.query(tableGameState);
    if (results.isEmpty) return null;
    
    return results.first;
  }
  
  // Save game state
  Future<void> saveGameState(Map<String, dynamic> gameStateData) async {
    final db = _database;
    if (db == null) return;
    
    // Check if a game state already exists
    final existingState = await getGameState();
    
    if (existingState == null) {
      // Insert new game state
      await db.insert(tableGameState, gameStateData);
    } else {
      // Update existing game state
      await db.update(
        tableGameState,
        gameStateData,
        where: 'id = ?',
        whereArgs: [existingState['id']],
      );
    }
  }
  
  // LOAN OPERATIONS
  
  // Get all loans
  Future<List<Map<String, dynamic>>> getLoans() async {
    final db = _database;
    if (db == null) return [];
    
    return await db.query(tableLoans);
  }
  
  // Save loan
  Future<void> saveLoan(Map<String, dynamic> loanData) async {
    final db = _database;
    if (db == null) return;
    
    await db.insert(
      tableLoans,
      loanData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  // Delete loan
  Future<void> deleteLoan(String id) async {
    final db = _database;
    if (db == null) return;
    
    await db.delete(
      tableLoans,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // Clear all data (for testing/reset)
  Future<void> clearAllData() async {
    final db = _database;
    if (db == null) return;
    
    await db.delete(tablePlayer);
    await db.delete(tableProperties);
    await db.delete(tableLandParcels);
    await db.delete(tableBuildings);
    await db.delete(tableGameState);
    await db.delete(tableLoans);
  }
}