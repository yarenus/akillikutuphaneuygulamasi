import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool isCurrentlyReserved(List<dynamic>? rezervasyonlar) {
    if (rezervasyonlar == null || rezervasyonlar.isEmpty) return false;
    DateTime now = DateTime.now();
    for (var rezervasyon in rezervasyonlar) {
      if (rezervasyon['baslangicSaat'] == null || rezervasyon['bitisSaat'] == null) continue;
      DateTime baslangic = (rezervasyon['baslangicSaat'] as Timestamp).toDate();
      DateTime bitis = (rezervasyon['bitisSaat'] as Timestamp).toDate();
      if (now.isAfter(baslangic) && now.isBefore(bitis)) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Kütüphane Masaları")),
      body: StreamBuilder(
        stream: firestore.collection('masalar').orderBy('masaNumarasi').snapshots(), // Firestore'dan masaları al ve sıralama ekle
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) return Center(child: Text("Bir hata oluştu: ${snapshot.error}"));
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          var masalar = snapshot.data!.docs;

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3), // 3 sütunlu grid
            itemCount: masalar.length,
            itemBuilder: (context, index) {
              var masa = masalar[index];
              bool dolu = masa['durum'] == "dolu"; // Masa dolu mu boş mu?
              bool currentlyReserved = isCurrentlyReserved(masa['rezervasyonlar'] ?? []);

              return GestureDetector(
                onTap: dolu ? null : () {
                  Navigator.pushNamed(context, "/reservation", arguments: masa.id);
                },
                child: Container(
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: currentlyReserved ? Colors.grey : (dolu ? Colors.orange : Colors.green), // Boşsa yeşil, doluysa turuncu, rezerve edilmişse gri
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(child: Text("Masa ${masa['masaNumarasi']}")),
                ),
              );
            },
          );
        },
      ),
    );
  }
}