import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Kayıt Ol Fonksiyonu
  Future<User?> signUpWithEmailAndPassword(String name, String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Kullanıcı başarılı şekilde kayıt olduysa
      User? user = userCredential.user;
      if (user != null) {
        await user.updateDisplayName(name); // Kullanıcı ismini kaydet
        await user.reload();
        return _auth.currentUser;
      }
      return null;
    } catch (e) {
      print("Hata: $e");
      return null;
    }
  }
}

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Çoklu Masa Ekleme Fonksiyonu
  Future<void> cokluMasaEkle(int baslangic, int bitis) async {
    try {
      for (int i = baslangic; i <= bitis; i++) {
        await _firestore.collection('masalar').doc(i.toString()).set({
          'masaNumarasi': i,
          'durum': 'bos', // Masa ilk başta boş olacak
          'rezervasyonlar': [] // Boş bir rezervasyon listesi olacak
        });
      }
      print("$baslangic ile $bitis arasındaki masalar Firestore’a eklendi!");
    } catch (e) {
      print("Hata: $e");
    }
  }

  // Masaları Getir (Boş & Dolu)
  Future<List<Map<String, dynamic>>> getMasalar() async {
    try {
      QuerySnapshot snapshot = await _firestore
        .collection("masalar")
        .orderBy("masaNumarasi", descending: false)
        .get();

    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  } catch (e) {
    print("Hata: $e");
      return [];
    }
  }

  // Masa Rezervasyonu Yapma
  Future<void> rezervasyonYap(String masaId, String kullaniciId, String baslangicSaat, String bitisSaat) async {
    try {
      DocumentReference masaRef = _firestore.collection('masalar').doc(masaId);

      await masaRef.update({
        'durum': 'dolu',
        'rezervasyonlar': FieldValue.arrayUnion([
          {
            'kullaniciId': kullaniciId,
            'baslangicSaat': baslangicSaat,
            'bitisSaat': bitisSaat
          }
        ])
      });
      print("Masa $masaId başarıyla rezerve edildi.");
    } catch (e) {
      print("Hata: $e");
    }
  }

  // Rezervasyon İptal Etme
  Future<void> rezervasyonIptal(String masaId, String kullaniciId) async {
    try {
      DocumentReference masaRef = _firestore.collection('masalar').doc(masaId);
      DocumentSnapshot doc = await masaRef.get();
      
      if (!doc.exists) return;

      List rezervasyonlar = (doc.data() as Map<String, dynamic>)['rezervasyonlar'];
      rezervasyonlar.removeWhere((rez) => rez['kullaniciId'] == kullaniciId);

      await masaRef.update({
        'rezervasyonlar': rezervasyonlar,
        'durum': rezervasyonlar.isEmpty ? 'bos' : 'dolu'
      });

      print("Masa $masaId için rezervasyon iptal edildi.");
    } catch (e) {
      print("Hata: $e");
    }
  }
}

