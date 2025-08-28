// lib/app/modules/home/widgets/recipe_card.dart - Update to handle optional images
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/recipe_model.dart';
import '../../../controllers/recipe_controller.dart';
import '../../../controllers/auth_controller.dart';

class RecipeCard extends StatelessWidget {
  final RecipeModel recipe;
  
  const RecipeCard({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final RecipeController recipeController = Get.find<RecipeController>();
    final AuthController authController = Get.find<AuthController>();
    
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recipe Header with User Info
          ListTile(
            leading: CircleAvatar(
              backgroundImage: recipe.userProfileImage != null
                  ? CachedNetworkImageProvider(recipe.userProfileImage!)
                  : null,
              child: recipe.userProfileImage == null
                  ? const Icon(Icons.person)
                  : null,
            ),
            title: Text(recipe.userName),
            subtitle: Text(_formatTimeAgo(recipe.createdAt)),
            trailing: recipe.isPremium
                ? const Chip(
                    label: Text('Premium'),
                    backgroundColor: Colors.yellow,
                  )
                : null,
          ),
          
          // ✅ UPDATED: Optional Recipe Image/Video
          if (recipe.media.isNotEmpty)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                imageUrl: recipe.media.first.url,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.error),
                  ),
                ),
              ),
            )
          else
            // ✅ NEW: Placeholder for recipes without images
            Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.orange.shade200,
                    Colors.orange.shade100,
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.restaurant,
                      size: 32,
                      color: Colors.orange.shade600,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Recipe by ${recipe.userName}',
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Recipe Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  recipe.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                
                // Recipe Info
                Row(
                  children: [
                    Icon(Icons.restaurant_menu, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${recipe.ingredients.length} ingredients',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.list, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${recipe.steps.length} steps',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Tags
                if (recipe.tags.isNotEmpty)
                  Wrap(
                    spacing: 4.0,
                    children: recipe.tags.take(3).map((tag) => Chip(
                      label: Text('#$tag'),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      labelStyle: const TextStyle(fontSize: 10),
                    )).toList(),
                  ),
              ],
            ),
          ),
          
          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    recipe.likedBy.contains(authController.userModel?.id)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: recipe.likedBy.contains(authController.userModel?.id)
                        ? Colors.red
                        : null,
                  ),
                  onPressed: () => recipeController.likeRecipe(recipe.id),
                ),
                Text('${recipe.likes}'),
                const SizedBox(width: 16),
                
                IconButton(
                  icon: const Icon(Icons.comment),
                  onPressed: () => Get.toNamed('/recipe/${recipe.id}/comments'),
                ),
                Text('${recipe.commentsCount}'),
                const SizedBox(width: 16),
                
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () => _shareRecipe(recipe),
                ),
                
                const Spacer(),
                
                // Rating
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    Text(' ${recipe.averageRating.toStringAsFixed(1)}'),
                  ],
                ),
                
                IconButton(
                  icon: const Icon(Icons.bookmark_border),
                  onPressed: () => _bookmarkRecipe(recipe),
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
  
  void _shareRecipe(RecipeModel recipe) {
    // Implement sharing functionality
  }
  
  void _bookmarkRecipe(RecipeModel recipe) {
    // Implement bookmark functionality
  }
}
