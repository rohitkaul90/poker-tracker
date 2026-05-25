import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import '../screens/auth/login_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final event = snapshot.data!.event;
        final session = snapshot.data!.session;

        // Token is expired on startup — keep spinner while SDK auto-refreshes.
        // Next event will be tokenRefreshed (or signedOut if refresh also fails).
        if (event == AuthChangeEvent.initialSession &&
            session != null &&
            _isExpired(session)) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (session == null) return const LoginScreen();
        return const MainNavigation();
      },
    );
  }

  bool _isExpired(Session session) {
    final expiresAt = session.expiresAt;
    if (expiresAt == null) return false;
    return DateTime.now().millisecondsSinceEpoch >= expiresAt * 1000;
  }
}
