import 'dart:async';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:investify/features/auth/view/auth_gate.dart';
import 'package:investify/features/auth/view/verify_email.dart';
import 'package:investify/features/post_idea/services/media_upload_service.dart';

import '../model/user_model.dart';
import '../services/user_service.dart';

/// Controller for handling authentication logic
class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Login fields
  final email = ''.obs;
  final password = ''.obs;

  // Registration fields
  final name = ''.obs;
  final age = 0.obs;
  final confirmPassword = ''.obs;
  final nidCardImagePath = Rxn<String>();
  final nidCardFileName = Rxn<String>();
  Uint8List? nidCardBytes;

  // UI state
  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final obscureConfirmPassword = true.obs;

  // Email verification
  final isEmailVerified = false.obs;
  Timer? _verificationTimer;

  // Password reset
  final resetEmailSent = false.obs;

  @override
  void onClose() {
    _verificationTimer?.cancel();
    super.onClose();
  }

  String get getCurrentUserEmail => _auth.currentUser?.email ?? '';

  /// Show snackbar message
  void _showMessage(String title, String message, {bool isError = false}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError ? Colors.red.shade100 : Colors.green.shade100,
      colorText: isError ? Colors.red.shade900 : Colors.green.shade900,
      duration: const Duration(seconds: 1),
      margin: const EdgeInsets.all(12),
      borderRadius: 8,
    );
  }

  /// Toggle password visibility
  void togglePassword() {
    obscurePassword.value = !obscurePassword.value;
  }

  /// Toggle confirm password visibility
  void toggleConfirmPassword() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  /// Pick NID card image using file picker
  Future<void> pickNidCardImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true, // Required to get bytes on mobile
      );

      if (result != null && result.files.isNotEmpty) {
        nidCardImagePath.value = result.files.single.path;
        nidCardFileName.value = result.files.single.name;
        nidCardBytes = result.files.single.bytes;
      }
    } catch (e) {
      _showMessage('Error', 'Error picking image: $e', isError: true);
    }
  }

  /// Clear picked NID card image
  void clearNidCardImage() {
    nidCardImagePath.value = null;
    nidCardFileName.value = null;
    nidCardBytes = null;
  }

  /// Validate registration form
  String? _validateRegistration() {
    if (name.value.trim().isEmpty) {
      return 'Please enter your name';
    }
    if (email.value.trim().isEmpty) {
      return 'Please enter your email';
    }
    if (!GetUtils.isEmail(email.value.trim())) {
      return 'Please enter a valid email';
    }
    if (age.value <= 0 || age.value > 120) {
      return 'Please enter a valid age';
    }
    if (password.value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (password.value != confirmPassword.value) {
      return 'Passwords do not match';
    }
    if (nidCardImagePath.value == null) {
      return 'Please upload your NID card image';
    }
    return null;
  }

  /// Login with email and password
  Future<void> login() async {
    if (email.value.trim().isEmpty || password.value.isEmpty) {
      _showMessage('Error', 'Please enter email and password', isError: true);
      return;
    }

    isLoading.value = true;
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.value.trim(),
        password: password.value,
      );
      _showMessage('Success', 'Login successful!');
      clearFields();
      isLoading.value = false;
      // AuthGate will handle navigation
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      _handleAuthError(e);
    } catch (e) {
      isLoading.value = false;
      _showMessage(
        'Error',
        'An error occurred. Please try again.',
        isError: true,
      );
    }
  }

  /// Handle Firebase auth errors with user-friendly messages
  void _handleAuthError(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'user-not-found':
        message = 'No account found with this email';
        break;
      case 'wrong-password':
        message = 'Incorrect password. Please try again';
        break;
      case 'invalid-email':
        message = 'Invalid email address';
        break;
      case 'user-disabled':
        message = 'This account has been disabled';
        break;
      case 'too-many-requests':
        message = 'Too many attempts. Please try again later';
        break;
      case 'email-already-in-use':
        message = 'An account already exists with this email';
        break;
      case 'weak-password':
        message = 'Password is too weak';
        break;
      case 'invalid-credential':
        message = 'Invalid email or password';
        break;
      default:
        message = e.message ?? 'Authentication failed';
    }
    _showMessage('Error', message, isError: true);
  }

  /// Register new user with email and password
  Future<void> register() async {
    final validationError = _validateRegistration();
    if (validationError != null) {
      _showMessage('Error', validationError, isError: true);
      return;
    }

    isLoading.value = true;
    try {
      debugPrint('Starting registration...');

      // Create user with Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.value.trim(),
        password: password.value,
      );

      debugPrint('User created: ${userCredential.user?.uid}');

      // Send email verification
      await sendEmailVerification();

      // Create user model
      final user = UserModel(
        uid: userCredential.user?.uid,
        name: name.value.trim(),
        email: email.value.trim(),
        age: age.value,
        nidCardImagePath: nidCardImagePath.value,
        createdAt: DateTime.now(),
      );

      // Upload NID card to Spaces and save user data to MongoDB
      try {
        String? nidCardUrl;

        // Upload NID card image if available
        if (nidCardBytes != null && nidCardFileName.value != null) {
          debugPrint('📤 Uploading NID card...');
          final uploadedNid = await MediaUploadService().uploadImage(
            UploadFile(name: nidCardFileName.value!, bytes: nidCardBytes!),
          );
          nidCardUrl = uploadedNid.url;
          debugPrint('✅ NID card uploaded: $nidCardUrl');
        }

        await UserService().createUser(
          name: name.value.trim(),
          email: email.value.trim(),
          age: age.value,
          nidCardUrl: nidCardUrl,
        );
        debugPrint('✅ User saved to MongoDB');
      } catch (e) {
        debugPrint('⚠️ Failed to save user to MongoDB: $e');
      }

      debugPrint('User registered: ${user.toJson()}');

      isLoading.value = false;

      debugPrint('Navigating to verify email screen...');
      // Navigate to verify email screen and clear stack
      Get.offAll(() => const VerifyEmailScreen());
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: ${e.code} - ${e.message}');
      isLoading.value = false;
      _handleAuthError(e);
    } catch (e) {
      debugPrint('Registration error: $e');
      isLoading.value = false;
      _showMessage(
        'Error',
        'Registration failed: ${e.toString()}',
        isError: true,
      );
    }
  }

  /// Send email verification
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        _showMessage('Email Sent', 'Verification email sent!');
      }
    } catch (e) {
      _showMessage('Error', 'Error sending verification email', isError: true);
    }
  }

  /// Check if email is verified
  Future<bool> checkEmailVerified() async {
    try {
      await _auth.currentUser?.reload();
      final verified = _auth.currentUser?.emailVerified ?? false;
      debugPrint('Email verification check: $verified');
      isEmailVerified.value = verified;
      return verified;
    } catch (e) {
      debugPrint('Error checking email verification: $e');
      return false;
    }
  }

  /// Start periodic check for email verification
  void startEmailVerificationCheck(VoidCallback onVerified) {
    debugPrint('Starting email verification check...');
    _verificationTimer?.cancel();
    _verificationTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      final verified = await checkEmailVerified();
      debugPrint('Verification timer tick - verified: $verified');
      if (verified) {
        debugPrint('Email verified! Calling onVerified callback...');
        _verificationTimer?.cancel();
        onVerified();
      }
    });
  }

  /// Stop email verification check
  void stopEmailVerificationCheck() {
    _verificationTimer?.cancel();
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail() async {
    if (email.value.trim().isEmpty) {
      _showMessage('Error', 'Please enter your email', isError: true);
      return;
    }

    if (!GetUtils.isEmail(email.value.trim())) {
      _showMessage('Error', 'Please enter a valid email', isError: true);
      return;
    }

    isLoading.value = true;
    try {
      await _auth.sendPasswordResetEmail(email: email.value.trim());
      isLoading.value = false;
      resetEmailSent.value = true;
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      _handleAuthError(e);
    } catch (e) {
      isLoading.value = false;
      _showMessage(
        'Error',
        'Failed to send reset email. Please try again.',
        isError: true,
      );
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
      clearFields();
      _showMessage('Success', 'Logged out successfully');
      // Navigate back to auth gate
      Get.offAll(() => const AuthGate());
    } catch (e) {
      _showMessage('Error', 'Error logging out', isError: true);
    }
  }

  /// Clear all form fields
  void clearFields() {
    email.value = '';
    password.value = '';
    confirmPassword.value = '';
    name.value = '';
    age.value = 0;
    clearNidCardImage();
  }
}
