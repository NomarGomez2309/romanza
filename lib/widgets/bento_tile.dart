
import 'package:flutter/material.dart';

class BentoTile extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const BentoTile({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(35, 114, 39, 100),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color.fromARGB(255, 255, 255, 255,))
        ),
        padding: const EdgeInsets.all(12),
        child: child,
      ),
    );
  }
}