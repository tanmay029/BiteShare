// lib/app/modules/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import '../../controllers/auth_controller.dart';
import '../../controllers/recipe_controller.dart';
import '../../controllers/subscription_controller.dart';
import '../../data/services/firebase_service.dart';
import '../home/widgets/recipe_card.dart';

class ProfileScreen extends GetView<AuthController> {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final RecipeController recipeController = Get.find<RecipeController>();
    final SubscriptionController subscriptionController = Get.find<SubscriptionController>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsSheet(context),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.userModel == null) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return SingleChildScrollView(
          child: Column(
            children: [
              _buildProfileHeader(context),
              const SizedBox(height: 20),
              _buildStatsRow(),
              const SizedBox(height: 20),
              _buildSubscriptionSection(subscriptionController),
              const SizedBox(height: 20),
              _buildRecipesList(recipeController),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _changeProfilePicture(context),
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: controller.userModel!.profileImage != null
                      ? CachedNetworkImageProvider(controller.userModel!.profileImage!)
                      : null,
                  child: controller.userModel!.profileImage == null
                      ? const Icon(Icons.person, size: 60)
                      : null,
                ),
                const Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.camera_alt, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            controller.userModel!.displayName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            '@${controller.userModel!.username}',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          if (controller.userModel!.bio != null) ...[
            const SizedBox(height: 8),
            Text(
              controller.userModel!.bio!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _editProfile(context),
                child: const Text('Edit Profile'),
              ),
              if (controller.userModel!.isCreator)
                ElevatedButton(
                  onPressed: () => Get.toNamed('/creator-dashboard'),
                  child: const Text('Creator Dashboard'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem('Recipes', '${controller.userModel?.recipesCount ?? 0}'),
        _buildStatItem('Followers', '${controller.userModel?.followers.length ?? 0}'),
        _buildStatItem('Following', '${controller.userModel?.following.length ?? 0}'),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildSubscriptionSection(SubscriptionController subscriptionController) {
    return Obx(() {
      if (subscriptionController.userSubscriptions.isEmpty) {
        return const SizedBox.shrink();
      }
      
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Active Subscriptions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...subscriptionController.userSubscriptions.map((sub) {
              return ListTile(
                leading: const Icon(Icons.star, color: Colors.yellow),
                title: Text('Subscription to Creator'),
                subtitle: Text('Expires: ${sub.endDate.toString().split(' ')[0]}'),
                trailing: sub.isActive 
                    ? const Chip(label: Text('Active'), backgroundColor: Colors.green)
                    : const Chip(label: Text('Expired'), backgroundColor: Colors.grey),
              );
            }).toList(),
          ],
        ),
      );
    });
  }

  Widget _buildRecipesList(RecipeController recipeController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'My Recipes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (recipeController.userRecipes.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const Icon(Icons.restaurant, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No recipes yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Get.toNamed('/create-recipe'),
                    child: const Text('Create Your First Recipe'),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recipeController.userRecipes.length,
            itemBuilder: (context, index) {
              return RecipeCard(recipe: recipeController.userRecipes[index]);
            },
          );
        }),
      ],
    );
  }

  void _changeProfilePicture(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      try {
        FirebaseService firebaseService = Get.find<FirebaseService>();
        String imageUrl = await firebaseService.uploadImage(
          File(image.path), 
          'profile_images'
        );
        
        await controller.updateProfile(profileImage: imageUrl);
        Get.snackbar('Success', 'Profile picture updated');
      } catch (e) {
        Get.snackbar('Error', 'Failed to update profile picture');
      }
    }
  }

  void _editProfile(BuildContext context) {
    final nameController = TextEditingController(text: controller.userModel!.displayName);
    final bioController = TextEditingController(text: controller.userModel!.bio ?? '');
    bool isPrivate = controller.userModel!.isPrivate;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Display Name'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bioController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Bio'),
              ),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setState) {
                  return SwitchListTile(
                    title: const Text('Private Account'),
                    value: isPrivate,
                    onChanged: (value) => setState(() => isPrivate = value),
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await controller.updateProfile(
                displayName: nameController.text,
                bio: bioController.text,
                isPrivate: isPrivate,
              );
              Navigator.pop(context);
              Get.snackbar('Success', 'Profile updated');
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            onTap: () => Get.toNamed('/notifications'),
          ),
          ListTile(
            leading: const Icon(Icons.bookmark),
            title: const Text('Saved Recipes'),
            onTap: () => Get.toNamed('/bookmarks'),
          ),
          ListTile(
            leading: const Icon(Icons.subscriptions),
            title: const Text('Subscriptions'),
            onTap: () => Get.toNamed('/subscriptions'),
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            onTap: () => Get.toNamed('/help'),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              controller.signOut();
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
