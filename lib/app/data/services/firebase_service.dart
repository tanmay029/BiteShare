// lib/app/data/services/firebase_service.dart
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
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
      Reference ref = _storage.ref().child(path).child(fileName);
      
      // ✅ FIXED: Same approach for video upload
      UploadTask uploadTask = ref.putFile(videoFile);
      TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
      
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Firebase Storage Error: $e');
      throw Exception('Failed to upload video: $e');
    }
  }

  Future<String> uploadImage(File imageFile, String path) async {
    try {
      // Generate unique filename with proper extension
      String fileName = '${const Uuid().v4()}.jpg';
      
      // Create proper storage reference
      Reference ref = _storage.ref().child(path).child(fileName);
      
      // ✅ FIXED: Await the upload task completion
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
      
      // ✅ FIXED: Get download URL from the completed snapshot reference
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Firebase Storage Error: $e');
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
