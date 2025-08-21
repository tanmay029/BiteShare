// lib/app/routes/app_pages.dart
import 'package:biteshare/app/bindings/auth_binding.dart';
import 'package:biteshare/app/bindings/bookmark_binding.dart';
import 'package:biteshare/app/bindings/notification_binding.dart';
import 'package:biteshare/app/bindings/recipe_binding.dart';
import 'package:biteshare/app/bindings/subscription_binding.dart';
import 'package:biteshare/app/routes/app_routes.dart';
import 'package:get/get.dart';
import '../bindings/initial_binding.dart';
import '../modules/auth/auth_screen.dart';
import '../modules/home/home_screen.dart';
import '../modules/profile/profile_screen.dart';
import '../modules/profile/user_profile_screen.dart';
import '../modules/recipe/create_recipe_screen.dart';
import '../modules/recipe/recipe_detail_screen.dart';
import '../modules/explore/explore_screen.dart';
import '../modules/bookmarks/bookmarks_screen.dart';
import '../modules/notifications/notifications_screen.dart';
import '../modules/subscription/subscription_screen.dart';

class AppPages {
  static const initial = AppRoutes.auth;

  static final routes = [
    // Auth
    GetPage(
      name: AppRoutes.auth,
      page: () => const AuthScreen(),
      binding: AuthBinding(),
    ),

    // Home
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: InitialBinding(),
    ),

    // Profile
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      binding: InitialBinding(),
    ),

    // User Profile
    GetPage(
      name: '/user/:id',
      page: () => UserProfileScreen(userId: Get.parameters['id']!),
      binding: InitialBinding(),
    ),

    // Recipe
    GetPage(
      name: AppRoutes.createRecipe,
      page: () => const CreateRecipeScreen(),
      binding: RecipeBinding(),
    ),

    GetPage(
      name: '/recipe/:id',
      page: () => RecipeDetailScreen(recipeId: Get.parameters['id']!),
      binding: RecipeBinding(),
    ),

    // Explore
    GetPage(
      name: AppRoutes.explore,
      page: () => const ExploreScreen(),
      binding: InitialBinding(),
    ),

    // Bookmarks
    GetPage(
      name: AppRoutes.bookmarks,
      page: () => const BookmarksScreen(),
      binding: BookmarkBinding(),
    ),

    // Notifications
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsScreen(),
      binding: NotificationBinding(),
    ),

    // Subscriptions
    GetPage(
      name: AppRoutes.subscriptions,
      page: () => const SubscriptionScreen(),
      binding: SubscriptionBinding(),
    ),

    GetPage(
      name: '/subscription/:creatorId',
      page: () => SubscriptionScreen(creatorId: Get.parameters['creatorId']!),
      binding: SubscriptionBinding(),
    ),
    GetPage(
      name: '/recipe/:id',
      page: () => RecipeDetailScreen(recipeId: Get.parameters['id']!),
      binding: RecipeBinding(),
    ),

    GetPage(
      name: '/user/:id',
      page: () => UserProfileScreen(userId: Get.parameters['id']!),
      binding: InitialBinding(),
    ),
  ];
}
