import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/global_providers.dart';
import '../../../data/models/transaction_model.dart';

/// Transactions Async Notifier Provider
final transactionsProvider =
    AsyncNotifierProvider<TransactionsNotifier, List<TransactionModel>>(TransactionsNotifier.new);

class TransactionsNotifier extends AsyncNotifier<List<TransactionModel>> {
  @override
  Future<List<TransactionModel>> build() async {
    final repo = ref.watch(financeRepositoryProvider);
    final list = await repo.getTransactions();
    list.sort((a, b) => b.tanggal.compareTo(a.tanggal));
    return list;
  }

  Future<void> fetchTransactions() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(financeRepositoryProvider);
      final list = await repo.getTransactions();
      list.sort((a, b) => b.tanggal.compareTo(a.tanggal));
      return list;
    });
  }

  Future<void> addTransaction(TransactionModel item) async {
    final repo = ref.read(financeRepositoryProvider);
    await repo.addTransaction(item);
    await fetchTransactions();
  }

  Future<void> updateTransaction(int row, TransactionModel item) async {
    final repo = ref.read(financeRepositoryProvider);
    await repo.updateTransaction(row, item);
    await fetchTransactions();
  }

  Future<void> deleteTransaction(int row) async {
    final repo = ref.read(financeRepositoryProvider);
    await repo.deleteTransaction(row);
    await fetchTransactions();
  }
}

/// Category Filter Provider ('Semua', 'Needs', 'Wants', 'Simpanan', 'Investasi')
class CategoryFilterNotifier extends Notifier<String> {
  @override
  String build() => 'Semua';

  void setFilter(String category) => state = category;
}

final categoryFilterProvider =
    NotifierProvider<CategoryFilterNotifier, String>(CategoryFilterNotifier.new);

/// Search Query Provider
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
}

final searchQueryProvider =
    NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

/// Computed filtered transactions list
final filteredTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  final transactionsAsync = ref.watch(transactionsProvider);
  final filter = ref.watch(categoryFilterProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();

  return transactionsAsync.maybeWhen(
    data: (transactions) {
      return transactions.where((item) {
        final matchesCategory = filter == 'Semua' || item.kategori == filter;
        final matchesQuery = query.isEmpty ||
            item.deskripsi.toLowerCase().contains(query) ||
            item.subKategori.toLowerCase().contains(query) ||
            item.nominal.toString().contains(query);
        return matchesCategory && matchesQuery;
      }).toList();
    },
    orElse: () => [],
  );
});
