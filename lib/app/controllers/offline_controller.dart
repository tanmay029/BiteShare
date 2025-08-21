// // lib/app/controllers/offline_controller.dart
// import 'package:biteshare/app/data/models/recipe_model.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';

// class OfflineController extends GetxController {
//   final RxBool isOnline = true.obs;
  
//   Future<void> cacheRecipes(List<RecipeModel> recipes) async {
//     final prefs = await SharedPreferences.getInstance();
//     final recipesJson = recipes.map((r) => r.toFirestore()).toList();
//     await prefs.setString('cached_recipes', jsonEncode(recipesJson));
//   }
  
//   Future<List<RecipeModel>> getCachedRecipes() async {
//     final prefs = await SharedPreferences.getInstance();
//     final cachedData = prefs.getString('cached_recipes');
//     if (cachedData != null) {
//       final List<dynamic> recipesJson = jsonDecode(cachedData);
//       return recipesJson.map((json) => RecipeModel.fromFirestore(
//         // Convert map to DocumentSnapshot mock
//       )).toList();
//     }
//     return [];
//   }
// }
