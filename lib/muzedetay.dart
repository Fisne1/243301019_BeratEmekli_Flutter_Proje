import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'muzeler.dart';

class MuseumDetailScreen extends StatefulWidget {
  final Museum museum;
  const MuseumDetailScreen({super.key, required this.museum});

  @override
  State<MuseumDetailScreen> createState() => _MuseumDetailScreenState();
}

class _MuseumDetailScreenState extends State<MuseumDetailScreen> {
  int _count = 1;

  Future<void> _handleBooking() async {
    final user = FirebaseAuth.instance.currentUser;

    // Kullanıcı girişi kontrolü
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lütfen önce giriş yapın!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Yükleniyor diyaloğunu aç
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    try {
      // Timeout ekleyerek sonsuza kadar dönmesini engelliyoruz
      await FirebaseFirestore.instance
          .collection('tickets')
          .add({
            'userId': user.uid,
            'museumName': widget.museum.name,
            'location': widget.museum.location,
            'date': DateTime.now().toString().split(' ')[0],
            'time': DateTime.now().toString().split(' ')[1].substring(0, 5),
            'visitorCount': "$_count Kişi",
            'totalPrice': widget.museum.price == "Ücretsiz"
                ? "₺0"
                : "₺${_count * 600}",
            'icon': widget.museum.icon,
            'status': 'active',
            'createdAt': FieldValue.serverTimestamp(),
          })
          .timeout(const Duration(seconds: 10)); // 10 saniye sonra hata ver

      // Başarılıysa yükleniyor diyaloğunu kapat
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      _showSuccessBottomSheet();
    } catch (e) {
      // Hata durumunda yükleniyor diyaloğunu MUTLAKA kapat
      if (mounted) Navigator.of(context, rootNavigator: true).pop();

      String errorMsg =
          "Bilet alınamadı. Lütfen internetini veya Firebase ayarlarını kontrol et.";
      if (e.toString().contains("permission-denied")) {
        errorMsg = "Firebase Kuralları (Rules) yazmaya izin vermiyor!";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
      );
      print("Hata Detayı: $e");
    }
  }

  void _showSuccessBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 16),
            const Text(
              "Biletin Hazır!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Modal kapat
                Navigator.pop(context); // Sayfadan çık
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "Harika!",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: const Color(0xFF2563EB),
                child: Center(
                  child: Text(
                    widget.museum.icon,
                    style: const TextStyle(fontSize: 80),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.museum.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.museum.location,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  _buildVisitorSelector(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomActionBar(),
    );
  }

  Widget _buildVisitorSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Ziyaretçi Sayısı",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            IconButton(
              onPressed: () => setState(() => _count > 1 ? _count-- : null),
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Text(
              "$_count",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: () => setState(() => _count++),
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _handleBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                padding: const EdgeInsets.symmetric(vertical: 16),
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
          ),
        ],
      ),
    );
  }
}
