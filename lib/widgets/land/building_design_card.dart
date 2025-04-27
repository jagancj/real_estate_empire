import 'package:flutter/material.dart';
import '../../models/building_model.dart';

class BuildingDesignCard extends StatelessWidget {
  final String designId;
  final String name;
  final BuildingType buildingType;
  final String imageAsset;
  final double costMultiplier;
  final double rentMultiplier;
  final bool isSelected;
  final VoidCallback onSelect;
  
  const BuildingDesignCard({
    super.key,
    required this.designId,
    required this.name,
    required this.buildingType,
    required this.imageAsset,
    required this.costMultiplier,
    required this.rentMultiplier,
    this.isSelected = false,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isSelected
            ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onSelect,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Design image
            Stack(
              children: [
                Image.asset(
                  imageAsset,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                if (isSelected)
                  Positioned.fill(
                    child: Container(
                      color: Theme.of(context).primaryColor.withOpacity(0.2),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                
                // Building type badge
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getBuildingTypeColor(buildingType),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getBuildingTypeString(buildingType),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Design info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  // Multipliers
                  Row(
                    children: [
                      _buildMultiplierChip(
                        context,
                        'Cost',
                        costMultiplier,
                        costMultiplier < 1 ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      _buildMultiplierChip(
                        context,
                        'Rent',
                        rentMultiplier,
                        rentMultiplier > 1 ? Colors.green : Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMultiplierChip(
    BuildContext context,
    String label,
    double value,
    Color color,
  ) {
    final formattedValue = value.toStringAsFixed(2).replaceAll('.00', '');
    final displayText = value >= 1 ? '×$formattedValue' : '÷${(1 / value).toStringAsFixed(1)}';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
          Text(
            displayText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  String _getBuildingTypeString(BuildingType type) {
    switch (type) {
      case BuildingType.smallHouse:
        return 'House';
      case BuildingType.apartment:
        return 'Apartment';
      case BuildingType.office:
        return 'Office';
      case BuildingType.retail:
        return 'Retail';
    }
  }
  
  Color _getBuildingTypeColor(BuildingType type) {
    switch (type) {
      case BuildingType.smallHouse:
      case BuildingType.apartment:
        return Colors.green;
      case BuildingType.office:
        return Colors.blue;
      case BuildingType.retail:
        return Colors.purple;
    }
  }
}