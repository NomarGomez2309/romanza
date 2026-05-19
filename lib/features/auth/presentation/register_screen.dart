import 'package:flutter/material.dart';

import 'login_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthAccessScreen(mode: AuthMode.register);
  }
}
