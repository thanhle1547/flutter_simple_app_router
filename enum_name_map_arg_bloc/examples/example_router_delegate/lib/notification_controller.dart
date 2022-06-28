import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:rxdart/rxdart.dart';
// ignore: depend_on_referenced_packages
import 'package:timezone/data/latest_all.dart' as tz;
// ignore: depend_on_referenced_packages
import 'package:timezone/timezone.dart' as tz;

Future<void> _configureLocalTimeZone() async {
  if (kIsWeb || Platform.isLinux) {
    return;
  }
  tz.initializeTimeZones();
  final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName));
}

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// On iOS and macOS
///
/// Streams are created so that app can respond to notification-related events
/// since the plugin is initialised in the `main` function
final BehaviorSubject<ReceivedNotification>
    _didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String?> _selectNotificationSubject =
    BehaviorSubject<String?>();

const MethodChannel platform = MethodChannel('saut/example_router_delegate');

String? selectedNotificationPayload;

enum NotificationConfig {
  trending(
    channelId: 'trending',
    channelName: 'Trending',
    channelDescription: 'Latest trending post',
  );

  const NotificationConfig({
    required String channelId,
    required String channelName,
    required String channelDescription,
  })  : _channelId = channelId,
        _channelName = channelName,
        _channelDescription = channelDescription;

  final String _channelId;
  final String _channelName;
  final String _channelDescription;
}

class NotificationController {
  static Future<NotificationAppLaunchDetails?>
      getNotificationAppLaunchDetails() async {
    return !kIsWeb && Platform.isLinux
        ? null
        : await _flutterLocalNotificationsPlugin
            .getNotificationAppLaunchDetails();
  }

  static Future<void> initialize() async {
    _configureLocalTimeZone();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    /// Note: permissions aren't requested here just to demonstrate that can be
    /// done later
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification: (
        int id,
        String? title,
        String? body,
        String? payload,
      ) async {
        _didReceiveLocalNotificationSubject.add(
          ReceivedNotification(
            id: id,
            title: title,
            body: body,
            payload: payload,
          ),
        );
      },
    );
    const MacOSInitializationSettings initializationSettingsMacOS =
        MacOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    final LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(
      defaultActionName: 'Open notification',
      defaultIcon: AssetsLinuxIcon('icons/app_icon.png'),
    );
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS,
      linux: initializationSettingsLinux,
    );
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: (String? payload) async {
        if (payload != null) {
          debugPrint('notification payload: $payload');
        }
        selectedNotificationPayload = payload;
        _selectNotificationSubject.add(payload);
      },
    );
  }

  static FlutterLocalNotificationsPlugin get plugin =>
      _flutterLocalNotificationsPlugin;

  static ValueStream<ReceivedNotification> get receivedNotificationStream =>
      _didReceiveLocalNotificationSubject.stream;

  static void closeReceivedNotificationStream() =>
      _didReceiveLocalNotificationSubject.close();

  static ValueStream<String?> get selectedNotificationStream =>
      _selectNotificationSubject.stream;

  static void closeSelectedNotificationStream() =>
      _selectNotificationSubject.close();

  static Future<void> showNotification({
    required NotificationConfig config,
    required int id,
    required String title,
    String? body,
    Object? data,
  }) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      config._channelId,
      config._channelName,
      channelDescription: config._channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      ticker: body,
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: jsonEncode(data),
    );
  }

  static Future<void> zonedScheduleNotification({
    required NotificationConfig config,
    required int id,
    required String title,
    Duration duration = const Duration(seconds: 10),
    String? body,
    Object? data,
  }) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      config._channelId,
      config._channelName,
      channelDescription: config._channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      ticker: body,
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.now(tz.local).add(duration),
      platformChannelSpecifics,
      payload: jsonEncode(data),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
