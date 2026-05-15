import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart'; // flutterfire configure ile oluşturulan dosya
import 'giris.dart'; // Giriş ekranı dosyanızın adı
import 'anasayfa.dart'; // Yeni oluşturduğumuz ana sayfa dosyanızın adı

void main() async {
  // Flutter motoru ve widget bağlarını başlatır
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase'i mevcut platformun (Android, iOS veya Web) ayarlarıyla başlatır
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MuzeApp());
}

class MuzeApp extends StatelessWidget {
  const MuzeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Müze Pass Uygulaması',
      debugShowCheckedModeBanner: false, // Sağ üstteki debug bandını kaldırır
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF2563EB),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        fontFamily:
            'Inter', // Eğer özel bir font eklediyseniz burada tanımlayabilirsiniz
      ),
      // authStateChanges() sayesinde kullanıcı giriş/çıkış yaptığında ekran anında değişir
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Firebase'den veri beklenirken yükleme göstergesi
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFF2563EB)),
              ),
            );
          }

          // Eğer snapshot veri içeriyorsa (User nesnesi null değilse) kullanıcı giriş yapmıştır
          if (snapshot.hasData) {
            return const HomeScreen();
          }

          // Kullanıcı giriş yapmamışsa AuthScreen ekranına yönlendirilir
          return const AuthScreen();
        },
      ),
    );
  }
}
