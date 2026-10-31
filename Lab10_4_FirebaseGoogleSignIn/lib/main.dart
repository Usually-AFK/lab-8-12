import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() => runApp(const GoogleLoginApp());

class GoogleLoginApp extends StatelessWidget {
  const GoogleLoginApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Google Sign-In',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff4362a5)),
      useMaterial3: true,
    ),
    home: const GoogleLoginPage(),
  );
}

class GoogleLoginPage extends StatefulWidget {
  const GoogleLoginPage({super.key});
  @override
  State<GoogleLoginPage> createState() => _GoogleLoginPageState();
}

class _GoogleLoginPageState extends State<GoogleLoginPage> {
  bool _busy = false;
  String? _error;
  User? _user;
  Future<void> _signIn() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (Firebase.apps.isEmpty) await Firebase.initializeApp();
      final account = await GoogleSignIn().signIn();
      if (account == null) return;
      final auth = await account.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );
      final result = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      if (mounted) setState(() => _user = result.user);
    } catch (e) {
      if (mounted) {
        setState(
          () => _error =
              'Firebase is not configured or sign-in failed. Follow README setup.\n$e',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
    } catch (_) {}
    if (mounted) setState(() => _user = null);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Google account')),
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_user == null) ...[
                const Icon(Icons.account_circle_outlined, size: 76),
                Text(
                  'Continue with Google',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                const Text('Authenticate with Firebase and view your profile.'),
                const SizedBox(height: 22),
                FilledButton.icon(
                  onPressed: _busy ? null : _signIn,
                  icon: const Icon(Icons.login),
                  label: _busy
                      ? const Text('Connecting…')
                      : const Text('Sign in with Google'),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 18),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
              ] else ...[
                CircleAvatar(
                  radius: 38,
                  backgroundImage: _user!.photoURL == null
                      ? null
                      : NetworkImage(_user!.photoURL!),
                  child: _user!.photoURL == null
                      ? const Icon(Icons.person, size: 38)
                      : null,
                ),
                const SizedBox(height: 14),
                Text(
                  _user!.displayName ?? 'Google user',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(_user!.email ?? 'No email available'),
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  onPressed: _signOut,
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign out'),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}
