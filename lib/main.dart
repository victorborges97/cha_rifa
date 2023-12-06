import 'package:cha_rifa/my_home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyB6geKEv3ilXwY5QSx12wCBD5WKxoJpsPc",
      appId: "1:402093067987:web:768c2642a7d3e032fa4e26",
      messagingSenderId: "402093067987",
      projectId: "easy-barber-dc584",
      databaseURL: "https://easy-barber-dc584-default-rtdb.firebaseio.com",
    ),
  );
  runApp(
    MaterialApp(
      home: MyHomePage(),
    ),
  );
}
