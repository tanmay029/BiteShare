// lib/app/bindings/initial_binding.dart
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/recipe_controller.dart';
import '../controllers/social_controller.dart';
import '../controllers/subscription_controller.dart';
import '../data/services/firebase_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<FirebaseService>(FirebaseService());
    Get.put<AuthController>(AuthController());
    Get.put<RecipeController>(RecipeController());
    Get.put<SocialController>(SocialController());
    Get.put<SubscriptionController>(SubscriptionController());
  }
}