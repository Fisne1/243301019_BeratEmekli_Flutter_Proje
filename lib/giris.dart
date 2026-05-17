import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLogin = true;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    try {
      if (isLogin) {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        UserCredential userCredential = await _auth
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );

        String fullName = _nameController.text.trim();
        String role = 'user';

        if (fullName.toUpperCase().startsWith("ADMIN")) {
          role = 'admin';
        }

        await userCredential.user!.updateDisplayName(fullName);

        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'fullName': fullName,
          'email': _emailController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
          'role': role,
        });
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Bir hata oluştu";
      if (e.code == 'user-not-found')
        errorMessage = "Kullanıcı bulunamadı.";
      else if (e.code == 'wrong-password')
        errorMessage = "Hatalı şifre.";
      else if (e.code == 'email-already-in-use')
        errorMessage = "Bu e-posta zaten kullanımda.";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor = isDarkMode
        ? const Color(0xFF0F172A)
        : const Color(0xFFF8FAFC);
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1E293B);
    final Color subTextColor = isDarkMode
        ? Colors.white70
        : const Color(0xFF64748B);
    final Color inputFillColor = isDarkMode
        ? const Color(0xFF1E293B)
        : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.museum_outlined,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isLogin ? "Tekrar Hoş Geldin" : "Hesap Oluştur",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isLogin
                    ? "Müzelerin kapısını aralamaya devam et."
                    : "Tarihi keşfetmek için ilk adımını at.",
                textAlign: TextAlign.center,
                style: TextStyle(color: subTextColor),
              ),
              const SizedBox(height: 32),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (!isLogin) ...[
                      _buildTextField(
                        _nameController,
                        "Ad Soyad (Admin için 'ADMIN ' yazın)",
                        Icons.person_outline,
                        inputFillColor,
                        textColor,
                        subTextColor,
                      ),
                      const SizedBox(height: 16),
                    ],
                    _buildTextField(
                      _emailController,
                      "E-posta Adresi",
                      Icons.mail_outline,
                      inputFillColor,
                      textColor,
                      subTextColor,
                      isEmail: true,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      _passwordController,
                      "Şifre",
                      Icons.lock_outline,
                      inputFillColor,
                      textColor,
                      subTextColor,
                      isPassword: true,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                isLogin ? "Giriş Yap" : "Kayıt Ol",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => setState(() => isLogin = !isLogin),
                child: Text(
                  isLogin
                      ? "Hesabın yok mu? Hemen Kayıt Ol"
                      : "Zaten hesabın var mı? Giriş Yap",
                  style: const TextStyle(
                    color: Color(0xFF2563EB),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon,
    Color fillColor,
    Color textColor,
    Color subTextColor, {
    bool isPassword = false,
    bool isEmail = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: TextStyle(color: textColor),
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: subTextColor, fontSize: 14),
        prefixIcon: Icon(icon, color: subTextColor, size: 20),
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return "Bu alan boş bırakılamaz";
        if (isEmail && !value.contains("@")) return "Geçerli bir e-posta girin";
        if (isPassword && value.length < 6)
          return "Şifre en az 6 karakter olmalı";
        return null;
      },
    );
  }
}
