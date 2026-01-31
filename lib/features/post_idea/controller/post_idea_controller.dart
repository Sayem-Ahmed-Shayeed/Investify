import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:investify/utils/sizes/size.dart';

import '../model/post_idea_model.dart';

class PostIdeaController extends GetxController {
  final content = ''.obs;

  // Video pitch
  final videoPitchPath = Rxn<String>();
  final videoPitchFileName = Rxn<String>();

  // Gallery images (max recommended: 5)
  final galleryImages = <String>[].obs;

  // UI state
  final isPublishing = false.obs;
  final isSavingDraft = false.obs;

  /// Update content text
  void updateContent(String value) {
    content.value = value;
  }

  Future<void> pickVideo() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;

        videoPitchPath.value = file.path;
        videoPitchFileName.value = file.name;
        _showMessage('Success', 'Video selected: ${file.name}');
      }
    } catch (e) {
      _showMessage('Error', 'Error picking video: $e', isError: true);
    }
  }

  /// Remove selected video
  void removeVideo() {
    videoPitchPath.value = null;
    videoPitchFileName.value = null;
  }

  /// Pick images for gallery
  Future<void> pickImages() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        for (final file in result.files) {
          if (file.path != null && !galleryImages.contains(file.path)) {
            galleryImages.add(file.path!);
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
    if (index >= 0 && index < galleryImages.length) {
      galleryImages.removeAt(index);
    }
  }

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

    try {
      final post = _createPostModel(isDraft: true);
      await _uploadToDatabase(post);

      isSavingDraft.value = false;
      _showMessage('Success', 'Draft saved successfully!');
      Get.back();
    } catch (e) {
      isSavingDraft.value = false;
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

    try {
      final post = _createPostModel(isDraft: false);
      await _uploadToDatabase(post);

      isPublishing.value = false;
      _showMessage('Success', 'Post published successfully!');
      _clearForm();
      Get.back();
    } catch (e) {
      isPublishing.value = false;
      _showMessage('Error', 'Failed to publish post: $e', isError: true);
    }
  }

  /// Create post model from current state
  PostIdeaModel _createPostModel({required bool isDraft}) {
    return PostIdeaModel(
      content: content.value.trim(),
      videoPitchPath: videoPitchPath.value,
      galleryImages: List<String>.from(galleryImages),
      isDraft: isDraft,
      createdAt: DateTime.now(),
      userId: FirebaseAuth.instance.currentUser?.uid,
    );
  }

  /// Upload post data to database
  /// TODO: Implement actual Firebase Firestore/Storage upload when configured
  Future<void> _uploadToDatabase(PostIdeaModel post) async {
    debugPrint('Uploading post to database...');
    debugPrint('Post data: ${post.toJson()}');

    // Simulate network delay for now
    await Future.delayed(const Duration(seconds: 1));

    // TODO: Upload video to Firebase Storage if exists
    if (post.videoPitchPath != null) {
      debugPrint('Would upload video: ${post.videoPitchPath}');
      // final videoUrl = await _uploadFileToStorage(post.videoPitchPath!, 'videos');
    }

    // TODO: Upload gallery images to Firebase Storage
    for (final imagePath in post.galleryImages) {
      debugPrint('Would upload image: $imagePath');
      // final imageUrl = await _uploadFileToStorage(imagePath, 'images');
    }

    // TODO: Save post document to Firestore
    // await FirebaseFirestore.instance.collection('posts').add(post.toJson());

    debugPrint('Post upload complete (simulated)');
  }

  /// Clear form after successful publish
  void _clearForm() {
    content.value = '';
    videoPitchPath.value = null;
    videoPitchFileName.value = null;
    galleryImages.clear();
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
