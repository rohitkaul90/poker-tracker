import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import '../screens/auth/login_screen.dart';
import '../widgets/splash_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final Widget child;

        if (!snapshot.hasData) {
          child = const SplashScreen(key: ValueKey('splash'));
        } else {
          final event = snapshot.data!.event;
          final session = snapshot.data!.session;

          // Token is expired on startup — keep splash while SDK auto-refreshes.
          if (event == AuthChangeEvent.initialSession &&
              session != null &&
              _isExpired(session)) {
            child = const SplashScreen(key: ValueKey('splash'));
          } else if (session == null) {
            child = const LoginScreen(key: ValueKey('login'));
          } else {
            child = const MainNavigation(key: ValueKey('main'));
          }
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          child: child,
        );
      },
    );
  }

  bool _isExpired(Session session) {
    final expiresAt = session.expiresAt;
    if (expiresAt == null) return false;
    return DateTime.now().millisecondsSinceEpoch >= expiresAt * 1000;
  }
}
