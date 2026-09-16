import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'driver_vehicle_info_screen_22.dart';

class DriverDocumentUploadScreen extends StatefulWidget {
  final String role;
  final Map<String, dynamic>? driverData;

  const DriverDocumentUploadScreen({
    super.key,
    this.role = 'Driver',
    this.driverData,
  });

  @override
  State<DriverDocumentUploadScreen> createState() => _DriverDocumentUploadScreenState();
}

class _DriverDocumentUploadScreenState extends State<DriverDocumentUploadScreen> {
  final _licenseNumberController = TextEditingController();
  
  bool _licenseFrontUploaded = false;
  String _dlFileName = '';
  String _dlFileSize = '';

  bool _rcUploaded = false;
  String _rcFileName = '';
  String _rcFileSize = '';

  bool _pollutionUploaded = false;
  String _pollutionFileName = '';
  String _pollutionFileSize = '';

  bool _photoUploaded = false;
  String _photoFileName = '';
  String _photoFileSize = '';

  Future<void> _pickDocument(String docKey) async {
    try {
      final isPdfDoc = docKey == 'dl' || docKey == 'rc' || docKey == 'pollution';
      final allowedExtensions = isPdfDoc ? ['pdf'] : ['png', 'jpg', 'jpeg'];
      final docLabel = docKey == 'dl'
          ? "Driver's License"
          : docKey == 'rc'
              ? "Vehicle Registration (RC)"
              : docKey == 'pollution'
                  ? "Pollution Certificate"
                  : "Driver's Photo";

      String? fileName;
      int? fileBytesLength;

      try {
        final FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: allowedExtensions,
          allowMultiple: false,
          withData: kIsWeb,
        );

        if (result != null && result.files.isNotEmpty) {
          final file = result.files.first;
          fileName = file.name;
          fileBytesLength = file.size;
        }
      } catch (e) {
        // Fallback: If FilePicker is not yet initialized in current web session
        if (!isPdfDoc) {
          final XFile? img = await ImagePicker().pickImage(source: ImageSource.gallery);
          if (img != null) {
            fileName = img.name;
            fileBytesLength = await img.length();
          }
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please restart your Flutter app in Chrome to register the new file picker plugin.'),
              backgroundColor: Colors.orangeAccent,
              duration: Duration(seconds: 4),
            ),
          );
          return;
        }
      }

      if (fileName != null && fileBytesLength != null) {
        final extension = (fileName.contains('.') ? fileName.split('.').last : '').toLowerCase();

        // 🛡️ STRICT VALIDATION 1: File Extension Check
        if (isPdfDoc) {
          if (extension != 'pdf') {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Invalid format! $docLabel ONLY accepts PDF (.pdf) files. Selected: .$extension'),
                backgroundColor: Colors.redAccent,
                duration: const Duration(seconds: 4),
              ),
            );
            return;
          }
        } else {
          if (!['png', 'jpg', 'jpeg'].contains(extension)) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Invalid format! $docLabel ONLY accepts PNG or JPEG/JPG images. Selected: .$extension'),
                backgroundColor: Colors.redAccent,
                duration: const Duration(seconds: 4),
              ),
            );
            return;
          }
        }

        // 🛡️ STRICT VALIDATION 2: File Size Limit Check
        // DL, RC, Pollution: Max 5MB (5 * 1024 * 1024 bytes)
        // Photo: Max 3MB (3 * 1024 * 1024 bytes)
        final maxSizeBytes = isPdfDoc ? (5 * 1024 * 1024) : (3 * 1024 * 1024);
        final maxSizeLabel = isPdfDoc ? '5MB' : '3MB';

        if (fileBytesLength > maxSizeBytes) {
          final uploadedMb = (fileBytesLength / (1024 * 1024)).toStringAsFixed(2);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File size exceeds $maxSizeLabel limit! (Selected file is $uploadedMb MB). Please select a smaller file.'),
              backgroundColor: Colors.redAccent,
              duration: const Duration(seconds: 4),
            ),
          );
          return;
        }

        final sizeKb = (fileBytesLength / 1024).toStringAsFixed(1);
        final sizeStr = fileBytesLength > 1024 * 1024
            ? '${(fileBytesLength / (1024 * 1024)).toStringAsFixed(1)} MB'
            : '$sizeKb KB';

        setState(() {
          if (docKey == 'dl') {
            _dlFileName = fileName!;
            _dlFileSize = sizeStr;
            _licenseFrontUploaded = true;
          } else if (docKey == 'rc') {
            _rcFileName = fileName!;
            _rcFileSize = sizeStr;
            _rcUploaded = true;
          } else if (docKey == 'pollution') {
            _pollutionFileName = fileName!;
            _pollutionFileSize = sizeStr;
            _pollutionUploaded = true;
          } else if (docKey == 'photo') {
            _photoFileName = fileName!;
            _photoFileSize = sizeStr;
            _photoUploaded = true;
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$docLabel uploaded successfully! ($sizeStr)'),
              backgroundColor: const Color(0xFF2E7D32),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File selection error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _nextStep() {
    final licenseNumber = _licenseNumberController.text.trim();

    if (licenseNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your Driving License Number.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_licenseFrontUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload your Driver\'s License (PDF < 5MB).'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_rcUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload your Vehicle Registration (RC) document (PDF < 5MB).'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_pollutionUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload your Pollution Certificate (PDF < 5MB).'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_photoUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload your Driver\'s Photo (PNG/JPG < 3MB).'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final updatedData = Map<String, dynamic>.from(widget.driverData ?? {});
    updatedData['drivingLicenseNumber'] = licenseNumber;
    updatedData['drivingLicenseDocument'] = '/uploads/$_dlFileName';
    updatedData['rcDocument'] = '/uploads/$_rcFileName';
    updatedData['pollutionDocument'] = '/uploads/$_pollutionFileName';
    updatedData['driverPhoto'] = '/uploads/$_photoFileName';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DriverVehicleInfoScreen(
          role: widget.role,
          driverData: updatedData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
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
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress Bar (Step 2 of 3)
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: const LinearProgressIndicator(
                            value: 0.66,
                            minHeight: 6,
                            backgroundColor: AppColors.border,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Step 2 of 3',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Screen 33 Header matching Figma
                  const Text(
                    'Upload Document',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Please upload requirement documents',
                    style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),

                  const SizedBox(height: 24),

                  // License Number Field
                  CustomTextField(
                    label: "Driving License Number",
                    hint: "RJ-142023004561",
                    controller: _licenseNumberController,
                    prefixIcon: Icons.badge_outlined,
                  ),

                  const SizedBox(height: 20),

                  // Document 1: Driver's License (PDF under 5MB)
                  _buildFigmaDocumentCard(
                    title: "Driver's license",
                    subtitle: _licenseFrontUploaded
                        ? '$_dlFileName ($_dlFileSize)'
                        : "Tap to upload license (PDF under 5MB)",
                    badgeText: "PDF < 5MB",
                    icon: Icons.drive_eta_rounded,
                    isUploaded: _licenseFrontUploaded,
                    onTap: () => _pickDocument('dl'),
                  ),

                  const SizedBox(height: 14),

                  // Document 2: Vehicle Registration (RC) (PDF under 5MB)
                  _buildFigmaDocumentCard(
                    title: "Vehicle Registration",
                    subtitle: _rcUploaded
                        ? '$_rcFileName ($_rcFileSize)'
                        : "Tap to upload RC (PDF under 5MB)",
                    badgeText: "PDF < 5MB",
                    icon: Icons.directions_car_rounded,
                    isUploaded: _rcUploaded,
                    onTap: () => _pickDocument('rc'),
                  ),

                  const SizedBox(height: 14),

                  // Document 3: Pollution Certificate (PDF under 5MB)
                  _buildFigmaDocumentCard(
                    title: "Pollution Certificate",
                    subtitle: _pollutionUploaded
                        ? '$_pollutionFileName ($_pollutionFileSize)'
                        : "Tap to upload (PDF under 5MB)",
                    badgeText: "PDF < 5MB",
                    icon: Icons.eco_rounded,
                    isUploaded: _pollutionUploaded,
                    onTap: () => _pickDocument('pollution'),
                  ),

                  const SizedBox(height: 14),

                  // Document 4: Driver's Photo (JPEG and PNG under 3MB)
                  _buildFigmaDocumentCard(
                    title: "Driver's Photo",
                    subtitle: _photoUploaded
                        ? '$_photoFileName ($_photoFileSize)'
                        : "Tap to upload photo (PNG/JPEG under 3MB)",
                    badgeText: "PNG/JPG < 3MB",
                    icon: Icons.portrait_rounded,
                    isUploaded: _photoUploaded,
                    onTap: () => _pickDocument('photo'),
                  ),

                  const SizedBox(height: 36),

                  // Continue CTA Button matching Screen 33
                  CustomButton(
                    text: 'Continue',
                    onPressed: _nextStep,
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFigmaDocumentCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isUploaded,
    required VoidCallback onTap,
    String? badgeText,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUploaded ? AppColors.primary.withAlpha(80) : AppColors.border,
            width: isUploaded ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF3EDF7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (badgeText != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(25),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badgeText,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isUploaded ? const Color(0xFF2E7D32) : AppColors.textSecondary,
                      fontWeight: isUploaded ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isUploaded ? const Color(0xFFE8F5E9) : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isUploaded ? const Color(0xFF4CAF50) : AppColors.border,
                ),
              ),
              child: Icon(
                isUploaded ? Icons.check_rounded : Icons.upload_file_rounded,
                color: isUploaded ? const Color(0xFF2E7D32) : AppColors.textSecondary,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
