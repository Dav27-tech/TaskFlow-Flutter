import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    // Laisse le temps au Splash de s'afficher.
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/logo/taskflow-illustration.svg',
              width: 220,
              height: 220,
            ),
            SizedBox(height: 24),
            const Text(
              'TaskFlow',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2563EB),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Ensemble, organisons vos projets.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Color(0xFF718096)),
            ),
            const SizedBox(height: 40),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          ],
        ),
      ),
    );
  }
}
