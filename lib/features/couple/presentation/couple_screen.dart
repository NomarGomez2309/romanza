import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../services/couple_service.dart';

class CoupleScreen extends StatefulWidget {
  const CoupleScreen({super.key});

  @override
  State<CoupleScreen> createState() => _CoupleScreenState();
}

class _CoupleScreenState extends State<CoupleScreen> {
  static const _ink = Color(0xFF5B5B5B);
  static const _mint = Color(0xFFDDF3EA);
  static const _sand = Color(0xFFE2C987);
  static const _orange = Color(0xFFFF9C39);
  static const _green = Color(0xFF75D48F);
  static const _paper = Color(0xFFE6E0D5);

  final CoupleService _service = CoupleService();
  final TextEditingController _codeController = TextEditingController();

  String? _inviteCode;
  String? _inviteLink;
  bool _isLoading = true;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _loadCouple();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _loadCouple() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      return;
    }

    final couple = await _service.getMyCouple(user.uid);
    if (!mounted) return;

    setState(() {
      _inviteCode = couple?['inviteCode'] as String?;
      _inviteLink = _inviteCode == null ? null : 'romanza://join/$_inviteCode';
      _isConnected = (couple?['user2Id'] as String? ?? '').isNotEmpty;
      _isLoading = false;
    });
  }

  Future<void> _createCouple() async {
    setState(() => _isLoading = true);
    final couple = await _service.createCouple();
    if (!mounted) return;

    setState(() {
      _inviteCode = couple?.inviteCode;
      _inviteLink = couple?.inviteLink;
      _isConnected = false;
      _isLoading = false;
    });

    if (couple == null) {
      _showMessage('Inicia sesion para crear un codigo.');
    }
  }

  Future<void> _joinCouple() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      _showMessage('Escribe un codigo primero.');
      return;
    }

    setState(() => _isLoading = true);
    final success = await _service.joinCouple(code);
    if (!mounted) return;

    setState(() {
      _isConnected = success;
      _isLoading = false;
    });

    _showMessage(success ? 'Pareja vinculada.' : 'Codigo invalido.');
  }

  Future<void> _copyCode() async {
    final code = _inviteCode;
    if (code == null) return;

    await Clipboard.setData(ClipboardData(text: code));
    if (mounted) {
      _showMessage('Codigo copiado.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(
      context,
    ).textTheme.apply(bodyColor: _ink, displayColor: _ink);

    return Theme(
      data: Theme.of(context).copyWith(textTheme: textTheme),
      child: Scaffold(
        backgroundColor: _mint,
        body: SafeArea(
          child: _StripedBackground(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 34),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(onBack: () => Navigator.of(context).pop()),
                  const SizedBox(height: 24),
                  _Panel(
                    color: _sand,
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Couple Code',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 12),
                        _CodeBox(
                          value: _isLoading ? '...' : (_inviteCode ?? '------'),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _inviteLink ?? 'Crea un codigo para vincular pareja.',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: _Button(
                          label: _inviteCode == null ? 'Create' : 'New Code',
                          onPressed: _isLoading ? null : _createCouple,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _Button(
                          label: 'Copy',
                          color: _green,
                          onPressed: _inviteCode == null ? null : _copyCode,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  _Panel(
                    color: _paper,
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enter Partner Code',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 12),
                        _RetroTextField(controller: _codeController),
                        const SizedBox(height: 14),
                        _Button(
                          label: 'Link Partner',
                          onPressed: _isLoading ? null : _joinCouple,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _Panel(
                    color: _isConnected ? _green : _paper,
                    height: 62,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _isConnected ? 'Status: Connected' : 'Status: Waiting',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StripedBackground extends StatelessWidget {
  const _StripedBackground({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: _CoupleScreenState._mint, child: child);
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onBack,
          child: Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFD7D7D7),
              border: Border.all(color: _CoupleScreenState._ink, width: 2),
            ),
            child: const Icon(
              Icons.arrow_back,
              color: _CoupleScreenState._ink,
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Couple /',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 23,
              letterSpacing: 0,
            ),
          ),
        ),
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFFD7D7D7),
            border: Border.all(color: _CoupleScreenState._ink, width: 2),
          ),
        ),
      ],
    );
  }
}

class _CodeBox extends StatelessWidget {
  const _CodeBox({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      decoration: BoxDecoration(
        color: _CoupleScreenState._sand,
        border: Border.all(color: _CoupleScreenState._ink, width: 2),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          value,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            fontSize: 48,
            height: .9,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

class _RetroTextField extends StatelessWidget {
  const _RetroTextField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLength: 6,
      textCapitalization: TextCapitalization.characters,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: _CoupleScreenState._ink,
        fontWeight: FontWeight.w800,
        letterSpacing: 1,
      ),
      decoration: InputDecoration(
        counterText: '',
        hintText: 'ABC123',
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: const BorderSide(
            color: _CoupleScreenState._ink,
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: const BorderSide(
            color: _CoupleScreenState._ink,
            width: 2.5,
          ),
        ),
      ),
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({
    required this.label,
    required this.onPressed,
    this.color = _CoupleScreenState._orange,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onPressed == null ? .55 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          child: _Panel(
            color: color,
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF275980),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.color,
    required this.child,
    this.height,
    this.padding = const EdgeInsets.all(8),
  });

  final Color color;
  final Widget child;
  final double? height;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: _CoupleScreenState._ink, width: 2),
        boxShadow: const [
          BoxShadow(
            color: _CoupleScreenState._ink,
            blurRadius: 0,
            offset: Offset(4, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
