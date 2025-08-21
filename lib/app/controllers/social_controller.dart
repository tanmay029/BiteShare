// lib/app/controllers/social_controller.dart
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/user_model.dart';
import 'auth_controller.dart';

class SocialController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();

  final RxList<UserModel> searchResults = <UserModel>[].obs;
  final RxBool isLoading = false.obs;

  Future<void> followUser(String targetUserId) async {
    try {
      String currentUserId = _authController.userModel!.id;
      
      await _firestore.runTransaction((transaction) async {
        // Update current user's following list
        DocumentReference currentUserRef = _firestore.collection('users').doc(currentUserId);
        DocumentSnapshot currentUserDoc = await transaction.get(currentUserRef);
        List<String> following = List<String>.from(currentUserDoc.get('following') ?? []);
        
        // Update target user's followers list
        DocumentReference targetUserRef = _firestore.collection('users').doc(targetUserId);
        DocumentSnapshot targetUserDoc = await transaction.get(targetUserRef);
        List<String> followers = List<String>.from(targetUserDoc.get('followers') ?? []);
        
        if (following.contains(targetUserId)) {
          // Unfollow
          following.remove(targetUserId);
          followers.remove(currentUserId);
        } else {
          // Follow
          following.add(targetUserId);
          followers.add(currentUserId);
          
          // Send follow notification
          await _sendFollowNotification(targetUserId, currentUserId);
        }
        
        transaction.update(currentUserRef, {'following': following});
        transaction.update(targetUserRef, {'followers': followers});
      });
      
      // Update local user data
      await _authController.loadUserData(currentUserId);
      
    } catch (e) {
      Get.snackbar('Error', 'Failed to follow/unfollow user');
    }
  }

  Future<void> searchUsers(String query) async {
    try {
      isLoading.value = true;
      
      if (query.isEmpty) {
        searchResults.clear();
        return;
      }

      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThanOrEqualTo: query + '\uf8ff')
          .limit(20)
          .get();

      searchResults.value = snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error searching users: $e');
    } finally {
      isLoading.value = false;
    }
  }

  bool isFollowing(String userId) {
    return _authController.userModel?.following.contains(userId) ?? false;
  }

  Future<void> _sendFollowNotification(String targetUserId, String followerUserId) async {
    await _firestore.collection('notifications').add({
      'type': 'follow',
      'targetUserId': targetUserId,
      'fromUserId': followerUserId,
      'createdAt': FieldValue.serverTimestamp(),
      'read': false,
    });
  }
}
