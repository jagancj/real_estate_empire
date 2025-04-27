import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/land/land_parcel_card.dart';
import '../widgets/land/construction_progress.dart';
import '../models/land_model.dart';
import '../models/building_model.dart';
import 'land_development_setup_screen.dart';
import '../app.dart';

class LandDevelopmentScreen extends StatefulWidget {
  const LandDevelopmentScreen({super.key});

  @override
  State<LandDevelopmentScreen> createState() => _LandDevelopmentScreenState();
}

class _LandDevelopmentScreenState extends State<LandDevelopmentScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final isLandDevelopmentUnlocked = gameProvider.isFeatureUnlocked('landDevelopment');
        
        if (!isLandDevelopmentUnlocked) {
          return _buildFeatureLockedState();
        }
        
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Land Development'),
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Available Land'),
                  Tab(text: 'Construction'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _buildAvailableLandTab(gameProvider),
                _buildConstructionTab(gameProvider),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildAvailableLandTab(GameProvider gameProvider) {
    final ownedLand = gameProvider.propertyProvider.ownedLand
        .where((land) => land.buildingId == null)
        .toList();
    
    if (ownedLand.isEmpty) {
      return _buildEmptyLandState();
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: ownedLand.length,
      itemBuilder: (context, index) {
        final land = ownedLand[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: LandParcelCard(
            land: land,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LandDevelopmentSetupScreen(land: land),
                ),
              );
            },
          ),
        );
      },
    );
  }
  
  Widget _buildConstructionTab(GameProvider gameProvider) {
    final buildings = gameProvider.propertyProvider.buildings
        .where((b) => b.status == BuildingStatus.underConstruction)
        .toList();
    
    if (buildings.isEmpty) {
      return _buildEmptyConstructionState();
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: buildings.length,
      itemBuilder: (context, index) {
        final building = buildings[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ConstructionProgress(
            building: building,
            onComplete: building.completionPercentage >= 100
                ? () => _completeConstruction(building, gameProvider)
                : null,
          ),
        );
      },
    );
  }
  
  Widget _buildEmptyLandState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.landscape,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            const Text(
              'No Land Available for Development',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Purchase land parcels from the market to start developing custom buildings.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to Market screen with Land tab selected
                navigationKey.currentState?.setCurrentIndex(2);
              },
              icon: const Icon(Icons.add),
              label: const Text('Purchase Land'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyConstructionState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            const Text(
              'No Active Construction Projects',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Start developing your land to see construction progress here.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            DefaultTabController.of(context) != null
                ? ElevatedButton.icon(
                    onPressed: () {
                      DefaultTabController.of(context)!.animateTo(0);
                    },
                    icon: const Icon(Icons.terrain),
                    label: const Text('View Available Land'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFeatureLockedState() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Land Development'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock,
                  size: 50,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Land Development Locked',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Reach player level 3 to unlock the ability to develop custom buildings on land parcels.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Navigate to profile to show progress
                  navigationKey.currentState?.setCurrentIndex(4);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('View Your Progress'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _completeConstruction(Building building, GameProvider gameProvider) async {
    final success = await gameProvider.completeBuilding(building.id);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tenants have moved into ${building.name}!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to find tenants for the building.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}