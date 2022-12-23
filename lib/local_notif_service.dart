import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzData;
//  Import the api.dart
import 'package:gojdu/others/api.dart';

class LocalNotificationService {
  LocalNotificationService();

  final _localNotificationService = FlutterLocalNotificationsPlugin();

  Future init() async {
    
    tzData.initializeTimeZones();
    const AndroidInitializationSettings androidSetting =
        AndroidInitializationSettings('@mipmap/gj_notif');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
            onDidReceiveLocalNotification: _onDidReceiveLocalNotification);

    final InitializationSettings settings = InitializationSettings(
      android: androidSetting,
      iOS: initializationSettingsDarwin,
    );

    await _localNotificationService.initialize(
      settings,
      onDidReceiveNotificationResponse: (notifResponse) async {
        m_debugPrint('data: $notifResponse');
      },
      // onDidReceiveBackgroundNotificationResponse: notificationTapBackground
    ).then((_) {
      m_debugPrint('setupPlugin: setup success');
    }).catchError((Object error) {
      m_debugPrint('Error: $error');
    });
  }

  Future<NotificationDetails> _notificationDetails() async {
    const androidNotifDetails = AndroidNotificationDetails(
        'channel_id', 'channel_name',
        channelDescription: 'description',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true);

    const iOSNotificationDetails = DarwinNotificationDetails();

    return const NotificationDetails(
        android: androidNotifDetails, iOS: iOSNotificationDetails);
  }

  Future showNotification(
      {required int id, required String title, required String body}) async {
    final details = await _notificationDetails();

    await _localNotificationService.show(id, title, body, details);
  }

  Future showPeriodicNotification(
      {required int id,
      required String title,
      required String body,
      required RepeatInterval repeatInterval}) async {
    final details = await _notificationDetails();

    await _localNotificationService.periodicallyShow(
        id, title, body, repeatInterval, details);
  }

  // @pragma('vm:entry-point')
  // void notificationTapBackground(NotificationResponse notificationResponse) {
  //   m_debugPrint('backgroundData: $notificationResponse');
  // }

  void _onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {
    m_debugPrint('id $id');
  }
}
