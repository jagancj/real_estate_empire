// screens/property_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_estate_empire/models/building_model.dart';
import '../app.dart';
import '../providers/game_provider.dart';
import '../widgets/property/property_card.dart';
import '../models/property_model.dart';
import '../widgets/common/custom_button.dart';
import 'property_detail_screen.dart';

class PropertyListScreen extends StatefulWidget {
  const PropertyListScreen({super.key});

  @override
  State<PropertyListScreen> createState() => _PropertyListScreenState();
}

class _PropertyListScreenState extends State<PropertyListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _filterType = 'All';
  
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
        title: const Text('My Properties'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Properties'),
            Tab(text: 'Buildings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPropertiesTab(),
          _buildBuildingsTab(),
        ],
      ),
    );
  }
  
  Widget _buildPropertiesTab() {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final properties = gameProvider.propertyProvider.ownedProperties;
        
        if (properties.isEmpty) {
          return _buildEmptyState(
            'No Properties Yet',
            'Start building your real estate empire by purchasing your first property!',
            Icons.home_work,
            () {
              // Navigate to Market screen
              navigationKey.currentState?.setCurrentIndex(2);
            },
          );
        }
        
        // Filter properties if needed
        final filteredProperties = _filterType == 'All'
            ? properties
            : properties.where((p) => p.type.toString().contains(_filterType)).toList();
        
        return Column(
          children: [
            _buildFilterChips(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredProperties.length,
                itemBuilder: (context, index) {
                  final property = filteredProperties[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: PropertyCard(
                      property: property,
                      showDetails: true,
                      onTap: () {
                        _navigateToPropertyDetail(property);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildBuildingsTab() {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final buildings = gameProvider.propertyProvider.buildings
            .where((b) => b.status != BuildingStatus.underConstruction).toList();
        
        if (buildings.isEmpty) {
          return _buildEmptyState(
            'No Buildings Yet',
            'Develop land to construct custom buildings for your portfolio!',
            Icons.business,
            () {
              // Navigate to Land Development screen
              navigationKey.currentState?.setCurrentIndex(3);
            },
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: buildings.length,
          itemBuilder: (context, index) {
            final building = buildings[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: InkWell(
                onTap: () {
                  // Navigate to building detail (to be implemented)
                  // _navigateToBuildingDetail(building);
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getBuildingIcon(building.type),
                              color: Colors.blue[800],
                              size: 36,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  building.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _getBuildingTypeString(building.type),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Daily Rent: \$${building.currentRent.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildStatusBadge(building.status),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
  
  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip('All'),
          _buildFilterChip('House'),
          _buildFilterChip('Apartment'),
          _buildFilterChip('Office'),
          _buildFilterChip('Retail'),
        ],
      ),
    );
  }
  
  Widget _buildFilterChip(String label) {
    final isSelected = _filterType == label;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        onSelected: (selected) {
          setState(() {
            _filterType = selected ? label : 'All';
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
    VoidCallback onAction,
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
            const SizedBox(height: 32),
            CustomButton(
              label: _tabController.index == 0
                  ? 'Browse Properties for Sale'
                  : 'Develop Land',
              onPressed: onAction,
              icon: _tabController.index == 0
                  ? Icons.real_estate_agent
                  : Icons.construction,
              type: ButtonType.primary,
            ),
          ],
        ),
      ),
    );
  }
  
  void _navigateToPropertyDetail(Property property) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyDetailScreen(property: property),
      ),
    );
  }
  
  Widget _buildStatusBadge(BuildingStatus status) {
    Color badgeColor;
    String statusText;
    
    switch (status) {
      case BuildingStatus.complete:
        badgeColor = Colors.orange;
        statusText = 'Vacant';
        break;
      case BuildingStatus.occupied:
        badgeColor = Colors.green;
        statusText = 'Occupied';
        break;
      case BuildingStatus.underMaintenance:
        badgeColor = Colors.red;
        statusText = 'Maintenance';
        break;
      default:
        badgeColor = Colors.grey;
        statusText = 'Unknown';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: badgeColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
  
  IconData _getBuildingIcon(BuildingType type) {
    switch (type) {
      case BuildingType.smallHouse:
        return Icons.home;
      case BuildingType.apartment:
        return Icons.apartment;
      case BuildingType.office:
        return Icons.business;
      case BuildingType.retail:
        return Icons.storefront;
    }
  }
  
  String _getBuildingTypeString(BuildingType type) {
    switch (type) {
      case BuildingType.smallHouse:
        return 'House';
      case BuildingType.apartment:
        return 'Apartment Building';
      case BuildingType.office:
        return 'Office Building';
      case BuildingType.retail:
        return 'Retail Space';
    }
  }
}