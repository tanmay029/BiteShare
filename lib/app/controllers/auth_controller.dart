// lib/app/controllers/auth_controller.dart
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/user_model.dart';
import '../data/services/firebase_service.dart';

class AuthController extends GetxController {
  static const String PROJECT_ID = 'biteshare-ee6c8';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseService _firebaseService = Get.find<FirebaseService>();

  final Rx<User?> _user = Rx<User?>(null);
  final Rx<UserModel?> _userModel = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;

  User? get user => _user.value;
  UserModel? get userModel => _userModel.value;
  bool get isLoggedIn => _user.value != null;

  @override
  void onInit() {
    super.onInit();
    _user.bindStream(_auth.authStateChanges());
    ever(_user, _setInitialScreen);
  }

  _setInitialScreen(User? user) async {
    if (user == null) {
      Get.offAllNamed('/auth');
    } else {
      await loadUserData(user.uid);
      Get.offAllNamed('/home');
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String username,
    required String displayName,
  }) async {
    try {
      isLoading.value = true;
      
      // Check if username is available
      final usernameExists = await _checkUsernameExists(username);
      if (usernameExists) {
        throw Exception('Username already exists');
      }

      // Create Firebase Auth user
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      UserModel newUser = UserModel(
        id: result.user!.uid,
        email: email,
        username: username,
        displayName: displayName,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(result.user!.uid)
          .set(newUser.toFirestore());

      _userModel.value = newUser;
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _userModel.value = null;
  }


Future<void> resetPassword(String email) async {
  try {
    await _auth.sendPasswordResetEmail(email: email);
    Get.snackbar('Success', 'Password reset email sent');
  } catch (e) {
    Get.snackbar('Error', 'Failed to send reset email: ${e.toString()}');
  }
}


  Future<void> loadUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _userModel.value = UserModel.fromFirestore(doc);
      }
    } catch (e) {
      print('Error loading user  $e');
    }
  }

  Future<bool> _checkUsernameExists(String username) async {
    final query = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    return query.docs.isNotEmpty;
  }

  Future<void> updateProfile({
    String? displayName,
    String? bio,
    String? profileImage,
    bool? isPrivate,
  }) async {
    if (_userModel.value == null) return;

    try {
      Map<String, dynamic> updates = {};
      if (displayName != null) updates['displayName'] = displayName;
      if (bio != null) updates['bio'] = bio;
      if (profileImage != null) updates['profileImage'] = profileImage;
      if (isPrivate != null) updates['isPrivate'] = isPrivate;

      await _firestore
          .collection('users')
          .doc(_userModel.value!.id)
          .update(updates);

      // Update local user model
      await loadUserData(_userModel.value!.id);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile');
    }
  }
}
