import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'stores/habit_store.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.bgSecondary,
  ));

  bool firebaseReady = false;
  try {
    await Firebase.initializeApp();
    firebaseReady = true;
  } catch (_) {
    // Firebase not configured — run without auth
  }

  runApp(InitHabitsApp(firebaseReady: firebaseReady));
}

class InitHabitsApp extends StatelessWidget {
  final bool firebaseReady;
  const InitHabitsApp({super.key, required this.firebaseReady});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HabitStore()),
        ChangeNotifierProvider<AuthService>(
          create: (_) => firebaseReady
              ? AuthService(FirebaseAuth.instance)
              : _NoOpAuthService(),
        ),
      ],
      child: MaterialApp(
        title: 'init.habits',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: firebaseReady ? const _AuthGate() : const MainShell(),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    if (auth.isAuthenticated) return const MainShell();
    return const LoginScreen();
  }
}

class _NoOpAuthService extends AuthService {
  _NoOpAuthService() : super(_DummyAuth());
  @override
  bool get initialized => true;
  @override
  User? get user => null;
  @override
  bool get isAuthenticated => false;
}

class _DummyAuth implements FirebaseAuth {
  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError();
  @override
  Stream<User?> authStateChanges() => const Stream.empty();
}
