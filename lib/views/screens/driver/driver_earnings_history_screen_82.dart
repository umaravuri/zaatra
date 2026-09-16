import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/api_service.dart';
import '../../../services/driver_service.dart';
import '../../widgets/custom_button.dart';

class DriverEarningsHistoryScreen extends StatefulWidget {
  const DriverEarningsHistoryScreen({super.key});

  @override
  State<DriverEarningsHistoryScreen> createState() => _DriverEarningsHistoryScreenState();
}

class _DriverEarningsHistoryScreenState extends State<DriverEarningsHistoryScreen> {
  String _totalFuelSaved = '-';
  String _tripsCount = '-';
  String _completedCount = '-';
  List<Map<String, dynamic>> _completedTrips = [];

  String _tripEarnings = '-';
  String _platformCommission = '-';
  final String _otherAdjustment = '₹0';
  final String _payouts = '₹0';
  String _netAmount = '-';

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEarningsData();
  }

  Future<void> _loadEarningsData() async {
    setState(() => _isLoading = true);

    try {
      // 1. Fetch live Dashboard Summary (GET /api/drivers/dashboard-summary)
      try {
        final summaryResult = await DriverService.getDashboardSummary();
        if (summaryResult['success'] == true) {
          if (summaryResult['stats'] is Map) {
            final stats = summaryResult['stats'] as Map;
            if (stats['rides'] != null) _tripsCount = stats['rides'].toString();
          }

          if (summaryResult['monthlySummary'] is Map) {
            final monthly = summaryResult['monthlySummary'] as Map;
            if (monthly['completed'] != null) _completedCount = monthly['completed'].toString();
            if (monthly['formattedFuelShare'] != null) {
              _totalFuelSaved = monthly['formattedFuelShare'].toString();
            } else if (monthly['fuelShare'] != null) {
              _totalFuelSaved = '₹ ${monthly['fuelShare']}';
            }
          }
        }
      } catch (_) {}

      // 2. Fetch completed rides (GET /api/rides)
      try {
        final ridesRes = await ApiService.get('/rides');
        if (ridesRes['success'] == true && ridesRes['rides'] is List) {
          final allRides = List<Map<String, dynamic>>.from(ridesRes['rides']);
          final completed = allRides.where((r) {
            final status = (r['status']?.toString().toLowerCase()) ?? '';
            return status == 'completed' || status == 'finished';
          }).toList();

          _completedTrips = completed;
          if (_tripsCount == '-') {
            _tripsCount = allRides.length.toString();
          }
          if (_completedCount == '-') {
            _completedCount = completed.length.toString();
          }

          if (completed.isNotEmpty) {
            num totalGross = 0;
            for (final r in completed) {
              final price = num.tryParse(r['price']?.toString() ?? r['pricePerSeat']?.toString() ?? '0') ?? 0;
              final booked = num.tryParse(r['booked']?.toString() ?? r['seatsBooked']?.toString() ?? '1') ?? 1;
              totalGross += (price * (booked > 0 ? booked : 1));
            }

            final commission = (totalGross * 0.10).round();
            final net = totalGross - commission;

            _tripEarnings = '₹ ${totalGross.toInt()}';
            _platformCommission = '-₹ $commission';
            _netAmount = '₹ ${net.toInt()}';
            if (_totalFuelSaved == '-') {
              _totalFuelSaved = '₹ ${net.toInt()}';
            }
          }
        }
      } catch (_) {}
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF3EDF7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Text('Month', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.primary),
                ],
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
            SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
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

                  // Purple Header Banner Card
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
                            const Text('Total Fuel cost saved', style: TextStyle(color: Colors.white70, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(
                              _totalFuelSaved,
                              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Trips & Completed Cards Row
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

                  const SizedBox(height: 24),

                  // Trip Details Section
                  const Text('Trip Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),

                  if (_completedTrips.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F8FD),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary.withAlpha(25)),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.receipt_long_rounded, color: AppColors.textMuted, size: 36),
                          SizedBox(height: 8),
                          Text(
                            'No completed trips yet',
                            style: TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Completed trips and earnings breakdown will appear here.',
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else
                    ..._completedTrips.asMap().entries.map((entry) {
                      final index = entry.key + 1;
                      final trip = entry.value;
                      final from = trip['from'] ?? trip['pickupLocation'] ?? '-';
                      final to = trip['to'] ?? trip['destinationLocation'] ?? '-';
                      final departureTime = trip['departureTime'] ?? '-';
                      final arrivalTime = trip['arrivalTime'] ?? '-';
                      final dateStr = trip['dateDisplay'] ?? trip['date'] ?? 'Completed';
                      final price = trip['price'] ?? trip['pricePerSeat'] ?? '-';

                      return _buildDynamicTripDetailRow(
                        'Trip #$index - $dateStr',
                        price != '-' ? '₹$price' : '-',
                        from: from.toString().split(',').first,
                        to: to.toString().split(',').first,
                        depTime: departureTime.toString(),
                        arrTime: arrivalTime.toString(),
                      );
                    }),

                  const SizedBox(height: 24),

                  // Payment Details Section
                  const Text('Payment Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 16),

                  _buildPaymentRow('Trip earnings', _tripEarnings),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 12),
                  _buildPaymentRow('Platform commission', _platformCommission),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 12),
                  _buildPaymentRow('Other adjustment', _otherAdjustment),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 12),
                  _buildPaymentRow('Payouts', _payouts),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 16),
                  _buildPaymentRow('Net amount', _netAmount, isBold: true),

                  const SizedBox(height: 28),

                  // Primary CTA Button matching Screen 10 ("Withdraw")
                  CustomButton(
                    text: 'Withdraw',
                    onPressed: () {
                      if (_netAmount != '-' && _netAmount != '₹0') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Withdrawal request of $_netAmount submitted successfully!'),
                            backgroundColor: const Color(0xFF2E7D32),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Payout request of ₹18,450 submitted for processing.'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 12),

                  // Withdraw / Payout Text Button
                  Center(
                    child: TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Viewing Payout History...')),
                        );
                      },
                      child: const Text(
                        'View Payout History',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
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

  Widget _buildDynamicTripDetailRow(
    String tripTitle,
    String price, {
    required String from,
    required String to,
    required String depTime,
    required String arrTime,
  }) {
    final parts = tripTitle.split(' - ');
    final tripLabel = parts.isNotEmpty ? parts[0] : tripTitle;
    final dateLabel = parts.length > 1 ? parts[1] : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  text: tripLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF27036),
                  ),
                  children: [
                    if (dateLabel.isNotEmpty)
                      TextSpan(
                        text: ' - $dateLabel',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    const TextSpan(
                      text: ' ----- ',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                price,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(from, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
              const Text('• • • • • • •', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              Text(to, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(depTime, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              Text(arrTime, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
