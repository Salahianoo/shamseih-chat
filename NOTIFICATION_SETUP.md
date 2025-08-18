# Firebase Push Notifications Setup

## Getting Your Firebase Server Key

To enable push notifications between users, you need to get your Firebase Cloud Messaging server key:

### Step 1: Go to Firebase Console
1. Visit [Firebase Console](https://console.firebase.google.com)
2. Select your project (`shamseih_chat`)

### Step 2: Get the Server Key
1. Click on the settings gear icon (⚙️) in the left sidebar
2. Select "Project settings"
3. Go to the "Cloud Messaging" tab
4. Look for "Server key" in the "Project credentials" section
5. Copy the server key

### Step 3: Update Your Code
1. Open `lib/services/notification_service.dart`
2. Replace `YOUR_SERVER_KEY_HERE` with your actual server key:

```dart
static const String serverKey = 'AAAAxxxxxxx:APA91bH...'; // Your actual server key
```

## How It Works

1. **Token Storage**: When users log in or register, their FCM tokens are stored in Firestore under a `users` collection
2. **Message Notifications**: When a user sends a message, the app automatically sends push notifications to all other users
3. **Background Handling**: Notifications are handled even when the app is in the background

## Firestore Structure

The app creates the following structure in Firestore:

```
users/
  {userId}/
    email: "user@example.com"
    fcmToken: "fcm_token_here"
    lastActive: timestamp

messages/
  {messageId}/
    text: "message content"
    sender: "sender@example.com"
    timestamp: timestamp
```

## Testing

1. Register/login with multiple users on different devices
2. Send a message from one device
3. The other devices should receive push notifications
4. Check the debug console for notification logs

## Troubleshooting

- Make sure your Firebase project has Cloud Messaging enabled
- Verify the server key is correct
- Check that users have granted notification permissions
- Look at debug console for error messages
