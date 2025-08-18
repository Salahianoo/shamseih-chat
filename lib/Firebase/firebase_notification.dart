import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/notification_service.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  // Handle background message
  final notification = message.notification;
  if (notification != null) {
    print(
      'Handling a background message: ${notification.title} - ${notification.body}',
    );
  } else {
    print('Received background message with no notification data');
  }
}

class FirebaseNotification {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<String?> init(BuildContext? context) async {
    // Request permission for iOS
    NotificationSettings settings = await _firebaseMessaging
        .requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else {
      print('User declined or has not accepted permission');
    }

    // Get the token
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');

    // Show token in a dialog if context is provided
    if (context != null && token != null && mounted) {
      _showTokenDialog(context, token);
    }

    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received foreground message: ${message.notification?.title}');

      if (context != null && message.notification != null && mounted) {
        _showForegroundNotification(context, message);
      }
    });

    // Store the FCM token for this user
    if (token != null) {
      await NotificationService.storeUserToken(token);
    }

    return token;
  }

  bool get mounted => true; // Simple mounted check

  void _showTokenDialog(BuildContext context, String token) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('FCM Token'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Your Firebase Cloud Messaging token:'),
              SizedBox(height: 10),
              SelectableText(
                token,
                style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: token));
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Token copied to clipboard!')),
                  );
                },
                child: Text('Copy Token'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showForegroundNotification(
    BuildContext context,
    RemoteMessage message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${message.notification!.title}: ${message.notification!.body}',
        ),
        duration: Duration(seconds: 3),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            // You can add navigation logic here if needed
          },
        ),
      ),
    );
  }
}
