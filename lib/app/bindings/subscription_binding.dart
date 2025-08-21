// lib/app/bindings/subscription_binding.dart
import 'package:get/get.dart';
import '../controllers/subscription_controller.dart';

class SubscriptionBinding extends Bindings {
  @override
  dependencies() {
    Get.lazyPut<SubscriptionController>(() => SubscriptionController());
  }
}