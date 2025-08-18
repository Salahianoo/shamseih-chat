import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  static const String serverKey =
      'YOUR_SERVER_KEY_HERE'; // Replace with your actual server key
  static const String fcmUrl = 'https://fcm.googleapis.com/fcm/send';

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Check if server key is configured
  static bool get isConfigured => serverKey != 'YOUR_SERVER_KEY_HERE';

  // Store FCM token for current user
  static Future<void> storeUserToken(String token) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'email': user.email,
          'fcmToken': token,
          'lastActive': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        print('FCM token stored for user: ${user.email}');
      }
    } catch (e) {
      print('Error storing FCM token: $e');
    }
  }

  // Get all users' FCM tokens except current user
  static Future<List<String>> getOtherUsersTokens() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return [];

      final snapshot = await _firestore
          .collection('users')
          .where('email', isNotEqualTo: currentUser.email)
          .get();

      List<String> tokens = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['fcmToken'] != null) {
          tokens.add(data['fcmToken']);
        }
      }
      return tokens;
    } catch (e) {
      print('Error getting other users tokens: $e');
      return [];
    }
  }

  // Send notification to specific tokens
  static Future<void> sendNotificationToTokens({
    required List<String> tokens,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    if (!isConfigured) {
      print(
        'Server key not configured. Please set your Firebase server key in NotificationService.',
      );
      return;
    }

    if (tokens.isEmpty) {
      print('No tokens to send notifications to');
      return;
    }

    try {
      // Send to each token individually
      for (String token in tokens) {
        await _sendSingleNotification(
          token: token,
          title: title,
          body: body,
          data: data,
        );
      }
    } catch (e) {
      print('Error sending notifications: $e');
    }
  }

  // Send notification to a single token
  static Future<void> _sendSingleNotification({
    required String token,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(fcmUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
        body: jsonEncode({
          'to': token,
          'notification': {
            'title': title,
            'body': body,
            'sound': 'default',
            'badge': '1',
          },
          'data': data ?? {},
          'priority': 'high',
        }),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully');
      } else {
        print('Failed to send notification: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('Error sending single notification: $e');
    }
  }

  // Send message notification to other users
  static Future<void> sendMessageNotification({
    required String senderEmail,
    required String messageText,
  }) async {
    try {
      // Get all other users' tokens
      final tokens = await getOtherUsersTokens();

      if (tokens.isNotEmpty) {
        await sendNotificationToTokens(
          tokens: tokens,
          title: 'New message from $senderEmail',
          body: messageText.length > 50
              ? '${messageText.substring(0, 50)}...'
              : messageText,
          data: {
            'type': 'message',
            'sender': senderEmail,
            'message': messageText,
          },
        );
      }
    } catch (e) {
      print('Error sending message notification: $e');
    }
  }
}
