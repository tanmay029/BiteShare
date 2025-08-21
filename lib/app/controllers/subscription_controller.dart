// lib/app/controllers/subscription_controller.dart
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/subscription_model.dart';
import 'auth_controller.dart';

class SubscriptionController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String RAZORPAY_KEY_ID = 'rzp_test_YOUR_KEY_ID';
  final AuthController _authController = Get.find<AuthController>();
  late Razorpay _razorpay;

  final RxList<SubscriptionModel> userSubscriptions = <SubscriptionModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void onClose() {
    super.onClose();
    _razorpay.clear();
  }

  Future<void> subscribeToCreator({
    required String creatorId,
    required SubscriptionPlan plan,
  }) async {
    try {
      // Calculate amount based on plan
      double amount = plan.type == SubscriptionType.monthly ? 
          plan.monthlyPrice : plan.yearlyPrice;

      var options = {
        'key': 'YOUR_RAZORPAY_KEY', // Replace with your key
        'amount': (amount * 100).toInt(), // Amount in paise
        'name': 'Recipe App Subscription',
        'description': 'Subscription to ${plan.creatorName}',
        'prefill': {
          'contact': _authController.userModel?.email,
          'email': _authController.userModel?.email
        },
        'notes': {
          'creatorId': creatorId,
          'planType': plan.type.toString(),
          'userId': _authController.userModel?.id,
        }
      };

      _razorpay.open(options);
    } catch (e) {
      Get.snackbar('Error', 'Failed to initiate payment');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      // Create subscription record
      String subscriptionId = response.paymentId!;
      
      SubscriptionModel subscription = SubscriptionModel(
        id: subscriptionId,
        userId: _authController.userModel!.id,
        creatorId: response.orderId!, // This should be set from notes
        planType: SubscriptionType.monthly, // Get from notes
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        isActive: true,
        paymentId: response.paymentId!,
      );

      await _firestore
          .collection('subscriptions')
          .doc(subscriptionId)
          .set(subscription.toFirestore());

      Get.snackbar('Success', 'Subscription activated successfully!');
      await loadUserSubscriptions();
    } catch (e) {
      Get.snackbar('Error', 'Failed to activate subscription');
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Get.snackbar('Payment Failed', response.message ?? 'Unknown error');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Get.snackbar('External Wallet', 'Selected wallet: ${response.walletName}');
  }

  Future<void> loadUserSubscriptions() async {
    try {
      isLoading.value = true;
      
      QuerySnapshot snapshot = await _firestore
          .collection('subscriptions')
          .where('userId', isEqualTo: _authController.userModel!.id)
          .where('isActive', isEqualTo: true)
          .get();

      userSubscriptions.value = snapshot.docs
          .map((doc) => SubscriptionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error loading subscriptions: $e');
    } finally {
      isLoading.value = false;
    }
  }

  bool isSubscribedTo(String creatorId) {
    return userSubscriptions.any((sub) => 
        sub.creatorId == creatorId && 
        sub.isActive && 
        sub.endDate.isAfter(DateTime.now()));
  }
}

