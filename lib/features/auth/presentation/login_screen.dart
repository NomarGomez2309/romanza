import 'package:flutter/material.dart';
import 'package:romanza/features/dashboard/presentation/dashboard_screen.dart';

import '../../../services/auth_service.dart';
import '../../onboarding/presentation/screens/relationship_date_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const _ink = Color(0xFF555555);
  static const _green = Color(0xFF70D39B);
  static const _paper = Color(0xFFFDFDFB);
  static const _tile = Color(0xFFD8D8D8);

  void _openLogin(BuildContext context) {
    final user = AuthService().currentUser;
    if (user != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AuthAccessScreen(mode: AuthMode.login),
      ),
    );
  }

  void _openSignIn(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const RegisterScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _paper,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(42, 28, 42, 40),
          child: Column(
            children: [
              const Spacer(flex: 5),
              const _CenterMark(),
              const Spacer(flex: 4),
              _NeoButton(
                label: 'Login',
                color: _green,
                textColor: Colors.white,
                onPressed: () => _openLogin(context),
              ),
              const SizedBox(height: 24),
              _NeoButton(
                label: 'Sign In',
                color: _paper,
                textColor: _ink,
                onPressed: () => _openSignIn(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum AuthMode { login, register }

class AuthAccessScreen extends StatefulWidget {
  const AuthAccessScreen({super.key, required this.mode});

  final AuthMode mode;

  @override
  State<AuthAccessScreen> createState() => _AuthAccessScreenState();
}

class _AuthAccessScreenState extends State<AuthAccessScreen> {
  final AuthService _auth = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  bool get _isRegister => widget.mode == AuthMode.register;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final result = _isRegister
        ? await _auth.register(email, password)
        : await _auth.login(email, password);

    if (!mounted) return;
    setState(() => _isLoading = false);

    final session = result.session;
    if (session == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? 'No pude entrar.')),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  Future<void> _continueWithGoogle() async {
    setState(() => _isLoading = true);

    final result = await _auth.loginWithGoogle();

    if (!mounted) return;
    setState(() => _isLoading = false);

    final session = result.session;
    if (session == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? 'No pude entrar con Google.')),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => _shouldOpenOnboarding(session)
            ? const RelationshipDateScreen()
            : const DashboardScreen(),
      ),
    );
  }

  bool _shouldOpenOnboarding(AuthSession session) {
    return session.profileCreated || !session.hasRelationshipDate;
  }

  @override
  Widget build(BuildContext context) {
    final title = _isRegister ? 'Create Account' : 'Welcome Back';
    final action = _isRegister ? 'Continue' : 'Login';

    return Scaffold(
      backgroundColor: LoginScreen._paper,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(26, 26, 26, 34),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.sizeOf(context).height -
                  MediaQuery.paddingOf(context).vertical -
                  60,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SquareIconButton(
                  icon: Icons.arrow_back,
                  onTap: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: 48),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: LoginScreen._ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isRegister
                      ? 'Use Google or email to start Romanza.'
                      : 'Enter with the account you already created.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: LoginScreen._ink.withValues(alpha: .72),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 30),
                _NeoButton(
                  label: 'Continue with Google',
                  color: const Color(0xFFE6E0D5),
                  textColor: LoginScreen._ink,
                  onPressed: _isLoading ? null : _continueWithGoogle,
                ),
                const SizedBox(height: 18),
                _NeoTextField(
                  controller: _emailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _NeoTextField(
                  controller: _passwordController,
                  label: 'Password',
                  obscureText: true,
                ),
                const SizedBox(height: 26),
                _NeoButton(
                  label: _isLoading ? 'Loading...' : action,
                  color: LoginScreen._green,
                  textColor: Colors.white,
                  onPressed: _isLoading ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CenterMark extends StatelessWidget {
  const _CenterMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 194,
      height: 102,
      alignment: Alignment.center,
      decoration: const BoxDecoration(color: LoginScreen._tile),
      child: Image.asset(
        'assets/images/Logo.png',
        width: 116,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _NeoTextField extends StatelessWidget {
  const _NeoTextField({
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: LoginScreen._ink,
        fontWeight: FontWeight.w800,
      ),
      decoration: InputDecoration(
        hintText: label,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: LoginScreen._ink, width: 2),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: LoginScreen._ink, width: 3),
        ),
      ),
    );
  }
}

class _NeoButton extends StatelessWidget {
  const _NeoButton({
    required this.label,
    required this.color,
    required this.textColor,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onPressed == null ? .6 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          child: Container(
            height: 50,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: LoginScreen._ink, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: LoginScreen._ink,
                  blurRadius: 0,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SquareIconButton extends StatelessWidget {
  const _SquareIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFD8D8D8),
          border: Border.all(color: LoginScreen._ink, width: 2),
          boxShadow: const [
            BoxShadow(
              color: LoginScreen._ink,
              blurRadius: 0,
              offset: Offset(3, 3),
            ),
          ],
        ),
        child: Icon(icon, color: LoginScreen._ink, size: 19),
      ),
    );
  }
}
