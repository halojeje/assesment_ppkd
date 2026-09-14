import 'dart:async';
import 'package:assesment_ppkd/core/pref_helper.dart';
import 'package:assesment_ppkd/navigator/main_navigator.dart';
import 'package:assesment_ppkd/views/loginpage.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _startSplashScreen();
  }

  void _startSplashScreen() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final prefHelper = PrefHelper();
    final bool isLogin = await prefHelper.isLoggedIn();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            isLogin ? const MainNavigation() : const LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFFAF8F5,
      ), // Warna background krem sesuai gambar
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ikon Logo Dokumen Biru
            Image.asset(
              'assets/images/icon_logo.png',
              width: 100,
              height: 100,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.description_outlined,
                size: 90,
                color: Color(0xFF4C84F6), // Warna biru ikon
              ),
            ),
            const SizedBox(height: 20),

            // Nama Aplikasi (Catatan Hewan) 2 Baris Serif
            const Text(
              'Catatan\nHewan',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                fontFamily: 'Serif',
                color: Colors.black,
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
