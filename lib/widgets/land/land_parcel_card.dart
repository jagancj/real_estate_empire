// widgets/land/land_parcel_card.dart (continued)
import 'package:flutter/material.dart';
import '../../models/land_model.dart';
import '../common/currency_display.dart';

class LandParcelCard extends StatelessWidget {
  final Land land;
  final VoidCallback? onTap;
  final bool isMarketListing;
  
  const LandParcelCard({
    super.key,
    required this.land,
    this.onTap,
    this.isMarketListing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Land image
            Stack(
              children: [
                Image.asset(
                  land.imageAsset,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                // Zone type badge
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getZoneColor(land.zoneType),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getZoneTypeString(land.zoneType),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                // Size badge
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getLandSizeString(land.size),
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
            
            // Land info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          land.location,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      CurrencyDisplay(
                        amount: isMarketListing 
                            ? land.purchasePrice 
                            : land.currentValue,
                        fontSize: 16,
                        compact: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatLandSize(land.squareFeet)} sq ft',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Has building indicator
                  if (land.isOwned && land.buildingId != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.business,
                            size: 14,
                            color: Colors.blue[800],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Building constructed',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Action button for market listings
                  if (isMarketListing) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: const Text('Purchase Land'),
                      ),
                    ),
                  ],
                  
                  // Develop button for owned land without building
                  if (land.isOwned && land.buildingId == null) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: const Text('Develop Land'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
  
  Color _getZoneColor(ZoneType type) {
    switch (type) {
      case ZoneType.residential:
        return Colors.green;
      case ZoneType.commercial:
        return Colors.purple;
      case ZoneType.mixedUse:
        return Colors.teal;
    }
  }
  
  String _getLandSizeString(LandSize size) {
    switch (size) {
      case LandSize.small:
        return 'Small';
      case LandSize.medium:
        return 'Medium';
      case LandSize.large:
        return 'Large';
    }
  }
  
  String _formatLandSize(int sqFt) {
    if (sqFt >= 10000) {
      return '${(sqFt / 1000).toStringAsFixed(1)}K';
    }
    return sqFt.toString();
  }
}
