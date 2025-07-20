import 'package:emo_music_app/ui/screens/auth/login_screen.dart';
import 'package:emo_music_app/ui/screens/auth/sign_up_screen.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool showLogin = true;

  void toggleAuth() {
    setState(() {
      showLogin = !showLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 500),
      child: showLogin
          ? LoginScreen(key: ValueKey("login"), onSignUpTap: toggleAuth)
          : SignUpScreen(key: ValueKey('signup'), onLoginTap: toggleAuth),
    );
  }
}
