import 'package:flutter/material.dart';
import 'main.dart'; // MuzeApp.of(context) kullanabilmek için main.dart'ı import et

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    // Mevcut temanın karanlık olup olmadığını kontrol ediyoruz
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Renkleri temaya göre dinamik seçiyoruz
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1E293B);
    final Color subTextColor = isDarkMode
        ? Colors.white70
        : const Color(0xFF64748B);
    final Color cardColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final Color borderColor = isDarkMode
        ? const Color(0xFF334155)
        : const Color(0xFFF1F5F9);

    return Scaffold(
      // Arka plan rengi main.dart içindeki temadan otomatik gelir
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Üst Kısım: Profil Resmi ve İsim
              Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: cardColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: borderColor, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text("👤", style: TextStyle(fontSize: 50)),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFF2563EB),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Berat Emekli",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      "Kültür Kaşifi",
                      style: TextStyle(
                        fontSize: 14,
                        color: subTextColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // İstatistik Kartları
              Row(
                children: [
                  _buildStatCard("Gezilen", "12", "🏛️", cardColor, textColor),
                  const SizedBox(width: 16),
                  _buildStatCard("Biletlerim", "3", "🎫", cardColor, textColor),
                  const SizedBox(width: 16),
                  _buildStatCard("Puan", "450", "⭐", cardColor, textColor),
                ],
              ),
              const SizedBox(height: 32),

              _buildSectionTitle("Uygulama Ayarları"),
              const SizedBox(height: 12),

              // Dil Seçeneği
              _buildMenuItem(
                Icons.language_outlined,
                "Dil Seçeneği",
                cardColor,
                textColor,
                trailing: "Türkçe",
              ),

              // KARANLIK MOD SWITCH (Tıklanabilir Yer Burası)
              _buildMenuItem(
                Icons.dark_mode_outlined,
                "Karanlık Mod",
                cardColor,
                textColor,
                isSwitch: true,
                switchValue: isDarkMode,
                onSwitchChanged: (value) {
                  // main.dart'taki changeTheme metodunu tetikler
                  MuzeApp.of(
                    context,
                  )?.changeTheme(value ? ThemeMode.dark : ThemeMode.light);
                },
              ),

              const SizedBox(height: 32),

              // Çıkış Butonu
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: borderColor),
                    ),
                    backgroundColor: cardColor,
                  ),
                  child: const Text(
                    "Çıkış Yap",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    String emoji,
    Color bg,
    Color text,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: bg == Colors.white
                ? const Color(0xFFE2E8F0)
                : Colors.transparent,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: text,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF94A3B8),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    Color bg,
    Color text, {
    String? trailing,
    bool isSwitch = false,
    bool switchValue = false,
    Function(bool)? onSwitchChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: bg == Colors.white
              ? const Color(0xFFF1F5F9)
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bg == Colors.white
                  ? const Color(0xFFF8FAFC)
                  : Colors.black26,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF64748B)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: text,
              ),
            ),
          ),
          if (isSwitch)
            Switch(
              value: switchValue,
              onChanged: onSwitchChanged,
              activeColor: const Color(0xFF2563EB),
            )
          else if (trailing != null)
            Text(
              trailing,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            )
          else
            const Icon(Icons.chevron_right, size: 20, color: Color(0xFFCBD5E1)),
        ],
      ),
    );
  }
}
