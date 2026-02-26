import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:investify/features/auth/view/login_screen.dart';
import 'package:investify/features/auth/view/verify_email.dart';
import 'package:investify/features/home/view/main_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CupertinoActivityIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const LoginScreen();
        }

        if (!snapshot.data!.emailVerified) {
          return const VerifyEmailScreen();
        }

        return const MainScreen();
      },
    );
  }
}
