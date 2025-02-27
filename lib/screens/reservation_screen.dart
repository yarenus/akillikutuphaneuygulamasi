import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationScreen extends StatefulWidget {
  final String masaNumarasi;

  const ReservationScreen({required this.masaNumarasi, Key? key}) : super(key: key);

  @override
  _ReservationScreenState createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  final String openTime = "09:00"; // Kütüphane açılış saati
  final String closeTime = "21:00"; // Kütüphane kapanış saati

  /// **Mevcut rezervasyonları getir**
  Future<List<Map<String, dynamic>>> getReservedSlots() async {
    try {
      DocumentSnapshot masaSnapshot = await firestore.collection('masalar').doc(widget.masaNumarasi).get();

      List<Map<String, dynamic>> reservedSlots = [];

      if (masaSnapshot.exists) {
        Map<String, dynamic>? data = masaSnapshot.data() as Map<String, dynamic>?;

        if (data != null && data.containsKey('rezervasyonlar')) {
          List<dynamic> rezervasyonlar = data['rezervasyonlar'];

          for (var rezervasyon in rezervasyonlar) {
            reservedSlots.add({
              "tarih": (rezervasyon['baslangicSaat'] as Timestamp).toDate(),
              "baslangic": (rezervasyon['baslangicSaat'] as Timestamp).toDate(),
              "bitis": (rezervasyon['bitisSaat'] as Timestamp).toDate(),
            });
          }
        }
      }
      return reservedSlots;
    } catch (e) {
      print("Error getting reserved slots: $e");
      return [];
    }
  }

  /// **Tarih Seçme Modalı**
  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 1)),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  /// **Saat Seçme Modalı**
  Future<void> selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      DateTime selectedTime = DateTime(2024, 1, 1, picked.hour, picked.minute);
      DateTime openingTime = DateTime(2024, 1, 1, 9, 0);
      DateTime closingTime = DateTime(2024, 1, 1, 21, 0);

      if (selectedTime.isBefore(openingTime) || selectedTime.isAfter(closingTime)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Sadece 09:00 - 21:00 saatleri arasında rezervasyon yapabilirsiniz!")),
        );
        return;
      }

      setState(() {
        if (isStart) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  /// **Rezervasyon işlemi**
  Future<void> reserveSeat() async {
    if (selectedDate == null || startTime == null || endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lütfen tarih, başlangıç ve bitiş saatlerini seçin!")),
      );
      return;
    }

    DateTime start = DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day, startTime!.hour, startTime!.minute);
    DateTime end = DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day, endTime!.hour, endTime!.minute);

    if (end.isBefore(start) || end.isAtSameMomentAs(start)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Bitiş saati, başlangıç saatinden sonra olmalıdır!")),
      );
      return;
    }

    try {
      DocumentReference masaRef = firestore.collection('masalar').doc(widget.masaNumarasi);
      DocumentSnapshot<Map<String, dynamic>> masaSnapshot = await masaRef.withConverter<Map<String, dynamic>>(
        fromFirestore: (snapshot, _) => snapshot.data()!,
        toFirestore: (data, _) => data,
      ).get();

      if (!masaSnapshot.exists || masaSnapshot.data() == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Masa bulunamadı.")),
        );
        return;
      }

      Map<String, dynamic> data = masaSnapshot.data()!;
      List<Map<String, dynamic>> reservedSlots = [];

      if (data.containsKey('rezervasyonlar')) {
        List<dynamic> rezervasyonlar = data['rezervasyonlar'];
        reservedSlots = rezervasyonlar.map((rez) => {
          "tarih": (rez['baslangicSaat'] as Timestamp).toDate(),
          "baslangic": (rez['baslangicSaat'] as Timestamp).toDate(),
          "bitis": (rez['bitisSaat'] as Timestamp).toDate(),
        }).toList();
      }

      for (var slot in reservedSlots) {
        if (slot["tarih"].year == selectedDate!.year &&
            slot["tarih"].month == selectedDate!.month &&
            slot["tarih"].day == selectedDate!.day) {
          DateTime slotStart = slot["baslangic"];
          DateTime slotEnd = slot["bitis"];

          if (!(end.isBefore(slotStart) || start.isAfter(slotEnd))) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Bu saat aralığı dolu! Lütfen başka bir zaman seçin.")),
            );
            return;
          }
        }
      }

      await masaRef.update({
        'rezervasyonlar': FieldValue.arrayUnion([
          {
            "baslangicSaat": Timestamp.fromDate(start),
            "bitisSaat": Timestamp.fromDate(end),
          }
        ])
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Masa ${widget.masaNumarasi} başarıyla rezerve edildi!")),
      );

      setState(() {
        selectedDate = null;
        startTime = null;
        endTime = null;
      });
    } catch (e) {
      print("Error reserving seat: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Rezervasyon sırasında bir hata oluştu. Lütfen tekrar deneyin.")),
      );
    }
  }

  /// **Rezervasyon iptal işlemi**
  Future<void> cancelReservation(DateTime baslangic, DateTime bitis) async {
    try {
      DocumentReference masaRef = firestore.collection('masalar').doc(widget.masaNumarasi);
      DocumentSnapshot masaSnapshot = await masaRef.get();

      if (masaSnapshot.exists && masaSnapshot.data() != null) {
        Map<String, dynamic> data = masaSnapshot.data() as Map<String, dynamic>;
        if (data.containsKey('rezervasyonlar')) {
          List<dynamic> rezervasyonlar = data['rezervasyonlar'];
          rezervasyonlar.removeWhere((rez) =>
              (rez['baslangicSaat'] as Timestamp).toDate() == baslangic &&
              (rez['bitisSaat'] as Timestamp).toDate() == bitis);

          await masaRef.set({'rezervasyonlar': rezervasyonlar}, SetOptions(merge: true));

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Rezervasyon iptal edildi!")),
          );

          setState(() {});
        }
      }
    } catch (e) {
      print("Error canceling reservation: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Rezervasyon iptali sırasında bir hata oluştu. Lütfen tekrar deneyin.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], 
      appBar: AppBar(
        title: Text("Masa ${widget.masaNumarasi} Rezervasyonu"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            /// **Kütüphane Saatleri Bilgisi**
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 5)],
              ),
              child: Column(
                children: [
                  Text(
                    "📅 Kütüphane Çalışma Saatleri",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  Text("⏰ $openTime - $closeTime", style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            SizedBox(height: 15),

            /// **Dolu Saatleri Gösterme**
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: getReservedSlots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text("Henüz rezervasyon yok.", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    );
                  }

                  List<Map<String, dynamic>> reservedSlots = snapshot.data!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("🔴 Dolu Saatler:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      ...reservedSlots.map((slot) {
                        return Card(
                          color: Colors.redAccent,
                          child: ListTile(
                            title: Text(
                              "${slot['tarih']} ${slot['baslangic']} - ${slot['bitis']} saatleri arası rezerve edildi",
                              style: TextStyle(color: Colors.white),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.cancel, color: Colors.white),
                              onPressed: () => cancelReservation(slot['baslangic'], slot['bitis']),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  );
                },
              ),
            ),

            /// **Tarih ve Saat Seçme Butonları**
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => selectDate(context),
                  icon: Icon(Icons.calendar_today),
                  label: Text("Tarih Seç"),
                ),
                ElevatedButton.icon(
                  onPressed: () => selectTime(context, true),
                  icon: Icon(Icons.timer),
                  label: Text("Başlangıç Saati"),
                ),
                ElevatedButton.icon(
                  onPressed: () => selectTime(context, false),
                  icon: Icon(Icons.timer_off),
                  label: Text("Bitiş Saati"),
                ),
              ],
            ),
            SizedBox(height: 20),

            /// **Rezerve Et Butonu**
            ElevatedButton(
              onPressed: reserveSeat,
              child: Text("Rezerve Et"),
            ),
          ],
        ),
      ),
    );
  }
}