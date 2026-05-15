import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  // Bilet onay
  Future<void> _approveTicket(String ticketId) async {
    // Onay penceresi göster
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Bileti Onayla"),
        content: const Text("Biletinizi Onaylamak İstiyor musunuz?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text(
              "Evet, Onayla",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('tickets')
            .doc(ticketId)
            .update({'status': 'used'}); // Durumu 'used' (kullanıldı) yapıyoruz

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Bilet başarıyla onaylandı!"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Hata: $e"), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Biletlerim",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tickets')
            .where('userId', isEqualTo: user?.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return Center(child: Text("Hata: ${snapshot.error}"));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2563EB)),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
            return _buildEmptyState();

          final tickets = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              var doc = tickets[index];
              var data = doc.data() as Map<String, dynamic>;
              String docId = doc.id; // Belgenin ID'sini alıyoruz

              return _buildPhysicalTicket(data, docId);
            },
          );
        },
      ),
    );
  }

  Widget _buildPhysicalTicket(Map<String, dynamic> data, String docId) {
    bool isUsed = data['status'] == 'used';

    return GestureDetector(
      // Eğer bilet zaten kullanılmadıysa üzerine tıklandığında onaylama tetiklensin
      onTap: isUsed ? null : () => _approveTicket(docId),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isUsed ? 0.6 : 1.0, // Kullanılmışsa biraz soluk görünsün
        child: Container(
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Üst Kısım
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          data['icon'] ?? "🎫",
                          style: const TextStyle(fontSize: 30),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['museumName'] ?? "Müze",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            data['location'] ?? "Konum Bilgisi",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Durum İkonu
                    Icon(
                      isUsed ? Icons.check_circle : Icons.qr_code_2,
                      size: 40,
                      color: isUsed ? Colors.green : const Color(0xFF1E293B),
                    ),
                  ],
                ),
              ),

              Row(
                children: [
                  _ticketNotch(isLeft: true),
                  Expanded(child: _dashedLine()),
                  _ticketNotch(isLeft: false),
                ],
              ),

              // Alt Kısım
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _ticketDetail("TARİH", data['date'] ?? "---"),
                        _ticketDetail("KİŞİ", data['visitorCount'] ?? "1 Kişi"),
                        _ticketDetail(
                          "DURUM",
                          isUsed ? "KULLANILDI" : "AKTİF",
                          isPrice: !isUsed,
                        ),
                      ],
                    ),
                    if (!isUsed)
                      const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Text(
                          "Onaylamak için biletin üzerine tıkla",
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ... ( _ticketNotch, _dashedLine, _ticketDetail, _buildEmptyState aynı kalıyor )
  // Not: _ticketDetail içindeki 'isPrice' parametresini rengi değiştirmek için kullanabiliriz.
  Widget _ticketNotch({required bool isLeft}) {
    return Container(
      height: 20,
      width: 10,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.only(
          topRight: isLeft ? const Radius.circular(10) : Radius.zero,
          bottomRight: isLeft ? const Radius.circular(10) : Radius.zero,
          topLeft: !isLeft ? const Radius.circular(10) : Radius.zero,
          bottomLeft: !isLeft ? const Radius.circular(10) : Radius.zero,
        ),
      ),
    );
  }

  Widget _dashedLine() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            (constraints.constrainWidth() / 10).floor(),
            (index) => const SizedBox(
              width: 5,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Color(0xFFE2E8F0)),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _ticketDetail(String label, String value, {bool isPrice = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isPrice
                ? const Color(0xFF2563EB)
                : (value == "KULLANILDI"
                      ? Colors.green
                      : const Color(0xFF1E293B)),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("🎫", style: TextStyle(fontSize: 80)),
          const SizedBox(height: 16),
          const Text(
            "Henüz biletin yok!",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Hemen keşfetmeye başlayıp ilk biletini al.",
            style: TextStyle(color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}
