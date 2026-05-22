import 'package:flutter_test/flutter_test.dart';
import 'package:romanza/main.dart';

void main() {
  testWidgets('renders the login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}
