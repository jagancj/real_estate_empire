// screens/property_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/property_model.dart';
import '../providers/game_provider.dart';
import '../widgets/property/upgrade_grid.dart';
import '../widgets/common/currency_display.dart';
import '../widgets/common/custom_button.dart';

class PropertyDetailScreen extends StatefulWidget {
  final Property property;
  
  const PropertyDetailScreen({
    super.key,
    required this.property,
  });

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  bool _showingUpgrades = false;
  
  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final property = widget.property;
        final stats = gameProvider.getPlayerStats();
        final canAffordUpgrade = stats['cash'] >= (property.currentValue * 0.05);
        
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              _buildAppBar(property),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPropertyHeader(property),
                      const SizedBox(height: 24),
                      _buildPropertyStats(property, gameProvider),
                      const SizedBox(height: 24),
                      _buildPropertyActions(property, gameProvider),
                      const SizedBox(height: 24),
                      _buildSectionHeader(
                        'Property Information',
                        Icons.info_outline,
                      ),
                      const SizedBox(height: 16),
                      _buildPropertyDescription(property),
                      const SizedBox(height: 24),
                      _buildSectionHeader(
                        'Available Upgrades',
                        Icons.upgrade,
                        onTap: () {
                          setState(() {
                            _showingUpgrades = !_showingUpgrades;
                          });
                        },
                        trailing: Icon(
                          _showingUpgrades
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                        ),
                      ),
                      if (_showingUpgrades) ...[
                        const SizedBox(height: 16),
                        UpgradeGrid(
                          property: property,
                          canAfford: canAffordUpgrade,
                          onUpgrade: (upgradeType) {
                            _handleUpgrade(property, upgradeType, gameProvider);
                          },
                        ),
                      ],
                      const SizedBox(height: 80), // Bottom padding
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildAppBar(Property property) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          property.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 3,
                color: Color.fromRGBO(0, 0, 0, 0.5),
              ),
            ],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              property.imageAsset,
              fit: BoxFit.cover,
            ),
            // Gradient for better text visibility
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black54,
                  ],
                  stops: [0.7, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPropertyHeader(Property property) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getPropertyTypeString(property.type),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Current Value',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              CurrencyDisplay(
                amount: property.currentValue,
                fontSize: 24,
              ),
            ],
          ),
        ),
        _buildStatusBadge(property.status),
      ],
    );
  }
  
  Widget _buildPropertyStats(Property property, GameProvider gameProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Property Stats', Icons.bar_chart),
        const SizedBox(height: 16),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildStatRow(
                  'Daily Rent',
                  CurrencyDisplay(
                    amount: property.currentRent,
                    fontSize: 16,
                    color: Colors.green[700],
                  ),
                  'Purchase Price',
                  CurrencyDisplay(
                    amount: property.purchasePrice,
                    fontSize: 16,
                  ),
                ),
                const Divider(height: 24),
                _buildStatRow(
                  'Upgrade Level',
                  Text(
                    '${property.upgradeLevel}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  'Owned Since',
                  Text(
                    _formatDate(property.acquiredDate),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(height: 24),
                _buildStatRow(
                  'ROI',
                  Text(
                    '${_calculateROI(property)}%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  'Appreciation',
                  Text(
                    '${_calculateAppreciation(property)}%',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
 Widget _buildPropertyActions(Property property, GameProvider gameProvider) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildSectionHeader('Property Actions', Icons.touch_app),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: CustomButton(
              label: 'Collect Rent',
              icon: Icons.payments,
              type: ButtonType.success,
              onPressed: () {
                _collectRent(property, gameProvider);
              },
              isFullWidth: true,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CustomButton(
              label: property.status == PropertyStatus.occupied 
                  ? 'Find New Tenant' 
                  : 'Find Tenant',
              icon: Icons.person_search,
              type: property.status == PropertyStatus.vacant
                  ? ButtonType.primary
                  : ButtonType.secondary,
              onPressed: property.status == PropertyStatus.vacant
                  ? () {
                      _findTenant(property, gameProvider);
                    }
                  : null,
              isFullWidth: true,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      CustomButton(
        label: 'Schedule Maintenance',
        icon: Icons.build,
        type: ButtonType.secondary,
        onPressed: property.status == PropertyStatus.underMaintenance
            ? null
            : () {
                _scheduleMaintenance(property, gameProvider);
              },
        isFullWidth: true,
      ),
    ],
  );
}
  
  Widget _buildPropertyDescription(Property property) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              property.description,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  'Sunrise Heights', // Placeholder location
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionHeader(
    String title,
    IconData icon, {
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const Spacer(),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatRow(
    String label1,
    Widget value1,
    String label2,
    Widget value2,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label1,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              value1,
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label2,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              value2,
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatusBadge(PropertyStatus status) {
    Color badgeColor;
    String statusText;
    
    switch (status) {
      case PropertyStatus.vacant:
        badgeColor = Colors.orange;
        statusText = 'Vacant';
        break;
      case PropertyStatus.occupied:
        badgeColor = Colors.green;
        statusText = 'Occupied';
        break;
      case PropertyStatus.underMaintenance:
        badgeColor = Colors.red;
        statusText = 'Maintenance';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: badgeColor),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: badgeColor,
          fontWeight: FontWeight.bold,
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
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays < 30) {
      return '${difference.inDays} days';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''}';
    } else {
      final years = (difference.inDays / 365).floor();
      final remainingMonths = ((difference.inDays % 365) / 30).floor();
      return '$years year${years > 1 ? 's' : ''}${remainingMonths > 0 ? ', $remainingMonths month${remainingMonths > 1 ? 's' : ''}' : ''}';
    }
  }
  
  String _calculateROI(Property property) {
    // Annual ROI = (Annual Income / Property Value) * 100
    final annualIncome = property.currentRent * 365;
    final roi = (annualIncome / property.currentValue) * 100;
    return roi.toStringAsFixed(1);
  }
  
  String _calculateAppreciation(Property property) {
    // Appreciation = ((Current Value - Purchase Price) / Purchase Price) * 100
    final appreciation = ((property.currentValue - property.purchasePrice) / property.purchasePrice) * 100;
    return appreciation.toStringAsFixed(1);
  }
  
  void _handleUpgrade(
    Property property,
    String upgradeType,
    GameProvider gameProvider,
  ) async {
    final success = await gameProvider.upgradeProperty(property.id, upgradeType);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Property upgraded with $upgradeType!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to upgrade property. Insufficient funds or other error.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _collectRent(Property property, GameProvider gameProvider) async {
    if (property.status != PropertyStatus.occupied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot collect rent from vacant property.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    final income = await gameProvider.collectAllIncome();
    
    if (income > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Collected \$${income.toStringAsFixed(2)} in rent!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No rent to collect at this time.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
  
  void _findTenant(Property property, GameProvider gameProvider) {
    // For now, this is a simple implementation
    // In a full game, this could have different tenant options, lease terms, etc.
    if (property.status != PropertyStatus.vacant) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Property is already occupied.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    setState(() {
      property.status = PropertyStatus.occupied;
      property.lastCollected = DateTime.now();
    });
    
    // Update property in the provider
    gameProvider.propertyProvider.savePropertyState(property);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('New tenant found! Rent collection has begun.'),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  void _scheduleMaintenance(Property property, GameProvider gameProvider) {
  // Method implementation...
  // For example:
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Schedule Maintenance'),
      content: const Text(
        'Maintenance will temporarily stop rent collection but will increase property value and prevent future issues. Continue?'
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            // In full implementation, this would start a maintenance process
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Maintenance scheduled. Feature coming soon!'),
                backgroundColor: Colors.blue,
              ),
            );
          },
          child: const Text('Confirm'),
        ),
      ],
    ),
  );
}
}