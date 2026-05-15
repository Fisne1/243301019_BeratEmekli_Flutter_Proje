import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // slate-50
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
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              "👤", // Buraya kullanıcı resmi gelebilir
                              style: TextStyle(fontSize: 50),
                            ),
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
                    const Text(
                      "Berat Emekli",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const Text(
                      "Kültür Kaşifi",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
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
                  _buildStatCard("Gezilen", "12", "🏛️"),
                  const SizedBox(width: 16),
                  _buildStatCard("Biletlerim", "3", "🎫"),
                  const SizedBox(width: 16),
                  _buildStatCard("Puan", "450", "⭐"),
                ],
              ),
              const SizedBox(height: 32),

              // Ayarlar Menüsü
              _buildSectionTitle("Hesap Ayarları"),
              const SizedBox(height: 12),
              _buildMenuItem(Icons.person_outline, "Kişisel Bilgiler"),
              _buildMenuItem(Icons.notifications_none_outlined, "Bildirimler"),
              _buildMenuItem(Icons.security_outlined, "Güvenlik"),

              const SizedBox(height: 24),
              _buildSectionTitle("Uygulama"),
              const SizedBox(height: 12),
              _buildMenuItem(
                Icons.language_outlined,
                "Dil Seçeneği",
                trailing: "Türkçe",
              ),
              _buildMenuItem(
                Icons.dark_mode_outlined,
                "Karanlık Mod",
                isSwitch: true,
              ),
              _buildMenuItem(Icons.help_outline, "Yardım & Destek"),

              const SizedBox(height: 32),

              // Çıkış Yap Butonu
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Color(0xFFF1F5F9)),
                    ),
                    backgroundColor: Colors.white,
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

  Widget _buildStatCard(String label, String value, String emoji) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF1E293B),
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
    String title, {
    String? trailing,
    bool isSwitch = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF64748B)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          if (isSwitch)
            Switch(
              value: false,
              onChanged: (v) {},
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
