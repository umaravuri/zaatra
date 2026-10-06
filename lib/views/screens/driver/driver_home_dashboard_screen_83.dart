import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/api_service.dart';
import '../../../services/driver_service.dart';
import 'driver_booking_requests_screen_99.dart';
import 'driver_earnings_history_screen_82.dart';
import 'driver_my_ride_screen_30.dart';
import 'driver_profile_settings_screen_87.dart';
import 'driver_ride_management_screen_98.dart';
import 'driver_ride_start_details_screen_88.dart';
import 'driver_support_help_screen_86.dart';
import 'driver_trip_shared_screen_94.dart';

class DriverHomeDashboardScreen83 extends StatefulWidget {
  final String? driverName;

  const DriverHomeDashboardScreen83({
    super.key,
    this.driverName,
  });

  @override
  State<DriverHomeDashboardScreen83> createState() => _DriverHomeDashboardScreen83State();
}

class _DriverHomeDashboardScreen83State extends State<DriverHomeDashboardScreen83> {
  String _name = 'Driver';
  String _driverPhone = '';
  bool _isOnline = true;
  int _currentNavIndex = 0;

  // Profile Photo State (Fetched dynamically from GET APIs)
  String? _profileImageUrl;
  Uint8List? _profileImageBytes;

  // Dynamic Driver Statistics (defaults to '-' until loaded from API)
  String _ridesCount = '-';
  String _coTravelers = '-';
  String _totalKm = '-';
  String _rating = '-';

  // Dynamic Summaries (defaults to '-' until loaded from API)
  String _todayComplete = '-';
  String _todayUpcoming = '-';
  String _todayFuelShare = '-';
  String _monthlyCompleted = '-';
  String _monthlyFuelShare = '-';

  // Dynamic Upcoming Ride State
  String _upcomingOrigin = '-';
  String _upcomingOriginTime = '-';
  String _upcomingDestination = '-';
  String _upcomingDestinationTime = '-';
  String _upcomingDateStr = '-';
  String _upcomingRideId = '';
  bool _hasUpcomingRide = false;

  @override
  void initState() {
    super.initState();
    _loadDriverProfile();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _formatImageUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    final cleanBase = ApiService.baseUrl.replaceAll('/api', '');
    final cleanPath = url.startsWith('/') ? url : '/$url';
    return '$cleanBase$cleanPath';
  }

  void _parseAndSetAvatar(dynamic photoData) {
    if (photoData == null) return;
    final photoStr = photoData.toString().trim();
    if (photoStr.isEmpty) return;

    if (photoStr.startsWith('data:image') || photoStr.length > 300) {
      try {
        final base64Content = photoStr.contains(',') ? photoStr.split(',').last : photoStr;
        _profileImageBytes = base64Decode(base64Content);
        _profileImageUrl = null;
        return;
      } catch (_) {}
    }
    _profileImageUrl = photoStr;
  }

  Future<void> _loadDriverProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentPhone = prefs.getString('currentPhone') ?? '';
      final cleanDigits = currentPhone.replaceAll(RegExp(r'[^0-9]'), '');
      _driverPhone = currentPhone;

      // Load persistent online toggle state
      if (prefs.containsKey('driver_online_state_$cleanDigits')) {
        _isOnline = prefs.getBool('driver_online_state_$cleanDigits') ?? true;
      }

      // Load name fallback
      final savedName = prefs.getString('user_name_$cleanDigits') ?? prefs.getString('currentUserName') ?? '';
      if (widget.driverName != null && widget.driverName!.isNotEmpty) {
        _name = widget.driverName!;
      } else if (savedName.isNotEmpty) {
        _name = savedName;
      }

      // Load saved avatar cache
      final savedAvatarBase64 = prefs.getString('driver_avatar_base64_$cleanDigits') ??
          prefs.getString('user_avatar_base64_$cleanDigits');
      if (savedAvatarBase64 != null && savedAvatarBase64.isNotEmpty) {
        try {
          _profileImageBytes = base64Decode(savedAvatarBase64);
        } catch (_) {}
      }
      final savedPhoto = prefs.getString('driver_photo_$cleanDigits') ??
          prefs.getString('profile_image_$cleanDigits') ??
          prefs.getString('current_user_avatar');
      if (savedPhoto != null && savedPhoto.isNotEmpty && _profileImageBytes == null) {
        _profileImageUrl = savedPhoto;
      }

      // 🚀 1. Fetch live Dashboard Summary API (GET /api/drivers/dashboard-summary)
      final summaryResult = await DriverService.getDashboardSummary();
      if (summaryResult['success'] == true) {
        // Cache driverId if provided
        final dynamic fetchedDriverId = summaryResult['driverId'] ??
            (summaryResult['driverProfile'] is Map ? summaryResult['driverProfile']['driverId'] ?? summaryResult['driverProfile']['id'] : null);
        if (fetchedDriverId != null && fetchedDriverId.toString().isNotEmpty) {
          await prefs.setString('driverId', fetchedDriverId.toString());
          if (cleanDigits.isNotEmpty) {
            await prefs.setString('driver_id_$cleanDigits', fetchedDriverId.toString());
          }
        }

        // Driver Profile & Avatar
        if (summaryResult['driverProfile'] is Map) {
          final profile = summaryResult['driverProfile'] as Map;
          if (profile['name'] != null && profile['name'].toString().isNotEmpty) {
            _name = profile['name'].toString();
          }
          if (profile['isOnline'] != null) {
            _isOnline = profile['isOnline'] == true;
          }
          final photo = profile['driverPhoto'] ??
              profile['profilePicture'] ??
              profile['avatar'] ??
              profile['photo'] ??
              profile['profilePhoto'] ??
              profile['image'] ??
              profile['profileImage'];
          if (photo != null) {
            _parseAndSetAvatar(photo);
          }
        }

        // Stats (Rides, Co-Travelers, KM, Ratings)
        if (summaryResult['stats'] is Map) {
          final stats = summaryResult['stats'] as Map;
          if (stats['rides'] != null) _ridesCount = stats['rides'].toString();
          if (stats['coTravelers'] != null) _coTravelers = stats['coTravelers'].toString();
          if (stats['km'] != null) _totalKm = stats['km'].toString();
          if (stats['ratings'] != null) _rating = stats['ratings'].toString();
        }

        // Upcoming Ride
        if (summaryResult['upcomingRide'] is Map) {
          final upcoming = summaryResult['upcomingRide'] as Map;
          final bool hasRide = upcoming['hasUpcomingRide'] == true ||
              (upcoming['pickupLocation'] != null && upcoming['destinationLocation'] != null) ||
              (upcoming['origin'] != null && upcoming['destination'] != null);

          if (hasRide) {
            _upcomingOrigin = upcoming['origin']?.toString() ??
                upcoming['pickupLocation']?.toString() ??
                upcoming['from']?.toString() ??
                '-';
            _upcomingOriginTime = upcoming['departureTime']?.toString() ?? '-';
            _upcomingDestination = upcoming['destination']?.toString() ??
                upcoming['destinationLocation']?.toString() ??
                upcoming['to']?.toString() ??
                '-';
            _upcomingDestinationTime = upcoming['arrivalTime']?.toString() ?? '-';
            _upcomingDateStr = upcoming['dateDisplay']?.toString() ?? upcoming['date']?.toString() ?? '-';
            _upcomingRideId = upcoming['rideId']?.toString() ?? '';
            _hasUpcomingRide = true;
          } else {
            _hasUpcomingRide = false;
          }
        }

        // Today's Summary
        if (summaryResult['todaySummary'] is Map) {
          final today = summaryResult['todaySummary'] as Map;
          if (today['complete'] != null) _todayComplete = today['complete'].toString();
          if (today['upcoming'] != null) _todayUpcoming = today['upcoming'].toString();
          if (today['formattedFuelShare'] != null) {
            _todayFuelShare = today['formattedFuelShare'].toString();
          } else if (today['fuelShare'] != null) {
            _todayFuelShare = today['fuelShare'].toString();
          }
        }

        // Monthly Summary
        if (summaryResult['monthlySummary'] is Map) {
          final monthly = summaryResult['monthlySummary'] as Map;
          if (monthly['completed'] != null) _monthlyCompleted = monthly['completed'].toString();
          if (monthly['formattedFuelShare'] != null) {
            _monthlyFuelShare = monthly['formattedFuelShare'].toString();
          } else if (monthly['fuelShare'] != null) {
            _monthlyFuelShare = monthly['fuelShare'].toString();
          }
        }
      }

      // 🚀 2. Fetch live Personal Info (GET /api/drivers/profile/personal) for latest photo
      try {
        final personalRes = await DriverService.getPersonalInfo(phone: currentPhone);
        if (personalRes['success'] == true) {
          final p = personalRes['personalInformation'] ?? personalRes['data'] ?? personalRes;
          if (p is Map) {
            if (p['fullName'] != null && p['fullName'].toString().isNotEmpty) {
              _name = p['fullName'].toString();
            }
            final pPhoto = p['driverPhoto'] ??
                p['profilePicture'] ??
                p['avatar'] ??
                p['photo'] ??
                p['image'] ??
                p['profileImage'];
            if (pPhoto != null) {
              _parseAndSetAvatar(pPhoto);
            }
          }
        }
      } catch (_) {}

      // 🚀 3. Check Upcoming Rides list if upcoming ride was not in summary
      if (!_hasUpcomingRide) {
        final upcomingListResult = await DriverService.getUpcomingRides();
        if (upcomingListResult['success'] == true &&
            upcomingListResult['upcomingRides'] is List &&
            (upcomingListResult['upcomingRides'] as List).isNotEmpty) {
          final firstRide = (upcomingListResult['upcomingRides'] as List).first as Map;
          _upcomingOrigin = firstRide['from']?.toString() ?? firstRide['origin']?.toString() ?? '-';
          _upcomingDestination = firstRide['to']?.toString() ?? firstRide['destination']?.toString() ?? '-';
          _upcomingOriginTime = firstRide['departureTime']?.toString() ?? '-';
          _upcomingDestinationTime = firstRide['arrivalTime']?.toString() ?? '-';
          _upcomingRideId = firstRide['rideId']?.toString() ?? '';
          _upcomingDateStr = firstRide['date']?.toString() ?? '-';
          _hasUpcomingRide = true;
        }
      }

      // 🚀 4. Fallback to Driver Approval profile for name & photo
      if (cleanDigits.isNotEmpty && summaryResult['success'] != true) {
        final statusResult = await DriverService.getDriverApprovalStatus(phone: cleanDigits);
        if (statusResult['success'] == true && statusResult['driver'] != null) {
          final driver = statusResult['driver'];
          if (driver['name'] != null && driver['name'].toString().isNotEmpty) {
            _name = driver['name'].toString();
          }
          final dPhoto = driver['driverPhoto'] ??
              driver['profilePicture'] ??
              driver['avatar'] ??
              driver['photo'] ??
              driver['image'];
          if (dPhoto != null && _profileImageUrl == null && _profileImageBytes == null) {
            _parseAndSetAvatar(dPhoto);
          }
        }
      }
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _toggleOnlineStatus() async {
    final targetState = !_isOnline;
    setState(() {
      _isOnline = targetState;
    });

    // 🚀 Call Driver Availability Switch API (PATCH/POST /api/drivers/availability)
    final switchResult = await DriverService.switchAvailability(
      isOnline: targetState,
      phone: _driverPhone,
    );

    if (switchResult['success'] == true) {
      if (switchResult['isOnline'] != null) {
        setState(() {
          _isOnline = switchResult['isOnline'] == true;
        });
      } else if (switchResult['availabilityStatus'] != null) {
        setState(() {
          _isOnline = switchResult['availabilityStatus'].toString().toUpperCase() == 'ON';
        });
      }
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final cleanDigits = _driverPhone.replaceAll(RegExp(r'[^0-9]'), '');
      await prefs.setBool('driver_online_state_$cleanDigits', _isOnline);
    } catch (_) {}

    if (mounted) {
      final bannerMsg = switchResult['message']?.toString() ??
          (_isOnline ? 'You are now Online (ON)' : 'You are now Offline (OFF)');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bannerMsg),
          backgroundColor: _isOnline ? const Color(0xFF2E7D32) : Colors.grey[800],
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _onBottomNavTapped(int index) {
    if (index == _currentNavIndex) return;

    if (index == 1) {
      // My Ride / Ride Management
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DriverRideManagementScreen()),
      );
    } else if (index == 2) {
      // Earnings
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DriverEarningsHistoryScreen()),
      );
    } else if (index == 3) {
      // Profile
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DriverProfileSettingsScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9FD),
      body: Stack(
        children: [
          // Scrollable Dashboard Body with Pull-To-Refresh
          Positioned.fill(
            child: RefreshIndicator(
              onRefresh: _loadDriverProfile,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Gradient Header with Profile & Online Toggle
                    _buildHeaderSection(),

                    const SizedBox(height: 12),

                    // Floating Metrics Card (Rides, Co-travelers, KM, Ratings)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: _buildTopMetricsCard(),
                    ),

                    const SizedBox(height: 24),

                    // Categories (My Ride, Supports, Notification, Earnings)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Categories',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _buildCategoriesRow(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Upcoming Ride Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Upcoming Ride',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _buildUpcomingRideCard(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Today Summary
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Today summery',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _buildTodaySummaryRow(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Monthly Summary
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Monthly summery',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _buildMonthlySummaryRow(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Navigation Bar with Floating Action Center Button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomNavigationBar(),
          ),
        ],
      ),
    );
  }

  // 1. Purple Header with Dynamic Profile Avatar, Dynamic Greeting & Online Switch
  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF5B3AA8),
            Color(0xFF6750A4),
            Color(0xFF7A62B8),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          // Profile Avatar Circle (Tapable to Settings / Profile)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DriverProfileSettingsScreen()),
              ).then((_) => _loadDriverProfile());
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: _buildAvatarImage(),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Dynamic Greeting & Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getGreeting(),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFE8DDFF),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Online / Offline Toggle Pill matching Screen 83
          GestureDetector(
            onTap: _toggleOnlineStatus,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: _isOnline ? const Color(0xFF66BB6A) : const Color(0xFF9E9E9E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 6, right: 4),
                    child: Text(
                      _isOnline ? 'ON' : 'OFF',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarImage() {
    if (_profileImageBytes != null) {
      return Image.memory(
        _profileImageBytes!,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildAvatarFallback(),
      );
    }

    if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty) {
      return Image.network(
        _formatImageUrl(_profileImageUrl!),
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildAvatarFallback(),
      );
    }

    return _buildAvatarFallback();
  }

  Widget _buildAvatarFallback() {
    final initials = _getInitials(_name);
    return Container(
      width: 48,
      height: 48,
      color: const Color(0xFFF3EDF7),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty || name == 'Driver') return 'D';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  // 2. Dynamic Top Metric Statistics Card
  Widget _buildTopMetricsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildMetricColumn('Rides', _ridesCount),
          _buildVerticalDivider(),
          _buildMetricColumn('Co-travelers', _coTravelers),
          _buildVerticalDivider(),
          _buildMetricColumn('KM', _totalKm),
          _buildVerticalDivider(),
          _buildMetricColumn('Ratings', _rating),
        ],
      ),
    );
  }

  Widget _buildMetricColumn(String label, String value) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 32,
      width: 1,
      color: const Color(0xFFEEEEEE),
    );
  }

  // 3. 4 Category Quick Action Buttons
  Widget _buildCategoriesRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildCategoryCard(
          label: 'My Ride',
          icon: Icons.directions_car_rounded,
          iconColor: const Color(0xFF1976D2),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DriverRideManagementScreen()),
            );
          },
        ),
        _buildCategoryCard(
          label: 'Supports',
          icon: Icons.headset_mic_rounded,
          iconColor: const Color(0xFF6750A4),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DriverSupportHelpScreen()),
            );
          },
        ),
        _buildCategoryCard(
          label: 'Notification',
          icon: Icons.notifications_rounded,
          iconColor: const Color(0xFF6750A4),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DriverBookingRequestsScreen()),
            );
          },
        ),
        _buildCategoryCard(
          label: 'Earnings',
          icon: Icons.monetization_on_rounded,
          iconColor: const Color(0xFFFFA000),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DriverEarningsHistoryScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategoryCard({
    required String label,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: const Color(0xFFF3EDF7),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // 4. Upcoming Ride Card matching Screen 83
  Widget _buildUpcomingRideCard() {
    if (!_hasUpcomingRide) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFF0EBF8)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFF3EDF7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.directions_car_filled_rounded,
                color: AppColors.primary,
                size: 26,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'No Upcoming Rides Scheduled',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'You have no active or scheduled rides at the moment.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DriverMyRideScreen()),
                );
              },
              icon: const Icon(Icons.add_rounded, size: 18, color: AppColors.primary),
              label: const Text(
                'Post New Ride',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary, width: 1.2),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF0EBF8)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Date Badge Pill
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF8FD),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                _upcomingDateStr,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Route with dotted line
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Origin
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _upcomingOrigin.split(',').first,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _upcomingOriginTime,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Center Dotted Line Indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Color(0xFF9E9E9E),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3.0),
                      child: Text(
                        '- - - -',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 11,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Color(0xFF9E9E9E),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),

              // Destination
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _upcomingDestination.split(',').first,
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _upcomingDestinationTime,
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DriverTripSharedScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                    side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'View & Share trip card',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DriverRideStartDetailsScreen(
                          rideId: _upcomingRideId,
                          origin: _upcomingOrigin,
                          destination: _upcomingDestination,
                          totalDistance: '$_totalKm KM',
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                    side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'View & Start Ride',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 5. Today Summary Row (Dynamic & Clickable)
  Widget _buildTodaySummaryRow() {
    return Row(
      children: [
        _buildSummaryCard(
          value: _todayComplete,
          label: 'Complete',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DriverRideManagementScreen(initialTabIndex: 2),
              ),
            );
          },
        ),
        const SizedBox(width: 10),
        _buildSummaryCard(
          value: _todayUpcoming,
          label: 'Upcoming',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DriverRideManagementScreen(initialTabIndex: 1),
              ),
            );
          },
        ),
        const SizedBox(width: 10),
        _buildSummaryCard(
          value: _todayFuelShare,
          label: 'Fuel Share',
          isHighlighted: true,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DriverEarningsHistoryScreen()),
            );
          },
        ),
      ],
    );
  }

  // 6. Monthly Summary Row (Dynamic & Clickable)
  Widget _buildMonthlySummaryRow() {
    return Row(
      children: [
        _buildSummaryCard(
          value: _monthlyCompleted,
          label: 'Completed',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DriverRideManagementScreen(initialTabIndex: 2),
              ),
            );
          },
        ),
        const SizedBox(width: 12),
        _buildSummaryCard(
          value: _monthlyFuelShare,
          label: 'Fuel Share',
          isHighlighted: true,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DriverEarningsHistoryScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String value,
    required String label,
    bool isHighlighted = false,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFF0EBF8)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isHighlighted ? const Color(0xFF5B3AA8) : AppColors.primary,
                    ),
                    maxLines: 1,
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 7. Bottom Navigation Bar with Center '+' Post-Ride Floating Action Button
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 1. Home
              _buildNavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isSelected: _currentNavIndex == 0,
                onTap: () => setState(() => _currentNavIndex = 0),
              ),

              // 2. My Ride
              _buildNavItem(
                icon: Icons.directions_car_rounded,
                label: 'My Ride',
                isSelected: false,
                onTap: () => _onBottomNavTapped(1),
              ),

              // 3. Center Floating '+' Post Ride Button
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DriverMyRideScreen()),
                  );
                },
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: Color(0xFF5B3AA8),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x665B3AA8),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),

              // 4. Earnings
              _buildNavItem(
                icon: Icons.currency_rupee_rounded,
                label: 'Earnings',
                isSelected: false,
                onTap: () => _onBottomNavTapped(2),
              ),

              // 5. Profile
              _buildNavItem(
                icon: Icons.person_outline_rounded,
                label: 'Profile',
                isSelected: false,
                onTap: () => _onBottomNavTapped(3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF5B3AA8) : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFF5B3AA8) : AppColors.textSecondary,
              ),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 14,
                height: 3,
                decoration: BoxDecoration(
                  color: const Color(0xFF5B3AA8),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

typedef DriverHomeDashboardScreen = DriverHomeDashboardScreen83;
