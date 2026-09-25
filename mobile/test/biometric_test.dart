import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finance_mobile/core/providers/global_providers.dart';
import 'package:finance_mobile/data/services/storage_service.dart';
import 'package:finance_mobile/features/auth/screens/biometric_lock_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalStorageService Biometric Preferences Tests', () {
    test('defaults to false and persists changes', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);

      expect(storage.isBiometricEnabled(), isFalse);

      await storage.setBiometricEnabled(true);
      expect(storage.isBiometricEnabled(), isTrue);

      await storage.setBiometricEnabled(false);
      expect(storage.isBiometricEnabled(), isFalse);
    });
  });

  group('BiometricLockScreen Widget Tests', () {
    testWidgets('renders BiometricLockScreen with unlock button properly', (tester) async {
      SharedPreferences.setMockInitialValues({'pref_biometric_enabled': true});
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageServiceProvider.overrideWithValue(storage),
          ],
          child: const MaterialApp(
            home: BiometricLockScreen(),
          ),
        ),
      );

      // Verify header and UI elements
      expect(find.text('Aplikasi Terkunci'), findsOneWidget);
      expect(find.text('KEAMANAN FINANSIAL'), findsOneWidget);
      expect(find.text('Buka dengan Sidik Jari'), findsOneWidget);
      expect(find.byIcon(Icons.fingerprint_rounded), findsWidgets);
    });
  });
}
