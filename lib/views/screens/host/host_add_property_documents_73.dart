import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import 'host_add_property_review_74.dart';
import 'common/host_add_property_review_common.dart';

class HostAddPropertyDocumentsScreen extends StatefulWidget {
  final List<String>? photos;
  final Map<String, dynamic>? propertyData;

  const HostAddPropertyDocumentsScreen({
    Key? key,
    this.photos,
    this.propertyData,
  }) : super(key: key);

  @override
  State<HostAddPropertyDocumentsScreen> createState() => _HostAddPropertyDocumentsScreenState();
}

class _HostAddPropertyDocumentsScreenState extends State<HostAddPropertyDocumentsScreen> {
  final List<Map<String, dynamic>> _docs = [
    {
      'key': 'propertyOwnershipProof',
      'title': 'Property ownership proof',
      'subtitle': 'PDF only, Max 5 MB',
      'fileName': null,
      'fileSize': null,
      'isUploaded': false,
      'format': 'PDF',
    },
    {
      'key': 'identityProof',
      'title': 'Identity Proof',
      'subtitle': 'PDF only, Max 5 MB',
      'fileName': null,
      'fileSize': null,
      'isUploaded': false,
      'format': 'PDF',
    },
    {
      'key': 'taxRegistrationDocuments',
      'title': 'Tax / Registration Documents',
      'subtitle': 'PDF only, Max 5 MB',
      'fileName': null,
      'fileSize': null,
      'isUploaded': false,
      'format': 'PDF',
    },
    {
      'key': 'nocOtherDocuments',
      'title': 'NOC / Other documents',
      'subtitle': 'PDF only, Max 5 MB',
      'fileName': null,
      'fileSize': null,
      'isUploaded': false,
      'format': 'PDF',
    },
  ];

  final _picker = ImagePicker();

  Future<void> _pickDocument(int index) async {
    final docTitle = _docs[index]['title'];
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
          _docs[index]['isUploaded'] = true;
          _docs[index]['fileName'] = file.name;
          _docs[index]['fileSize'] = sizeStr;
          _docs[index]['format'] = 'PDF';
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Document "${file.name}" attached successfully!'),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {}
  }

  void _toggleUpload(int index) {
    setState(() {
      _docs[index]['isUploaded'] = !(_docs[index]['isUploaded'] as bool);
    });

    final docTitle = _docs[index]['title'];
    final isUploaded = _docs[index]['isUploaded'] as bool;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isUploaded ? '$docTitle attached successfully!' : '$docTitle removed.'),
        backgroundColor: isUploaded ? AppColors.primary : Colors.black87,
        duration: const Duration(milliseconds: 1400),
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
          'Add new property',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 16),
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
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Documents', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        const Text('Upload required verification & KYC documents', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),

                        const SizedBox(height: 14),

                        // Formats Info Banner
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F5FE),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.verified_user_outlined, color: AppColors.primary, size: 20),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Accepted Formats: PDF, PNG, JPEG • Max 5MB per document',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        ...List.generate(_docs.length, (index) {
                          final item = _docs[index];
                          final isUploaded = item['isUploaded'] as bool;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isUploaded ? const Color(0xFFFAFAFE) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isUploaded ? AppColors.primary.withOpacity(0.5) : AppColors.border,
                                width: isUploaded ? 1.5 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isUploaded ? const Color(0xFFE8DEF8) : const Color(0xFFF3EDF7),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    item['format'] == 'PDF' ? Icons.picture_as_pdf_rounded : Icons.article_outlined,
                                    color: AppColors.primary,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['title']!,
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                      ),
                                      const SizedBox(height: 3),
                                      if (isUploaded)
                                        Text(
                                          '${item['fileName']} • ${item['fileSize']}',
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF2E7D32)),
                                        )
                                      else
                                        Text(
                                          item['subtitle']!,
                                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                        ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () => _pickDocument(index),
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isUploaded ? const Color(0xFFE8F5E9) : const Color(0xFFF3EDF7),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isUploaded ? const Color(0xFF81C784) : AppColors.border,
                                      ),
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
                                          isUploaded ? 'Attached' : 'Attach',
                                          style: TextStyle(
                                            fontSize: 11,
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
                        }),
                      ],
                    ),
                  ),
                ),

                // Dual Buttons Row matching 73.png
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
                          text: 'Next: Review',
                          onPressed: () {
                            final docsMap = <String, dynamic>{};
                            for (var d in _docs) {
                              if (d['isUploaded'] == true) {
                                docsMap[d['key']] = d['fileName'];
                              }
                            }

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HostAddPropertyReviewScreen(
                                  photos: widget.photos,
                                  documents: docsMap,
                                  propertyData: widget.propertyData,
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
}
