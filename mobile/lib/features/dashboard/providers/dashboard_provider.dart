import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../../data/models/transaction_model.dart';

class DashboardSummary {
  final num totalSpent;
  final num needsTotal;
  final num wantsTotal;
  final num simpananTotal;
  final num investasiTotal;
  final List<TransactionModel> recentTransactions;
  final String primaryInsight;

  const DashboardSummary({
    required this.totalSpent,
    required this.needsTotal,
    required this.wantsTotal,
    required this.simpananTotal,
    required this.investasiTotal,
    required this.recentTransactions,
    required this.primaryInsight,
  });

  double get needsPercentage => totalSpent == 0 ? 0 : (needsTotal / totalSpent) * 100;
  double get wantsPercentage => totalSpent == 0 ? 0 : (wantsTotal / totalSpent) * 100;
  double get simpananPercentage => totalSpent == 0 ? 0 : (simpananTotal / totalSpent) * 100;
  double get investasiPercentage => totalSpent == 0 ? 0 : (investasiTotal / totalSpent) * 100;
}

final dashboardSummaryProvider = Provider<DashboardSummary>((ref) {
  final transactionsAsync = ref.watch(transactionsProvider);

  return transactionsAsync.maybeWhen(
    data: (transactions) {
      num total = 0;
      num needs = 0;
      num wants = 0;
      num simpanan = 0;
      num investasi = 0;

      for (final t in transactions) {
        total += t.nominal;
        switch (t.kategori) {
          case 'Needs':
            needs += t.nominal;
            break;
          case 'Wants':
            wants += t.nominal;
            break;
          case 'Simpanan':
            simpanan += t.nominal;
            break;
          case 'Investasi':
            investasi += t.nominal;
            break;
        }
      }

      String insight = 'Belum ada transaksi tercatat.';
      if (total > 0) {
        final needsPct = (needs / total) * 100;
        final wantsPct = (wants / total) * 100;
        if (needsPct > 60) {
          insight = 'Pengeluaran kebutuhan (Needs) mendominasi ${needsPct.toStringAsFixed(0)}% dari total pengeluaran.';
        } else if (wantsPct > 40) {
          insight = 'Pengeluaran gaya hidup (Wants) cukup tinggi (${wantsPct.toStringAsFixed(0)}%). Pertimbangkan hemat.';
        } else if (simpanan + investasi > 0) {
          final savePct = ((simpanan + investasi) / total) * 100;
          insight = 'Alokasi tabungan & investasi sehat: ${savePct.toStringAsFixed(0)}% dari arus kas.';
        } else {
          insight = 'Arus pengeluaran terpantau teratur.';
        }
      }

      final recent = transactions.take(5).toList();

      return DashboardSummary(
        totalSpent: total,
        needsTotal: needs,
        wantsTotal: wants,
        simpananTotal: simpanan,
        investasiTotal: investasi,
        recentTransactions: recent,
        primaryInsight: insight,
      );
    },
    orElse: () => const DashboardSummary(
      totalSpent: 0,
      needsTotal: 0,
      wantsTotal: 0,
      simpananTotal: 0,
      investasiTotal: 0,
      recentTransactions: [],
      primaryInsight: 'Memuat data finansial...',
    ),
  );
});
