// screens/land_development_setup_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/land_model.dart';
import '../models/building_model.dart';
import '../models/game_constants.dart';
import '../providers/game_provider.dart';
import '../widgets/common/custom_button.dart';
import '../widgets/common/currency_display.dart';
import '../widgets/land/building_design_card.dart';

class LandDevelopmentSetupScreen extends StatefulWidget {
  final Land land;
  
  const LandDevelopmentSetupScreen({
    super.key,
    required this.land,
  });

  @override
  State<LandDevelopmentSetupScreen> createState() => _LandDevelopmentSetupScreenState();
}

class _LandDevelopmentSetupScreenState extends State<LandDevelopmentSetupScreen> {
  BuildingType _selectedBuildingType = BuildingType.smallHouse;
  String _selectedDesignId = '';
  String _buildingName = '';
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _initializeDefaults();
  }
  
  void _initializeDefaults() {
    // Set default building type based on zone
    switch (widget.land.zoneType) {
      case ZoneType.residential:
        _selectedBuildingType = BuildingType.smallHouse;
        break;
      case ZoneType.commercial:
        _selectedBuildingType = BuildingType.retail;
        break;
      case ZoneType.mixedUse:
        _selectedBuildingType = BuildingType.smallHouse;
        break;
    }
    
    // Set default building name
    _buildingName = _getDefaultBuildingName(_selectedBuildingType);
    
    // Set first available design as default
    _setDefaultDesign();
  }
  
  void _setDefaultDesign() {
    final availableDesigns = _getAvailableDesigns();
    if (availableDesigns.isNotEmpty) {
      _selectedDesignId = availableDesigns.first['id'] as String;
    }
  }
  
  String _getDefaultBuildingName(BuildingType type) {
    switch (type) {
      case BuildingType.smallHouse:
        return '${widget.land.location} House';
      case BuildingType.apartment:
        return '${widget.land.location} Apartments';
      case BuildingType.office:
        return '${widget.land.location} Office Center';
      case BuildingType.retail:
        return '${widget.land.location} Retail Plaza';
    }
  }
  
  List<Map<String, dynamic>> _getAvailableDesigns() {
    return GameConstants.buildingDesigns
        .where((design) => design['buildingType'] == _selectedBuildingType)
        .toList();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Develop Land'),
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          final playerStats = gameProvider.getPlayerStats();
          final availableCash = playerStats['cash'] as double;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLandInfo(),
                const SizedBox(height: 24),
                _buildBuildingTypeSelector(),
                const SizedBox(height: 24),
                _buildNameField(),
                const SizedBox(height: 24),
                _buildDesignSelector(),
                const SizedBox(height: 24),
                _buildCostSummary(availableCash),
                const SizedBox(height: 32),
                _buildStartConstructionButton(gameProvider, availableCash),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildLandInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
                    color: Colors.amber[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.terrain,
                    color: Colors.amber[800],
                    size: 36,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.land.location,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildBadge(
                            _getZoneTypeString(widget.land.zoneType),
                            _getZoneColor(widget.land.zoneType),
                          ),
                          const SizedBox(width: 8),
                          _buildBadge(
                            _getLandSizeString(widget.land.size),
                            Colors.blue,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Land Value',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    CurrencyDisplay(
                      amount: widget.land.currentValue,
                      fontSize: 16,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Land Area',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${_formatNumber(widget.land.squareFeet)} sq ft',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBuildingTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Building Type',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildBuildingTypeOption(
                  BuildingType.smallHouse,
                  'Single Family Home',
                  Icons.home,
                  widget.land.zoneType == ZoneType.residential || widget.land.zoneType == ZoneType.mixedUse,
                ),
                const Divider(height: 16),
                _buildBuildingTypeOption(
                  BuildingType.apartment,
                  'Apartment Building',
                  Icons.apartment,
                  widget.land.zoneType == ZoneType.residential || widget.land.zoneType == ZoneType.mixedUse,
                ),
                const Divider(height: 16),
                _buildBuildingTypeOption(
                  BuildingType.office,
                  'Office Building',
                  Icons.business,
                  widget.land.zoneType == ZoneType.commercial || widget.land.zoneType == ZoneType.mixedUse,
                ),
                const Divider(height: 16),
                _buildBuildingTypeOption(
                  BuildingType.retail,
                  'Retail Space',
                  Icons.storefront,
                  widget.land.zoneType == ZoneType.commercial || widget.land.zoneType == ZoneType.mixedUse,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildBuildingTypeOption(
    BuildingType type,
    String label,
    IconData icon,
    bool isAvailable,
  ) {
    return Opacity(
      opacity: isAvailable ? 1.0 : 0.5,
      child: RadioListTile<BuildingType>(
        title: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        secondary: Icon(icon),
        value: type,
        groupValue: _selectedBuildingType,
        onChanged: isAvailable
            ? (value) {
                if (value != null) {
                  setState(() {
                    _selectedBuildingType = value;
                    _buildingName = _getDefaultBuildingName(value);
                    _setDefaultDesign();
                  });
                }
              }
            : null,
        activeColor: Theme.of(context).primaryColor,
        selected: _selectedBuildingType == type,
      ),
    );
  }
  
  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Building Name',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: _buildingName,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white,
            hintText: 'Enter a name for your building',
          ),
          onChanged: (value) {
            setState(() {
              _buildingName = value;
            });
          },
        ),
      ],
    );
  }
  
  Widget _buildDesignSelector() {
    final availableDesigns = _getAvailableDesigns();
    
    if (availableDesigns.isEmpty) {
      return const Center(
        child: Text('No designs available for this building type.'),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Building Design',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: availableDesigns.length,
            itemBuilder: (context, index) {
              final design = availableDesigns[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 260,
                  child: BuildingDesignCard(
                    designId: design['id'] as String,
                    name: design['name'] as String,
                    buildingType: design['buildingType'] as BuildingType,
                    imageAsset: design['imageAsset'] as String,
                    costMultiplier: design['costMultiplier'] as double,
                    rentMultiplier: design['rentMultiplier'] as double,
                    isSelected: _selectedDesignId == design['id'],
                    onSelect: () {
                      setState(() {
                        _selectedDesignId = design['id'] as String;
                      });
                    },
                  ),
                ),
              );
                // Continuing screens/land_development_setup_screen.dart
          },
          ),
        ),
      ],
    );
  }
  
  Widget _buildCostSummary(double availableCash) {
    // Calculate construction costs based on selection
    final constructionCost = _calculateConstructionCost();
    final canAfford = availableCash >= constructionCost;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Construction Summary',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Construction Cost',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    CurrencyDisplay(
                      amount: constructionCost,
                      fontSize: 16,
                      color: canAfford ? Colors.black : Colors.red,
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Construction Time',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      _getConstructionTimeString(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Estimated Daily Income',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    CurrencyDisplay(
                      amount: _calculateEstimatedIncome(),
                      fontSize: 16,
                      color: Colors.green[700],
                    ),
                  ],
                ),
                if (!canAfford) ...[
                  const Divider(height: 24),
                  Row(
                    children: [
                      Icon(
                        Icons.warning,
                        color: Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'You need ${(constructionCost - availableCash).toStringAsFixed(2)} more to start construction.',
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildStartConstructionButton(GameProvider gameProvider, double availableCash) {
    final constructionCost = _calculateConstructionCost();
    final canAfford = availableCash >= constructionCost;
    final hasName = _buildingName.trim().isNotEmpty;
    final hasDesign = _selectedDesignId.isNotEmpty;
    
    return CustomButton(
      label: 'Start Construction',
      onPressed: (canAfford && hasName && hasDesign && !_isLoading)
          ? () => _startConstruction(gameProvider)
          : () {},
      icon: Icons.construction,
      type: ButtonType.primary,
      isFullWidth: true,
      isLoading: _isLoading,
    );
  }
  
  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
  
  double _calculateConstructionCost() {
    // Get base cost per square foot for building type
    double costPerSqFt;
    switch (_selectedBuildingType) {
      case BuildingType.smallHouse:
        costPerSqFt = GameConstants.smallHouseCostPerSqFt;
        break;
      case BuildingType.apartment:
        costPerSqFt = GameConstants.apartmentCostPerSqFt;
        break;
      case BuildingType.office:
        costPerSqFt = GameConstants.officeCostPerSqFt;
        break;
      case BuildingType.retail:
        costPerSqFt = GameConstants.retailCostPerSqFt;
        break;
    }
    
    // Apply design multiplier if a design is selected
    if (_selectedDesignId.isNotEmpty) {
      final designData = GameConstants.buildingDesigns.firstWhere(
        (d) => d['id'] == _selectedDesignId,
        orElse: () => {'costMultiplier': 1.0},
      );
      
      costPerSqFt *= (designData['costMultiplier'] as double);
    }
    
    // Calculate total construction cost
    final buildingSize = _getBuildingSizeForLand();
    return buildingSize * costPerSqFt;
  }
  
  double _calculateEstimatedIncome() {
    // Get base rental rate multiplier based on building type
    double rentMultiplier;
    switch (_selectedBuildingType) {
      case BuildingType.smallHouse:
      case BuildingType.apartment:
        rentMultiplier = GameConstants.residentialRentMultiplier;
        break;
      case BuildingType.office:
      case BuildingType.retail:
        rentMultiplier = GameConstants.commercialRentMultiplier;
        break;
    }
    
    // Apply design multiplier if a design is selected
    if (_selectedDesignId.isNotEmpty) {
      final designData = GameConstants.buildingDesigns.firstWhere(
        (d) => d['id'] == _selectedDesignId,
        orElse: () => {'rentMultiplier': 1.0},
      );
      
      rentMultiplier *= (designData['rentMultiplier'] as double);
    }
    
    // Calculate estimated daily income based on construction cost
    return _calculateConstructionCost() * rentMultiplier;
  }
  
  int _getBuildingSizeForLand() {
    // Use a portion of the land for the building
    switch (widget.land.size) {
      case LandSize.small:
        // Use 50% of the land for the building
        return (widget.land.squareFeet * 0.5).round();
      case LandSize.medium:
        // Use 60% of the land for the building
        return (widget.land.squareFeet * 0.6).round();
      case LandSize.large:
        // Use 70% of the land for the building
        return (widget.land.squareFeet * 0.7).round();
    }
  }
  
  String _getConstructionTimeString() {
    int hours;
    switch (_selectedBuildingType) {
      case BuildingType.smallHouse:
        hours = GameConstants.smallHouseConstructionTime;
        break;
      case BuildingType.apartment:
        hours = GameConstants.apartmentConstructionTime;
        break;
      case BuildingType.office:
        hours = GameConstants.officeConstructionTime;
        break;
      case BuildingType.retail:
        hours = GameConstants.retailConstructionTime;
        break;
    }
    
    // Adjust for land size
    switch (widget.land.size) {
      case LandSize.small:
        // No adjustment for small land
        break;
      case LandSize.medium:
        // 20% more time for medium land
        hours = (hours * 1.2).round();
        break;
      case LandSize.large:
        // 50% more time for large land
        hours = (hours * 1.5).round();
        break;
    }
    
    if (hours < 24) {
      return '$hours hours';
    } else {
      final days = (hours / 24).floor();
      final remainingHours = hours % 24;
      if (remainingHours == 0) {
        return '$days days';
      } else {
        return '$days days, $remainingHours hours';
      }
    }
  }
  
  void _startConstruction(GameProvider gameProvider) async {
    if (_buildingName.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a name for your building.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    final success = await gameProvider.startConstruction(
      widget.land.id,
      _selectedBuildingType,
      _selectedDesignId,
      _buildingName.trim(),
    );
    
    setState(() {
      _isLoading = false;
    });
    
    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Construction of $_buildingName has begun!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to start construction. Please check your funds and try again.'),
          backgroundColor: Colors.red,
        ),
      );
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
  
  String _formatNumber(int number) {
    if (number >= 10000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}