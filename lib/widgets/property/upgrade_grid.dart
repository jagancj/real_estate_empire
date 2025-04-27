import 'package:flutter/material.dart';
import '../../models/property_model.dart';
import '../common/currency_display.dart';

class UpgradeGrid extends StatelessWidget {
  final Property property;
  final Function(String) onUpgrade;
  final bool canAfford;
  
  const UpgradeGrid({
    super.key,
    required this.property,
    required this.onUpgrade,
    required this.canAfford,
  });

  @override
  Widget build(BuildContext context) {
    // Get available upgrades based on property type
    final List<Map<String, dynamic>> availableUpgrades = _getAvailableUpgrades();
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: availableUpgrades.length,
      itemBuilder: (context, index) {
        final upgrade = availableUpgrades[index];
        final upgradeName = upgrade['name'] as String;
        final description = upgrade['description'] as String;
        final costMultiplier = upgrade['costMultiplier'] as double;
        final rentIncrease = upgrade['rentIncrease'] as double;
        
        // Calculate cost
        final cost = property.currentValue * costMultiplier;
        
        // Check if this upgrade is already applied
        final isApplied = property.upgrades.containsKey(upgradeName);
        final level = isApplied ? property.upgrades[upgradeName] : 0;
        
        return _buildUpgradeCard(
          context,
          upgradeName,
          description,
          cost,
          rentIncrease,
          isApplied,
          level ?? 0,
          () => onUpgrade(upgradeName),
        );
      },
    );
  }
  
  List<Map<String, dynamic>> _getAvailableUpgrades() {
    // This is a simplified implementation
    // In a full game, you'd get these from GameConstants based on property type
    switch (property.type) {
      case PropertyType.studioApartment:
        return [
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
          {
            'name': 'Fresh Paint',
            'description': 'New paint throughout',
            'costMultiplier': 0.03,
            'rentIncrease': 0.05,
          },
        ];
      case PropertyType.smallHouse:
        return [
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
          {
            'name': 'New Roof',
            'description': 'Replace the roof',
            'costMultiplier': 0.07,
            'rentIncrease': 0.08,
          },
        ];
      default:
        return [
          {
            'name': 'Basic Upgrade',
            'description': 'Improve the property',
            'costMultiplier': 0.05,
            'rentIncrease': 0.1,
          },
          {
            'name': 'Premium Upgrade',
            'description': 'Significant improvements',
            'costMultiplier': 0.1,
            'rentIncrease': 0.2,
          },
        ];
    }
  }
  
  Widget _buildUpgradeCard(
    BuildContext context,
    String name,
    String description,
    double cost,
    double rentIncrease,
    bool isApplied,
    int level,
    VoidCallback onUpgrade,
  ) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: (canAfford && !isApplied) ? onUpgrade : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isApplied)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Lv ${level}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cost',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                      CurrencyDisplay(
                        amount: cost,
                        fontSize: 12,
                        compact: true,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Rent Increase',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '+${(rentIncrease * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}