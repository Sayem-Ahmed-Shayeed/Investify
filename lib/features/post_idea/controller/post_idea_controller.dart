import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:investify/utils/constants/api_config.dart';
import 'package:investify/utils/sizes/size.dart';

import '../../home/controller/home_feed_controller.dart';
import '../../home/controller/nav_bar_controller.dart';
import '../services/media_upload_service.dart';
import '../services/post_service.dart';
import '../services/video_thumbnail_service.dart';

class PostIdeaController extends GetxController {
  final content = ''.obs;

  // Video pitch - store both bytes, name, and path for web support
  final videoPitchBytes = Rxn<Uint8List>();
  final videoPitchFileName = Rxn<String>();
  final videoPitchPath = Rxn<String>(); // Store path for thumbnail generation

  final galleryImageBytes = <Uint8List>[].obs;
  final galleryImageNames = <String>[].obs;

  // UI state
  final isPublishing = false.obs;
  final isSavingDraft = false.obs;
  final isEnhancing = false.obs;
  final uploadProgress = 0.0.obs;
  final uploadStatus = ''.obs;

  // Text editing controller for programmatic text updates
  final contentController = TextEditingController();

  // Services
  final _mediaUploadService = MediaUploadService();
  final _postService = PostService();
  final _thumbnailService = VideoThumbnailService();

  /// Update content text
  void updateContent(String value) {
    content.value = value;
  }

  @override
  void onClose() {
    contentController.dispose();
    super.onClose();
  }

  /// Enhance content text using AI (grammar/spelling correction)
  Future<void> enhanceContent() async {
    final text = content.value.trim();
    if (text.isEmpty) {
      _showMessage(
        'Nothing to enhance',
        'Please write some content first.',
        isError: true,
      );
      return;
    }

    isEnhancing.value = true;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not authenticated');
      final token = await user.getIdToken();

      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.enhance}'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'text': text}),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode != 200) {
        throw Exception('Enhancement failed');
      }

      final data = jsonDecode(response.body);
      final enhancedText = data['enhancedText'] as String?;

      if (enhancedText != null && enhancedText.isNotEmpty) {
        content.value = enhancedText;
        contentController.text = enhancedText;
        contentController.selection = TextSelection.fromPosition(
          TextPosition(offset: enhancedText.length),
        );
        _showMessage('Enhanced! ✨', 'Your text has been improved.');
      }
    } catch (e) {
      debugPrint('Enhance error: $e');
      _showMessage(
        'Error',
        'Failed to enhance text. Try again.',
        isError: true,
      );
    } finally {
      isEnhancing.value = false;
    }
  }

  Future<void> pickVideo() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
        withData: true,
        withReadStream: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;

        if (file.bytes != null) {
          videoPitchBytes.value = file.bytes;
          videoPitchFileName.value = file.name;
          videoPitchPath.value =
              file.path; // Store path for thumbnail generation
          _showMessage('Success', 'Video selected: ${file.name}');
        } else {
          _showMessage('Error', 'Could not load video data', isError: true);
        }
      }
    } catch (e) {
      _showMessage('Error', 'Error picking video: $e', isError: true);
    }
  }

  /// Remove selected video
  void removeVideo() {
    videoPitchBytes.value = null;
    videoPitchFileName.value = null;
    videoPitchPath.value = null;
  }

  /// Pick images for gallery
  Future<void> pickImages() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: true, // Important for web - loads bytes
      );

      if (result != null && result.files.isNotEmpty) {
        for (final file in result.files) {
          if (file.bytes != null) {
            galleryImageBytes.add(file.bytes!);
            galleryImageNames.add(file.name);
          }
        }
        _showMessage('Success', '${result.files.length} image(s) added');
      }
    } catch (e) {
      _showMessage('Error', 'Error picking images: $e', isError: true);
    }
  }

  /// Remove image from gallery at index
  void removeImage(int index) {
    if (index >= 0 && index < galleryImageBytes.length) {
      galleryImageBytes.removeAt(index);
      galleryImageNames.removeAt(index);
    }
  }

  // Legacy getter for UI compatibility
  List<String> get galleryImages => galleryImageNames;

  /// Validate post before saving/publishing
  String? _validatePost() {
    if (content.value.trim().isEmpty) {
      return 'Please add some content to your post';
    }
    return null;
  }

  /// Save post as draft
  Future<void> saveDraft() async {
    final validationError = _validatePost();
    if (validationError != null) {
      _showMessage('Error', validationError, isError: true);
      return;
    }

    isSavingDraft.value = true;
    uploadStatus.value = 'Uploading media...';

    try {
      // Upload media files
      final uploadedMedia = await _uploadAllMedia();

      // Create post via API
      uploadStatus.value = 'Saving draft...';
      await _postService.createPost(
        caption: content.value.trim(),
        media: uploadedMedia,
        isDraft: true,
      );

      isSavingDraft.value = false;
      uploadStatus.value = '';
      _showMessage('Success', 'Draft saved successfully!');
      _clearForm();
      Get.back();
    } catch (e) {
      isSavingDraft.value = false;
      uploadStatus.value = '';
      _showMessage('Error', 'Failed to save draft: $e', isError: true);
    }
  }

  /// Publish post
  Future<void> publishPost() async {
    final validationError = _validatePost();
    if (validationError != null) {
      _showMessage('Error', validationError, isError: true);
      return;
    }

    isPublishing.value = true;
    uploadStatus.value = 'Uploading media...';

    try {
      // Upload media files
      final uploadedMedia = await _uploadAllMedia();

      // Create post via API
      uploadStatus.value = 'Publishing...';
      await _postService.createPost(
        caption: content.value.trim(),
        media: uploadedMedia,
        isDraft: false,
      );

      isPublishing.value = false;
      uploadStatus.value = '';
      _showMessage('Success', 'Post published successfully!');
      _clearForm();

      // Switch to home tab and refresh feed
      if (Get.isRegistered<NavBarController>()) {
        Get.find<NavBarController>().onTabChanged(0);
      }
      if (Get.isRegistered<HomeFeedController>()) {
        Get.find<HomeFeedController>().refreshPosts();
      }
    } catch (e) {
      isPublishing.value = false;
      uploadStatus.value = '';
      _showMessage('Error', 'Failed to publish post: $e', isError: true);
    }
  }

  /// Upload all media (video + images) and return UploadedMedia list
  Future<List<UploadedMedia>> _uploadAllMedia() async {
    final uploadedMedia = <UploadedMedia>[];

    // Upload video if exists
    if (videoPitchBytes.value != null && videoPitchFileName.value != null) {
      uploadStatus.value = 'Generating thumbnail...';

      // Generate thumbnail from video (mobile only, not web)
      Uint8List? thumbnailBytes;
      if (videoPitchPath.value != null && !kIsWeb) {
        try {
          thumbnailBytes = await _thumbnailService.generateThumbnailFromFile(
            videoPitchPath.value!,
          );
          if (thumbnailBytes != null) {
            debugPrint('✅ Thumbnail generated: ${thumbnailBytes.length} bytes');
          }
        } catch (e) {
          debugPrint('⚠️ Thumbnail generation failed: $e');
          // Continue without thumbnail
        }
      }

      uploadStatus.value = 'Uploading video...';
      try {
        final uploadFile = UploadFile(
          name: videoPitchFileName.value!,
          bytes: videoPitchBytes.value!,
        );
        final uploadedVideo = await _mediaUploadService.uploadVideo(
          uploadFile,
          thumbnailBytes: thumbnailBytes,
        );
        uploadedMedia.add(uploadedVideo);
        debugPrint('✅ Video uploaded: ${uploadedVideo.url}');
        if (uploadedVideo.thumbnailUrl != null) {
          debugPrint('✅ Thumbnail URL: ${uploadedVideo.thumbnailUrl}');
        }
      } catch (e) {
        debugPrint('❌ Video upload failed: $e');
        rethrow;
      }
    }

    // Upload images if exist
    if (galleryImageBytes.isNotEmpty) {
      uploadStatus.value = 'Uploading images (${galleryImageBytes.length})...';
      try {
        final uploadFiles = <UploadFile>[];
        for (int i = 0; i < galleryImageBytes.length; i++) {
          uploadFiles.add(
            UploadFile(name: galleryImageNames[i], bytes: galleryImageBytes[i]),
          );
        }
        final uploadedImages = await _mediaUploadService.uploadImages(
          uploadFiles,
        );
        uploadedMedia.addAll(uploadedImages);
        debugPrint('✅ ${uploadedImages.length} images uploaded');
      } catch (e) {
        debugPrint('❌ Image upload failed: $e');
        rethrow;
      }
    }

    return uploadedMedia;
  }

  /// Clear form after successful publish
  void _clearForm() {
    content.value = '';
    videoPitchBytes.value = null;
    videoPitchFileName.value = null;
    videoPitchPath.value = null;
    galleryImageBytes.clear();
    galleryImageNames.clear();
  }

  /// Show snackbar message
  void _showMessage(String title, String message, {bool isError = false}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError ? Colors.red.shade100 : Colors.green.shade100,
      colorText: isError ? Colors.red.shade900 : Colors.green.shade900,
      duration: const Duration(seconds: 1),
      margin: const EdgeInsets.all(RomRomSizes.medium),
      borderRadius: RomRomSizes.roundedBoxCorner,
    );
  }
}
