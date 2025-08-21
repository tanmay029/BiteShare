// lib/app/controllers/notification_controller.dart
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../data/models/notification_model.dart';
import 'auth_controller.dart';

class NotificationController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final AuthController _authController = Get.find<AuthController>();

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _setupNotificationListeners();
    loadNotifications();
  }

  void _setupNotificationListeners() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message);
    });

    // Handle notification tap when app is terminated
    // FirebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
    //   if (message != null) {
    //     _handleNotificationTap(message);
    //   }
    // });
  }

  Future<void> loadNotifications() async {
    try {
      isLoading.value = true;
      
      QuerySnapshot snapshot = await _firestore
          .collection('notifications')
          .where('targetUserId', isEqualTo: _authController.userModel?.id)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      notifications.value = snapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();

      unreadCount.value = notifications.where((n) => !n.read).length;
    } catch (e) {
      print('Error loading notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'read': true});

      // Update local state
      int index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        notifications[index] = notifications[index].copyWith(read: true);
        unreadCount.value = notifications.where((n) => !n.read).length;
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      String userId = _authController.userModel!.id;
      
      QuerySnapshot unreadNotifications = await _firestore
          .collection('notifications')
          .where('targetUserId', isEqualTo: userId)
          .where('read', isEqualTo: false)
          .get();

      WriteBatch batch = _firestore.batch();
      for (var doc in unreadNotifications.docs) {
        batch.update(doc.reference, {'read': true});
      }
      await batch.commit();

      // Update local state
      for (int i = 0; i < notifications.length; i++) {
        if (!notifications[i].read) {
          notifications[i] = notifications[i].copyWith(read: true);
        }
      }
      unreadCount.value = 0;
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  void _showLocalNotification(RemoteMessage message) {
    // Show in-app notification or use local notifications package
    Get.snackbar(
      message.notification?.title ?? 'Notification',
      message.notification?.body ?? '',
      duration: const Duration(seconds: 3),
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    Map<String, dynamic> data = message.data;
    
    switch (data['type']) {
      case 'follow':
        Get.toNamed('/user/${data['fromUserId']}');
        break;
      case 'like':
      case 'comment':
        Get.toNamed('/recipe/${data['recipeId']}');
        break;
      case 'new_recipe':
        Get.toNamed('/recipe/${data['recipeId']}');
        break;
    }
  }

  Future<void> sendNotification( String targetUserId, {
    required String targetUsrId, // error changed from targetUserId to targetUsrId
    required String type,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    try {
      // Create notification document
      await _firestore.collection('notifications').add({
        'targetUserId': targetUserId,
        'fromUserId': _authController.userModel?.id,
        'type': type,
        'title': title,
        'body': body,
        'data': data ?? {},
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Send push notification via Cloud Function
      // This would typically be handled by a Firebase Cloud Function
    } catch (e) {
      print('Error sending notification: $e');
    }
  }
}

