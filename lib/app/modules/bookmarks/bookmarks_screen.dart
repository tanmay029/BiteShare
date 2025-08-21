// lib/app/modules/bookmarks/bookmarks_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/bookmark_controller.dart';
import '../home/widgets/recipe_card.dart';

class BookmarksScreen extends GetView<BookmarkController> {
  const BookmarksScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Recipes'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (controller.bookmarkedRecipes.isEmpty) {
          return _buildEmptyState();
        }
        
        return RefreshIndicator(
          onRefresh: controller.loadBookmarks,
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: controller.bookmarkedRecipes.length,
            itemBuilder: (context, index) {
              return RecipeCard(
                recipe: controller.bookmarkedRecipes[index],
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Saved Recipes',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start bookmarking recipes you love!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Get.toNamed('/explore'),
            child: const Text('Explore Recipes'),
          ),
        ],
      ),
    );
  }
}
