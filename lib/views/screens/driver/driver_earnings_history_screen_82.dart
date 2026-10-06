import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/driver_service.dart';

class DriverEarningsHistoryScreen extends StatefulWidget {
  const DriverEarningsHistoryScreen({super.key});

  @override
  State<DriverEarningsHistoryScreen> createState() => _DriverEarningsHistoryScreenState();
}

class _DriverEarningsHistoryScreenState extends State<DriverEarningsHistoryScreen> {
  // Earnings Summary State
  String _totalEarnings = '₹0';
  String _tripsCount = '0';
  String _completedCount = '0';

  bool _isLoading = true;

  // Filter State (Default: This Month)
  String _selectedFilterKey = 'this_month';
  String _selectedFilterLabel = 'This Month';
  DateTimeRange? _customDateRange;

  // Table Data & Server-Side Pagination State
  List<Map<String, dynamic>> _paymentRecords = [];
  int _currentPage = 1;
  int _rowsPerPage = 5;
  int _totalPages = 1;
  int _totalEntries = 0;

  @override
  void initState() {
    super.initState();
    _fetchFuelShareData();
  }

  String _formatDateToYMD(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> _fetchFuelShareData({
    int? page,
    int? limit,
    String? filterKey,
    DateTimeRange? customRange,
  }) async {
    setState(() => _isLoading = true);

    final activeFilter = filterKey ?? _selectedFilterKey;
    final activePage = page ?? _currentPage;
    final activeLimit = limit ?? _rowsPerPage;

    String? startStr;
    String? endStr;

    if (activeFilter == 'custom') {
      final range = customRange ?? _customDateRange;
      if (range != null) {
        startStr = _formatDateToYMD(range.start);
        endStr = _formatDateToYMD(range.end);
      }
    }

    try {
      final res = await DriverService.getFuelShareHistory(
        filter: activeFilter,
        startDate: startStr,
        endDate: endStr,
        page: activePage,
        limit: activeLimit,
      );

      if (res['success'] == true || res['data'] != null || res['records'] != null || res['trips'] != null) {
        final data = res['data'] is Map<String, dynamic> ? res['data'] as Map<String, dynamic> : res;

        // 1. Total Earnings
        final rawEarnings = data['totalEarnings'] ?? data['totalFuelShare'] ?? data['formattedTotalEarnings'] ?? data['earnings'];
        if (rawEarnings != null) {
          final earningsStr = rawEarnings.toString();
          _totalEarnings = earningsStr.startsWith('₹') ? earningsStr : '₹$earningsStr';
        }

        // 2. Summary Counts
        final rawTrips = data['totalTrips'] ?? data['tripsCount'] ?? data['trips'] ?? data['totalCount'];
        if (rawTrips != null && rawTrips is! List) {
          _tripsCount = rawTrips.toString();
        }

        final rawCompleted = data['completedTrips'] ?? data['completedCount'] ?? data['completed'];
        if (rawCompleted != null && rawCompleted is! List) {
          _completedCount = rawCompleted.toString();
        }

        // 3. Records List
        final rawList = data['records'] ?? data['trips'] ?? data['items'] ?? data['fuelShareRecords'] ?? (data['data'] is List ? data['data'] : null);
        if (rawList is List) {
          _paymentRecords = List<Map<String, dynamic>>.from(
            rawList.map((item) => Map<String, dynamic>.from(item as Map)),
          );
        } else {
          _paymentRecords = [];
        }

        // 4. Pagination Metadata
        _currentPage = (data['page'] ?? data['currentPage'] ?? activePage) as int;
        _rowsPerPage = (data['limit'] ?? data['perPage'] ?? activeLimit) as int;
        _totalPages = (data['totalPages'] ?? data['pages'] ?? ((_paymentRecords.length / _rowsPerPage).ceil().clamp(1, 999))) as int;
        _totalEntries = (data['totalEntries'] ?? data['total'] ?? data['count'] ?? _paymentRecords.length) as int;
      }
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _selectedFilterKey = activeFilter;
          if (customRange != null) {
            _customDateRange = customRange;
          }
        });
      }
    }
  }

  Future<void> _selectCustomDateRange() async {
    final now = DateTime.now();
    final initialRange = _customDateRange ??
        DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: now,
        );

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDateRange: initialRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final label = '${picked.start.day}/${picked.start.month} - ${picked.end.day}/${picked.end.month}';
      setState(() {
        _selectedFilterKey = 'custom';
        _selectedFilterLabel = label;
        _customDateRange = picked;
        _currentPage = 1;
      });
      _fetchFuelShareData(filterKey: 'custom', customRange: picked, page: 1);
    }
  }

  void _onFilterSelected(String filterKey) {
    if (filterKey == 'custom') {
      _selectCustomDateRange();
      return;
    }

    String label = 'This Month';
    switch (filterKey) {
      case 'today':
        label = 'Today';
        break;
      case 'yesterday':
        label = 'Yesterday';
        break;
      case 'this_week':
        label = 'This Week';
        break;
      case 'this_month':
      default:
        label = 'This Month';
        break;
    }

    setState(() {
      _selectedFilterKey = filterKey;
      _selectedFilterLabel = label;
      _currentPage = 1;
    });

    _fetchFuelShareData(filterKey: filterKey, page: 1);
  }

  PopupMenuItem<String> _buildPopupMenuItem(String value, String label, {IconData? icon}) {
    final isSelected = _selectedFilterKey == value;
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: isSelected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ),
          if (isSelected) const Icon(Icons.check_rounded, size: 18, color: AppColors.primary),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Fuel Share',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Theme(
                data: Theme.of(context).copyWith(
                  cardColor: Colors.white,
                  popupMenuTheme: const PopupMenuThemeData(
                    color: Colors.white,
                    surfaceTintColor: Colors.transparent,
                  ),
                ),
                child: PopupMenuButton<String>(
                  initialValue: _selectedFilterKey,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onSelected: _onFilterSelected,
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    _buildPopupMenuItem('this_month', 'This Month'),
                    _buildPopupMenuItem('this_week', 'This Week'),
                    _buildPopupMenuItem('today', 'Today'),
                    _buildPopupMenuItem('yesterday', 'Yesterday'),
                    const PopupMenuDivider(height: 1),
                    _buildPopupMenuItem('custom', 'Custom Range', icon: Icons.calendar_month_rounded),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3EDF7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _selectedFilterLabel,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Bottom Background Graphic
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Image.asset(
                  'assets/images/image 31.png',
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.bottomCenter,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),

            // Viewport-adaptive dynamic layout fitting all screen sizes
            LayoutBuilder(
              builder: (context, constraints) {
                // Compute dynamic available vertical height for table
                final double minTableHeight = (constraints.maxHeight - 310).clamp(260.0, double.infinity);

                return RefreshIndicator(
                  onRefresh: () => _fetchFuelShareData(),
                  color: AppColors.primary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: (constraints.maxHeight - 36).clamp(0.0, double.infinity),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_isLoading) ...[
                                const LinearProgressIndicator(
                                  minHeight: 2,
                                  color: AppColors.primary,
                                  backgroundColor: Color(0xFFF3EDF7),
                                ),
                                const SizedBox(height: 12),
                              ],

                              // 1. Purple Header Banner Card
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFFB300),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.monetization_on_rounded, color: Colors.white, size: 28),
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Total Earnings', style: TextStyle(color: Colors.white70, fontSize: 13)),
                                        const SizedBox(height: 4),
                                        Text(
                                          _totalEarnings,
                                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),

                              // 2. Trips & Completed Cards Row
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF7F5FE),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text('Trips', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                              const SizedBox(height: 4),
                                              Text(_tripsCount, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                            ],
                                          ),
                                          const Icon(Icons.two_wheeler_rounded, color: AppColors.primary, size: 26),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF7F5FE),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text('Completed', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                              const SizedBox(height: 4),
                                              Text(_completedCount, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                            ],
                                          ),
                                          const Icon(Icons.check_circle_rounded, color: Color(0xFF4CAF50), size: 26),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // 3. Trip Details Table Section Title
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Trip details',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                  ),
                                  if (_paymentRecords.isNotEmpty)
                                    Text(
                                      '$_totalEntries records',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                    ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Fluid Paginated Data Table Widget fitting dynamically to screen size
                          _buildPaymentDataTable(minHeight: minTableHeight),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- Dynamic Trip Details Fluid Paginated Data Table ---
  Widget _buildPaymentDataTable({required double minHeight}) {
    final int totalEntries = _totalEntries > 0 ? _totalEntries : _paymentRecords.length;
    final int totalPages = _totalPages > 0 ? _totalPages : 1;
    final int startIndex = totalEntries == 0 ? 0 : (_currentPage - 1) * _rowsPerPage;
    final int endIndex = totalEntries == 0 ? 0 : (startIndex + _paymentRecords.length > totalEntries ? totalEntries : startIndex + _paymentRecords.length);

    final double tableBodyMinHeight = (minHeight - 110).clamp(180.0, double.infinity);

    return Container(
      constraints: BoxConstraints(minHeight: minHeight),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEADBFA)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Horizontally Scrollable Table for responsive columns
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: 620, minHeight: minHeight - 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Table Header Row
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3EDF7),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                    ),
                    child: const Row(
                      children: [
                        SizedBox(
                          width: 140,
                          child: Text(
                            'Customer Name',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ),
                        SizedBox(
                          width: 160,
                          child: Text(
                            'Ride',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ),
                        SizedBox(
                          width: 90,
                          child: Text(
                            'Amount',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ),
                        SizedBox(
                          width: 110,
                          child: Text(
                            'Start Date',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ),
                        SizedBox(
                          width: 110,
                          child: Text(
                            'Completed Date',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Table Body Rows (Fluid Dynamic Height)
                  if (_paymentRecords.isEmpty)
                    Container(
                      width: 620,
                      height: tableBodyMinHeight,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.table_chart_outlined, size: 48, color: AppColors.textMuted),
                          const SizedBox(height: 12),
                          const Text(
                            'No trip records found',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _isLoading
                                ? 'Loading fuel share trip details...'
                                : 'Customer trip and earnings details will appear here once rides are completed.',
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else
                    ..._paymentRecords.asMap().entries.map((entry) {
                      final isEven = entry.key % 2 == 0;
                      final row = entry.value;

                      final custName = row['customerName'] ?? row['passengerName'] ?? row['customer'] ?? row['name'] ?? '-';
                      final rideRoute = row['ride'] ?? row['route'] ?? (row['origin'] != null && row['destination'] != null ? '${row['origin']} ➔ ${row['destination']}' : (row['from'] != null && row['to'] != null ? '${row['from']} ➔ ${row['to']}' : '-'));
                      final rawAmount = row['amount'] ?? row['price'] ?? row['fare'] ?? row['fuelShare'] ?? '₹0';
                      final amountStr = rawAmount.toString().startsWith('₹') ? rawAmount.toString() : '₹$rawAmount';
                      final startDate = row['startDate'] ?? row['departureDate'] ?? row['departureTime'] ?? row['date'] ?? '-';
                      final compDate = row['completedDate'] ?? row['arrivalTime'] ?? row['finishedDate'] ?? row['date'] ?? '-';

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: isEven ? Colors.white : const Color(0xFFFAF9FD),
                          border: const Border(
                            bottom: BorderSide(color: Color(0xFFF0EBF8), width: 1),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Customer Name
                            SizedBox(
                              width: 140,
                              child: Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 13,
                                    backgroundColor: Color(0xFFEADBFA),
                                    child: Icon(Icons.person, size: 15, color: AppColors.primary),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      custName.toString(),
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Ride
                            SizedBox(
                              width: 160,
                              child: Text(
                                rideRoute.toString(),
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            // Amount
                            SizedBox(
                              width: 90,
                              child: Text(
                                amountStr,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                              ),
                            ),

                            // Start Date
                            SizedBox(
                              width: 110,
                              child: Text(
                                startDate.toString(),
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ),

                            // Completed Date
                            SizedBox(
                              width: 110,
                              child: Text(
                                compDate.toString(),
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),

          // Fluid Pagination Control Footer (Fixed at the bottom of the table card)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFFAF9FD),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
              border: Border(
                top: BorderSide(color: Color(0xFFEADBFA), width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Showing count label & Rows per page selector
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      totalEntries == 0
                          ? 'Showing 0 of 0'
                          : 'Showing ${startIndex + 1}-$endIndex of $totalEntries',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 8),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _rowsPerPage,
                        isDense: true,
                        icon: const Icon(Icons.arrow_drop_down, size: 16, color: AppColors.primary),
                        items: const [
                          DropdownMenuItem(value: 5, child: Text('5/page', style: TextStyle(fontSize: 11))),
                          DropdownMenuItem(value: 10, child: Text('10/page', style: TextStyle(fontSize: 11))),
                          DropdownMenuItem(value: 20, child: Text('20/page', style: TextStyle(fontSize: 11))),
                        ],
                        onChanged: (int? newValue) {
                          if (newValue != null && newValue != _rowsPerPage) {
                            setState(() {
                              _rowsPerPage = newValue;
                              _currentPage = 1;
                            });
                            _fetchFuelShareData(page: 1, limit: newValue);
                          }
                        },
                      ),
                    ),
                  ],
                ),

                // Pagination Buttons (Previous / Next)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      color: _currentPage > 1 ? AppColors.primary : Colors.grey[400],
                      onPressed: _currentPage > 1
                          ? () {
                              _fetchFuelShareData(page: _currentPage - 1);
                            }
                          : null,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFEADBFA)),
                      ),
                      child: Text(
                        '$_currentPage / $totalPages',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      color: _currentPage < totalPages ? AppColors.primary : Colors.grey[400],
                      onPressed: _currentPage < totalPages
                          ? () {
                              _fetchFuelShareData(page: _currentPage + 1);
                            }
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
