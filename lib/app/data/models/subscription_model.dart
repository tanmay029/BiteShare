// lib/app/data/models/subscription_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionModel {
  final String id;
  final String userId;
  final String creatorId;
  final SubscriptionType planType;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final String paymentId;

  SubscriptionModel({
    required this.id,
    required this.userId,
    required this.creatorId,
    required this.planType,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.paymentId,
  });

  factory SubscriptionModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return SubscriptionModel(
      id: doc.id,
      userId: data['userId'],
      creatorId: data['creatorId'],
      planType: SubscriptionType.values[data['planType']],
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      isActive: data['isActive'],
      paymentId: data['paymentId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'creatorId': creatorId,
      'planType': planType.index,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'isActive': isActive,
      'paymentId': paymentId,
    };
  }
}

class SubscriptionPlan {
  final String creatorId;
  final String creatorName;
  final double monthlyPrice;
  final double yearlyPrice;
  final String description;
  final SubscriptionType type;

  SubscriptionPlan({
    required this.creatorId,
    required this.creatorName,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.description,
    required this.type,
  });

  factory SubscriptionPlan.fromMap(Map<String, dynamic> map) {
    return SubscriptionPlan(
      creatorId: map['creatorId'],
      creatorName: map['creatorName'],
      monthlyPrice: map['monthlyPrice'].toDouble(),
      yearlyPrice: map['yearlyPrice'].toDouble(),
      description: map['description'],
      type: SubscriptionType.values[map['type']],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'creatorId': creatorId,
      'creatorName': creatorName,
      'monthlyPrice': monthlyPrice,
      'yearlyPrice': yearlyPrice,
      'description': description,
      'type': type.index,
    };
  }
}

enum SubscriptionType { monthly, yearly }
