import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../dashboard/presentation/dashboard_screen.dart';

class RelationshipDateScreen extends StatefulWidget {
  const RelationshipDateScreen({super.key});

  @override
  State<RelationshipDateScreen> createState() => _RelationshipDateScreenState();
}

class _RelationshipDateScreenState extends State<RelationshipDateScreen> {
  static const _ink = Color(0xFF555555);
  static const _green = Color(0xFF70D39B);
  static const _sand = Color(0xFFE2C987);
  static const _paper = Color(0xFFFDFDFB);

  DateTime? _selectedDate;
  bool _isSaving = false;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(1950),
      lastDate: now,
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _continue() async {
    final selectedDate = _selectedDate;
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Elige una fecha para continuar.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'relationshipStartDate': Timestamp.fromDate(
            DateTime(selectedDate.year, selectedDate.month, selectedDate.day),
          ),
        }, SetOptions(merge: true));
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No pude guardar la fecha. Intenta otra vez.'),
        ),
      );
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final label = _selectedDate == null
        ? 'Select Date'
        : '${_selectedDate!.month.toString().padLeft(2, '0')}/'
              '${_selectedDate!.day.toString().padLeft(2, '0')}/'
              '${_selectedDate!.year}';

    return Scaffold(
      backgroundColor: _paper,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 34, 28, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text(
                'When did it start?',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: _ink,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Save the first day of your story together.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: _ink.withValues(alpha: .72),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 36),
              _DatePanel(label: label, onTap: _pickDate),
              const Spacer(flex: 2),
              _NeoButton(
                label: _isSaving ? 'Saving...' : 'Continue',
                onPressed: _isSaving ? null : _continue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DatePanel extends StatelessWidget {
  const _DatePanel({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 124,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _RelationshipDateScreenState._sand,
            border: Border.all(
              color: _RelationshipDateScreenState._ink,
              width: 2,
            ),
            boxShadow: const [
              BoxShadow(
                color: _RelationshipDateScreenState._ink,
                blurRadius: 0,
                offset: Offset(5, 5),
              ),
            ],
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: _RelationshipDateScreenState._ink,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _NeoButton extends StatelessWidget {
  const _NeoButton({required this.label, required this.onPressed});

  final String label;
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
            height: 52,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _RelationshipDateScreenState._green,
              border: Border.all(
                color: _RelationshipDateScreenState._ink,
                width: 2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: _RelationshipDateScreenState._ink,
                  blurRadius: 0,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
