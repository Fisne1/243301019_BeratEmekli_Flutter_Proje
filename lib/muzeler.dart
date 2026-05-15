import 'package:flutter/material.dart';
import 'biletler.dart';
import "muzedetay.dart";

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

  @override
  Widget build(BuildContext context) {
    final filteredMuseums = museumsData.where((m) {
      final matchesSearch =
          m.name.toLowerCase().contains(searchTerm.toLowerCase()) ||
          m.location.toLowerCase().contains(searchTerm.toLowerCase());
      final matchesCategory =
          selectedCategory == "Hepsi" || m.category == selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Müzeleri Keşfet",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Türkiye'nin tarihine yolculuk yapın.",
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 24),

              TextField(
                onChanged: (value) => setState(() => searchTerm = value),
                decoration: InputDecoration(
                  hintText: "İsim veya şehir ile ara...",
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF94A3B8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
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
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF2563EB)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF2563EB)
                                : const Color(0xFFF1F5F9),
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: Center(
                          child: Text(
                            cat,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF64748B),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "SONUÇLAR (${filteredMuseums.length})",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF94A3B8),
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              if (filteredMuseums.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: Text(
                      "Müze bulunamadı.",
                      style: TextStyle(color: Color(0xFF64748B)),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredMuseums.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final museum = filteredMuseums[index];

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MuseumDetailScreen(museum: museum),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(32),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
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
                                      color: _getCategoryColor(museum.category),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    museum.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Color(0xFF1E293B),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        size: 12,
                                        color: Color(0xFF94A3B8),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        museum.location,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
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
                                        : const Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Icon(
                                  Icons.chevron_right,
                                  color: Color(0xFFCBD5E1),
                                  size: 20,
                                ),
                              ],
                            ),
                          ],
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
