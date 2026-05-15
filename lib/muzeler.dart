import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Museum {
  final int id;
  final String name;
  final String location;
  final String price;
  final String category;
  final double rating;
  final String icon;

  Museum({
    required this.id,
    required this.name,
    required this.location,
    required this.price,
    required this.category,
    required this.rating,
    required this.icon,
  });
}

class MuseumsScreen extends StatefulWidget {
  const MuseumsScreen({super.key});

  @override
  State<MuseumsScreen> createState() => _MuseumsScreenState();
}

class _MuseumsScreenState extends State<MuseumsScreen> {
  final List<String> categories = ["Hepsi", "Saray", "Kale", "Tarihi", "Dini"];
  String selectedCategory = "Hepsi";
  String searchTerm = "";

  final List<Museum> museumsData = [
    Museum(
      id: 1,
      name: "Ayasofya-i Kebir Cami-i",
      location: "İstanbul, Fatih",
      price: "Ücretsiz",
      category: "Tarihi",
      rating: 4.9,
      icon: "🕌",
    ),
    Museum(
      id: 2,
      name: "Topkapı Sarayı Müzesi",
      location: "İstanbul, Fatih",
      price: "₺1500",
      category: "Saray",
      rating: 4.8,
      icon: "🏰",
    ),
    Museum(
      id: 3,
      name: "Yerebatan Sarnıcı",
      location: "İstanbul, Sultanahmet",
      price: "₺600",
      category: "Tarihi",
      rating: 4.7,
      icon: "💧",
    ),
    Museum(
      id: 4,
      name: "Amasya Kalesi",
      location: "Amasya, Merkez",
      price: "₺74",
      category: "Kale",
      rating: 4.5,
      icon: "🛡️",
    ),
    Museum(
      id: 5,
      name: "Çankırı Kalesi",
      location: "Çankırı, Merkez",
      price: "Ücretsiz",
      category: "Kale",
      rating: 4.3,
      icon: "⚔️",
    ),
    Museum(
      id: 6,
      name: "Mevlana Müzesi ve Camii",
      location: "Konya, Karatay",
      price: "Ücretsiz",
      category: "Dini",
      rating: 4.9,
      icon: "🕌",
    ),
  ];

  // --- BILET ONALAMA MODALI ---
  void _showBookingDialog(Museum museum) {
    int count = 1;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final bool isFree = museum.price == "Ücretsiz";
            final int unitPrice = isFree
                ? 0
                : int.parse(museum.price.replaceAll('₺', ''));
            final String totalDisplay = isFree
                ? "Ücretsiz"
                : "₺${unitPrice * count}";

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(museum.icon, style: const TextStyle(fontSize: 48)),
                    const SizedBox(height: 16),
                    Text(
                      museum.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      museum.location,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Ziyaretçi",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => setDialogState(
                                () => count > 1 ? count-- : null,
                              ),
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                            Text(
                              "$count",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: () => setDialogState(() => count++),
                              icon: const Icon(
                                Icons.add_circle_outline,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Toplam Tutar",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          totalDisplay,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () =>
                          _handleBooking(museum, count, totalDisplay),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "Bileti Onayla",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "İptal Et",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- FIREBASE KAYIT ISLEMI ---
  Future<void> _handleBooking(
    Museum museum,
    int count,
    String totalPrice,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    Navigator.pop(context); // Dialogu kapat

    // Yükleme Göstergesi
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: Colors.blue)),
    );

    try {
      await FirebaseFirestore.instance.collection('tickets').add({
        'userId': user.uid,
        'museumName': museum.name,
        'location': museum.location,
        'date': DateTime.now().toString().split(' ')[0],
        'time': DateTime.now().toString().split(' ')[1].substring(0, 5),
        'visitorCount': "$count Kişi",
        'totalPrice': totalPrice,
        'icon': museum.icon,
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context); // Yüklemeyi kapat
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata: $e"), backgroundColor: Colors.red),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 70),
            const SizedBox(height: 16),
            const Text(
              "İşlem Başarılı!",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Biletinizi 'Biletlerim' sekmesinde bulabilirsiniz.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Anladım",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2563EB),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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

    final filteredMuseums = museumsData.where((m) {
      final matchesSearch =
          m.name.toLowerCase().contains(searchTerm.toLowerCase()) ||
          m.location.toLowerCase().contains(searchTerm.toLowerCase());
      final matchesCategory =
          selectedCategory == "Hepsi" || m.category == selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Müzeleri Keşfet",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Türkiye'nin tarihine yolculuk yapın.",
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: subTextColor,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                onChanged: (value) => setState(() => searchTerm = value),
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: "İsim veya şehir ile ara...",
                  hintStyle: TextStyle(color: subTextColor),
                  prefixIcon: Icon(Icons.search, color: subTextColor),
                  filled: true,
                  fillColor: cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: borderColor),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 45,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final isSelected = selectedCategory == cat;
                    return GestureDetector(
                      onTap: () => setState(() => selectedCategory = cat),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF2563EB)
                              : cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF2563EB)
                                : borderColor,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            cat,
                            style: TextStyle(
                              color: isSelected ? Colors.white : subTextColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "SONUÇLAR (${filteredMuseums.length})",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: subTextColor,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 18),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredMuseums.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final museum = filteredMuseums[index];
                  return Material(
                    color: Colors.transparent,
                    child: Ink(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: borderColor),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(32),
                        onTap: () =>
                            _showBookingDialog(museum), // Direkt modal açar
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? Colors.black26
                                      : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: Text(
                                    museum.icon,
                                    style: const TextStyle(fontSize: 32),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      museum.category.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: _getCategoryColor(
                                          museum.category,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      museum.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: textColor,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          size: 12,
                                          color: subTextColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          museum.location,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: subTextColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    museum.price,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: museum.price == "Ücretsiz"
                                          ? Colors.green
                                          : textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Icon(
                                    Icons.add_circle,
                                    color: Color(0xFF2563EB),
                                    size: 24,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Saray':
        return const Color(0xFFD97706);
      case 'Kale':
        return const Color(0xFF059669);
      case 'Dini':
        return const Color(0xFF9333EA);
      default:
        return const Color(0xFF2563EB);
    }
  }
}
