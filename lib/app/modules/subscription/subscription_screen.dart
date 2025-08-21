// lib/app/modules/subscription/subscription_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/subscription_controller.dart';
import '../../data/models/subscription_model.dart';

class SubscriptionScreen extends GetView<SubscriptionController> {
  final String? creatorId;
  
  const SubscriptionScreen({Key? key, this.creatorId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (creatorId != null) {
      return _buildCreatorSubscriptionPage();
    } else {
      return _buildMySubscriptionsPage();
    }
  }

  Widget _buildCreatorSubscriptionPage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscribe to Creator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Creator info would be loaded here
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      child: Icon(Icons.person, size: 40),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Creator Name',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Get access to premium recipes and exclusive content',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Subscription plans
            const Text(
              'Choose Your Plan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            _buildPlanCard(
              title: 'Monthly',
              price: '₹199/month',
              description: 'Access to all premium recipes',
              isPopular: false,
              onTap: () => _subscribeToPlan(SubscriptionType.monthly),
            ),
            
            const SizedBox(height: 12),
            
            _buildPlanCard(
              title: 'Yearly',
              price: '₹1999/year',
              description: 'Save ₹389 with annual billing',
              isPopular: true,
              onTap: () => _subscribeToPlan(SubscriptionType.yearly),
            ),
            
            const Spacer(),
            
            const Text(
              'Features included:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            ..._buildFeaturesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMySubscriptionsPage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Subscriptions'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (controller.userSubscriptions.isEmpty) {
          return _buildEmptySubscriptions();
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.userSubscriptions.length,
          itemBuilder: (context, index) {
            return _buildSubscriptionCard(controller.userSubscriptions[index]);
          },
        );
      }),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required String description,
    required bool isPopular,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isPopular ? Colors.orange : Colors.grey[300]!,
          width: isPopular ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          if (isPopular)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: const Text(
                  'POPULAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.orange[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(SubscriptionModel subscription) {
    bool isExpired = subscription.endDate.isBefore(DateTime.now());
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star, color: Colors.yellow),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Creator Subscription',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(
                  label: Text(isExpired ? 'Expired' : 'Active'),
                  backgroundColor: isExpired ? Colors.red[100] : Colors.green,
                  labelStyle: TextStyle(
                    color: isExpired ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Started: ${subscription.startDate.toString().split(' ')[0]}',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 4),
            
            Row(
              children: [
                Icon(Icons.event, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Expires: ${subscription.endDate.toString().split(' ')[0]}',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            
            if (!isExpired) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.toNamed('/user/${subscription.creatorId}'),
                      child: const Text('View Creator'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showCancelDialog(subscription),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySubscriptions() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.subscriptions_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Active Subscriptions',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Subscribe to creators to access premium content',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Get.toNamed('/explore'),
            child: const Text('Discover Creators'),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFeaturesList() {
    const features = [
      'Access to all premium recipes',
      'HD video cooking tutorials',
      'Exclusive behind-the-scenes content',
      'Early access to new recipes',
      'Direct messaging with creator',
    ];
    
    return features.map((feature) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.check, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(feature)),
        ],
      ),
    )).toList();
  }

  void _subscribeToPlan(SubscriptionType planType) {
    // Create a dummy subscription plan for demo
    SubscriptionPlan plan = SubscriptionPlan(
      creatorId: creatorId!,
      creatorName: 'Creator Name',
      monthlyPrice: 199.0,
      yearlyPrice: 1999.0,
      description: 'Access to premium content',
      type: planType,
    );
    
    controller.subscribeToCreator(
      creatorId: creatorId!,
      plan: plan,
    );
  }

  void _showCancelDialog(SubscriptionModel subscription) {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Subscription'),
        content: const Text(
          'Are you sure you want to cancel this subscription? You will lose access to premium content.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Subscription'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement cancellation logic
              Get.snackbar('Cancelled', 'Subscription cancelled successfully');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cancel Subscription'),
          ),
        ],
      ),
    );
  }
}
