// screens/property_detail_preview_screen.dart
import 'package:flutter/material.dart';
import '../models/property_model.dart';
import '../widgets/common/currency_display.dart';
import '../widgets/common/custom_button.dart';

class PropertyDetailPreviewScreen extends StatelessWidget {
  final Property property;
  final VoidCallback? onPurchase;
  
  const PropertyDetailPreviewScreen({
    super.key,
    required this.property,
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
                  _buildPropertyHeader(),
                  const SizedBox(height: 24),
                  _buildPropertyInfo(),
                  const SizedBox(height: 24),
                  _buildFinancialInfo(),
                  const SizedBox(height: 24),
                  _buildDescription(),
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
  
  Widget _buildPropertyHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Property type badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _getPropertyTypeString(property.type),
            style: TextStyle(
              color: Colors.blue[800],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
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
                    amount: property.purchasePrice,
                    fontSize: 24,
                  ),
                ],
              ),
            ),
            _buildEstimatedROIBadge(),
          ],
        ),
      ],
    );
  }
  
  Widget _buildEstimatedROIBadge() {
    // Calculate ROI
    final annualIncome = property.baseRent * 365;
    final roi = (annualIncome / property.purchasePrice) * 100;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green),
      ),
      child: Column(
        children: [
          Text(
            'Est. ROI',
            style: TextStyle(
              fontSize: 12,
              color: Colors.green[800],
            ),
          ),
          Text(
            '${roi.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPropertyInfo() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Property Information',
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
                    Icons.location_on,
                    'Location',
                    'Sunrise Heights', // Placeholder location
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    Icons.straighten,
                    'Size',
                    _getPropertySizeString(property.type),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    Icons.home,
                    'Condition',
                    'Good',
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    Icons.calendar_today,
                    'Year Built',
                    '2020', // Placeholder year
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
  
  Widget _buildFinancialInfo() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Financial Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildFinancialItem(
              'Daily Rent',
              CurrencyDisplay(
                amount: property.baseRent,
                fontSize: 16,
                color: Colors.green[700],
              ),
            ),
            const Divider(height: 24),
            _buildFinancialItem(
              'Monthly Revenue',
              CurrencyDisplay(
                amount: property.baseRent * 30,
                fontSize: 16,
                color: Colors.green[700],
              ),
            ),
            const Divider(height: 24),
            _buildFinancialItem(
              'Annual Revenue',
              CurrencyDisplay(
                amount: property.baseRent * 365,
                fontSize: 16,
                color: Colors.green[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFinancialItem(String label, Widget value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[800],
          ),
        ),
        value,
      ],
    );
  }
  
  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          property.description,
          style: const TextStyle(
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ],
    );
  }
  
  Widget _buildPurchaseButton() {
    return CustomButton(
      label: 'Purchase Property',
      onPressed: onPurchase ?? () {},
      icon: Icons.real_estate_agent,
      type: onPurchase != null ? ButtonType.primary : ButtonType.secondary,
      isFullWidth: true,
      isLoading: false,
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
  
  String _getPropertySizeString(PropertyType type) {
    switch (type) {
      case PropertyType.studioApartment:
        return '450 sq ft';
      case PropertyType.smallHouse:
        return '1,200 sq ft';
      case PropertyType.duplex:
        return '2,400 sq ft';
      case PropertyType.smallOffice:
        return '800 sq ft';
      case PropertyType.retailStore:
        return '1,500 sq ft';
    }
  }
}
