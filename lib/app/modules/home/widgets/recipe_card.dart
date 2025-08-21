// lib/app/modules/home/widgets/recipe_card.dart
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
            subtitle: Text(recipe.createdAt.toString()),
            trailing: recipe.isPremium
                ? const Chip(
                    label: Text('Premium'),
                    backgroundColor: Colors.yellow,
                  )
                : null,
          ),
          
          // Recipe Image/Video
          if (recipe.media.isNotEmpty)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                imageUrl: recipe.media.first.url,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
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
                Text(recipe.description),
                const SizedBox(height: 8),
                
                // Tags
                if (recipe.tags.isNotEmpty)
                  Wrap(
                    spacing: 8.0,
                    children: recipe.tags.map((tag) => Chip(
                      label: Text('#$tag'),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                Text('${recipe.commentsCount ?? 0}'),
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
  
  void _shareRecipe(RecipeModel recipe) {
    // Implement sharing functionality
  }
  
  void _bookmarkRecipe(RecipeModel recipe) {
    // Implement bookmark functionality
  }
}