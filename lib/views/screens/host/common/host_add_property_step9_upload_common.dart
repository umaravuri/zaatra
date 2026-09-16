import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../widgets/custom_button.dart';
import 'host_add_property_review_common.dart';

class HostAddPropertyStep9UploadCommonScreen extends StatefulWidget {
  final String selectedCategory;
  final String propertyName;
  final Map<String, dynamic> propertyDetails;
  final Map<String, dynamic> addressMap;
  final String formattedAddress;
  final String description;
  final dynamic amenities;
  final List<String> houseRules;
  final Map<String, dynamic> pricing;
  final String checkInTime;
  final String checkOutTime;

  const HostAddPropertyStep9UploadCommonScreen({
    Key? key,
    required this.selectedCategory,
    required this.propertyName,
    required this.propertyDetails,
    required this.addressMap,
    required this.formattedAddress,
    required this.description,
    required this.amenities,
    required this.houseRules,
    required this.pricing,
    required this.checkInTime,
    required this.checkOutTime,
  }) : super(key: key);

  @override
  State<HostAddPropertyStep9UploadCommonScreen> createState() => _HostAddPropertyStep9UploadCommonScreenState();
}

class _HostAddPropertyStep9UploadCommonScreenState extends State<HostAddPropertyStep9UploadCommonScreen> {
  // Pre-loaded photo previews (JPEG & PNG supported)
  final List<Map<String, String>> _uploadedPhotos = [];

  // 4 KYC Documents State (PDF, PNG, JPEG supported)
  final Map<String, Map<String, dynamic>> _documents = {
    'ownershipProof': {
      'title': 'Property Ownership Proof',
      'desc': 'Registered Sale Deed / Electricity Bill',
      'fileName': null,
      'format': 'PDF',
      'size': null,
      'isUploaded': false,
    },
    'identityProof': {
      'title': 'Host Identity Proof',
      'desc': 'Aadhar Card / Passport / Voter ID',
      'fileName': null,
      'format': 'JPEG',
      'size': null,
      'isUploaded': false,
    },
    'taxRegistration': {
      'title': 'Tax / Registration Documents',
      'desc': 'GST Certificate / Local Trade License',
      'fileName': null,
      'format': 'PDF',
      'size': null,
      'isUploaded': false,
    },
    'nocClearance': {
      'title': 'NOC / Safety Clearances',
      'desc': 'Fire Safety NOC / Society Approval',
      'fileName': null,
      'format': 'PNG',
      'size': null,
      'isUploaded': false,
    },
  };

  final _picker = ImagePicker();

  Future<void> _addSamplePhoto() async {
    try {
      final List<XFile> files = await _picker.pickMultiImage();

      if (files.isNotEmpty) {
        setState(() {
          for (var file in files) {
            final ext = file.name.split('.').last.toUpperCase();
            _uploadedPhotos.add({
              'name': file.name,
              'type': ext.isEmpty ? 'JPEG' : ext,
              'url': '/uploads/property/${file.name}',
            });
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${files.length} photo(s) selected!'),
            backgroundColor: AppColors.primary,
          ),
        );
        return;
      }
    } catch (_) {}

    final nextIndex = _uploadedPhotos.length + 1;
    final isPng = nextIndex % 2 == 0;
    setState(() {
      _uploadedPhotos.add({
        'name': 'property_photo_$nextIndex.${isPng ? 'png' : 'jpg'}',
        'type': isPng ? 'PNG' : 'JPEG',
        'url': '/uploads/property/photo${(nextIndex % 5) + 1}.jpg',
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Photo added (${isPng ? 'PNG' : 'JPEG'} format)'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _toggleDocument(String key) async {
    try {
      final XFile? file = await _picker.pickImage(source: ImageSource.gallery);

      if (file != null) {
        final ext = file.name.split('.').last.toLowerCase();
        if (ext != 'pdf') {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Only PDF files are allowed for document verification.'),
              backgroundColor: Colors.redAccent,
              duration: Duration(seconds: 3),
            ),
          );
          return;
        }

        final length = await file.length();
        if (length > 5 * 1024 * 1024) {
          final sizeMb = (length / (1024 * 1024)).toStringAsFixed(1);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File size exceeds 5 MB limit ($sizeMb MB). Please upload a smaller PDF.'),
              backgroundColor: Colors.redAccent,
              duration: const Duration(seconds: 3),
            ),
          );
          return;
        }

        final sizeKb = (length / 1024).toStringAsFixed(1);
        final sizeStr = length > 1024 * 1024
            ? '${(length / (1024 * 1024)).toStringAsFixed(1)} MB'
            : '$sizeKb KB';

        setState(() {
          final doc = _documents[key]!;
          doc['isUploaded'] = true;
          doc['fileName'] = file.name;
          doc['size'] = sizeStr;
          doc['format'] = 'PDF';
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Document "${file.name}" attached successfully!'),
            backgroundColor: AppColors.primary,
          ),
        );
        return;
      }
    } catch (_) {}
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
          children: [
            const Text('Add new property', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 16)),
            const SizedBox(height: 2),
            Text('Set 9 by 9 (${widget.selectedCategory})', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
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
                        Text('Photos & KYC Documents', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        Text('Upload photos (JPEG/PNG) and verification documents (PDF/PNG/JPEG)', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        const SizedBox(height: 22),

                        // Section 1: Photos Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.photo_library_rounded, color: AppColors.primary, size: 20),
                                SizedBox(width: 8),
                                Text('Property Photos', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _uploadedPhotos.length >= 5 ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_uploadedPhotos.length} / 5 Uploaded (JPEG/PNG)',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: _uploadedPhotos.length >= 5 ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Photos Grid
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1.0,
                          ),
                          itemCount: _uploadedPhotos.length + 1,
                          itemBuilder: (context, index) {
                            if (index == _uploadedPhotos.length) {
                              // Add Photo Button
                              return GestureDetector(
                                onTap: _addSamplePhoto,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9F9FB),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 1.5),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.add_a_photo_rounded, color: AppColors.primary, size: 26),
                                      SizedBox(height: 4),
                                      Text('+ Add Photo', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                      Text('JPEG/PNG', style: TextStyle(fontSize: 9, color: AppColors.textMuted)),
                                    ],
                                  ),
                                ),
                              );
                            }

                            final photo = _uploadedPhotos[index];
                            return Stack(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3EDF7),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Center(
                                    child: Icon(Icons.image_rounded, color: AppColors.primary.withOpacity(0.7), size: 36),
                                  ),
                                ),
                                Positioned(
                                  bottom: 4,
                                  left: 4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.65),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      photo['type']!,
                                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _uploadedPhotos.removeAt(index);
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                                      ),
                                      child: const Icon(Icons.close_rounded, size: 12, color: Colors.red),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 28),

                        // Section 2: KYC Documents Header
                        Row(
                          children: const [
                            Icon(Icons.verified_user_rounded, color: AppColors.primary, size: 20),
                            SizedBox(width: 8),
                            Text('KYC & Ownership Documents', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text('Upload documents in PDF, PNG or JPEG formats', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        const SizedBox(height: 14),

                        // 4 Document Cards
                        ..._documents.entries.map((entry) {
                          final key = entry.key;
                          final doc = entry.value;
                          final isUploaded = doc['isUploaded'] as bool;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isUploaded ? const Color(0xFFF9F9FB) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isUploaded ? const Color(0xFFE8DEF8) : AppColors.border,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isUploaded ? const Color(0xFFE8F5E9) : const Color(0xFFF3EDF7),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    doc['format'] == 'PDF' ? Icons.picture_as_pdf_rounded : Icons.description_rounded,
                                    color: isUploaded ? const Color(0xFF2E7D32) : AppColors.primary,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        doc['title'] as String,
                                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                      ),
                                      const SizedBox(height: 2),
                                      if (isUploaded)
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary.withOpacity(0.12),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                doc['format'] as String,
                                                style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppColors.primary),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                '${doc['fileName']} (${doc['size']})',
                                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        )
                                      else
                                        Text(
                                          doc['desc'] as String,
                                          style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                                        ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () => _toggleDocument(key),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isUploaded ? const Color(0xFFE8F5E9) : AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isUploaded ? Icons.check_circle_rounded : Icons.upload_file_rounded,
                                          size: 14,
                                          color: isUploaded ? const Color(0xFF2E7D32) : AppColors.primary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          isUploaded ? 'Attached' : 'Upload',
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.bold,
                                            color: isUploaded ? const Color(0xFF2E7D32) : AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Back',
                          isOutlined: true,
                          backgroundColor: Colors.white,
                          textColor: AppColors.primary,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: CustomButton(
                          text: 'Review Listing',
                          onPressed: () {
                            if (_uploadedPhotos.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please upload at least one photo of your property.'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                              return;
                            }
                            final photosList = _uploadedPhotos.map((p) => p['url']!).toList();
                            final documentsMap = {
                              'propertyOwnershipProof': _documents['ownershipProof']!['fileName'],
                              'identityProof': _documents['identityProof']!['fileName'],
                              'taxRegistrationDocuments': _documents['taxRegistration']!['fileName'],
                              'nocOtherDocuments': _documents['nocDocuments']!['fileName'],
                            };

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HostAddPropertyReviewCommonScreen(
                                  selectedCategory: widget.selectedCategory,
                                  propertyName: widget.propertyName,
                                  propertyDetails: widget.propertyDetails,
                                  addressMap: widget.addressMap,
                                  formattedAddress: widget.formattedAddress,
                                  description: widget.description,
                                  amenities: widget.amenities,
                                  houseRules: widget.houseRules,
                                  pricing: widget.pricing,
                                  checkInTime: widget.checkInTime,
                                  checkOutTime: widget.checkOutTime,
                                  photos: photosList,
                                  documents: documentsMap,
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
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    color: AppColors.primary,
                  ),
                ),
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
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
