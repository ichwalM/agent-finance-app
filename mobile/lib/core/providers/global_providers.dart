import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/api_service.dart';
import '../../data/services/storage_service.dart';
import '../../data/repositories/finance_repository.dart';

/// Local Storage Service Provider (Overridden in main.dart)
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError('localStorageServiceProvider must be initialized');
});

/// API Service Provider
final apiServiceProvider = Provider<ApiService>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  final baseUrl = storage.getBaseUrl();
  return ApiService(baseUrl: baseUrl);
});

/// Finance Repository Provider
final financeRepositoryProvider = Provider<IFinanceRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return FinanceRepository(apiService);
});

/// Theme Mode State Provider
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final storage = ref.watch(localStorageServiceProvider);
    return storage.getThemeMode();
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    await ref.read(localStorageServiceProvider).setThemeMode(mode);
  }

  void toggleTheme() {
    if (state == ThemeMode.dark) {
      setTheme(ThemeMode.light);
    } else {
      setTheme(ThemeMode.dark);
    }
  }
}
