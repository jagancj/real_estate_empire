import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/property/property_card.dart';
import '../widgets/land/land_parcel_card.dart';
import '../widgets/common/currency_display.dart';
import '../models/property_model.dart';
import '../models/land_model.dart';
import 'property_detail_preview_screen.dart';
import 'land_detail_preview_screen.dart';
import '../app.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _propertyFilterType = 'All';
  String _landFilterType = 'All';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real Estate Market'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Properties'),
            Tab(text: 'Land'),
          ],
        ),
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          final playerStats = gameProvider.getPlayerStats();
          final cashAvailable = playerStats['cash'] as double;
          
          return Column(
            children: [
              _buildPlayerBalance(cashAvailable),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPropertiesTab(gameProvider, cashAvailable),
                    _buildLandTab(gameProvider, cashAvailable),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildPlayerBalance(double balance) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.grey[100],
      child: Row(
        children: [
          const Icon(
            Icons.account_balance_wallet,
            color: Color(0xFF4361EE),
          ),
          const SizedBox(width: 12),
          const Text(
            'Your Balance:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          CurrencyDisplay(
            amount: balance,
            fontSize: 18,
            color: Colors.black,
          ),
        ],
      ),
    );
  }
  
  Widget _buildPropertiesTab(GameProvider gameProvider, double cashAvailable) {
    final properties = gameProvider.propertyProvider.marketProperties;
    
    if (properties.isEmpty) {
      return _buildEmptyState(
        'No Properties Available',
        'Check back later for new property listings.',
        Icons.home_work,
      );
    }
    
    // Filter properties if needed
    final filteredProperties = _propertyFilterType == 'All'
        ? properties
        : properties.where((p) => _getPropertyTypeString(p.type) == _propertyFilterType).toList();
    
    return Column(
      children: [
        _buildPropertyFilterChips(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredProperties.length,
            itemBuilder: (context, index) {
              final property = filteredProperties[index];
              final canAfford = cashAvailable >= property.purchasePrice;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: PropertyCard(
                  property: property,
                  isMarketListing: true,
                  onTap: () {
                    _showPropertyPreview(property, gameProvider, canAfford);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildLandTab(GameProvider gameProvider, double cashAvailable) {
    final landParcels = gameProvider.propertyProvider.marketLandParcels;
    final isLandDevelopmentUnlocked = gameProvider.isFeatureUnlocked('landDevelopment');
    
    if (!isLandDevelopmentUnlocked) {
      return _buildFeatureLockedState(
        'Land Development Locked',
        'Reach player level 3 to unlock land development.',
        Icons.lock,
      );
    }
    
    if (landParcels.isEmpty) {
      return _buildEmptyState(
        'No Land Available',
        'Check back later for new land listings.',
        Icons.landscape,
      );
    }
    
    // Filter land if needed
    final filteredLand = _landFilterType == 'All'
        ? landParcels
        : landParcels.where((l) => _getZoneTypeString(l.zoneType) == _landFilterType).toList();
    
    return Column(
      children: [
        _buildLandFilterChips(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredLand.length,
            itemBuilder: (context, index) {
              final land = filteredLand[index];
              final canAfford = cashAvailable >= land.purchasePrice;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: LandParcelCard(
                  land: land,
                  isMarketListing: true,
                  onTap: () {
                    _showLandPreview(land, gameProvider, canAfford);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildPropertyFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildPropertyFilterChip('All'),
          _buildPropertyFilterChip('Studio Apartment'),
          _buildPropertyFilterChip('Small House'),
          _buildPropertyFilterChip('Duplex'),
          _buildPropertyFilterChip('Office Space'),
          _buildPropertyFilterChip('Retail Store'),
        ],
      ),
    );
  }
  
  Widget _buildPropertyFilterChip(String label) {
    final isSelected = _propertyFilterType == label;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        onSelected: (selected) {
          setState(() {
            _propertyFilterType = selected ? label : 'All';
          });
        },
        selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
        checkmarkColor: Theme.of(context).primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? Theme.of(context).primaryColor : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
  
  Widget _buildLandFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildLandFilterChip('All'),
          _buildLandFilterChip('Residential'),
          _buildLandFilterChip('Commercial'),
          _buildLandFilterChip('Mixed-Use'),
        ],
      ),
    );
  }
  
  Widget _buildLandFilterChip(String label) {
    final isSelected = _landFilterType == label;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        onSelected: (selected) {
          setState(() {
            _landFilterType = selected ? label : 'All';
          });
        },
        selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
        checkmarkColor: Theme.of(context).primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? Theme.of(context).primaryColor : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
  
  Widget _buildEmptyState(
    String title,
    String message,
    IconData icon,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFeatureLockedState(
    String title,
    String message,
    IconData icon,
  ) {
    return Center(
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
                icon,
                size: 50,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              message,
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
    );
  }
  
  void _showPropertyPreview(
    Property property,
    GameProvider gameProvider,
    bool canAfford,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyDetailPreviewScreen(
          property: property,
          onPurchase: canAfford
              ? () async {
                  final success = await gameProvider.purchaseProperty(property.id);
                  if (success) {
                    Navigator.pop(context); // Close preview
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Successfully purchased ${property.name}!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to purchase property.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              : null,
        ),
      ),
    );
  }
  
  void _showLandPreview(
    Land land,
    GameProvider gameProvider,
    bool canAfford,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LandDetailPreviewScreen(
          land: land,
          onPurchase: canAfford
              ? () async {
                  final success = await gameProvider.purchaseLand(land.id);
                  if (success) {
                    Navigator.pop(context); // Close preview
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Successfully purchased land in ${land.location}!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to purchase land.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              : null,
        ),
      ),
    );
  }
  
  String _getPropertyTypeString(PropertyType type) {
    switch (type) {
      case PropertyType.studioApartment:
        return 'Studio Apartment';
      case PropertyType.smallHouse:
        return 'Small House';
      case PropertyType.duplex:
        return 'Duplex';
      case PropertyType.smallOffice:
        return 'Office Space';
      case PropertyType.retailStore:
        return 'Retail Store';
    }
  }
  
  String _getZoneTypeString(ZoneType type) {
    switch (type) {
      case ZoneType.residential:
        return 'Residential';
      case ZoneType.commercial:
        return 'Commercial';
      case ZoneType.mixedUse:
        return 'Mixed-Use';
    }
  }
}