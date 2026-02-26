import 'dart:async';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:investify/features/auth/view/auth_gate.dart';
import 'package:investify/features/auth/view/verify_email.dart';
import 'package:investify/features/post_idea/services/media_upload_service.dart';
import 'package:investify/services/firestore_service.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../../home/view/main_screen.dart';
import '../../profile/controller/profile_controller.dart';
import '../model/user_model.dart';
import '../services/user_service.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Login fields
  final email = ''.obs;
  final password = ''.obs;

  // Registration fields
  final name = ''.obs;
  final age = 0.obs;
  final confirmPassword = ''.obs;
  final nidCardImagePath = Rxn<String>(); //Reactive obserable variable
  final nidCardFileName = Rxn<String>();
  Uint8List? nidCardBytes;

  // UI state
  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final obscureConfirmPassword = true.obs;

  // Email verification
  final isEmailVerified = false.obs;
  Timer? _verificationTimer;
  StreamSubscription? _verificationStreamSubscription;

  // Password reset
  final resetEmailSent = false.obs;

  // Cached user profile data
  final cachedUserName = ''.obs;
  final cachedProfileImageUrl = Rxn<String>();
  final isUploadingProfileImage = false.obs;

  // Verification status
  final isVerified = false.obs;
  final isAdmin = false.obs;

  @override
  void onClose() {
    _verificationTimer?.cancel();
    _verificationStreamSubscription?.cancel();
    super.onClose();
  }

  Future<void> _listenToVerificationStatus(String uid) async {
    _verificationStreamSubscription?.cancel();
    _verificationStreamSubscription = 
      FirestoreService().streamUserVerificationStatus(uid).listen((status) {
        isVerified.value = status['isVerified'] ?? false;
        isAdmin.value = status['isAdmin'] ?? false;
      });
  }

  Future<void> _setupOneSignal(String uid) async {
    try {
      await OneSignal.login(uid);
    } catch (e) {
      debugPrint('Error setting up OneSignal: $e');
    }
  }

  @override
  void onInit() {
    super.onInit();
    if (_auth.currentUser != null) {
      cachedUserName.value = _auth.currentUser?.displayName ?? 'User';
      fetchUserProfile();
      _setupOneSignal(_auth.currentUser!.uid);
      _fetchVerificationStatus();
    }
  }

  Future<void> _fetchVerificationStatus() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      final status = await FirestoreService().getVerificationStatus(uid);
      isVerified.value = status['isVerified'] ?? false;
      isAdmin.value = status['isAdmin'] ?? false;
      await _listenToVerificationStatus(uid);
    }
  }

  //user name age
  Future<void> fetchUserProfile() async {
    try {
      //Current user er information like name age nidcardimgpth
      final userData = await UserService().getCurrentUser();

      if (userData != null) {
        if (userData['name'] != null) {
          cachedUserName.value = userData['name'];
        }
        if (userData['profileImageUrl'] != null) {
          cachedProfileImageUrl.value = userData['profileImageUrl'];
        }
      }
    } catch (e) {
      debugPrint('Failed to fetch user profile: $e');
    }
  }

  // Pick and upload profile image
  Future<void> pickAndUploadProfileImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result == null) {
        return;
      }

      isUploadingProfileImage.value = true;

      final file = result.files.single;

      final uploadedImage = await MediaUploadService().uploadImage(
        UploadFile(name: file.name, bytes: file.bytes!),
      );

      debugPrint('Profile image uploaded: ${uploadedImage.url}');

      await UserService().updateUser(profileImageUrl: uploadedImage.url);

      cachedProfileImageUrl.value = uploadedImage.url;

      debugPrint(' Profile image URL saved to MongoDB');
      _showMessage('Success', 'Profile photo updated!');
    } catch (e) {
      _showMessage('Error', 'Failed to upload profile photo', isError: true);
    } finally {
      isUploadingProfileImage.value = false;
    }
  }

  Future<void> removeProfileImage() async {
    try {
      isUploadingProfileImage.value = true;

      await UserService().updateUser(profileImageUrl: '');

      cachedProfileImageUrl.value = null;

      _showMessage('Success', 'Profile photo removed!');
    } catch (e) {
      _showMessage('Error', 'Failed to remove profile photo', isError: true);
    } finally {
      isUploadingProfileImage.value = false;
    }
  }

  String get getCurrentUserEmail => _auth.currentUser?.email ?? '';

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

  // Pick NID card image using file picker
  Future<void> pickNidCardImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
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

  void clearNidCardImage() {
    nidCardImagePath.value = null;
    nidCardFileName.value = null;
    nidCardBytes = null;
  }

  /// Validation
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
    if (age.value <= 0 || age.value > 60) {
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

  /// Login
  Future<void> login() async {
    //email and pass validation
    if (email.value.trim().isEmpty || password.value.isEmpty) {
      _showMessage('Error', 'Please enter email and password', isError: true);
      return;
    }

    isLoading.value = true;
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.value.trim(),
        password: password.value,
      );

      // Set up OneSignal for this user
      final uid = userCredential.user?.uid;
      if (uid != null) {
        await _setupOneSignal(uid);

        // Check if admin and fetch verification status
        final userEmail = email.value.trim().toLowerCase();
        if (userEmail == 'pshayeed1@gmail.com') {
          await FirestoreService().checkAndSetAdmin(userEmail, uid);
        }
        final status = await FirestoreService().getVerificationStatus(uid);
        isVerified.value = status['isVerified'] ?? false;
        isAdmin.value = status['isAdmin'] ?? false;
        
        // Listen for real-time updates
        await _listenToVerificationStatus(uid);
      }

      _showMessage('Success', 'Login successful!');
      clearFields();
      isLoading.value = false;

      // Fetch new user's profile data
      cachedUserName.value = _auth.currentUser?.displayName ?? 'User';
      fetchUserProfile();

      // Refresh profile posts for the new user
      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().fetchMyPosts();
      }
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

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.value.trim(),
        password: password.value,
      );

      final uid = userCredential.user?.uid;
      if (uid != null) {
        await _setupOneSignal(uid);

        // Upload NID card FIRST
        String? nidCardUrl;
        if (nidCardBytes != null && nidCardFileName.value != null) {
          final uploadedNid = await MediaUploadService().uploadImage(
            UploadFile(name: nidCardFileName.value!, bytes: nidCardBytes!),
          );
          nidCardUrl = uploadedNid.url;
          debugPrint('NID card uploaded: $nidCardUrl');
        }

        // Then initialize Firestore with nidCardUrl
        await FirestoreService().initializeUserVerification(
          uid,
          name: name.value.trim(),
          email: email.value.trim(),
          age: age.value,
          nidCardUrl: nidCardUrl,
        );
      }

      debugPrint('User created');

      // Create user model
      final user = UserModel(
        uid: userCredential.user?.uid,
        name: name.value.trim(),
        email: email.value.trim(),
        age: age.value,
        nidCardImagePath: nidCardImagePath.value,
        createdAt: DateTime.now(),
      );

      try {
        String? nidCardUrl;

        if (nidCardBytes != null && nidCardFileName.value != null) {
          debugPrint(' Uploading NID card...');
          final uploadedNid = await MediaUploadService().uploadImage(
            UploadFile(name: nidCardFileName.value!, bytes: nidCardBytes!),
          );
          nidCardUrl = uploadedNid.url;
          debugPrint('NID card uploaded: $nidCardUrl');
        }

        await UserService().createUser(
          name: name.value.trim(),
          email: email.value.trim(),
          age: age.value,
          nidCardUrl: nidCardUrl,
        );

        await sendEmailVerification();
        debugPrint('User saved to MongoDB');
      } catch (e) {
        debugPrint('Failed to save user to MongoDB: $e');
      }

      debugPrint('User registered: ${user.toJson()}');

      isLoading.value = false;

      debugPrint('Navigating to verify email screen...');

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

  // Send verify email
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

  // check email verification
  Future<bool> checkEmailVerified() async {
    try {
      await _auth.currentUser?.reload();
      final verified = _auth.currentUser?.emailVerified ?? false;
      isEmailVerified.value = verified;
      return verified;
    } catch (e) {
      debugPrint('Error checking email verification: $e');
      return false;
    }
  }

  Future<void> startEmailVerificationCheck() async {
    _verificationTimer?.cancel();
    _verificationTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      final verified = await checkEmailVerified();
      if (verified) {
        _verificationTimer?.cancel();
        Get.snackbar(
          'Success',
          'Email verified successfully!',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
        );
        Get.offAll(() => const MainScreen());
      }
    });
  }

  // Stop email verification check
  void stopEmailVerificationCheck() {
    _verificationTimer?.cancel();
  }

  String? getCurrentUserId() {
    final user = _auth.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      return null;
    }
  }

  // Send password reset email
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
      await _verificationStreamSubscription?.cancel();
      await OneSignal.logout();

      await _auth.signOut();
      clearFields();

      cachedUserName.value = '';
      cachedProfileImageUrl.value = null;
      isVerified.value = false;
      isAdmin.value = false;

      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().posts.clear();
      }

      _showMessage('Success', 'Logged out successfully');
      // Navigate back to auth gate
      Get.offAll(() => const AuthGate());
    } catch (e) {
      _showMessage('Error', 'Error logging out', isError: true);
    }
  }

  /// Delete own account
  Future<void> deleteAccount() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      _showMessage('Error', 'No user logged in', isError: true);
      return;
    }

    isLoading.value = true;
    try {
      await FirestoreService().deleteUserAccount(uid);
      await OneSignal.logout();

      cachedUserName.value = '';
      cachedProfileImageUrl.value = null;
      isVerified.value = false;
      isAdmin.value = false;

      _showMessage('Success', 'Account deleted successfully');
      Get.offAll(() => const AuthGate());
    } catch (e) {
      _showMessage(
        'Error',
        'Failed to delete account: ${e.toString()}',
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void clearFields() {
    email.value = '';
    password.value = '';
    confirmPassword.value = '';
    name.value = '';
    age.value = 0;
    clearNidCardImage();
  }
}
