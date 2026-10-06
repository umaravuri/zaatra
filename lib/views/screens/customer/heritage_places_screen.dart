import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/heritage_place_model.dart';
import '../../../services/heritage_service.dart';
import 'heritage_detail_screen.dart';

class HeritagePlacesScreen extends StatefulWidget {
  final String? initialCity;
  final HeritageMonumentType? initialType;

  const HeritagePlacesScreen({
    super.key,
    this.initialCity,
    this.initialType,
  });

  @override
  State<HeritagePlacesScreen> createState() => _HeritagePlacesScreenState();
}

class _HeritagePlacesScreenState extends State<HeritagePlacesScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  List<HeritagePlace> _places = [];
  final Set<String> _favoritePlaceIds = {};
  final Set<String> _selectedCities = {};

  HeritageMonumentType _selectedType = HeritageMonumentType.all;
  HeritageSortOption _selectedSort = HeritageSortOption.topRated;
  bool _mustVisitOnly = false;
  bool _isLoading = true;
  bool _showSearchBar = false;
  List<String> _dynamicCategories = [];
  List<String> _dynamicCities = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialType != null) {
      _selectedType = widget.initialType!;
    }
    if (widget.initialCity != null && widget.initialCity!.trim().isNotEmpty) {
      _selectedCities.add(widget.initialCity!.trim());
    }
    _loadCategoriesAndCities();
    _loadPlaces();
  }

  Future<void> _loadCategoriesAndCities() async {
    final meta = await HeritageService.getCategoriesAndCities();
    if (mounted && meta.success) {
      setState(() {
        _dynamicCategories = meta.categories;
        _dynamicCities = meta.cities;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadPlaces() async {
    setState(() => _isLoading = true);

    final filterState = HeritageFilterState(
      selectedType: _selectedType,
      city: _selectedCities.length == 1 ? _selectedCities.first : null,
      selectedCities: _selectedCities.toList(),
      mustVisitOnly: _mustVisitOnly,
      searchQuery: _searchController.text,
      sortOption: _selectedSort,
    );

    final res = await HeritageService.getPlaces(filterState: filterState);

    if (mounted) {
      setState(() {
        _places = res.places;
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      _loadPlaces();
    });
  }

  // 1. Sort Modal Bottom Sheet
  void _showSortModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Icon(Icons.swap_vert_rounded, color: Color(0xFF6C4CE8), size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Sort Heritage Places',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSortTile(HeritageSortOption.topRated, Icons.star_rounded),
                _buildSortTile(HeritageSortOption.mostVisited, Icons.local_fire_department_rounded),
                _buildSortTile(HeritageSortOption.mustVisit, Icons.verified_rounded),
                _buildSortTile(HeritageSortOption.nameAsc, Icons.sort_by_alpha_rounded),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSortTile(HeritageSortOption option, IconData icon) {
    final isSelected = _selectedSort == option;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF3EDF7) : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: isSelected ? const Color(0xFF6C4CE8) : AppColors.textSecondary, size: 20),
      ),
      title: Text(
        option.label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? const Color(0xFF6C4CE8) : AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        option.description,
        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: Color(0xFF6C4CE8))
          : null,
      onTap: () {
        Navigator.pop(context);
        setState(() => _selectedSort = option);
        _loadPlaces();
      },
    );
  }

  // 2. Filter Modal Bottom Sheet
  void _showFilterModal() {
    var tempType = _selectedType;
    var tempMustVisit = _mustVisitOnly;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.filter_list_rounded, color: Color(0xFF6C4CE8), size: 22),
                            SizedBox(width: 8),
                            Text(
                              'Filter Heritage Sites',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              tempType = HeritageMonumentType.all;
                              tempMustVisit = false;
                            });
                          },
                          child: const Text('Reset', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Monument Category',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: HeritageMonumentType.values.map((type) {
                        final isSelected = tempType == type;
                        return ChoiceChip(
                          label: Text(type.displayName),
                          selected: isSelected,
                          selectedColor: const Color(0xFF6C4CE8),
                          backgroundColor: const Color(0xFFF7F7F9),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: isSelected ? const Color(0xFF6C4CE8) : AppColors.border,
                            ),
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setModalState(() => tempType = type);
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Must-Visit Places Only', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: const Text('Show only editor-selected top highlights', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      value: tempMustVisit,
                      activeThumbColor: const Color(0xFF6C4CE8),
                      onChanged: (val) => setModalState(() => tempMustVisit = val),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          setState(() {
                            _selectedType = tempType;
                            _mustVisitOnly = tempMustVisit;
                          });
                          _loadPlaces();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C4CE8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: const Text('Apply Filters', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 3. City Multi-Select Filter Modal Bottom Sheet
  void _showCityFilterModal() {
    final cityCounts = HeritageService.getAvailableCitiesWithCounts(_places);
    for (final c in _dynamicCities) {
      cityCounts.putIfAbsent(c, () => 0);
    }
    final allCities = cityCounts.keys.toList()..sort();
    final tempSelectedCities = Set<String>.from(_selectedCities);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isAllSelected = tempSelectedCities.length == allCities.length && allCities.isNotEmpty;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.location_city_rounded, color: Color(0xFF6C4CE8), size: 22),
                            SizedBox(width: 8),
                            Text(
                              'Filter by City',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              tempSelectedCities.clear();
                            });
                          },
                          child: const Text('Clear', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Select one or more cities to discover heritage places',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    // Quick Action: Select All / Deselect All
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        setModalState(() {
                          if (isAllSelected) {
                            tempSelectedCities.clear();
                          } else {
                            tempSelectedCities.addAll(allCities);
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isAllSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                              size: 18,
                              color: const Color(0xFF6C4CE8),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isAllSelected ? 'Deselect All' : 'Select All Cities',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF6C4CE8)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.45,
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: allCities.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final city = allCities[index];
                          final count = cityCounts[city] ?? 0;
                          final isSelected = tempSelectedCities.contains(city);

                          return CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            activeColor: const Color(0xFF6C4CE8),
                            title: Row(
                              children: [
                                Text(
                                  city,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected ? const Color(0xFF6C4CE8) : AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFF6C4CE8).withValues(alpha: 0.12) : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$count places',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected ? const Color(0xFF6C4CE8) : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            value: isSelected,
                            onChanged: (bool? val) {
                              setModalState(() {
                                if (val == true) {
                                  tempSelectedCities.add(city);
                                } else {
                                  tempSelectedCities.remove(city);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          setState(() {
                            _selectedCities
                              ..clear()
                              ..addAll(tempSelectedCities);
                          });
                          _loadPlaces();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C4CE8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: Text(
                          tempSelectedCities.isEmpty
                              ? 'Show All Cities'
                              : 'Apply Cities (${tempSelectedCities.length})',
                          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            const Text(
              'Heritage Places',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              'Explore ${_places.length} Historical Options',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showSearchBar ? Icons.close_rounded : Icons.search_rounded,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _showSearchBar = !_showSearchBar;
                if (!_showSearchBar) {
                  _searchController.clear();
                  _loadPlaces();
                }
              });
            },
          ),
        ],
        centerTitle: true,
        backgroundColor: const Color(0xFF6C4CE8),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search field when toggled
            if (_showSearchBar)
              Container(
                color: const Color(0xFF6C4CE8),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Search monuments, forts, palaces...',
                      hintStyle: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF6C4CE8), size: 20),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),

            // 3 Equal Action Pills Bar matching Screen 45 (Sort, Filter, City)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionPill(
                      icon: Icons.swap_vert_rounded,
                      label: 'Sort',
                      badge: _selectedSort != HeritageSortOption.topRated ? '•' : null,
                      onTap: _showSortModal,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildActionPill(
                      icon: Icons.filter_list_rounded,
                      label: 'Filter',
                      badge: (_selectedType != HeritageMonumentType.all || _mustVisitOnly) ? '•' : null,
                      onTap: _showFilterModal,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildActionPill(
                      icon: Icons.location_city_rounded,
                      label: _selectedCities.isEmpty
                          ? 'City'
                          : _selectedCities.length == 1
                              ? _selectedCities.first
                              : 'City (${_selectedCities.length})',
                      badge: _selectedCities.isNotEmpty ? '•' : null,
                      onTap: _showCityFilterModal,
                    ),
                  ),
                ],
              ),
            ),

            // Main Clean Card List matching Screen 45
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadPlaces,
                color: const Color(0xFF6C4CE8),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C4CE8)))
                    : _places.isEmpty
                        ? _buildEmptyState()
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            itemCount: _places.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              final place = _places[index];
                              return _buildHeritageCardScreen45(place);
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Equal Action Pill matching Screen 45
  Widget _buildActionPill({
    required IconData icon,
    required String label,
    String? badge,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF3EDF7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF1D1B20)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D1B20),
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 4),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF6C4CE8),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Heritage Card Layout matching Screen 45
  Widget _buildHeritageCardScreen45(HeritagePlace place) {
    final isFav = _favoritePlaceIds.contains(place.placeId);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HeritageDetailScreen(placeId: place.placeId, initialPlace: place),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Image with Heart Icon matching Screen 45
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    place.coverImage.isNotEmpty
                        ? place.coverImage
                        : 'https://images.unsplash.com/photo-1590490360182-c33d57733427?auto=format&fit=crop&w=800&q=80',
                    width: 110,
                    height: 125,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 110,
                      height: 125,
                      color: const Color(0xFFF3EDF7),
                      child: const Center(child: Icon(Icons.castle_rounded, color: Color(0xFF6C4CE8), size: 36)),
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  left: 6,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isFav) {
                          _favoritePlaceIds.remove(place.placeId);
                        } else {
                          _favoritePlaceIds.add(place.placeId);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFav ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                        color: isFav ? const Color(0xFFFF5252) : AppColors.textSecondary,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 12),

            // Right Details Column matching Screen 45
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Rating Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          place.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Text(
                              place.rating.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFE65100)),
                            ),
                            const SizedBox(width: 2),
                            const Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 12),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 3),

                  // City, State & Category
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          '${place.city}, ${place.state} • ${place.category}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Red highlights text matching Screen 45 style
                  Text(
                    place.tagline.isNotEmpty
                        ? place.tagline
                        : (place.famousHighlights.isNotEmpty ? place.famousHighlights.first : 'Iconic heritage site'),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFFD32F2F),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 3),

                  // Timings text
                  Text(
                    '${place.timings.openTime} - ${place.timings.closeTime} • ${place.timings.openDays}',
                    style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Green Price Text matching Screen 45 style
                  Text(
                    place.entryFee.isFreeEntry
                        ? 'Free Entry for all visitors'
                        : 'Entry : ₹${place.entryFee.domestic.toStringAsFixed(0)} (Domestic)',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.castle_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 12),
            const Text(
              'No heritage places match your filter',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try changing your search query or reset filter options.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _selectedType = HeritageMonumentType.all;
                  _mustVisitOnly = false;
                  _selectedSort = HeritageSortOption.topRated;
                  _selectedCities.clear();
                });
                _loadPlaces();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C4CE8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Reset All Filters', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
