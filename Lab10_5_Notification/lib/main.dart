import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() => runApp(const NotificationApp());

class NotificationApp extends StatelessWidget {
  const NotificationApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Local Notifications',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff8a4b22)),
      useMaterial3: true,
    ),
    home: const NotificationPage(),
  );
}

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});
  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;
  String _status = 'Preparing notification service…';
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      );
      await _plugin.initialize(settings);
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await android?.requestNotificationsPermission();
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      await ios?.requestPermissions(alert: true, badge: true, sound: true);
      if (mounted) setState(() => _ready = true);
    } catch (e) {
      if (mounted) {
        setState(() => _status = 'Could not initialize notifications: $e');
      }
    }
  }

  Future<void> _show() async {
    try {
      await _plugin.show(
        10,
        'Action completed',
        'Your local notification is working.',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'lab_demo',
            'Lab demonstration',
            channelDescription: 'Notifications created by the Lab 10 demo',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
      if (mounted) {
        setState(
          () => _status =
              'Notification sent. Check your system notification tray.',
        );
      }
    } catch (e) {
      if (mounted) setState(() => _status = 'Could not show notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Local notification demo')),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.notifications_active_outlined, size: 72),
            const SizedBox(height: 16),
            Text(_status, textAlign: TextAlign.center),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: _ready ? _show : null,
              icon: const Icon(Icons.send),
              label: const Text('Show test notification'),
            ),
          ],
        ),
      ),
    ),
  );
}
