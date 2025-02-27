import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application2/firebase_options.dart';
import 'package:flutter_application2/screens/signup_screen.dart';
import 'screens/login_screen.dart';  // Giriş ekranını ekledik
import 'screens/library_screen.dart' as lib;  // Kütüphane ekranını ekledik
import 'screens/reservation_screen.dart'; // Randevu ekranı da eklendi
import 'services/firestore_services.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirestoreService firestoreService = FirestoreService();

  firestoreService.cokluMasaEkle(1, 32);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kütüphane Rezervasyon',
      initialRoute: "/login", // Uygulama açıldığında giriş ekranı gelsin
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      routes: {
        "/login": (context) => LoginScreen(),
        "/signup": (context) => SignUpScreen(),
        "/home": (context) => lib.LibraryScreen(), // Giriş başarılı olunca buraya gidecek
        "/reservation": (context) {
          final String masaNumarasi = (ModalRoute.of(context)!.settings.arguments ?? '') as String;
          return ReservationScreen(masaNumarasi: masaNumarasi);
        },
      },
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kütüphane Rezervasyon"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Text("data"),
    );
  }
}



