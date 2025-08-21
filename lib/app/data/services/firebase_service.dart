// lib/app/data/services/firebase_service.dart
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';

class FirebaseService {
  static const String PROJECT_ID = 'biteshare-ee6c8';
  static const String STORAGE_BUCKET = 'biteshare-ee6c8.appspot.com';
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<String> uploadVideo(File videoFile, String path) async {
    try {
      String fileName = '${const Uuid().v4()}.mp4';
      Reference ref = _storage.ref().child('$path/$fileName');
      
      UploadTask uploadTask = ref.putFile(videoFile);
      TaskSnapshot snapshot = await uploadTask;
      
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload video: $e');
    }
  }

  Future<String> uploadImage(File imageFile, String path) async {
  try {
    // Compress image before upload
    final compressedImage = await FlutterImageCompress.compressWithFile(
      imageFile.absolute.path,
      minWidth: 1024,
      minHeight: 1024,
      quality: 70,
    );
    
    if (compressedImage != null) {
      String fileName = '${const Uuid().v4()}.jpg';
      Reference ref = _storage.ref().child('$path/$fileName');
      
      UploadTask uploadTask = ref.putData(compressedImage);
      TaskSnapshot snapshot = await uploadTask;
      
      return await snapshot.ref.getDownloadURL();
    }
    
    throw Exception('Image compression failed');
  } catch (e) {
    throw Exception('Failed to upload image: $e');
  }
}

  Future<void> initializeNotifications() async {
    // Request permission for notifications
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      
      // Get FCM token
      String? token = await _messaging.getToken();
      print('FCM Token: $token');
      
      // Save token to Firestore for the current user
      // This should be called after user authentication
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }
}
