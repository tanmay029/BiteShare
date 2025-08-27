// lib/app/utils/dummy_data_generator.dart

// lib/app/utils/dummy_data_generator.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../data/models/user_model.dart';
import '../data/models/recipe_model.dart';

class DummyDataGenerator {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const Uuid _uuid = Uuid();

  static Future<void> generateDummyData() async {
    try {
      // Check if dummy data already exists
      QuerySnapshot existingUsers = await _firestore
          .collection('users')
          .where('username', whereIn: ['chef_maria', 'baker_john', 'spice_master', 'dessert_queen', 'healthy_chef'])
          .get();

      if (existingUsers.docs.isNotEmpty) {
        print('Dummy data already exists. Skipping generation.');
        return;
      }

      print('Generating dummy creators and recipes...');
      
      // Create dummy creators
      List<Map<String, dynamic>> creators = await _createDummyCreators();
      
      // Create dummy recipes for each creator
      await _createDummyRecipes(creators);
      
      // Add some interactions (likes, comments, follows)
      await _addDummyInteractions(creators);
      
      print('✅ Dummy data generation completed successfully!');
    } catch (e) {
      print('❌ Error generating dummy  $e');
    }
  }

  static Future<List<Map<String, dynamic>>> _createDummyCreators() async {
    List<Map<String, dynamic>> creators = [
      {
        'id': 'creator_maria',
        'email': 'chef.maria@biteshare.com',
        'username': 'chef_maria',
        'displayName': 'Chef Maria Rodriguez',
        'profileImage': 'https://images.unsplash.com/photo-1494790108755-2616c041c4db?w=400',
        'bio': '🍝 Mediterranean cuisine expert | 15+ years experience | Award-winning chef | Sharing family recipes passed down through generations',
        'isPrivate': false,
        'followers': [],
        'following': [],
        'isCreator': true,
        'createdAt': DateTime.now().subtract(const Duration(days: 365)),
      },
      {
        'id': 'creator_john',
        'email': 'baker.john@biteshare.com',
        'username': 'baker_john',
        'displayName': 'John "The Bread Master" Smith',
        'profileImage': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
        'bio': '🍞 Artisan baker | Sourdough specialist | Teaching bread making for 20+ years | Fresh daily recipes',
        'isPrivate': false,
        'followers': [],
        'following': [],
        'isCreator': true,
        'createdAt': DateTime.now().subtract(const Duration(days: 300)),
      },
      {
        'id': 'creator_priya',
        'email': 'spice.priya@biteshare.com',
        'username': 'spice_master',
        'displayName': 'Priya Sharma',
        'profileImage': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400',
        'bio': '🌶️ Indian cuisine master | Spice blending expert | Traditional recipes with modern twists | Mumbai-based chef',
        'isPrivate': false,
        'followers': [],
        'following': [],
        'isCreator': true,
        'createdAt': DateTime.now().subtract(const Duration(days: 200)),
      },
      {
        'id': 'creator_sophie',
        'email': 'dessert.sophie@biteshare.com',
        'username': 'dessert_queen',
        'displayName': 'Sophie Chen',
        'profileImage': 'https://images.unsplash.com/photo-1544725176-7c40e5a71c5e?w=400',
        'bio': '🍰 Pastry chef & dessert artist | French patisserie trained | Creating sweet masterpieces daily',
        'isPrivate': false,
        'followers': [],
        'following': [],
        'isCreator': true,
        'createdAt': DateTime.now().subtract(const Duration(days: 150)),
      },
      {
        'id': 'creator_alex',
        'email': 'healthy.alex@biteshare.com',
        'username': 'healthy_chef',
        'displayName': 'Alex Green',
        'profileImage': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400',
        'bio': '🥗 Nutritionist & healthy recipe creator | Plant-based specialist | Helping people eat better every day',
        'isPrivate': false,
        'followers': [],
        'following': [],
        'isCreator': true,
        'createdAt': DateTime.now().subtract(const Duration(days: 100)),
      },
    ];

    // Add creators to Firestore
    for (var creator in creators) {
      await _firestore.collection('users').doc(creator['id']).set({
        'email': creator['email'],
        'username': creator['username'],
        'displayName': creator['displayName'],
        'profileImage': creator['profileImage'],
        'bio': creator['bio'],
        'isPrivate': creator['isPrivate'],
        'followers': creator['followers'],
        'following': creator['following'],
        'createdAt': Timestamp.fromDate(creator['createdAt']),
        'isCreator': creator['isCreator'],
      });
      
      print('✅ Created creator: ${creator['displayName']}');
    }

    return creators;
  }

  static Future<void> _createDummyRecipes(List<Map<String, dynamic>> creators) async {
    // Recipes for Chef Maria (Mediterranean)
    await _createRecipesForCreator('creator_maria', [
      {
        'title': 'Authentic Greek Moussaka',
        'description': 'A traditional Greek dish with layers of eggplant, meat sauce, and béchamel. Perfect comfort food!',
        'ingredients': ['Eggplant (3 large)', 'Ground lamb (1 lb)', 'Onions (2 medium)', 'Tomatoes (4 ripe)', 'Olive oil', 'Béchamel sauce', 'Cheese (Kefalotiri)', 'Cinnamon', 'Oregano'],
        'tags': ['greek', 'mediterranean', 'comfort-food', 'lamb'],
        'isPremium': true,
        'difficulty': 'Advanced',
        'cookTime': '2 hours',
      },
      {
        'title': 'Classic Caesar Salad',
        'description': 'Crispy romaine lettuce with homemade Caesar dressing, croutons, and parmesan.',
        'ingredients': ['Romaine lettuce', 'Parmesan cheese', 'Croutons', 'Anchovies', 'Garlic', 'Lemon juice', 'Olive oil', 'Egg yolk'],
        'tags': ['salad', 'vegetarian', 'quick', 'classic'],
        'isPremium': false,
        'difficulty': 'Easy',
        'cookTime': '15 minutes',
      },
      {
        'title': 'Spanish Paella Valencia',
        'description': 'Traditional Spanish paella with saffron rice, chicken, rabbit, and green beans.',
        'ingredients': ['Bomba rice', 'Chicken', 'Rabbit', 'Green beans', 'Saffron', 'Paprika', 'Olive oil', 'Garlic'],
        'tags': ['spanish', 'rice', 'saffron', 'traditional'],
        'isPremium': true,
        'difficulty': 'Advanced',
        'cookTime': '1.5 hours',
      }
    ]);

    // Recipes for Baker John (Breads & Baking)
    await _createRecipesForCreator('creator_john', [
      {
        'title': 'Sourdough Starter Guide',
        'description': 'Complete guide to creating and maintaining your own sourdough starter from scratch.',
        'ingredients': ['Whole wheat flour', 'Bread flour', 'Water (filtered)', 'Time and patience'],
        'tags': ['sourdough', 'starter', 'fermentation', 'bread-basics'],
        'isPremium': false,
        'difficulty': 'Intermediate',
        'cookTime': '7 days',
      },
      {
        'title': 'Artisan Sourdough Loaf',
        'description': 'Perfect crusty sourdough bread with an open crumb structure. A baker\'s masterpiece!',
        'ingredients': ['Active sourdough starter', 'Bread flour', 'Water', 'Sea salt'],
        'tags': ['sourdough', 'artisan', 'bread', 'fermentation'],
        'isPremium': true,
        'difficulty': 'Advanced',
        'cookTime': '24 hours',
      },
      {
        'title': 'Classic French Baguettes',
        'description': 'Crispy outside, soft inside - the perfect French baguette recipe.',
        'ingredients': ['Bread flour', 'Water', 'Yeast', 'Salt'],
        'tags': ['french', 'baguette', 'bread', 'classic'],
        'isPremium': false,
        'difficulty': 'Intermediate',
        'cookTime': '4 hours',
      }
    ]);

    // Recipes for Spice Master Priya (Indian Cuisine)
    await _createRecipesForCreator('creator_priya', [
      {
        'title': 'Authentic Chicken Biryani',
        'description': 'Aromatic basmati rice layered with spiced chicken and cooked to perfection.',
        'ingredients': ['Basmati rice', 'Chicken', 'Yogurt', 'Onions', 'Garam masala', 'Saffron', 'Mint', 'Cilantro'],
        'tags': ['indian', 'biryani', 'chicken', 'rice', 'spicy'],
        'isPremium': true,
        'difficulty': 'Advanced',
        'cookTime': '2 hours',
      },
      {
        'title': 'Homemade Garam Masala',
        'description': 'Learn to make your own garam masala spice blend for authentic Indian flavors.',
        'ingredients': ['Cardamom pods', 'Cinnamon sticks', 'Cloves', 'Black peppercorns', 'Cumin seeds', 'Coriander seeds'],
        'tags': ['spices', 'indian', 'seasoning', 'homemade'],
        'isPremium': false,
        'difficulty': 'Easy',
        'cookTime': '30 minutes',
      },
      {
        'title': 'Butter Chicken (Murgh Makhani)',
        'description': 'Creamy, rich, and flavorful butter chicken - a restaurant favorite at home!',
        'ingredients': ['Chicken', 'Tomatoes', 'Cream', 'Butter', 'Garam masala', 'Ginger-garlic paste', 'Cashews'],
        'tags': ['indian', 'chicken', 'curry', 'creamy', 'popular'],
        'isPremium': false,
        'difficulty': 'Intermediate',
        'cookTime': '1 hour',
      }
    ]);

    // Recipes for Dessert Queen Sophie (Pastries & Desserts)
    await _createRecipesForCreator('creator_sophie', [
      {
        'title': 'French Macarons Masterclass',
        'description': 'Perfect macarons with smooth tops, ruffled feet, and delicious fillings.',
        'ingredients': ['Almond flour', 'Powdered sugar', 'Egg whites', 'Food coloring', 'Various fillings'],
        'tags': ['french', 'macarons', 'pastry', 'advanced', 'colorful'],
        'isPremium': true,
        'difficulty': 'Advanced',
        'cookTime': '3 hours',
      },
      {
        'title': 'Chocolate Lava Cake',
        'description': 'Warm chocolate cake with a molten center - the ultimate chocolate dessert!',
        'ingredients': ['Dark chocolate', 'Butter', 'Eggs', 'Sugar', 'Flour', 'Vanilla'],
        'tags': ['chocolate', 'dessert', 'warm', 'molten', 'indulgent'],
        'isPremium': false,
        'difficulty': 'Intermediate',
        'cookTime': '45 minutes',
      }
    ]);

    // Recipes for Healthy Chef Alex (Healthy & Plant-based)
    await _createRecipesForCreator('creator_alex', [
      {
        'title': 'Rainbow Buddha Bowl',
        'description': 'Nutritious and colorful bowl packed with vegetables, quinoa, and tahini dressing.',
        'ingredients': ['Quinoa', 'Kale', 'Sweet potato', 'Chickpeas', 'Avocado', 'Tahini', 'Lemon', 'Hemp seeds'],
        'tags': ['healthy', 'vegan', 'bowl', 'nutritious', 'colorful'],
        'isPremium': false,
        'difficulty': 'Easy',
        'cookTime': '30 minutes',
      },
      {
        'title': 'Green Smoothie Power Pack',
        'description': 'Energizing green smoothie packed with nutrients to start your day right.',
        'ingredients': ['Spinach', 'Banana', 'Mango', 'Chia seeds', 'Coconut water', 'Mint'],
        'tags': ['smoothie', 'healthy', 'vegan', 'breakfast', 'energy'],
        'isPremium': false,
        'difficulty': 'Easy',
        'cookTime': '5 minutes',
      }
    ]);
  }

  static Future<void> _createRecipesForCreator(String creatorId, List<Map<String, dynamic>> recipeData) async {
    for (int i = 0; i < recipeData.length; i++) {
      var recipe = recipeData[i];
      String recipeId = _uuid.v4();
      
      // Create recipe steps
      List<Map<String, dynamic>> steps = [
        {
          'stepNumber': 1,
          'instruction': 'Gather and prepare all ingredients as listed.',
          'image': null,
        },
        {
          'stepNumber': 2,
          'instruction': 'Follow the detailed cooking instructions for this recipe.',
          'image': null,
        },
        {
          'stepNumber': 3,
          'instruction': 'Plate beautifully and serve immediately. Enjoy your meal!',
          'image': null,
        },
      ];

      DateTime createdDate = DateTime.now().subtract(Duration(days: (i + 1) * 10));
      
      await _firestore.collection('recipes').doc(recipeId).set({
        'userId': creatorId,
        'title': recipe['title'],
        'description': recipe['description'],
        'ingredients': recipe['ingredients'],
        'steps': steps,
        'tags': recipe['tags'],
        'media': [],
        'likes': (15 + (i * 5)) + (creatorId.hashCode % 20), // Random-ish likes
        'likedBy': [],
        'averageRating': 4.0 + ((i % 3) * 0.3), // Ratings between 4.0-4.6
        'ratingsCount': 5 + (i * 2),
        'isPremium': recipe['isPremium'],
        'createdAt': Timestamp.fromDate(createdDate),
        'updatedAt': Timestamp.fromDate(createdDate),
      });
      
      print('   ✅ Created recipe: ${recipe['title']}');
    }
  }

  static Future<void> _addDummyInteractions(List<Map<String, dynamic>> creators) async {
    print('Adding dummy interactions (follows, likes)...');
    
    // Create some mutual follows between creators
    await _addFollowRelationship('creator_maria', 'creator_john');
    await _addFollowRelationship('creator_john', 'creator_priya');
    await _addFollowRelationship('creator_priya', 'creator_sophie');
    await _addFollowRelationship('creator_sophie', 'creator_alex');
    await _addFollowRelationship('creator_alex', 'creator_maria');
    await _addFollowRelationship('creator_maria', 'creator_priya');
    
    print('✅ Added follow relationships between creators');
  }

  static Future<void> _addFollowRelationship(String followerId, String followeeId) async {
    // Add to follower's following list
    await _firestore.collection('users').doc(followerId).update({
      'following': FieldValue.arrayUnion([followeeId])
    });
    
    // Add to followee's followers list
    await _firestore.collection('users').doc(followeeId).update({
      'followers': FieldValue.arrayUnion([followerId])
    });
  }

  static Future<void> clearDummyData() async {
    print('Clearing existing dummy data...');
    
    // Delete dummy users
    List<String> dummyUserIds = ['creator_maria', 'creator_john', 'creator_priya', 'creator_sophie', 'creator_alex'];
    
    for (String userId in dummyUserIds) {
      await _firestore.collection('users').doc(userId).delete();
    }
    
    // Delete dummy recipes
    QuerySnapshot recipes = await _firestore
        .collection('recipes')
        .where('userId', whereIn: dummyUserIds)
        .get();
    
    for (var doc in recipes.docs) {
      await doc.reference.delete();
    }
    
    print('✅ Dummy data cleared');
  }
}


// import 'dart:math';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../data/models/user_model.dart';
// import '../data/models/recipe_model.dart';

// class DummyDataGenerator {
//   static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   static Future<void> generateDummyData() async {
//     await _createDummyUsers();
//     await _createDummyRecipes();
//   }

//   static Future<void> _createDummyUsers() async {
//     List<Map<String, dynamic>> dummyUsers = [
//       {
//         'id': 'user1',
//         'email': 'chef.maria@example.com',
//         'username': 'chef_maria',
//         'displayName': 'Chef Maria Rodriguez',
//         'bio': 'Professional chef specializing in Mediterranean cuisine',
//         'isCreator': true,
//         'followers': ['user2', 'user3'],
//         'following': ['user2'],
//       },
//       {
//         'id': 'user2',
//         'email': 'baker.john@example.com',
//         'username': 'baker_john',
//         'displayName': 'John Baker',
//         'bio': 'Passionate home baker sharing family recipes',
//         'isCreator': true,
//         'followers': ['user1', 'user3'],
//         'following': ['user1'],
//       },
//       // Add more dummy users...
//     ];

//     for (var userData in dummyUsers) {
//       UserModel user = UserModel(
//         id: userData['id'],
//         email: userData['email'],
//         username: userData['username'],
//         displayName: userData['displayName'],
//         bio: userData['bio'],
//         isCreator: userData['isCreator'],
//         followers: List<String>.from(userData['followers']),
//         following: List<String>.from(userData['following']),
//         createdAt: DateTime.now().subtract(Duration(days: 30)),
//       );

//       await _firestore.collection('users').doc(user.id).set(user.toFirestore());
//     }
//   }

//   static Future<void> _createDummyRecipes() async {
//     List<Map<String, dynamic>> dummyRecipes = [
//       {
//         'userId': 'user1',
//         'title': 'Authentic Spanish Paella',
//         'description': 'A traditional Valencian paella recipe passed down through generations',
//         'ingredients': ['Rice', 'Saffron', 'Chicken', 'Rabbit', 'Green beans', 'Lima beans', 'Olive oil'],
//         'tags': ['Spanish', 'Traditional', 'Main Course'],
//         'isPremium': false,
//       },
//       {
//         'userId': 'user2',
//         'title': 'Artisan Sourdough Bread',
//         'description': 'Learn to make perfect sourdough with this detailed guide',
//         'ingredients': ['Sourdough starter', 'Bread flour', 'Water', 'Salt'],
//         'tags': ['Bread', 'Artisan', 'Fermentation'],
//         'isPremium': true,
//       },
//       // Add more dummy recipes...
//     ];

//     for (var recipeData in dummyRecipes) {
//       List<RecipeStep> steps = [
//         RecipeStep(stepNumber: 1, instruction: 'Prepare all ingredients'),
//         RecipeStep(stepNumber: 2, instruction: 'Mix and combine'),
//         RecipeStep(stepNumber: 3, instruction: 'Cook according to directions'),
//       ];

//       RecipeModel recipe = RecipeModel(
//         id: DateTime.now().millisecondsSinceEpoch.toString(),
//         userId: recipeData['userId'],
//         title: recipeData['title'],
//         description: recipeData['description'],
//         ingredients: List<String>.from(recipeData['ingredients']),
//         steps: steps,
//         tags: List<String>.from(recipeData['tags']),
//         media: [], // Add dummy media URLs if needed
//         isPremium: recipeData['isPremium'],
//         createdAt: DateTime.now().subtract(Duration(days: Random().nextInt(30))),
//         updatedAt: DateTime.now(),
//         likes: Random().nextInt(100), 
//         userName: '',
//       );

//       await _firestore.collection('recipes').doc(recipe.id).set(recipe.toFirestore());
//     }
//   }
// }
