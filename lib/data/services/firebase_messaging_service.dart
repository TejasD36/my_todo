import '../../core.dart';
import 'local_notification_service.dart';

class FirebaseMessagingService {
  static FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static Future<void> initialise() async {
    // Initialize Firebase messaging
    _firebaseMessaging = FirebaseMessaging.instance;

    // Request permission for iOS devices
    await _firebaseMessaging.requestPermission(alert: true, badge: true, sound: true);

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);

    // Configure Firebase messaging
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      // Handle foreground messages
      if (Platform.isAndroid) {
        // Only show manually for Android
        await NotificationService.showNotification(
          title: message.notification?.title ?? "",
          body: message.notification?.body ?? "",
          pictureUrl: message.notification?.android?.imageUrl ?? "",
        );
      }
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle notification taps while app is in foreground/background
      print('Message clicked!');
      // _handleOnMessage(message);
    });

    await getToken();
  }

  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print('Handling a background message: ${message.messageId}');
    // No need to manually show, Firebase shows it automatically in background
  }

  static void unsubscribeFromTopic(String topicName) {
    _firebaseMessaging.unsubscribeFromTopic(topicName);
  }

  static void subscribeToTopic(String topicName) {
    _firebaseMessaging.subscribeToTopic(topicName);
  }

  /*  static Future<String?> getToken() async {
    String? token = await _firebaseMessaging.getToken();
    debugPrint('FCM Token: $token');
    SharedPreferencesService prefs = await SharedPreferencesService();
    if (token != null) {
      await prefs.saveFcmToken(token);
      fcmToken = token;
    }
    return token;
  }*/

  static Future<String?> getToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken(vapidKey: null);
      debugPrint('FCM Token: $token');
      if (token != null) {
        // final prefs = SharedPreferencesService();
        // await prefs.saveFcmToken(token);
        // fcmToken = token;
      }
      return token;
    } catch (e) {
      debugPrint('Error retrieving FCM token: $e');
      return null;
    }
  }

  static Future<void> _handleOnMessage(RemoteMessage message) async {
    await NotificationService.showNotification(
      title: message.notification?.title ?? "",
      body: message.notification?.body ?? "",
      pictureUrl: Platform.isAndroid ? message.notification?.android?.imageUrl ?? "" : message.notification?.apple?.imageUrl ?? "",
    );
  }
}
