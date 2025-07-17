import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
// ignore: depend_on_referenced_packages
import 'package:timezone/data/latest_all.dart' as tz;
// ignore: depend_on_referenced_packages
import 'package:timezone/timezone.dart' as tz;

const String _kIconName = 'app_icon';
const String _kIconPath = "assets/icons/$_kIconName.png";

Future<void> _configureLocalTimeZone() async {
  if (kIsWeb || Platform.isLinux) {
    return;
  }
  tz.initializeTimeZones();
  if (Platform.isWindows) {
    return;
  }
  final String timeZoneName = await FlutterTimezone.getLocalTimezone();
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
  static Future<NotificationAppLaunchDetails?> getNotificationAppLaunchDetails() async {
    return !kIsWeb && Platform.isLinux
        ? null
        : await _flutterLocalNotificationsPlugin
            .getNotificationAppLaunchDetails();
  }

  static Future<void> initialize() async {
    await _configureLocalTimeZone();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(_kIconName);

    /// Note: permissions aren't requested here just to demonstrate that can be
    /// done later
    const DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    final LinuxInitializationSettings initializationSettingsLinux = LinuxInitializationSettings(
      defaultActionName: 'Open notification',
      defaultIcon: AssetsLinuxIcon(_kIconPath),
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: selectNotificationStream.add,
      onDidReceiveBackgroundNotificationResponse: _notificationTapBackground,
    );
  }


  static final StreamController<NotificationResponse> selectNotificationStream =
      StreamController<NotificationResponse>.broadcast();


  static Future<void> requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      final bool? grantedNotificationPermission =
          await androidImplementation?.requestNotificationsPermission();
    }
  }

  static Future<void> showNotification({
    required NotificationConfig config,
    required int id,
    required String title,
    String? body,
    Object? data,
  }) async {
    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      config._channelId,
      config._channelName,
      channelDescription: config._channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
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
    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      config._channelId,
      config._channelName,
      channelDescription: config._channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      ticker: body,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.now(tz.local).add(duration),
      notificationDetails,
      payload: jsonEncode(data),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}

@pragma('vm:entry-point')
void _notificationTapBackground(NotificationResponse notificationResponse) {
  print(
    'notification(${notificationResponse.id}) action tapped: '
    '${notificationResponse.actionId} with'
    ' payload: ${notificationResponse.payload}',
  );

  if (notificationResponse.input?.isNotEmpty ?? false) {
    print('notification action tapped with input: ${notificationResponse.input}');
  }
}