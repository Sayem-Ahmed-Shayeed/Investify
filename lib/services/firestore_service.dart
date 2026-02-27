import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();

  factory FirestoreService() => _instance;

  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _usersCollection = 'users';
  static const String _postsCollection = 'posts';
  static const String _keyInvestorsCollection = 'key_investors';
  static const String _adminEmail = 'pshayeed1@gmail.com';

  // ─── Key Investors CRUD ─────────────────────────────────────────────────────

  Future<void> addKeyInvestor(Map<String, dynamic> data) async {
    await _firestore.collection(_keyInvestorsCollection).add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> getKeyInvestors() async {
    final snapshot = await _firestore
        .collection(_keyInvestorsCollection)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<void> updateKeyInvestor(
    String id,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection(_keyInvestorsCollection).doc(id).update(data);
  }

  Future<void> deleteKeyInvestor(String id) async {
    await _firestore.collection(_keyInvestorsCollection).doc(id).delete();
  }

  // ─── Admin & Auth ───────────────────────────────────────────────────────────

  Future<void> checkAndSetAdmin(String email, String uid) async {
    if (email.toLowerCase() == _adminEmail.toLowerCase()) {
      await _firestore.collection(_usersCollection).doc(uid).set({
        'isAdmin': true,
        'isVerified': true,
      }, SetOptions(merge: true));
    }
  }

  Future<void> initializeUserVerification(
    String uid, {
    required String name,
    required String email,
    int? age,
    String? nidCardUrl,
    String? profileImageUrl,
    bool isInvestor = false,
    String? phoneNumber,
  }) async {
    await _firestore.collection(_usersCollection).doc(uid).set({
      'isVerified': false,
      'isAdmin': false,
      'name': name,
      'email': email,
      if (age != null) 'age': age,
      if (nidCardUrl != null) 'nidCardUrl': nidCardUrl,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      'isInvestor': isInvestor,
      if (phoneNumber != null && phoneNumber.isNotEmpty)
        'phoneNumber': phoneNumber,
    }, SetOptions(merge: true));
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final snapshot = await _firestore
          .collection(_usersCollection)
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Timeout fetching users'),
          );
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['uid'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getUserByUid(String uid) async {
    final doc = await _firestore.collection(_usersCollection).doc(uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      data['uid'] = doc.id;
      return data;
    }
    return {};
  }

  /// Lightweight check: is this user an investor?
  Future<bool> isUserInvestor(String uid) async {
    final doc = await _firestore.collection(_usersCollection).doc(uid).get();
    return doc.data()?['isInvestor'] ?? false;
  }

  Future<Map<String, bool>> getVerificationStatus(String uid) async {
    final doc = await _firestore.collection(_usersCollection).doc(uid).get();
    if (doc.exists) {
      return {
        'isVerified': doc.data()?['isVerified'] ?? false,
        'isAdmin': doc.data()?['isAdmin'] ?? false,
      };
    }
    return {'isVerified': false, 'isAdmin': false};
  }

  Stream<Map<String, dynamic>> streamUserVerificationStatus(String uid) {
    return _firestore.collection(_usersCollection).doc(uid).snapshots().map((
      doc,
    ) {
      if (doc.exists) {
        return {
          'isVerified': doc.data()?['isVerified'] ?? false,
          'isAdmin': doc.data()?['isAdmin'] ?? false,
        };
      }
      return {'isVerified': false, 'isAdmin': false};
    });
  }

  Future<void> approveUser(String uid) async {
    await _firestore.collection(_usersCollection).doc(uid).update({
      'isVerified': true,
    });
  }

  Future<void> rejectUser(String uid) async {
    await _firestore.collection(_usersCollection).doc(uid).update({
      'isVerified': false,
    });
  }

  Future<List<Map<String, dynamic>>> getAllPosts() async {
    final snapshot = await _firestore.collection(_postsCollection).get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<void> deletePost(String postId) async {
    await _firestore.collection(_postsCollection).doc(postId).delete();
  }

  Future<void> deleteUserAccount(String uid) async {
    await _firestore.collection(_usersCollection).doc(uid).delete();
    final user = _auth.currentUser;
    if (user != null && user.uid == uid) {
      await user.delete();
    }
  }
}
