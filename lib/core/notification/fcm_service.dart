import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:front_erp_aromair/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../firebase_options.dart';
import 'notification_service.dart';

// Top-level BG handler — NEVER navigate here
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.I.init();

  final title =
      message.notification?.title ?? message.data['title'] ?? 'New alert';
  final body =
      message.notification?.body ??
      message.data['body'] ??
      'An alert was created';
  await NotificationService.I.showAlert(title: title, body: body);
}

class FcmService {
  FcmService._();
  static final FcmService I = FcmService._();

  final _openedStream = StreamController<RemoteMessage>.broadcast();
  bool _postUiReady = false;

  /// 1) Call BEFORE runApp — no navigation here
  Future<void> preUiInit() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await NotificationService.I.init();

    // Permissions
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      if (!status.isGranted) await Permission.notification.request();
    }

    // Background
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Foreground: show local banner
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final title =
          message.notification?.title ?? message.data['title'] ?? 'New alert';
      final body =
          message.notification?.body ??
          message.data['body'] ??
          'An alert was created';
      await NotificationService.I.showAlert(title: title, body: body);
    });

    // Queue taps until UI is ready
    FirebaseMessaging.onMessageOpenedApp.listen(_openedStream.add);

    // Topic subscribe (optional)
    await FirebaseMessaging.instance.subscribeToTopic('alerts');

    // Debug token
    final token = await FirebaseMessaging.instance.getToken();
    if (kDebugMode) print('FCM token: $token');
  }

  /// 2) Call AFTER runApp — navigation is safe here
  Future<void> postUiInit() async {
    _postUiReady = true;

    // Handle the case where app was launched by tapping a notification
    final initialMsg = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMsg != null) {
      _handleOpen(initialMsg);
    }

    // Handle any subsequent taps
    _openedStream.stream.listen((msg) {
      if (_postUiReady) _handleOpen(msg);
    });
  }

  void _handleOpen(RemoteMessage message) {
    // Extract your routing data
    final alertId = message.data['alertId'];
    print('Opened from notification, alertId=$alertId');
    Get.toNamed(AppRoutes.alerteDetail, arguments: {'alerteId': alertId});
    if (alertId != null) {
    } else {
      Get.toNamed(AppRoutes.adminAlertes);
    }
  }
}
