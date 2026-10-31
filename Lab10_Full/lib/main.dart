import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const Lab10App());

class Lab10App extends StatelessWidget {
  const Lab10App({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Lab 10 Auth',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff285b70)),
      useMaterial3: true,
    ),
    home: const BootPage(),
  );
}

class BootPage extends StatefulWidget {
  const BootPage({super.key});
  @override
  State<BootPage> createState() => _BootPageState();
}

class _BootPageState extends State<BootPage> {
  @override
  void initState() {
    super.initState();
    _route();
  }

  Future<void> _route() async {
    await Notices.init();
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final token = prefs.getString('auth_token');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => token == null
            ? const LoginPage()
            : HomePage(
                name: prefs.getString('user_name') ?? 'User',
                token: token,
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

class Notices {
  static final plugin = FlutterLocalNotificationsPlugin();
  static Future<void> init() async {
    try {
      await plugin.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(),
        ),
      );
      await plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    } catch (_) {}
  }

  static Future<void> success() async {
    try {
      await plugin.show(
        1,
        'Welcome back',
        'You have signed in successfully.',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'auth',
            'Account activity',
            channelDescription: 'Account action alerts',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    } catch (_) {}
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final form = GlobalKey<FormState>();
  final username = TextEditingController(text: 'emilys');
  final password = TextEditingController(text: 'emilyspass');
  bool busy = false;
  String? error;
  Future<void> _apiLogin() async {
    if (!form.currentState!.validate()) return;
    setState(() => busy = true);
    try {
      final response = await http
          .post(
            Uri.https('dummyjson.com', '/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': username.text.trim(),
              'password': password.text,
              'expiresInMins': 30,
            }),
          )
          .timeout(const Duration(seconds: 15));
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(data['message'] ?? 'Login failed');
      }
      await _finish(
        (data['accessToken'] ?? data['token']) as String,
        data['firstName'] as String? ?? username.text.trim(),
      );
    } catch (e) {
      if (mounted) {
        setState(() => error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _googleLogin() async {
    setState(() => error = null);
    try {
      if (Firebase.apps.isEmpty) await Firebase.initializeApp();
      final account = await GoogleSignIn().signIn();
      if (account == null) return;
      final a = await account.authentication;
      final result = await FirebaseAuth.instance.signInWithCredential(
        GoogleAuthProvider.credential(
          accessToken: a.accessToken,
          idToken: a.idToken,
        ),
      );
      await _finish(
        await result.user?.getIdToken() ?? '',
        result.user?.displayName ?? 'Google user',
      );
    } catch (e) {
      if (mounted) {
        setState(
          () =>
              error = 'Configure Firebase and Google Sign-In using README. $e',
        );
      }
    }
  }

  Future<void> _finish(String token, String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_name', name);
    await Notices.success();
    if (mounted) {
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(name: name, token: token),
        ),
      );
    }
  }

  @override
  void dispose() {
    username.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Form(
            key: form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.shield_outlined, size: 64),
                Text(
                  'Welcome back',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: username,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter your username' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: password,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter your password' : null,
                ),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: busy ? null : _apiLogin,
                  child: busy
                      ? const CircularProgressIndicator()
                      : const Text('Sign in with API'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: busy ? null : _googleLogin,
                  icon: const Icon(Icons.g_mobiledata),
                  label: const Text('Continue with Google'),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Demo API account: emilys / emilyspass',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.name, required this.token});
  final String name, token;
  Future<void> _logout(BuildContext context) async {
    final p = await SharedPreferences.getInstance();
    await p.remove('auth_token');
    await p.remove('user_name');
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
    } catch (_) {}
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Account')),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified_user, size: 60, color: Colors.green),
          Text(
            'Hello, $name',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const Text('Your session is saved on this device.'),
          Text(
            'Token: ${token.substring(0, token.length.clamp(0, 12))}...',
          ),
          const SizedBox(height: 18),
          FilledButton.tonalIcon(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            label: const Text('Log out'),
          ),
        ],
      ),
    ),
  );
}
