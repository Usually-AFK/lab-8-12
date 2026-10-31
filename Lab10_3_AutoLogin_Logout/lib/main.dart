import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const SessionApp());

class SessionApp extends StatelessWidget {
  const SessionApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Session Login',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff185c87)),
      useMaterial3: true,
    ),
    home: const SplashPage(),
  );
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _route();
  }

  Future<void> _route() async {
    final prefs = await SharedPreferences.getInstance();
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    final token = prefs.getString('auth_token');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            token == null ? const LoginPage() : HomePage(token: token),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Restoring your session...'),
        ],
      ),
    ),
  );
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _form = GlobalKey<FormState>();
  final _username = TextEditingController(text: 'emilys');
  final _password = TextEditingController(text: 'emilyspass');
  bool _busy = false;
  String? _error;
  Future<void> _login() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      final r = await http
          .post(
            Uri.https('dummyjson.com', '/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': _username.text.trim(),
              'password': _password.text,
              'expiresInMins': 30,
            }),
          )
          .timeout(const Duration(seconds: 15));
      final data = jsonDecode(r.body) as Map<String, dynamic>;
      if (r.statusCode < 200 || r.statusCode >= 300) {
        throw Exception(data['message'] ?? 'Login failed');
      }
      final token = (data['accessToken'] ?? data['token']) as String;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      if (!mounted) return;
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage(token: token)),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.login, size: 60),
                Text(
                  'Sign in',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _username,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter a username' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter a password' : null,
                ),
                if (_error != null)
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: _busy ? null : _login,
                  child: _busy
                      ? const CircularProgressIndicator()
                      : const Text('Login'),
                ),
                const Text(
                  'Demo: emilys / emilyspass',
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
  const HomePage({super.key, required this.token});
  final String token;
  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
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
    appBar: AppBar(title: const Text('Your session')),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified_user, size: 56, color: Colors.green),
          const Text('Session restored from device storage.'),
          Text(
            'Token: ${token.substring(0, token.length.clamp(0, 12))}...',
          ),
          const SizedBox(height: 16),
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
