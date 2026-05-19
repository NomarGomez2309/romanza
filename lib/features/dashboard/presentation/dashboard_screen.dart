import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:romanza/features/couple/presentation/couple_screen.dart';
import 'package:romanza/features/music/presentation/music_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  static const _ink = Color(0xFF5B5B5B);
  static const _mint = Color(0xFFDDF3EA);
  static const _sand = Color(0xFFE2C987);
  static const _orange = Color(0xFFFF9C39);
  static const _green = Color(0xFF75D48F);
  static const _pink = Color(0xFFF3A1B8);
  static const _paper = Color(0xFFE6E0D5);
  static const _blue = Color(0xFF667396);
  static const _red = Color(0xFFDB5255);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final Future<DateTime?> _relationshipStartDate;

  @override
  void initState() {
    super.initState();
    _relationshipStartDate = _loadRelationshipStartDate();
  }

  Future<DateTime?> _loadRelationshipStartDate() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final value = snapshot.data()?['relationshipStartDate'];

    if (value is Timestamp) {
      return value.toDate();
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme.apply(
      bodyColor: DashboardScreen._ink,
      displayColor: DashboardScreen._ink,
    );

    return Theme(
      data: Theme.of(context).copyWith(textTheme: textTheme),
      child: Scaffold(
        backgroundColor: DashboardScreen._mint,
        body: SafeArea(
          child: _StripedBackground(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final horizontalPadding = constraints.maxWidth < 390
                    ? 20.0
                    : 30.0;

                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    4,
                    horizontalPadding,
                    32,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 36,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _RetroTopBar(),
                        const SizedBox(height: 18),
                        FutureBuilder<DateTime?>(
                          future: _relationshipStartDate,
                          builder: (context, snapshot) {
                            final startDate = snapshot.data;

                            return _TimeTogetherPanel(
                              duration: startDate == null
                                  ? null
                                  : RelationshipDuration.between(
                                      startDate,
                                      DateTime.now(),
                                    ),
                              isLoading:
                                  snapshot.connectionState ==
                                  ConnectionState.waiting,
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        const _DashboardGrid(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class RelationshipDuration {
  const RelationshipDuration({
    required this.years,
    required this.months,
    required this.days,
  });

  final int years;
  final int months;
  final int days;

  factory RelationshipDuration.between(DateTime startDate, DateTime endDate) {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);

    if (start.isAfter(end)) {
      return const RelationshipDuration(years: 0, months: 0, days: 0);
    }

    var years = end.year - start.year;
    var yearAnchor = _copyWithYear(start, start.year + years);
    if (yearAnchor.isAfter(end)) {
      years--;
      yearAnchor = _copyWithYear(start, start.year + years);
    }

    var months =
        (end.year - yearAnchor.year) * 12 + end.month - yearAnchor.month;
    var monthAnchor = _addMonths(yearAnchor, months);
    if (monthAnchor.isAfter(end)) {
      months--;
      monthAnchor = _addMonths(yearAnchor, months);
    }

    final days = end.difference(monthAnchor).inDays;

    return RelationshipDuration(years: years, months: months, days: days);
  }

  static DateTime _copyWithYear(DateTime date, int year) {
    final day = date.day.clamp(1, _daysInMonth(year, date.month));
    return DateTime(year, date.month, day);
  }

  static DateTime _addMonths(DateTime date, int months) {
    final totalMonths = date.month - 1 + months;
    final year = date.year + totalMonths ~/ 12;
    final month = totalMonths % 12 + 1;
    final day = date.day.clamp(1, _daysInMonth(year, month));

    return DateTime(year, month, day);
  }

  static int _daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }
}

void _openMusic(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const MusicScreen()));
}

void _openCoupleCode(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const CoupleScreen()));
}

class RetroSurface extends StatelessWidget {
  const RetroSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(30, 18, 30, 32),
    this.backgroundColor = DashboardScreen._mint,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: DashboardScreen._ink,
          displayColor: DashboardScreen._ink,
        ),
      ),
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: _StripedBackground(
            child: SingleChildScrollView(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}

class RetroPanel extends StatelessWidget {
  const RetroPanel({
    super.key,
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
    return _NeoPanel(
      color: color,
      height: height,
      padding: padding,
      child: child,
    );
  }
}

class RetroButton extends StatelessWidget {
  const RetroButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = DashboardScreen._orange,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        child: _NeoPanel(
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
    );
  }
}

class _StripedBackground extends StatelessWidget {
  const _StripedBackground({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: DashboardScreen._mint, child: child);
  }
}

class _RetroTopBar extends StatelessWidget {
  const _RetroTopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Dashboard /',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 23,
              letterSpacing: 0,
            ),
          ),
        ),
        const _WindowButton(),
        const SizedBox(width: 14),
        const _WindowButton(),
      ],
    );
  }
}

class _WindowButton extends StatelessWidget {
  const _WindowButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFFD7D7D7),
        border: Border.all(color: DashboardScreen._ink, width: 2),
      ),
    );
  }
}

class _TimeTogetherPanel extends StatelessWidget {
  const _TimeTogetherPanel({required this.duration, required this.isLoading});

  final RelationshipDuration? duration;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final duration = this.duration;

    return _NeoPanel(
      color: DashboardScreen._sand,
      height: 148,
      padding: const EdgeInsets.all(6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              height: double.infinity,
              decoration: BoxDecoration(
                color: DashboardScreen._sand,
                border: Border.all(color: DashboardScreen._ink, width: 2),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: DashboardScreen._sand,
                border: Border.all(color: DashboardScreen._ink, width: 2),
              ),
              child: isLoading
                  ? Text(
                      'Loading...',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    )
                  : duration == null
                  ? Text(
                      'Set your\nDate',
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        height: .95,
                        fontWeight: FontWeight.w800,
                      ),
                    )
                  : FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _DurationLine(
                            value: duration.years,
                            label: duration.years == 1 ? 'Year' : 'Years',
                          ),
                          _DurationLine(
                            value: duration.months,
                            label: duration.months == 1 ? 'Month' : 'Months',
                          ),
                          _DurationLine(
                            value: duration.days,
                            label: duration.days == 1 ? 'Day' : 'Days',
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DurationLine extends StatelessWidget {
  const _DurationLine({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '$value',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            fontSize: 34,
            height: .88,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: 5),
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              height: 1,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _DashboardGrid extends StatelessWidget {
  const _DashboardGrid();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Expanded(
          child: Column(
            children: [
              _ConnectCard(),
              SizedBox(height: 24),
              _MusicCard(),
              SizedBox(height: 24),
              _BirthdayCard(),
            ],
          ),
        ),
        SizedBox(width: 36),
        Expanded(
          child: Column(
            children: [
              _ListCard(),
              SizedBox(height: 24),
              _WeddingCard(),
              SizedBox(height: 24),
              _MoviesCard(),
            ],
          ),
        ),
      ],
    );
  }
}

class _ConnectCard extends StatelessWidget {
  const _ConnectCard();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openCoupleCode(context),
        child: _NeoPanel(
          color: DashboardScreen._orange,
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Connect to your\nPartner',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 14,
                height: .9,
                color: const Color(0xFF275980),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MusicCard extends StatelessWidget {
  const _MusicCard();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openMusic(context),
        child: _NeoPanel(
          color: DashboardScreen._green,
          height: 190,
          padding: const EdgeInsets.all(9),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(color: DashboardScreen._ink, width: 2),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/Album.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 7),
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: DashboardScreen._green,
                      border: Border.all(color: DashboardScreen._ink, width: 2),
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: DashboardScreen._ink,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'On Repeat\nPlaylist',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                height: .9,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Novio + Novia - Spotify',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontSize: 7, height: 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RetroHeader extends StatelessWidget {
  const RetroHeader({super.key, required this.title, this.onBack});

  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (onBack != null) ...[
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFD7D7D7),
                border: Border.all(color: DashboardScreen._ink, width: 2),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: DashboardScreen._ink,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 23,
              letterSpacing: 0,
            ),
          ),
        ),
        const _WindowButton(),
      ],
    );
  }
}

class RetroCodeBox extends StatelessWidget {
  const RetroCodeBox({super.key, required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: DashboardScreen._sand,
        border: Border.all(color: DashboardScreen._ink, width: 2),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          value,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            fontSize: 42,
            height: .9,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

class RetroTextField extends StatelessWidget {
  const RetroTextField({
    super.key,
    required this.controller,
    required this.hintText,
  });

  final TextEditingController controller;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textCapitalization: TextCapitalization.characters,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: DashboardScreen._ink,
        fontWeight: FontWeight.w800,
        letterSpacing: 1,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: const BorderSide(color: DashboardScreen._ink, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: const BorderSide(color: DashboardScreen._ink, width: 2.5),
        ),
      ),
    );
  }
}

class RetroPalette {
  static const ink = DashboardScreen._ink;
  static const mint = DashboardScreen._mint;
  static const sand = DashboardScreen._sand;
  static const orange = DashboardScreen._orange;
  static const green = DashboardScreen._green;
  static const pink = DashboardScreen._pink;
  static const paper = DashboardScreen._paper;
  static const blue = DashboardScreen._blue;
  static const red = DashboardScreen._red;
}

class _BirthdayCard extends StatelessWidget {
  const _BirthdayCard();

  @override
  Widget build(BuildContext context) {
    return _NeoPanel(
      color: DashboardScreen._red,
      height: 144,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            height: 34,
            alignment: Alignment.center,
            color: DashboardScreen._paper,
            child: Text(
              "Angie's BD",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const Divider(height: 2, thickness: 2, color: DashboardScreen._ink),
          Expanded(
            child: Center(
              child: FittedBox(
                child: Column(
                  children: [
                    Text(
                      'October',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        height: .9,
                      ),
                    ),
                    Text(
                      '27',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 62,
                        height: .8,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListCard extends StatelessWidget {
  const _ListCard();

  @override
  Widget build(BuildContext context) {
    return _NeoPanel(
      color: DashboardScreen._pink,
      height: 144,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
            child: Text(
              'List',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          const Divider(height: 2, thickness: 2, color: DashboardScreen._ink),
          const Padding(
            padding: EdgeInsets.fromLTRB(8, 7, 8, 0),
            child: Column(
              children: [
                _CheckRow(label: 'Make Dinner', checked: true),
                _CheckRow(label: 'Read Bible'),
                _CheckRow(label: 'Kissing'),
                _CheckRow(label: 'Studying'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeddingCard extends StatelessWidget {
  const _WeddingCard();

  @override
  Widget build(BuildContext context) {
    return _NeoPanel(
      color: DashboardScreen._paper,
      height: 190,
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFD7D7D7),
                border: Border.all(color: DashboardScreen._ink, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Our',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              height: .75,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            'Wedding',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              height: .85,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            '09/23/2030',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontSize: 10, height: 1),
          ),
        ],
      ),
    );
  }
}

class _MoviesCard extends StatelessWidget {
  const _MoviesCard();

  @override
  Widget build(BuildContext context) {
    return _NeoPanel(
      color: DashboardScreen._blue,
      height: 144,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
            child: Text(
              'Movies',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const Divider(height: 2, thickness: 2, color: DashboardScreen._ink),
          const Padding(
            padding: EdgeInsets.fromLTRB(8, 9, 8, 0),
            child: Column(
              children: [
                _CheckRow(label: 'La La Land', light: true),
                _CheckRow(label: 'The Mask', light: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({
    required this.label,
    this.checked = false,
    this.light = false,
  });

  final String label;
  final bool checked;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final textColor = light ? Colors.white : DashboardScreen._ink;

    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Container(
            width: 17,
            height: 17,
            color: checked ? DashboardScreen._ink : const Color(0xFFE8E0D8),
            child: checked
                ? const Icon(Icons.check, size: 13, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: textColor, height: 1),
            ),
          ),
        ],
      ),
    );
  }
}

class _NeoPanel extends StatelessWidget {
  const _NeoPanel({
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
        border: Border.all(color: DashboardScreen._ink, width: 2),
        boxShadow: const [
          BoxShadow(
            color: DashboardScreen._ink,
            blurRadius: 0,
            offset: Offset(4, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
