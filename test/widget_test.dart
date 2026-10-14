import 'package:flutter_test/flutter_test.dart';
import 'package:hf_application_by_use_of_ai/app.dart';

void main() {
  testWidgets('House Finder app boots to login', (tester) async {
    await tester.pumpWidget(const HouseFinderApp());
    await tester.pumpAndSettle();
    expect(find.text('House Finder'), findsWidgets);
    expect(find.text('Sign in'), findsOneWidget);
  });
}
