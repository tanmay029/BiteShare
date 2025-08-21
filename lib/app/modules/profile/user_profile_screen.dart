// lib/app/modules/profile/user_profile_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/social_controller.dart';
import '../../controllers/recipe_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/subscription_controller.dart';
import '../../data/models/user_model.dart';
import '../../data/models/recipe_model.dart';
import '../home/widgets/recipe_card.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;
  
  const UserProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SocialController _socialController = Get.find<SocialController>();
  final RecipeController _recipeController = Get.find<RecipeController>();
  final AuthController _authController = Get.find<AuthController>();
  final SubscriptionController _subscriptionController = Get.find<SubscriptionController>();

  UserModel? user;
  List<RecipeModel> userRecipes = [];
  bool isLoading = true;
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      // Load user data
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();
      
      if (userDoc.exists) {
        user = UserModel.fromFirestore(userDoc);
        
        // Check if current user is following this user
        isFollowing = _socialController.isFollowing(widget.userId);
        
        // Load user's recipes
        QuerySnapshot recipesSnapshot = await FirebaseFirestore.instance
            .collection('recipes')
            .where('userId', isEqualTo: widget.userId)
            .orderBy('createdAt', descending: true)
            .get();
        
        userRecipes = recipesSnapshot.docs
            .map((doc) => RecipeModel.fromFirestore(doc))
            .toList();
      }
    } catch (e) {
      print('Error loading user  $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('User Not Found')),
        body: const Center(child: Text('User not found')),
      );
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.orange[400]!,
                        Colors.orange!,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ];
        },
        body: Column(
          children: [
            _buildProfileHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildRecipesTab(),
                  _buildAboutTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Profile Picture
          CircleAvatar(
            radius: 50,
            backgroundImage: user!.profileImage != null
                ? CachedNetworkImageProvider(user!.profileImage!)
                : null,
            child: user!.profileImage == null
                ? Text(
                    user!.username[0].toUpperCase(),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          
          // Name and Username
          Text(
            user!.displayName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            '@${user!.username}',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          
          if (user!.bio != null) ...[
            const SizedBox(height: 8),
            Text(
              user!.bio!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ],
          
          const SizedBox(height: 16),
          
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatColumn('Recipes', userRecipes.length.toString()),
              _buildStatColumn('Followers', user!.followers.length.toString()),
              _buildStatColumn('Following', user!.following.length.toString()),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Action Buttons
          if (widget.userId != _authController.userModel?.id) ...[
            Row(
              children: [
                Expanded(
                  child: Obx(() {
                    bool following = _socialController.isFollowing(widget.userId);
                    return ElevatedButton(
                      onPressed: () {
                        _socialController.followUser(widget.userId);
                        setState(() {
                          isFollowing = !isFollowing;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: following ? Colors.grey : Colors.orange,
                      ),
                      child: Text(following ? 'Following' : 'Follow'),
                    );
                  }),
                ),
                const SizedBox(width: 12),
                
                if (user!.isCreator) ...[
                  Expanded(
                    child: Obx(() {
                      bool isSubscribed = _subscriptionController.isSubscribedTo(widget.userId);
                      return ElevatedButton(
                        onPressed: () {
                          if (isSubscribed) {
                            Get.toNamed('/subscriptions');
                          } else {
                            Get.toNamed('/subscription/${widget.userId}');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSubscribed ? Colors.yellow : Colors.blue,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(isSubscribed ? Icons.star : Icons.star_border),
                            const SizedBox(width: 4),
                            Text(isSubscribed ? 'Subscribed' : 'Subscribe'),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String count) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.orange,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.orange,
        tabs: const [
          Tab(text: 'Recipes', icon: Icon(Icons.restaurant)),
          Tab(text: 'About', icon: Icon(Icons.info)),
        ],
      ),
    );
  }

  Widget _buildRecipesTab() {
    if (userRecipes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No recipes yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: userRecipes.length,
      itemBuilder: (context, index) {
        RecipeModel recipe = userRecipes[index];
        
        // Check if user can access premium content
        if (recipe.isPremium && !_canAccessPremiumContent()) {
          return _buildPremiumRecipeCard(recipe);
        }
        
        return RecipeCard(recipe: recipe);
      },
    );
  }

  Widget _buildAboutTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (user!.bio != null) ...[
            const Text(
              'About',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(user!.bio!),
            const SizedBox(height: 20),
          ],
          
          const Text(
            'Joined',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '${user!.createdAt.toString().split(' ')[0]}',
            style: const TextStyle(color: Colors.grey),
          ),
          
          if (user!.isCreator) ...[
            const SizedBox(height: 20),
            const Text(
              'Creator Stats',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Recipes'),
                        Text(
                          userRecipes.length.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Premium Recipes'),
                        Text(
                          userRecipes.where((r) => r.isPremium).length.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Likes'),
                        Text(
                          userRecipes.fold(0, (sum, recipe) => sum + recipe.likes).toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPremiumRecipeCard(RecipeModel recipe) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          // Blurred content
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    'Premium Content',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    'Subscribe to unlock',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          
          // Recipe title overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => Get.toNamed('/subscription/${widget.userId}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                    ),
                    child: const Text('Subscribe to Unlock'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canAccessPremiumContent() {
    if (widget.userId == _authController.userModel?.id) return true;
    return _subscriptionController.isSubscribedTo(widget.userId);
  }
}
