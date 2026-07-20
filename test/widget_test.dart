import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:booking_cinema/app/app.dart';
import 'package:booking_cinema/core/services/preferences_service.dart';

void main() {
  testWidgets('opens login placeholder', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          preferencesServiceProvider.overrideWithValue(
            PreferencesService(preferences),
          ),
        ],
        child: const MovieBookingApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Đăng nhập'), findsNWidgets(2));
    expect(find.text('Tạo tài khoản'), findsOneWidget);
    expect(find.text('Quên mật khẩu'), findsOneWidget);
  });
}
