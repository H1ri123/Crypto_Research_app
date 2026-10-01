import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto_research_app/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('New user: Splash transitions to OnboardingScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const CryptoResearchApp());
    expect(find.text('CRYPTO RESEARCH'), findsOneWidget);

    // Advance past the splash screen timer and animation
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pump(const Duration(milliseconds: 500));

    // Verify Onboarding Screen is shown for unauthenticated users
    expect(find.textContaining('The Card That'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
  });

  testWidgets('Logged in user: Splash transitions directly to Market screen',
      (WidgetTester tester) async {
    // Set logged in
    SharedPreferences.setMockInitialValues({'is_logged_in': true});

    await tester.pumpWidget(const CryptoResearchApp());
    expect(find.text('CRYPTO RESEARCH'), findsOneWidget);

    // Advance past the splash screen timer and animation
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pump(const Duration(milliseconds: 500));

    // Verify Market screen is loaded directly, skipping onboarding & auth
    expect(find.text('Crypto Research'), findsWidgets);
    expect(find.text('Track the crypto market'), findsOneWidget);
  });
}
