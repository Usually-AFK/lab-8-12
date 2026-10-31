import 'package:flutter/material.dart';

void main() => runApp(const MockLoginApp());

class MockLoginApp extends StatelessWidget {
  const MockLoginApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Mock Login',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff4e55b8)),
      useMaterial3: true,
    ),
    home: const LoginPage(),
  );
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  Future<void> _login() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _busy = false);
    if (_email.text.trim() == 'student@lab.com' &&
        _password.text == 'flutter123') {
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomePage(email: _email.text.trim())),
      );
    } else {
      setState(() => _error = 'Email or password is incorrect.');
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      const Icon(Icons.lock_person_outlined, size: 68),
      const SizedBox(height: 12),
      Text(
        'Welcome back',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const SizedBox(height: 8),
      const Text(
        'Sign in to your learning workspace.',
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 28),
      TextFormField(
        controller: _email,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          labelText: 'Email',
          prefixIcon: Icon(Icons.email_outlined),
          border: OutlineInputBorder(),
        ),
        validator: (v) => v == null || !v.contains('@')
            ? 'Enter a valid email address'
            : null,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _password,
        obscureText: true,
        decoration: const InputDecoration(
          labelText: 'Password',
          prefixIcon: Icon(Icons.key_outlined),
          border: OutlineInputBorder(),
        ),
        validator: (v) =>
            v == null || v.length < 6 ? 'Use at least 6 characters' : null,
      ),
      if (_error != null)
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      const SizedBox(height: 20),
      FilledButton(
        onPressed: _busy ? null : _login,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: _busy
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Sign in'),
        ),
      ),
      const SizedBox(height: 20),
      const Card(
        child: Padding(
          padding: EdgeInsets.all(14),
          child: Text(
            'Demo account\nstudent@lab.com  |  flutter123',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ];
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.email});
  final String email;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Home')),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
          const SizedBox(height: 12),
          Text('Signed in as $email'),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginPage()),
            ),
            child: const Text('Log out'),
          ),
        ],
      ),
    ),
  );
}
