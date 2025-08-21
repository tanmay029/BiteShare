// lib/app/modules/recipe/widgets/comments_section.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../controllers/comment_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../data/models/comment_model.dart';

class CommentsSection extends StatelessWidget {
  final String recipeId;
  final CommentController commentController;
  
  const CommentsSection({
    Key? key, 
    required this.recipeId, 
    required this.commentController
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController textController = TextEditingController();
    final AuthController authController = Get.find<AuthController>();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Comments',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // Add comment field
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: authController.userModel?.profileImage != null
                    ? CachedNetworkImageProvider(authController.userModel!.profileImage!)
                    : null,
                child: authController.userModel?.profileImage == null
                    ? const Icon(Icons.person, size: 16)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: textController,
                  decoration: const InputDecoration(
                    hintText: 'Add a comment...',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (text) {
                    if (text.isNotEmpty) {
                      commentController.addComment(
                        recipeId: recipeId,
                        text: text,
                      );
                      textController.clear();
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Comments list
          Obx(() {
            if (commentController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (commentController.comments.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No comments yet. Be the first to comment!',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            }
            
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: commentController.comments.length,
              itemBuilder: (context, index) {
                CommentModel comment = commentController.comments[index];
                return _buildCommentItem(comment, authController);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCommentItem(CommentModel comment, AuthController authController) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: comment.userProfileImage != null
                ? CachedNetworkImageProvider(comment.userProfileImage!)
                : null,
            child: comment.userProfileImage == null
                ? Text(comment.username[0].toUpperCase())
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.username,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(comment.text),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => commentController.likeComment(comment.id),
                      child: Row(
                        children: [
                          Icon(
                            comment.likedBy.contains(authController.userModel?.id)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 16,
                            color: comment.likedBy.contains(authController.userModel?.id)
                                ? Colors.red
                                : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text('${comment.likes}', style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      _formatTimeAgo(comment.createdAt),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    Duration difference = DateTime.now().difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}