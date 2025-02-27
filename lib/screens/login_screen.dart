import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _login() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      // Giriş başarılı, ana ekrana yönlendir
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LibraryScreen()),
      );
    } catch (e) {
      // Hata durumunda kullanıcıya mesaj göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Giriş başarısız: $e")),
      );
    }
  }

  bool isCurrentlyReserved(List<dynamic>? rezervasyonlar) {
    if (rezervasyonlar == null) return false;
    DateTime now = DateTime.now();
    for (var rezervasyon in rezervasyonlar) {
      if (rezervasyon['baslangicSaat'] == null || rezervasyon['bitisSaat'] == null) continue;
      DateTime baslangic = DateTime.parse(rezervasyon['baslangicSaat']);
      DateTime bitis = DateTime.parse(rezervasyon['bitisSaat']);
      if (now.isAfter(baslangic) && now.isBefore(bitis)) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Giriş Yap")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "E-mail"),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Şifre"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text("Giriş Yap"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, "/signup");
              },
              child: Text("Hesabın yok mu? Kayıt ol"),
            ),
          ],
        ),
      ),
    );
  }
}

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool isCurrentlyReserved(List<dynamic>? rezervasyonlar) {
    if (rezervasyonlar == null) return false;
    DateTime now = DateTime.now();
    for (var rezervasyon in rezervasyonlar) {
      if (rezervasyon['baslangicSaat'] == null || rezervasyon['bitisSaat'] == null) continue;
      DateTime baslangic = DateTime.parse(rezervasyon['baslangicSaat']);
      DateTime bitis = DateTime.parse(rezervasyon['bitisSaat']);
      if (now.isAfter(baslangic) && now.isBefore(bitis)) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Kütüphane Masaları")),
      body: StreamBuilder(
        stream: firestore.collection('masalar').orderBy('masaNumarasi').snapshots(), // Firestore'dan masaları al ve sıralama ekle
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) return Center(child: Text("Bir hata oluştu: ${snapshot.error}"));
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          var masalar = snapshot.data!.docs;

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3), // 3 sütunlu grid
            itemCount: masalar.length,
            itemBuilder: (context, index) {
              var masa = masalar[index];
              bool dolu = masa['durum'] == "dolu"; // Masa dolu mu boş mu?
              bool currentlyReserved = isCurrentlyReserved(masa['rezervasyonlar'] ?? []);

              return GestureDetector(
                onTap: dolu ? null : () {
                  Navigator.pushNamed(context, "/reservation", arguments: masa.id);
                },
                child: Container(
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: currentlyReserved ? Colors.grey : (dolu ? Colors.grey : Colors.green), // Boşsa yeşil, doluysa gri, rezerve edilmişse soluk gri
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