import 'package:flutter/material.dart';

class NeoCard extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;

  const NeoCard({
    super.key,
    required this.child,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          color: Colors.black,
          width: 2.5, // Grosor del borde negro
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            blurRadius: 0, // Hace la sombra sólida
            offset: Offset(5, 5), // Dirección de la sombra (X, Y)
          ),
        ],
      ),
      child: child,
    );
  }
}