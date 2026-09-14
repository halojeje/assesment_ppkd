import 'package:assesment_ppkd/firebase_options.dart';
import 'package:assesment_ppkd/providers/auth_provider.dart';
import 'package:assesment_ppkd/providers/note_provider.dart';
import 'package:assesment_ppkd/views/splashpage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization note: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..loadUserSession(),
        ),
        ChangeNotifierProvider(
          create: (_) => NoteProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Catatan Hewan',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5080E8)),
          fontFamily: 'Fraunces',
          useMaterial3: true,
        ),
        home: const SplashPage(),
      ),
    );
  }
}
