import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  // Bileti onaylamak (kullanıldı olarak işaretlemek) için fonksiyon
  Future<void> _approveTicket(String ticketId) async {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        title: Text(
          "Bileti Onayla",
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
        content: Text(
          "Biletinizi Onaylamak İstiyor musunuz?",
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
        ),
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
            .update({'status': 'used'});

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
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Renk Değişkenleri
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1E293B);
    final Color subTextColor = isDarkMode
        ? Colors.white70
        : const Color(0xFF64748B);
    final Color cardColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final Color borderColor = isDarkMode
        ? const Color(0xFF334155)
        : const Color(0xFFE2E8F0);
    final Color scaffoldBg = isDarkMode
        ? const Color(0xFF0F172A)
        : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: Text(
          "Biletlerim",
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        centerTitle: true,
        backgroundColor: cardColor,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tickets')
            .where('userId', isEqualTo: user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Sorgu Hatası: ${snapshot.error}",
                style: TextStyle(color: textColor),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2563EB)),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState(textColor, subTextColor);
          }

          final tickets = snapshot.data!.docs.toList();

          // Manuel Sıralama
          tickets.sort((a, b) {
            var aData = a.data() as Map<String, dynamic>;
            var bData = b.data() as Map<String, dynamic>;
            Timestamp? aTime = aData['createdAt'] as Timestamp?;
            Timestamp? bTime = bData['createdAt'] as Timestamp?;
            if (aTime == null || bTime == null) return 0;
            return bTime.compareTo(aTime);
          });

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              var doc = tickets[index];
              var data = doc.data() as Map<String, dynamic>;
              String docId = doc.id;

              return _buildPhysicalTicket(
                data,
                docId,
                cardColor,
                textColor,
                subTextColor,
                borderColor,
                scaffoldBg,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPhysicalTicket(
    Map<String, dynamic> data,
    String docId,
    Color bg,
    Color text,
    Color subText,
    Color border,
    Color scaffoldBg,
  ) {
    bool isUsed = data['status'] == 'used';

    return GestureDetector(
      onTap: isUsed ? null : () => _approveTicket(docId),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isUsed ? 0.6 : 1.0,
        child: Container(
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isUsed ? 0.02 : 0.1),
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
                        color: border.withOpacity(0.3),
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
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: text,
                            ),
                          ),
                          Text(
                            data['location'] ?? "Konum Bilgisi",
                            style: TextStyle(color: subText, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isUsed ? Icons.check_circle : Icons.qr_code_2,
                      size: 40,
                      color: isUsed ? Colors.green : text,
                    ),
                  ],
                ),
              ),

              // Kesik Çizgi ve Çentikler
              Row(
                children: [
                  _ticketNotch(isLeft: true, color: scaffoldBg),
                  Expanded(child: _dashedLine(border)),
                  _ticketNotch(isLeft: false, color: scaffoldBg),
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
                        _ticketDetail(
                          "TARİH",
                          data['date'] ?? "---",
                          subText,
                          text,
                        ),
                        _ticketDetail(
                          "KİŞİ",
                          data['visitorCount'] ?? "1 Kişi",
                          subText,
                          text,
                        ),
                        _ticketDetail(
                          "DURUM",
                          isUsed ? "KULLANILDI" : "AKTİF",
                          subText,
                          text,
                          isPrice: !isUsed,
                        ),
                      ],
                    ),
                    if (!isUsed)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          "Onaylamak için biletin üzerine tıkla",
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue.shade400,
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

  Widget _ticketNotch({required bool isLeft, required Color color}) {
    return Container(
      height: 20,
      width: 10,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.only(
          topRight: isLeft ? const Radius.circular(10) : Radius.zero,
          bottomRight: isLeft ? const Radius.circular(10) : Radius.zero,
          topLeft: !isLeft ? const Radius.circular(10) : Radius.zero,
          bottomLeft: !isLeft ? const Radius.circular(10) : Radius.zero,
        ),
      ),
    );
  }

  Widget _dashedLine(Color color) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            (constraints.constrainWidth() / 10).floor(),
            (index) => SizedBox(
              width: 5,
              height: 1,
              child: DecoratedBox(decoration: BoxDecoration(color: color)),
            ),
          ),
        );
      },
    );
  }

  Widget _ticketDetail(
    String label,
    String value,
    Color labelColor,
    Color valueColor, {
    bool isPrice = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: labelColor,
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
                : (value == "KULLANILDI" ? Colors.green : valueColor),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(Color text, Color subText) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("🎫", style: TextStyle(fontSize: 80)),
          const SizedBox(height: 16),
          Text(
            "Henüz biletin yok!",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Hemen keşfetmeye başlayıp ilk biletini al.",
            style: TextStyle(color: subText),
          ),
        ],
      ),
    );
  }
}
