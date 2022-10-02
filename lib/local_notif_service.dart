import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/subjects.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzData;

class LocalNotificationService {
    LocalNotificationService();
    
    final _localNotificationService = FlutterLocalNotificationsPlugin();
    
    Future init() async {
      tzData.initializeTimeZones();
      const AndroidInitializationSettings androidSetting = AndroidInitializationSettings('@mipmap/gj_notif');

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
            print('data: ${notifResponse}');
        },
        // onDidReceiveBackgroundNotificationResponse: notificationTapBackground
      ).then((_) {
        debugPrint('setupPlugin: setup success');
      }).catchError((Object error) {
        debugPrint('Error: $error');
      });
    }
    
    Future<NotificationDetails> _notificationDetails() async {
      const androidNotifDetails = AndroidNotificationDetails(
        'channel_id',
        'channel_name',
        channelDescription: 'description',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true

      );

      const iOSNotificationDetails = DarwinNotificationDetails();

      return const NotificationDetails(android: androidNotifDetails, iOS: iOSNotificationDetails);
    }

    Future showNotification({required int id, required String title, required String body}) async {
      final details = await _notificationDetails();

      await _localNotificationService.show(id, title, body, details);

    }

    Future showPeriodicNotification({required int id, required String title, required String body, required RepeatInterval repeatInterval}) async {
      final details = await _notificationDetails();

      await _localNotificationService.periodicallyShow(id, title, body, repeatInterval, details);

    }


    // @pragma('vm:entry-point')
    // void notificationTapBackground(NotificationResponse notificationResponse) {
    //   print('backgroundData: $notificationResponse');
    // }


    void _onDidReceiveLocalNotification(int id, String? title, String? body, String? payload){
      print('id $id');
    }


}