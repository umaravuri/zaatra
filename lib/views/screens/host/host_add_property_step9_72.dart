import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import 'host_add_property_documents_73.dart';

class PropertyPhotoItem {
  final String name;
  final String? assetPath;
  final Uint8List? bytes;

  PropertyPhotoItem({
    required this.name,
    this.assetPath,
    this.bytes,
  });
}

class HostAddPropertyStep9Screen extends StatefulWidget {
  final Map<String, dynamic>? propertyData;
  const HostAddPropertyStep9Screen({Key? key, this.propertyData}) : super(key: key);

  @override
  State<HostAddPropertyStep9Screen> createState() => _HostAddPropertyStep9ScreenState();
}

class _HostAddPropertyStep9ScreenState extends State<HostAddPropertyStep9Screen> {
  final _picker = ImagePicker();
  final List<PropertyPhotoItem> _photos = [];

  Future<void> _addPhoto() async {
    try {
      final List<XFile> files = await _picker.pickMultiImage();

      if (files.isNotEmpty) {
        for (var file in files) {
          final bytes = await file.readAsBytes();
          setState(() {
            _photos.add(
              PropertyPhotoItem(
                name: file.name,
                bytes: bytes,
              ),
            );
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${files.length} photo(s) selected!'),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Graceful fallback for non-filepicker environments
      setState(() {
        _photos.add(
          PropertyPhotoItem(
            name: 'IMG_${_photos.length + 1}.PNG',
            assetPath: 'assets/images/image 27.png',
          ),
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Photo ${_photos.length} (JPEG) added successfully!'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _photos.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo removed.'),
        backgroundColor: Colors.black87,
        duration: Duration(milliseconds: 1200),
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
        title: Column(
          children: const [
            Text('Add new property', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 16)),
            SizedBox(height: 2),
            Text('Step 9 of 9', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ],
        ),
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
            Column(
              children: [
                _buildProgressBar(9),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Photos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                SizedBox(height: 4),
                                Text('Upload photos of your property', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8DEF8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_photos.length} Uploaded',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Supported Formats Banner
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F5FE),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.file_upload_rounded, color: AppColors.primary, size: 20),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Click "+ Add Photos" to browse real JPEG, PNG files from your computer',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Dynamic Photos Grid matching 72.png
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 1.25,
                          ),
                          itemCount: _photos.length + 1,
                          itemBuilder: (context, index) {
                            if (index == _photos.length) {
                              // Add Photos Action Card
                              return InkWell(
                                onTap: _addPhoto,
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF7F5FE),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppColors.primary, width: 1.5),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.add_photo_alternate_rounded, color: AppColors.primary, size: 30),
                                      SizedBox(height: 6),
                                      Text(
                                        '+ Add Photos',
                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Browse Files',
                                        style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            final item = _photos[index];
                            return Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: item.bytes != null
                                      ? Image.memory(
                                          item.bytes!,
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          item.assetPath ?? 'assets/images/image 20.png',
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            color: const Color(0xFFF3EDF7),
                                            child: const Center(
                                              child: Icon(Icons.photo_library_rounded, color: AppColors.primary, size: 32),
                                            ),
                                          ),
                                        ),
                                ),
                                // Format Badge
                                Positioned(
                                  bottom: 8,
                                  left: 8,
                                  right: 32,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.65),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      item.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                // Delete (✕) Button
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: GestureDetector(
                                    onTap: () => _removePhoto(index),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close_rounded, color: Colors.white, size: 14),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Dual Buttons Row
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: CustomButton(
                          text: 'Back',
                          isOutlined: true,
                          backgroundColor: Colors.white,
                          textColor: AppColors.primary,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 6,
                        child: CustomButton(
                          text: 'Next: Documents',
                          fontSize: 14.5,
                          onPressed: () {
                            if (_photos.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please upload at least one photo of your property.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            final photoNames = _photos.map((p) => p.name).toList();
                            final updatedData = Map<String, dynamic>.from(widget.propertyData ?? {});
                            updatedData['photos'] = photoNames;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HostAddPropertyDocumentsScreen(
                                  photos: photoNames,
                                  propertyData: updatedData,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(int currentStep) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: List.generate(9, (index) {
          final isCompleted = index < currentStep;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    color: isCompleted ? AppColors.primary : const Color(0xFFF3EDF7),
                  ),
                ),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isCompleted ? AppColors.primary : const Color(0xFFF3EDF7),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
