// lib/app/routes/app_routes.dart
abstract class AppRoutes {
  static const home = '/home';
  static const auth = '/auth';
  static const profile = '/profile';
  static const createRecipe = '/create-recipe';
  static const search = '/search';
  static const explore = '/explore';
  static const bookmarks = '/bookmarks';
  static const recipeDetails = '/recipe/:id';
  static const userProfile = '/user/:id';
  static const subscription = '/subscription/:creatorId';
  static const notifications = '/notifications';
  static const subscriptions = '/subscriptions';
}
