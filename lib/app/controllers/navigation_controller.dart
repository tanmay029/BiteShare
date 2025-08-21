// lib/app/controllers/navigation_controller.dart
import 'package:get/get.dart';

class NavigationController extends GetxController {
  final RxInt currentIndex = 0.obs;
  
  void changeIndex(int index) {
    currentIndex.value = index;
    
    switch (index) {
      case 0:
        Get.toNamed('/home');
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
  }
}
