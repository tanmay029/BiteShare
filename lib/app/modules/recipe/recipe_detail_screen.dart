// lib/app/modules/recipe/recipe_detail_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';
import '../../controllers/recipe_controller.dart';
import '../../controllers/comment_controller.dart';
import '../../controllers/bookmark_controller.dart';
import '../../controllers/subscription_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../data/models/recipe_model.dart';
import 'widgets/video_player_widget.dart';
import 'widgets/rating_dialog.dart';
import 'widgets/comments_section.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String recipeId;
  
  const RecipeDetailScreen({Key? key, required this.recipeId}) : super(key: key);

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final RecipeController _recipeController = Get.find<RecipeController>();
  final CommentController _commentController = Get.put(CommentController());
  final BookmarkController _bookmarkController = Get.find<BookmarkController>();
  final SubscriptionController _subscriptionController = Get.find<SubscriptionController>();
  final AuthController _authController = Get.find<AuthController>();

  RecipeModel? recipe;
  bool isLoading = true;
  int currentMediaIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadRecipe();
  }

  Future<void> _loadRecipe() async {
    try {
      // Load recipe details
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('recipes')
          .doc(widget.recipeId)
          .get();
      
      if (doc.exists) {
        recipe = RecipeModel.fromFirestore(doc);
        
        // Check if user can access premium content
        if (recipe!.isPremium && !_canAccessPremiumContent()) {
          _showSubscriptionDialog();
          return;
        }
        
        // Load comments
        await _commentController.loadComments(widget.recipeId);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load recipe');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  bool _canAccessPremiumContent() {
    if (recipe!.userId == _authController.userModel?.id) return true;
    return _subscriptionController.isSubscribedTo(recipe!.userId);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (recipe == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Recipe Not Found')),
        body: const Center(child: Text('Recipe not found')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRecipeHeader(),
                _buildMediaSection(),
                _buildRecipeContent(),
                _buildIngredientsSection(),
                _buildStepsSection(),
                _buildCommentsSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: recipe!.media.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: recipe!.media.first.url,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : Container(
                color: Colors.grey[300],
                child: const Icon(Icons.restaurant, size: 100),
              ),
      ),
      actions: [
        Obx(() {
          bool isBookmarked = _bookmarkController.isBookmarked(recipe!.id);
          return IconButton(
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: isBookmarked ? Colors.yellow : Colors.white,
            ),
            onPressed: () => _bookmarkController.toggleBookmark(recipe!.id),
          );
        }),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: _shareRecipe,
        ),
      ],
    );
  }

  Widget _buildRecipeHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  recipe!.title,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              if (recipe!.isPremium)
                const Chip(
                  label: Text('Premium'),
                  backgroundColor: Colors.yellow,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            recipe!.description,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          
          // Action Row
          Row(
            children: [
              Obx(() {
                bool isLiked = recipe!.likedBy.contains(_authController.userModel?.id);
                return GestureDetector(
                  onTap: () => _recipeController.likeRecipe(recipe!.id),
                  child: Row(
                    children: [
                      Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text('${recipe!.likes}'),
                    ],
                  ),
                );
              }),
              const SizedBox(width: 20),
              
              GestureDetector(
                onTap: () => _showRatingDialog(),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text('${recipe!.averageRating.toStringAsFixed(1)} (${recipe!.ratingsCount})'),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Author Info
              GestureDetector(
                onTap: () => Get.toNamed('/user/${recipe!.userId}'),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: recipe!.userProfileImage != null
                          ? CachedNetworkImageProvider(recipe!.userProfileImage!)
                          : null,
                      child: recipe!.userProfileImage == null
                          ? const Icon(Icons.person, size: 16)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      recipe!.userName,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMediaSection() {
    if (recipe!.media.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 250,
      child: PageView.builder(
        itemCount: recipe!.media.length,
        onPageChanged: (index) {
          setState(() {
            currentMediaIndex = index;
          });
        },
        itemBuilder: (context, index) {
          MediaItem media = recipe!.media[index];
          
          if (media.type == MediaType.image) {
            return GestureDetector(
              onTap: () => _showImageFullScreen(media.url),
              child: CachedNetworkImage(
                imageUrl: media.url,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          } else {
            return VideoPlayerWidget(videoUrl: media.url);
          }
        },
      ),
    );
  }

  Widget _buildRecipeContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (recipe!.tags.isNotEmpty) ...[
            Wrap(
              spacing: 8.0,
              children: recipe!.tags.map((tag) => Chip(
                label: Text('#$tag'),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              )).toList(),
            ),
            const SizedBox(height: 16),
          ],
          
          Row(
            children: [
              _buildInfoChip(Icons.timer, '30 min'), // You can add duration to model
              const SizedBox(width: 8),
              _buildInfoChip(Icons.restaurant, '4 servings'), // You can add servings to model
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildIngredientsSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ingredients',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...recipe!.ingredients.map((ingredient) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(ingredient)),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildStepsSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Instructions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...recipe!.steps.map((step) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${step.stepNumber}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.instruction,
                          style: const TextStyle(fontSize: 16),
                        ),
                        if (step.image != null) ...[
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: step.image!,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildCommentsSection() {
    return CommentsSection(
      recipeId: widget.recipeId,
      commentController: _commentController,
    );
  }

  void _shareRecipe() {
    Share.share(
      'Check out this amazing recipe: ${recipe!.title}\n\n${recipe!.description}',
      subject: recipe!.title,
    );
  }

  void _showImageFullScreen(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: PhotoView(
            imageProvider: CachedNetworkImageProvider(imageUrl),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          ),
        ),
      ),
    );
  }

  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (context) => RatingDialog(
        recipeId: recipe!.id,
        onRated: (rating) {
          _recipeController.rateRecipe(recipe!.id, rating);
        },
      ),
    );
  }

  void _showSubscriptionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Premium Content'),
        content: const Text(
          'This is premium content. Subscribe to the creator to access their exclusive recipes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Get.toNamed('/subscription/${recipe!.userId}');
            },
            child: const Text('Subscribe'),
          ),
        ],
      ),
    );
  }
}
