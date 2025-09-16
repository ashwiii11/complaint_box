import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_page.dart';
// if you used flutterfire configure, import generated options:
// import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // If you used flutterfire CLI:
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // If not using firebase_options.dart, plain call (works if platform's config files added)
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Complaint Box',
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}
