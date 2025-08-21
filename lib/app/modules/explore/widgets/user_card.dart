// lib/app/modules/explore/widgets/user_card.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/user_model.dart';
import '../../../controllers/social_controller.dart';

class UserCard extends StatelessWidget {
  final UserModel user;
  
  const UserCard({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SocialController socialController = Get.find<SocialController>();
    
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: user.profileImage != null
              ? CachedNetworkImageProvider(user.profileImage!)
              : null,
          child: user.profileImage == null
              ? Text(user.username[0].toUpperCase())
              : null,
        ),
        title: Text(user.displayName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('@${user.username}'),
            if (user.bio != null) Text(user.bio!),
            Text('${user.followers.length} followers'),
          ],
        ),
        trailing: Obx(() {
          bool isFollowing = socialController.isFollowing(user.id);
          return ElevatedButton(
            onPressed: () => socialController.followUser(user.id),
            style: ElevatedButton.styleFrom(
              backgroundColor: isFollowing ? Colors.grey : null,
            ),
            child: Text(isFollowing ? 'Following' : 'Follow'),
          );
        }),
        onTap: () => Get.toNamed('/user/${user.id}'),
      ),
    );
  }
}
