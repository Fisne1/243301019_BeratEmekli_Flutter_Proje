import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'giris.dart';
import 'anasayfa.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MuzeApp());
}

class MuzeApp extends StatefulWidget {
  const MuzeApp({super.key});

  @override
  State<MuzeApp> createState() => _MuzeAppState();

  // Tema değişikliğini diğer sayfalardan tetiklemek için statik metod
  static _MuzeAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MuzeAppState>();
}

class _MuzeAppState extends State<MuzeApp> {
  // Varsayılan tema modu
  ThemeMode _themeMode = ThemeMode.system;

  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Müze Pass Uygulaması',
      debugShowCheckedModeBanner: false,

      // AYDINLIK TEMA
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: const Color(0xFF2563EB),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        fontFamily: 'Inter',
      ),

      // KARANLIK TEMA
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF2563EB),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        fontFamily: 'Inter',
      ),

      themeMode: _themeMode,

      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFF2563EB)),
              ),
            );
          }

          if (snapshot.hasData) {
            return const HomeScreen(); // Kullanıcı giriş yapmışsa
          }

          return const AuthScreen(); // Kullanıcı giriş yapmamışsa
        },
      ),
    );
  }
}
