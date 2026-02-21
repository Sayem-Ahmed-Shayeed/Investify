import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../post_idea/services/media_upload_service.dart';
import '../services/sandbox_service.dart';

/// Controller for the Sandbox tab — pick media, upload, submit to n8n for review
class SandboxController extends GetxController {
  final _sandboxService = SandboxService();
  final _uploadService = MediaUploadService();

  // Form fields
  final captionText = ''.obs;

  // Video
  final videoPitchBytes = Rxn<Uint8List>();
  final videoPitchFileName = Rxn<String>();

  // Images
  final galleryImages = <Map<String, dynamic>>[].obs;
  // Each entry: { 'name': String, 'bytes': Uint8List }

  // Loading and state
  final isSubmitting = false.obs;
  final isPending = false.obs; // True if a submission is currently in progress
  final isLoadingStatus = true.obs; // True while checking initial status
  final uploadStatus = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _checkStatus();
  }

  /// Check if there's an existing pending submission
  Future<void> _checkStatus() async {
    isLoadingStatus.value = true;
    try {
      isPending.value = await _sandboxService.checkPendingStatus();
    } catch (e) {
      debugPrint('Error checking sandbox status: $e');
    } finally {
      isLoadingStatus.value = false;
    }
  }

  /// Refresh the tab state completely
  Future<void> refreshStatus() async {
    await _checkStatus();
  }

  /// Update caption text
  void updateCaption(String value) {
    captionText.value = value;
  }

  /// Pick a video file
  Future<void> pickVideo() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          videoPitchBytes.value = file.bytes;
          videoPitchFileName.value = file.name;
        }
      }
    } catch (e) {
      debugPrint('Error picking video: $e');
      _showMessage('Error', 'Failed to pick video', isError: true);
    }
  }

  /// Remove selected video
  void removeVideo() {
    videoPitchBytes.value = null;
    videoPitchFileName.value = null;
  }

  /// Pick images
  Future<void> pickImages() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: true,
      );

      if (result != null) {
        for (final file in result.files) {
          if (file.bytes != null) {
            galleryImages.add({'name': file.name, 'bytes': file.bytes!});
          }
        }
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
      _showMessage('Error', 'Failed to pick images', isError: true);
    }
  }

  /// Remove image at index
  void removeImage(int index) {
    if (index >= 0 && index < galleryImages.length) {
      galleryImages.removeAt(index);
    }
  }

  /// Submit content for AI review
  Future<void> submitForReview() async {
    // Validate
    if (captionText.value.trim().isEmpty) {
      _showMessage(
        'Missing Caption',
        'Please write a caption for your post.',
        isError: true,
      );
      return;
    }

    if (videoPitchBytes.value == null && galleryImages.isEmpty) {
      _showMessage(
        'No Media',
        'Please add at least one video or image for review.',
        isError: true,
      );
      return;
    }

    isSubmitting.value = true;
    uploadStatus.value = 'Uploading media...';

    try {
      final List<Map<String, dynamic>> uploadedMedia = [];

      // Upload video if present
      if (videoPitchBytes.value != null) {
        uploadStatus.value = 'Uploading video...';

        final videoFile = UploadFile(
          bytes: videoPitchBytes.value!,
          name: videoPitchFileName.value ?? 'video.mp4',
        );

        final uploaded = await _uploadService.uploadVideo(videoFile);

        uploadedMedia.add({
          'url': uploaded.url,
          'type': 'video',
          if (uploaded.thumbnailUrl != null)
            'thumbnailUrl': uploaded.thumbnailUrl,
        });
      }

      // Upload images if present
      if (galleryImages.isNotEmpty) {
        uploadStatus.value = 'Uploading images...';

        final imageFiles = galleryImages.map((img) {
          return UploadFile(
            bytes: img['bytes'] as Uint8List,
            name: img['name'] as String,
          );
        }).toList();

        final uploadedImages = await _uploadService.uploadImages(imageFiles);

        for (final img in uploadedImages) {
          uploadedMedia.add({'url': img.url, 'type': 'image'});
        }
      }

      // Submit to backend (which triggers n8n webhook)
      uploadStatus.value = 'Submitting for review...';

      await _sandboxService.submitForReview(
        caption: captionText.value.trim(),
        media: uploadedMedia,
      );

      // Set UI to pending mode immediately
      isPending.value = true;

      // Clear form
      _clearForm();

      // Show success dialog
      _showSuccessDialog();
    } catch (e) {
      debugPrint('❌ Sandbox submit error: $e');
      _showMessage('Error', 'Failed to submit: ${e.toString()}', isError: true);
    } finally {
      isSubmitting.value = false;
      uploadStatus.value = '';
    }
  }

  /// Clear form after successful submission
  void _clearForm() {
    captionText.value = '';
    videoPitchBytes.value = null;
    videoPitchFileName.value = null;
    galleryImages.clear();
  }

  /// Show success dialog with 5-7 minute email notice
  void _showSuccessDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade400, size: 28),
            const SizedBox(width: 10),
            const Text('Submitted!'),
          ],
        ),
        content: const Text(
          'Your content has been submitted for AI review.\n\n'
          'You will receive an email with detailed feedback within 5-7 minutes.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Got it')),
        ],
      ),
    );
  }

  /// Show snackbar message
  void _showMessage(String title, String message, {bool isError = false}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError ? Colors.red.shade100 : Colors.green.shade100,
      colorText: isError ? Colors.red.shade900 : Colors.green.shade900,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );
  }
}
