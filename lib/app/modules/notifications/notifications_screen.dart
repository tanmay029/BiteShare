// lib/app/modules/notifications/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/notification_controller.dart';
import '../../data/models/notification_model.dart';

class NotificationsScreen extends GetView<NotificationController> {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          Obx(() {
            return controller.unreadCount.value > 0
                ? TextButton(
                    onPressed: controller.markAllAsRead,
                    child: const Text(
                      'Mark All Read',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (controller.notifications.isEmpty) {
          return _buildEmptyState();
        }
        
        return RefreshIndicator(
          onRefresh: controller.loadNotifications,
          child: ListView.builder(
            itemCount: controller.notifications.length,
            itemBuilder: (context, index) {
              return _buildNotificationItem(controller.notifications[index]);
            },
          ),
        );
      }),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    return Container(
      color: notification.read ? null : Colors.blue[50],
      child: ListTile(
        leading: _buildNotificationIcon(notification.type),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.read ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.body),
            const SizedBox(height: 4),
            Text(
              _formatTimeAgo(notification.createdAt),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: notification.read ? null : Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
        ),
        onTap: () {
          if (!notification.read) {
            controller.markAsRead(notification.id);
          }
          _handleNotificationTap(notification);
        },
      ),
    );
  }

  Widget _buildNotificationIcon(String type) {
    IconData iconData;
    Color color;
    
    switch (type) {
      case 'follow':
        iconData = Icons.person_add;
        color = Colors.blue;
        break;
      case 'like':
        iconData = Icons.favorite;
        color = Colors.red;
        break;
      case 'comment':
        iconData = Icons.comment;
        color = Colors.green;
        break;
      case 'new_recipe':
        iconData = Icons.restaurant;
        color = Colors.orange;
        break;
      default:
        iconData = Icons.notifications;
        color = Colors.grey;
    }
    
    return CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      child: Icon(iconData, color: color),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Notifications',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'ll see notifications here when you have activity',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    Duration difference = DateTime.now().difference(dateTime);
    
    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _handleNotificationTap(NotificationModel notification) {
    switch (notification.type) {
      case 'follow':
        if (notification.data.containsKey('fromUserId')) {
          Get.toNamed('/user/${notification.data['fromUserId']}');
        }
        break;
      case 'like':
      case 'comment':
      case 'new_recipe':
        if (notification.data.containsKey('recipeId')) {
          Get.toNamed('/recipe/${notification.data['recipeId']}');
        }
        break;
    }
  }
}
