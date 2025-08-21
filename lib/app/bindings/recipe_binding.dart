// lib/app/bindings/recipe_binding.dart
import 'package:get/get.dart';
import '../controllers/recipe_controller.dart';
import '../controllers/comment_controller.dart';

class RecipeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RecipeController>(() => RecipeController());
    Get.lazyPut<CommentController>(() => CommentController());
  }
}
