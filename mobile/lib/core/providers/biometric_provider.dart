import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/biometric_service.dart';
import 'global_providers.dart';

/// Biometric Service Provider
final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

/// Biometric Hardware Availability Provider
final biometricAvailableProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(biometricServiceProvider);
  return await service.canAuthenticate();
});

/// Biometric Enabled State Provider (persisted in SharedPreferences)
final biometricEnabledProvider =
    NotifierProvider<BiometricEnabledNotifier, bool>(BiometricEnabledNotifier.new);

class BiometricEnabledNotifier extends Notifier<bool> {
  @override
  bool build() {
    final storage = ref.watch(localStorageServiceProvider);
    return storage.isBiometricEnabled();
  }

  Future<bool> toggleBiometric(bool enable) async {
    final service = ref.read(biometricServiceProvider);
    final storage = ref.read(localStorageServiceProvider);

    if (enable) {
      // Must authenticate successfully first before enabling
      final success = await service.authenticate(
        reason: 'Pindai sidik jari untuk mengaktifkan kunci biometrik',
      );
      if (!success) {
        return false;
      }
    }

    state = enable;
    await storage.setBiometricEnabled(enable);

    // If turned off, make sure app lock state is unlocked
    if (!enable) {
      ref.read(appLockProvider.notifier).unlock();
    }
    return true;
  }
}

/// App Lock State Provider (Tracks whether UI is locked and requires biometric scan)
final appLockProvider = NotifierProvider<AppLockNotifier, bool>(AppLockNotifier.new);

class AppLockNotifier extends Notifier<bool> {
  @override
  bool build() {
    final isEnabled = ref.watch(biometricEnabledProvider);
    // When enabled on app startup, lock immediately
    return isEnabled;
  }

  void lock() {
    final isEnabled = ref.read(biometricEnabledProvider);
    if (isEnabled) {
      state = true;
    }
  }

  void unlock() {
    state = false;
  }

  Future<bool> authenticateAndUnlock() async {
    final service = ref.read(biometricServiceProvider);
    final success = await service.authenticate(
      reason: 'Pindai sidik jari untuk membuka Walldev Finance',
    );
    if (success) {
      state = false;
      return true;
    }
    return false;
  }
}
