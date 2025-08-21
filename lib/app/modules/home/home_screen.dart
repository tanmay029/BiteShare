// lib/app/modules/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/recipe_controller.dart';
import '../../controllers/auth_controller.dart';
import 'widgets/recipe_card.dart';

class HomeScreen extends GetView<RecipeController> {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Feed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Get.toNamed('/search'),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.toNamed('/create-recipe'),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (controller.feedRecipes.isEmpty) {
          return const Center(
            child: Text('No recipes to show. Follow some creators!'),
          );
        }
        
        return RefreshIndicator(
          onRefresh: controller.loadFeedRecipes,
          child: ListView.builder(
            itemCount: controller.feedRecipes.length,
            itemBuilder: (context, index) {
              return RecipeCard(recipe: controller.feedRecipes[index]);
            },
          ),
        );
      }),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Saved'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              // Already on home
              break;
            case 1:
              Get.toNamed('/explore');
              break;
            case 2:
              Get.toNamed('/bookmarks');
              break;
            case 3:
              Get.toNamed('/profile');
              break;
          }
        },
      ),
    );
  }
}


