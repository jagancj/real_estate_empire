import 'package:flutter/material.dart';
import '../models/land_model.dart';
import '../widgets/common/currency_display.dart';
import '../widgets/common/custom_button.dart';

class LandDetailPreviewScreen extends StatelessWidget {
  final Land land;
  final VoidCallback? onPurchase;
  
  const LandDetailPreviewScreen({
    super.key,
    required this.land,
    this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLandHeader(),
                  const SizedBox(height: 24),
                  _buildLandInfo(),
                  const SizedBox(height: 24),
                  _buildDevelopmentPotential(),
                  const SizedBox(height: 24),
                  _buildLocation(),
                  const SizedBox(height: 32),
                  _buildPurchaseButton(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          '${_getLandSizeString(land.size)} ${_getZoneTypeString(land.zoneType)} Land',
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
              land.imageAsset,
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
  
  Widget _buildLandHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Land badges
        Row(
          children: [
            // Zone type badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getZoneColor(land.zoneType).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _getZoneColor(land.zoneType)),
              ),
              child: Text(
                _getZoneTypeString(land.zoneType),
                style: TextStyle(
                  color: _getZoneColor(land.zoneType),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Size badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue),
              ),
              child: Text(
                _getLandSizeString(land.size),
                style: TextStyle(
                  color: Colors.blue[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Purchase Price',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  CurrencyDisplay(
                    amount: land.purchasePrice,
                    fontSize: 24,
                  ),
                ],
              ),
            ),
            _buildPricePerSqFtBadge(),
          ],
        ),
      ],
    );
  }
  
  Widget _buildPricePerSqFtBadge() {
    // Calculate price per square foot
    final pricePerSqFt = land.purchasePrice / land.squareFeet;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.amber[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber),
      ),
      child: Column(
        children: [
          Text(
            'Per sq ft',
            style: TextStyle(
              fontSize: 12,
              color: Colors.amber[800],
            ),
          ),
          Text(
            '\$${pricePerSqFt.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.amber[800],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildLandInfo() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Land Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    Icons.aspect_ratio,
                    'Total Area',
                    '${_formatLandSize(land.squareFeet)} sq ft',
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    Icons.landscape,
                    'Topography',
                    'Flat', // Placeholder
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    Icons.water_drop,
                    'Water Access',
                    'Yes', // Placeholder
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    Icons.electrical_services,
                    'Utilities',
                    'Available', // Placeholder
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildDevelopmentPotential() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Development Potential',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDevelopmentOption(
              'smallHouse',
              'Single Family Home',
              'Suitable for a detached family residence',
              land.zoneType == ZoneType.residential || land.zoneType == ZoneType.mixedUse,
            ),
            const Divider(height: 24),
            _buildDevelopmentOption(
              'apartment',
              'Apartment Building',
              'Multi-unit residential building',
              land.zoneType == ZoneType.residential || land.zoneType == ZoneType.mixedUse,
            ),
            const Divider(height: 24),
            _buildDevelopmentOption(
              'office',
              'Office Building',
              'Professional office space',
              land.zoneType == ZoneType.commercial || land.zoneType == ZoneType.mixedUse,
            ),
            const Divider(height: 24),
            _buildDevelopmentOption(
              'retail',
              'Retail Space',
              'Commercial space for stores or restaurants',
              land.zoneType == ZoneType.commercial || land.zoneType == ZoneType.mixedUse,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDevelopmentOption(
    String buildingType,
    String title,
    String description,
    bool isPossible,
  ) {
    return Row(
      children: [
        Icon(
          isPossible ? Icons.check_circle : Icons.cancel,
          color: isPossible ? Colors.green : Colors.red[300],
          size: 24,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildLocation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Placeholder for a map - in a real app this would be a MapView
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.map,
                      size: 50,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 20,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        land.location,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.business,
                      size: 20,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Neighborhood: ${land.location}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildPurchaseButton() {
    return CustomButton(
      label: 'Purchase Land',
      onPressed: onPurchase ?? () {},
      icon: Icons.terrain,
      type: onPurchase != null ? ButtonType.primary : ButtonType.secondary,
      isFullWidth: true,
      isLoading: false,
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