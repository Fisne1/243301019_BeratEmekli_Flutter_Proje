import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'muzeler.dart';
import 'profil.dart';
import 'biletler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1E293B);
    final Color subTextColor = isDarkMode
        ? Colors.white70
        : const Color(0xFF64748B);
    final Color cardColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final Color borderColor = isDarkMode
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);

    return Scaffold(
      body: _selectedIndex == 0
          ? _buildHomeContent(
              isDarkMode,
              textColor,
              subTextColor,
              cardColor,
              borderColor,
            )
          : _selectedIndex == 1
          ? const MuseumsScreen()
          : _selectedIndex == 2
          ? const TicketsScreen()
          : const ProfileScreen(),
      bottomNavigationBar: _buildBottomNav(isDarkMode),
    );
  }

  Widget _buildHomeContent(
    bool isDarkMode,
    Color textColor,
    Color subTextColor,
    Color cardColor,
    Color borderColor,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(textColor, subTextColor, cardColor, borderColor),
          _buildExplorePrompt(
            isDarkMode,
            textColor,
            subTextColor,
            cardColor,
            borderColor,
          ),
          _buildSectionTitle("Geçmiş Ziyaretlerin", textColor),
          _buildVisitedPlacesList(cardColor, textColor, borderColor),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildHeader(
    Color textColor,
    Color subTextColor,
    Color cardColor,
    Color borderColor,
  ) {
    final user = FirebaseAuth.instance.currentUser;
    return Padding(
      padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hoş Geldin 👋",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Text(
                user?.displayName?.split('@')[0] ?? "Gezgin",
                style: TextStyle(color: subTextColor, fontSize: 14),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => setState(() => _selectedIndex = 3),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cardColor,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor),
              ),
              child: Icon(Icons.person_outline, color: textColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExplorePrompt(
    bool isDarkMode,
    Color textColor,
    Color subTextColor,
    Color cardColor,
    Color borderColor,
  ) {
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = 1),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.blue.withOpacity(0.1)
                    : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.map_outlined,
                color: Color(0xFF2563EB),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Müzeleri Keşfet",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                  Text(
                    "Türkiye'nin tüm hazinelerini gör",
                    style: TextStyle(fontSize: 13, color: subTextColor),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: subTextColor),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _selectedIndex = 2),
            child: const Text(
              "Tümünü Gör",
              style: TextStyle(
                color: Color(0xFF2563EB),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitedPlacesList(
    Color cardColor,
    Color textColor,
    Color borderColor,
  ) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tickets')
          .where('userId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'used')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 140,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final List<QueryDocumentSnapshot> docs = snapshot.data?.docs ?? [];

        docs.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final t1 = aData['createdAt'] as Timestamp?;
          final t2 = bData['createdAt'] as Timestamp?;
          if (t1 == null || t2 == null) return 0;
          return t2.compareTo(t1);
        });

        final visitedDocs = docs.take(5).toList();

        if (visitedDocs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  const Text("🏙️", style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Henüz onaylanmış bir ziyaretin yok.",
                      style: TextStyle(
                        color: textColor.withOpacity(0.6),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SizedBox(
          height: 140,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: visitedDocs.length,
            itemBuilder: (context, index) {
              final data = visitedDocs[index].data() as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: _visitedPlaceCard(
                  data['museumName'] ?? "Müze",
                  data['location'] ?? "Konum",
                  data['icon'] ?? "🏛️",
                  data['date'] ?? "---",
                  cardColor,
                  textColor,
                  borderColor,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _visitedPlaceCard(
    String name,
    String city,
    String icon,
    String date,
    Color bg,
    Color text,
    Color border,
  ) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: border.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: text,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  city,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(bool isDarkMode) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      type: BottomNavigationBarType.fixed,
      backgroundColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
      selectedItemColor: const Color(0xFF2563EB),
      unselectedItemColor: const Color(0xFF94A3B8),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_filled),
          label: "Ana Sayfa",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.explore_outlined),
          label: "Keşfet",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.confirmation_num_outlined),
          label: "Biletlerim",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: "Profil",
        ),
      ],
    );
  }
}
