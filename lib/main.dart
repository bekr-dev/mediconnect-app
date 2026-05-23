import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mediconnect/screens/auth/splash_screen.dart';
import 'package:mediconnect/screens/doctor/doctor_home_screen.dart';
//import 'package:mediconnect/models/models.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart'; // تأكد من وجود هذا الاستيراد
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'models/app_state.dart';
import 'screens/auth/register_choice_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 تهيئة Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const MediConnectApp(),
    ),
  );
}

class MediConnectApp extends StatelessWidget {
  const MediConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediConnect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      // 🔥 تحقق من الجلسة عند بدء التطبيق
      home: const AuthGate(),
    );
  }
}

/// يقرر أين يذهب المستخدم:
/// - مستخدم جديد (لم يسجل دخوله أبداً) → SplashScreen (الانيميشن)
/// - مستخدم سجل دخوله من قبل → مباشرة للـ home حسب الدور
/// - لا يوجد جلسة → LoginScreen
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

// Dans main.dart - La classe AuthGate mise à jour
class _AuthGateState extends State<AuthGate> {
  bool? _isFirstTime;
  Future<String?>? _roleFuture;
  String? _lastUid;

  @override
  void initState() {
    super.initState();
    _loadFirstTimeStatus();
  }

  Future<void> _loadFirstTimeStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isFirstTime = prefs.getBool('is_first_time') ?? true;
      });
    }
  }

  void _handleRoleError(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.of(context);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );

        _lastUid = null;
        _roleFuture = null;
        await FirebaseAuth.instance.signOut();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isFirstTime == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF2196F3), // ضع هنا لون تطبيقك الأساسي
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text("error de conexión"),
            ),
          );
        }

        if (snapshot.hasData) {
          final user = snapshot.data!;
          if (_lastUid != user.uid) {
            _lastUid = user.uid;
            _roleFuture = AppState.getUserRole(user.uid);
          }
          return FutureBuilder<String?>(
            future: _roleFuture,
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                    body: Center(child: CircularProgressIndicator()));
              }
              if (roleSnapshot.hasError) {
                return const Scaffold(
                  body: Center(
                    child: Text("error de conexión"),
                  ),
                );
              }
              final role = roleSnapshot.data;
              if (role == 'doctor') {
                return const SplashScreen(nextScreen: DoctorHomeScreen());
              }
              // Message en français en cas d'erreur de rôle
              _handleRoleError(context, "Erreur d'accès : Rôle non défini.");
              return const Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.red),
                      SizedBox(height: 16),
                      Text("sign out ..."),
                    ],
                  ),
                ),
              );
            },
          );
        }

        if (_isFirstTime!) {
          return const SplashScreen(nextScreen: RegisterChoiceScreen());
        } else {
          return const SplashScreen(nextScreen: LoginScreen());
        }
      },
    );
  }
}
