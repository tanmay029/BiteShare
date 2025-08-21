// lib/app/controllers/comment_controller.dart
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/comment_model.dart';
import 'auth_controller.dart';
import 'notification_controller.dart';

class CommentController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();
  final NotificationController _notificationController = Get.find<NotificationController>();

  final RxList<CommentModel> comments = <CommentModel>[].obs;
  final RxBool isLoading = false.obs;

  Future<void> loadComments(String recipeId) async {
    try {
      isLoading.value = true;
      
      QuerySnapshot snapshot = await _firestore
          .collection('comments')
          .where('recipeId', isEqualTo: recipeId)
          .orderBy('createdAt', descending: false)
          .get();

      comments.value = snapshot.docs
          .map((doc) => CommentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error loading comments: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addComment({
    required String recipeId,
    required String text,
    String? parentCommentId,
  }) async {
    try {
      String userId = _authController.userModel!.id;
      
      CommentModel comment = CommentModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        recipeId: recipeId,
        userId: userId,
        username: _authController.userModel!.username,
        userProfileImage: _authController.userModel!.profileImage,
        text: text,
        parentCommentId: parentCommentId,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('comments')
          .doc(comment.id)
          .set(comment.toFirestore());

      // Send notification to recipe owner
      await _sendCommentNotification(recipeId, text);

      // Reload comments
      await loadComments(recipeId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to add comment');
    }
  }

  Future<void> likeComment(String commentId) async {
    try {
      String userId = _authController.userModel!.id;
      DocumentReference commentRef = _firestore.collection('comments').doc(commentId);
      
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(commentRef);
        if (!snapshot.exists) return;
        
        List<String> likedBy = List<String>.from(snapshot.get('likedBy') ?? []);
        int likes = snapshot.get('likes') ?? 0;
        
        if (likedBy.contains(userId)) {
          likedBy.remove(userId);
          likes--;
        } else {
          likedBy.add(userId);
          likes++;
        }
        
        transaction.update(commentRef, {
          'likedBy': likedBy,
          'likes': likes,
        });
      });
      
      // Update local state
      int index = comments.indexWhere((c) => c.id == commentId);
      if (index != -1) {
        List<String> likedBy = List<String>.from(comments[index].likedBy);
        int likes = comments[index].likes;
        
        if (likedBy.contains(userId)) {
          likedBy.remove(userId);
          likes--;
        } else {
          likedBy.add(userId);
          likes++;
        }
        
        comments[index] = comments[index].copyWith(likedBy: likedBy, likes: likes);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to like comment');
    }
  }

  Future<void> _sendCommentNotification(String recipeId, String commentText) async {
    try {
      // Get recipe owner
      DocumentSnapshot recipeDoc = await _firestore.collection('recipes').doc(recipeId).get();
      if (!recipeDoc.exists) return;
      
      String recipeOwnerId = recipeDoc.get('userId');
      String recipeTitle = recipeDoc.get('title');
      
      if (recipeOwnerId != _authController.userModel!.id) {
        await _notificationController.sendNotification(
          targetUsrId: recipeOwnerId,
          type: 'comment',
          title: 'New Comment',
          body: '${_authController.userModel!.username} commented on your recipe "$recipeTitle"',
           {'recipeId': recipeId} as String, //error 
        );
      }
    } catch (e) {
      print('Error sending comment notification: $e');
    }
  }
}

