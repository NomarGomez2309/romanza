import 'package:flutter_test/flutter_test.dart';
import 'package:romanza/main.dart';

void main() {
  testWidgets('renders the retro dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('Dashboard /'), findsOneWidget);
    expect(find.text('Days'), findsOneWidget);
    expect(find.text('List'), findsOneWidget);
    expect(find.text('Movies'), findsOneWidget);
    expect(find.text('Wedding'), findsOneWidget);
  });
}
