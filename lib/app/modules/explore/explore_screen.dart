// lib/app/modules/explore/explore_screen.dart
import 'package:biteshare/app/data/models/recipe_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/recipe_controller.dart';
import '../../controllers/social_controller.dart';
import '../home/widgets/recipe_card.dart';
import 'widgets/user_card.dart';

class ExploreScreen extends GetView<RecipeController> {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SocialController socialController = Get.find<SocialController>();
    
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Explore'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Recipes', icon: Icon(Icons.restaurant)),
              Tab(text: 'Trending', icon: Icon(Icons.trending_up)),
              Tab(text: 'Creators', icon: Icon(Icons.person)),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _showSearchDialog(context),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildRecipesTab(),
            _buildTrendingTab(),
            _buildCreatorsTab(socialController),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipesTab() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      
      return RefreshIndicator(
        onRefresh: controller.loadExploreRecipes,
        child: ListView.builder(
          itemCount: controller.searchResults.length,
          itemBuilder: (context, index) {
            return RecipeCard(recipe: controller.searchResults[index]);
          },
        ),
      );
    });
  }

  Widget _buildTrendingTab() {
    return Obx(() {
      // Sort by likes + rating combination
      List<RecipeModel> trendingRecipes = List.from(controller.searchResults);
      trendingRecipes.sort((a, b) {
        double scoreA = (a.likes * 0.7) + (a.averageRating * a.ratingsCount * 0.3);
        double scoreB = (b.likes * 0.7) + (b.averageRating * b.ratingsCount * 0.3);
        return scoreB.compareTo(scoreA);
      });
      
      return ListView.builder(
        itemCount: trendingRecipes.length,
        itemBuilder: (context, index) {
          return RecipeCard(recipe: trendingRecipes[index]);
        },
      );
    });
  }

  Widget _buildCreatorsTab(SocialController socialController) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search creators...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (query) {
              if (query.length > 2) {
                socialController.searchUsers(query);
              }
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              if (socialController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              
              return ListView.builder(
                itemCount: socialController.searchResults.length,
                itemBuilder: (context, index) {
                  return UserCard(user: socialController.searchResults[index]);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Recipes'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Enter recipe name...',
            prefixIcon: Icon(Icons.search),
          ),
          onSubmitted: (query) {
            Navigator.pop(context);
            controller.searchRecipes(query);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

