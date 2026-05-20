import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

//burda düzenleme yapmam lazım
class AdminAnaSayfa extends StatefulWidget {
  const AdminAnaSayfa({super.key});

  @override
  _AdminAnaSayfaState createState() => _AdminAnaSayfaState();
}

class _AdminAnaSayfaState extends State<AdminAnaSayfa> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isSettingUp = false;

  Future<void> _checkAndSetupMuseums(List<QueryDocumentSnapshot> docs) async {
    if (docs.isEmpty && !_isSettingUp) {
      setState(() {
        _isSettingUp = true;
      });

      final List<Map<String, dynamic>> defaultMuseums = [
        {
          'name': "Ayasofya-i Kebir Cami-i",
          'location': "İstanbul, Fatih",
          'price': "Ücretsiz",
          'category': "Tarihi",
          'rating': 4.9,
          'icon': "🕌",
          'isLocked': false,
        },
        {
          'name': "Topkapı Sarayı Müzesi",
          'location': "İstanbul, Fatih",
          'price': "₺1500",
          'category': "Saray",
          'rating': 4.8,
          'icon': "🏰",
          'isLocked': false,
        },
        {
          'name': "Yerebatan Sarnıcı",
          'location': "İstanbul, Sultanahmet",
          'price': "₺600",
          'category': "Tarihi",
          'rating': 4.7,
          'icon': "💧",
          'isLocked': false,
        },
        {
          'name': "Amasra Kalesi",
          'location': "Bartın, Merkez",
          'price': "₺74",
          'category': "Kale",
          'rating': 4.5,
          'icon': "🛡️",
          'isLocked': false,
        },
        {
          'name': "Çankırı Kalesi",
          'location': "Çankırı, Merkez",
          'price': "Ücretsiz",
          'category': "Kale",
          'rating': 4.3,
          'icon': "⚔️",
          'isLocked': false,
        },
        {
          'name': "Mevlana Müzesi ve Camii",
          'location': "Konya, Karatay",
          'price': "Ücretsiz",
          'category': "Dini",
          'rating': 4.9,
          'icon': "🕌",
          'isLocked': false,
        },
      ];

      try {
        WriteBatch batch = _firestore.batch();
        for (var museum in defaultMuseums) {
          String docId = museum['name']
              .toString()
              .toLowerCase()
              .replaceAll(' ', '_')
              .replaceAll('-', '_');
          DocumentReference docRef = _firestore
              .collection('museums')
              .doc(docId);
          batch.set(docRef, museum);
        }
        await batch.commit();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Müzeler veritabanına otomatik olarak başarıyla yüklendi!",
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        debugPrint("Veritabanı kurulum hatası: $e");
      } finally {
        if (mounted) {
          setState(() {
            _isSettingUp = false;
          });
        }
      }
    }
  }

  void _cikisYap() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("Çıkış Yap"),
          content: const Text(
            "Yönetim panelinden çıkış yapıp giriş ekranına dönmek istiyor musunuz?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Vazgeç", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                Navigator.pop(context);

                await FirebaseAuth.instance.signOut();
              },
              child: const Text(
                "Çıkış Yap",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _toggleTicketSales(String docId, bool currentLockStatus) async {
    try {
      await _firestore.collection('museums').doc(docId).update({
        'isLocked': currentLockStatus,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              currentLockStatus
                  ? "Müze kilitlendi, bilet satışı kapatıldı."
                  : "Müze kilidi açıldı, bilet satışı aktif.",
            ),
            backgroundColor: currentLockStatus ? Colors.red : Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Durum güncellenirken hata oluştu: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDarkMode ? Colors.white : Colors.blueGrey[900]!;
    final Color cardColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final Color scaffoldBg = isDarkMode
        ? const Color(0xFF0F172A)
        : const Color(0xFFF8FAFC);
    final Color borderColor = isDarkMode
        ? const Color(0xFF334155)
        : Colors.grey[200]!;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: Text(
          "Müze Yönetimi",
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        backgroundColor: cardColor,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              onPressed: _cikisYap,
              icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              tooltip: "Çıkış Yap",
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Yönetim Paneli",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Bilet alımını durdurmak istediğiniz müzenin anahtarını kapatın.",
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('museums').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _checkAndSetupMuseums(docs);
                  });
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          "Veritabanı otomatik olarak kuruluyor...",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: docs.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final String docId = doc.id;
                    final String name = data['name'] ?? docId;
                    final String location =
                        data['location'] ?? "Konum Belirtilmedi";
                    final String price = data['price'] ?? "Ücretsiz";
                    final String icon = data['icon'] ?? "🏛️";

                    final bool isLocked = data['isLocked'] ?? false;

                    return Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: !isLocked
                              ? borderColor
                              : Colors.red.withOpacity(0.3),
                          width: !isLocked ? 1 : 1.5,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Colors.black26
                                : Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              icon,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        title: Text(
                          name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: !isLocked
                                ? textColor
                                : textColor.withOpacity(0.5),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              location,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: !isLocked
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    !isLocked ? "AÇIK" : "KAPALI",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: !isLocked
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  !isLocked ? price : "Kilitli",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    color: !isLocked ? Colors.blue : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Switch(
                          value: !isLocked,
                          activeColor: Colors.blue,
                          activeTrackColor: Colors.blue.withOpacity(0.2),
                          inactiveThumbColor: Colors.grey,
                          inactiveTrackColor: Colors.grey.withOpacity(0.2),
                          onChanged: (bool value) {
                            _toggleTicketSales(docId, !value);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
