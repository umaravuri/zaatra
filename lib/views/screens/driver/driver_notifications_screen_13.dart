import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/driver_service.dart';

class DriverNotificationsScreen extends StatefulWidget {
  const DriverNotificationsScreen({super.key});

  @override
  State<DriverNotificationsScreen> createState() => _DriverNotificationsScreenState();
}

class _DriverNotificationsScreenState extends State<DriverNotificationsScreen> {
  String _selectedFilter = 'ALL';
  bool _isLoading = false;
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
    });

    final res = await DriverService.getDriverNotifications(filter: _selectedFilter);

    if (!mounted) return;

    final dynamic data = res['data'] ?? res['notifications'] ?? [];
    List<Map<String, dynamic>> loadedNotifications = [];

    if (data is List) {
      loadedNotifications = data.map((item) {
        if (item is Map<String, dynamic>) {
          return item;
        }
        return <String, dynamic>{
          'title': item.toString(),
          'subtitle': '',
          'time': 'Just now',
          'type': 'new',
        };
      }).toList();
    }

    setState(() {
      _notifications = loadedNotifications;
      _isLoading = false;
    });
  }

  void _onFilterChanged(String? val) {
    if (val == null || val == _selectedFilter) return;
    setState(() => _selectedFilter = val);
    _fetchNotifications();
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
          'Notification',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3EDF7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedFilter,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary, size: 18),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                    items: ['ALL', 'NEW', 'CONFIRMED', 'TRIP'].map((filter) {
                      return DropdownMenuItem<String>(
                        value: filter,
                        child: Text(filter),
                      );
                    }).toList(),
                    onChanged: _onFilterChanged,
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
            RefreshIndicator(
              onRefresh: _fetchNotifications,
              color: AppColors.primary,
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    )
                  : _notifications.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.22),
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF3EDF7),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.notifications_none_rounded,
                                      size: 48,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  const Text(
                                    'No notifications yet',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 40),
                                    child: Text(
                                      "You're all caught up! New ride bookings and updates will appear here.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(20.0),
                          itemCount: _notifications.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final notif = _notifications[index];
                            final title = notif['title']?.toString() ?? 'Notification';
                            final subtitle = notif['subtitle']?.toString() ?? notif['message']?.toString() ?? '';
                            final time = notif['time']?.toString() ?? notif['createdAt']?.toString() ?? 'Just now';
                            final type = notif['type']?.toString().toLowerCase() ?? 'new';
                            final isConfirmed = type.contains('confirm') || type.contains('accept');

                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isConfirmed ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isConfirmed ? Icons.check_circle_outline_rounded : Icons.call_made_rounded,
                                      color: isConfirmed ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                        ),
                                        if (subtitle.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            subtitle,
                                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Text(
                                    time,
                                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
