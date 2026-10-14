import 'package:flutter_test/flutter_test.dart';
import 'package:hf_application_by_use_of_ai/providers/auth_provider.dart';
import 'package:hf_application_by_use_of_ai/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('demo seeker, owner, and admin can log in', () async {
    final auth = AuthProvider();
    await auth.tryRestoreSession();

    expect(await auth.login('seeker@housefinder.com', 'seeker123'), isNull);
    expect(auth.currentUser?.role, UserRole.seeker);
    await auth.logout();

    expect(await auth.login('owner@housefinder.com', 'owner123'), isNull);
    expect(auth.currentUser?.role, UserRole.owner);
    await auth.logout();

    expect(await auth.login('admin@housefinder.com', 'admin123'), isNull);
    expect(auth.currentUser?.role, UserRole.admin);
  });

  test('change password works for current user', () async {
    final auth = AuthProvider();
    await auth.tryRestoreSession();
    await auth.login('owner@housefinder.com', 'owner123');

    final err = await auth.changePassword(
      currentPassword: 'owner123',
      newPassword: 'owner456',
      confirmPassword: 'owner456',
    );
    expect(err, isNull);
    await auth.logout();
    expect(await auth.login('owner@housefinder.com', 'owner123'), isNotNull);
    expect(await auth.login('owner@housefinder.com', 'owner456'), isNull);
  });
}
