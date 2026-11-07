import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Posts **real** system notifications (the phone's status bar / notification
/// shade) for every new entry in the in-app bell feed, so a reply, a daily
/// tip or a new release is visible even when AskOptSam is in the background.
///
/// The class is deliberately forgiving: on platforms without a notification
/// host, or when permission is refused, calls become no-ops instead of
/// crashing the app.
class LocalNotifications {
  LocalNotifications._();

  static final LocalNotifications instance = LocalNotifications._();

  static const _channelId = 'asksam_notices';
  static const _channelName = 'AskOptSam';
  static const _channelDescription = 'Arifa / Notifications';

  /// Longest body we hand to the system; anything longer is truncated.
  static const _maxBody = 190;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _ready = false;

  bool get ready => _ready;

  /// Creates the Android notification channel. Fast and non-blocking: it never
  /// shows a dialog, so it is safe to call before the first frame. Safe to
  /// call more than once.
  Future<void> init() async {
    if (_ready || kIsWeb) return;
    try {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
      );

      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        await android.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDescription,
            importance: Importance.high,
          ),
        );
      }

      _ready = true;
    } catch (error) {
      debugPrint('System notifications unavailable: $error');
    }
  }

  /// Shows the Android 13+ permission dialog. Called once the first frame is
  /// on screen so the dialog never covers a blank window; on older Android
  /// versions the permission is granted at install time and this is a no-op.
  Future<void> requestPermission() async {
    if (!_ready || kIsWeb) return;
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await android?.requestNotificationsPermission();
    } catch (error) {
      debugPrint('Notification permission not granted: $error');
    }
  }

  /// Shows one system notification. Called only for genuinely new notices,
  /// so repeated app opens never re-post the same item.
  Future<void> show({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_ready || kIsWeb || title.trim().isEmpty) return;
    try {
      var text = body.trim();
      if (text.length > _maxBody) {
        text = '${text.substring(0, _maxBody).trim()}…';
      }
      await _plugin.show(
        id: id,
        title: title.trim(),
        body: text,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            playSound: true,
            enableVibration: true,
          ),
        ),
      );
    } catch (error) {
      debugPrint('Could not post system notification: $error');
    }
  }
}
