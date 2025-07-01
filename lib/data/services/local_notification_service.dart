import 'package:http/http.dart' as http;

import '../../core.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static int _notificationId = 0;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'creatoo_channel',
    'Creatoo Notifications',
    description: 'This channel is used for Creatoo notifications.',
    importance: Importance.high,
  );

  static Future<void> initialize() async {
    const InitializationSettings initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/launcher_icon'),
      iOS: DarwinInitializationSettings(requestSoundPermission: true, requestBadgePermission: true, requestAlertPermission: true),
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    if (Platform.isAndroid) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);
    }
  }

  static Future<void> showNotification({String? title, String? body, String? payload, String? pictureUrl}) async {
    if (Platform.isIOS) {
      return;
    }

    _notificationId++;
    if (pictureUrl != null && pictureUrl.isNotEmpty) {
      String path = await _downloadAndSaveFile(pictureUrl, 'picture');
      await _showBigPictureNotification(id: _notificationId, title: title!, body: body!, bigPicturePath: path);
    } else {
      await _simpleNotification(id: _notificationId, title: title!, body: body!);
    }
  }

  static Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName.png';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  static Future<void> _simpleNotification({required int id, required String title, required String body}) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(body),
    );

    const DarwinNotificationDetails iosPlatformChannelSpecifics = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(id, title, body, platformChannelSpecifics);
  }

  static Future<void> _showBigPictureNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
    required String bigPicturePath,
  }) async {
    final BigPictureStyleInformation bigPictureStyleInformation = BigPictureStyleInformation(
      FilePathAndroidBitmap(bigPicturePath),
      hideExpandedLargeIcon: false,
      contentTitle: title,
      summaryText: body,
    );

    final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.max,
      priority: Priority.max,
      styleInformation: bigPictureStyleInformation,
    );

    const DarwinNotificationDetails iosPlatformChannelSpecifics = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(id, title, body, platformChannelSpecifics, payload: payload);
  }

  static Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }
}
