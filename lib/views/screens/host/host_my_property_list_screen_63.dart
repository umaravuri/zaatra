import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/host_service.dart';
import '../../widgets/custom_image_placeholder.dart';
import 'host_add_property_step1_71.dart';

class HostMyPropertyListScreen extends StatefulWidget {
  const HostMyPropertyListScreen({Key? key}) : super(key: key);

  @override
  State<HostMyPropertyListScreen> createState() => _HostMyPropertyListScreenState();
}

class _HostMyPropertyListScreenState extends State<HostMyPropertyListScreen> {
  bool _isLoading = true;
  List<dynamic> _properties = [];

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    setState(() => _isLoading = true);
    try {
      final list = await HostService.getHostProperties();
      if (mounted) {
        setState(() {
          _properties = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showQuickEditModal(Map<String, dynamic> property) {
    final propertyId = (property['_id'] ?? property['id'] ?? property['propertyId'] ?? '').toString();
    final currentTitle = (property['propertyName'] ?? property['title'] ?? 'Property').toString();
    final propDetails = property['propertyDetails'] is Map ? Map<String, dynamic>.from(property['propertyDetails']) : <String, dynamic>{};

    int eventCap = (propDetails['dayEventCapacity'] ?? propDetails['eventCapacity'] ?? 100) is num
        ? (propDetails['dayEventCapacity'] ?? propDetails['eventCapacity'] ?? 100).toInt()
        : 100;
    int parkingCap = (propDetails['parkingCapacity'] ?? 10) is num
        ? (propDetails['parkingCapacity'] ?? 10).toInt()
        : 10;
    double price = (property['pricePerNight'] ?? property['price'] ?? 4500) is num
        ? (property['pricePerNight'] ?? property['price'] ?? 4500).toDouble()
        : 4500.0;

    final priceController = TextEditingController(text: price.toStringAsFixed(0));
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Update Property Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            const SizedBox(height: 2),
                            Text(currentTitle, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Price per night
                  const Text('Price per Night (₹)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter price in INR',
                      prefixIcon: const Icon(Icons.currency_rupee_rounded, size: 20, color: AppColors.primary),
                      filled: true,
                      fillColor: const Color(0xFFF9F9FB),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Event Capacity Counter
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Day Event Capacity', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          Text('Max guests for parties/lawns', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary),
                            onPressed: () {
                              if (eventCap > 25) {
                                setModalState(() => eventCap -= 25);
                              }
                            },
                          ),
                          Text('$eventCap', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                            onPressed: () {
                              setModalState(() => eventCap += 25);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Parking Capacity Counter
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Vehicle Parking Capacity', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          Text('Number of designated car spots', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary),
                            onPressed: () {
                              if (parkingCap > 1) {
                                setModalState(() => parkingCap -= 1);
                              }
                            },
                          ),
                          Text('$parkingCap', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                            onPressed: () {
                              setModalState(() => parkingCap += 1);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Save Button (calls PUT /api/properties/:id)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: isSaving
                          ? null
                          : () async {
                              if (propertyId.isEmpty) {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Property ID not found for update.'), backgroundColor: Colors.red),
                                );
                                return;
                              }

                              setModalState(() => isSaving = true);
                              final parsedPrice = double.tryParse(priceController.text.trim()) ?? price;

                              final updatePayload = {
                                'pricePerNight': parsedPrice,
                                'price': parsedPrice,
                                'propertyDetails': {
                                  ...propDetails,
                                  'dayEventCapacity': eventCap,
                                  'parkingCapacity': parkingCap,
                                  'vehicleParkingCapacity': '$parkingCap Cars',
                                },
                              };

                              final messenger = ScaffoldMessenger.of(context);
                              final res = await HostService.updateProperty(propertyId, updatePayload);
                              setModalState(() => isSaving = false);

                              if (!mounted) return;
                              Navigator.pop(ctx);

                              if (res['success'] == true) {
                                messenger.showSnackBar(
                                  const SnackBar(content: Text('Property updated successfully!'), backgroundColor: Colors.green),
                                );
                                _loadProperties();
                              } else {
                                messenger.showSnackBar(
                                  SnackBar(content: Text(res['message'] ?? 'Failed to update property.'), backgroundColor: Colors.orange),
                                );
                              }
                            },
                      child: isSaving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Save & Update Property', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Properties',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
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
            Column(
              children: [
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                      : _properties.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.villa_outlined, size: 64, color: AppColors.textMuted.withValues(alpha: 0.5)),
                                  const SizedBox(height: 12),
                                  const Text('No properties listed yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                  const SizedBox(height: 4),
                                  const Text('Tap below to add your first property listing', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              color: AppColors.primary,
                              onRefresh: _loadProperties,
                              child: ListView.separated(
                                padding: const EdgeInsets.all(20.0),
                                itemCount: _properties.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 14),
                                itemBuilder: (context, index) {
                                  final prop = _properties[index];
                                  final title = (prop['propertyName'] ?? prop['title'] ?? 'Zaatra Property').toString();
                                  final type = (prop['propertyType'] ?? prop['type'] ?? 'Stay').toString();
                                  final priceNum = prop['pricePerNight'] ?? prop['price'] ?? 4500;
                                  final status = (prop['status'] ?? 'pending').toString().toLowerCase();
                                  final isApproved = status == 'approved' || status == 'active' || prop['isApproved'] == true;

                                  final propDetails = prop['propertyDetails'] is Map ? prop['propertyDetails'] as Map : {};
                                  final beds = propDetails['bedrooms'] ?? prop['bedrooms'] ?? 1;
                                  final parking = propDetails['parkingCapacity'] ?? 4;
                                  final eventCap = propDetails['dayEventCapacity'] ?? propDetails['eventCapacity'];

                                  final subtitle = eventCap != null
                                      ? '$type • $beds Bed • Event: $eventCap • $parking Cars'
                                      : '$type • $beds Bed • $parking Cars Parking';

                                  return Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(color: AppColors.border),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.03),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        const CustomImagePlaceholder(
                                          width: 80,
                                          height: 70,
                                          icon: Icons.maps_home_work_rounded,
                                          borderRadius: BorderRadius.all(Radius.circular(12)),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                              const SizedBox(height: 3),
                                              Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                              const SizedBox(height: 4),
                                              Text('₹$priceNum / night', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: isApproved ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                isApproved ? 'Active' : 'Pending',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: isApproved ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            InkWell(
                                              onTap: () => _showQuickEditModal(prop is Map<String, dynamic> ? prop : Map<String, dynamic>.from(prop)),
                                              borderRadius: BorderRadius.circular(8),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary.withValues(alpha: 0.1),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.edit, size: 13, color: AppColors.primary),
                                                    SizedBox(width: 4),
                                                    Text('Edit', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const HostAddPropertyStep1Screen()),
                        );
                        _loadProperties();
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_rounded, color: Colors.white, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Add New Property',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
