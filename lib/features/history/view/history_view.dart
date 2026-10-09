import 'package:danamoo/features/wallet/provider/wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constant.dart';
import '../../../core/utils/utils.dart';
import '../../../core/widgets/custom_appbar.dart';
import '../../../core/widgets/custom_navigator.dart';
import '../../../core/widgets/custom_textfield.dart';
import '../../../core/widgets/date_picker_sheet.dart';
import '../../../core/widgets/wallet_selector.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/wallet_model.dart';
import '../../auth/provider/auth_provider.dart';
import '../../home/view/widget/list_item_widget.dart';
import '../provider/history_provider.dart';
import 'detail_history_view.dart';

class HistoryView extends StatefulWidget {
  final String? initialType;
  final String? initialCategory;
  final DateTime? initialMonth;
  final String? initialWalledId;

  const HistoryView({
    super.key,
    this.initialType,
    this.initialCategory,
    this.initialMonth,
    this.initialWalledId,
  });

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialType != null || widget.initialWalledId != null) {
        context.read<HistoryProvider>().applyFilters(
          type: widget.initialType,
          category: widget.initialCategory,
          month: widget.initialMonth,
          walletId: widget.initialWalledId,
        );
        debugPrint("wallet berhasil: ${widget.initialWalledId}");
      }
      debugPrint("wallet gagal: ${widget.initialWalledId}");
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      await context.read<HistoryProvider>().fetchData(user.id);
    }
  }

  late HistoryProvider _historyProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _historyProvider = context.read<HistoryProvider>();
  }

  @override
  void dispose() {
    _historyProvider.resetFilters();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HistoryProvider>();
    final filteredTransactions = provider.filteredTransactions;
    final walletProvider = context.watch<WalletProvider>();
    final wallets = walletProvider.wallets;

    return Scaffold(
      backgroundColor: Constant.bgNeutral,
      appBar: CustomAppBar.standard(
        title: 'Riwayat',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => CustomNavigator.pop(context),
        ),
        backgroundColor: Constant.bgNeutral,
        foregroundColor: Constant.surfaceDark,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Column(
            children: [
              // Search & Date Filter Row
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: CustomTextField.search(
                        controller: _searchController,
                        onChanged: provider.setSearchQuery,
                        onClear: () => provider.setSearchQuery(''),
                        hint: 'Cari transaksi...',
                        borderFocusColor: Constant.surfaceDark,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _buildDateFilterButton(provider),
                  ],
                ),
              ),

              if (wallets.length > 1) ...[
                const SizedBox(height: 10),
                _buildWalletFilterChips(provider, wallets),
              ],

              const SizedBox(height: 10),

              // Type Filter Chips
              _buildTypeFilterChips(provider),

              // Category Filter (only when Expense selected)
              if (provider.selectedType != 'Semua') ...[
                const SizedBox(height: 10),
                _buildCategoryFilterChips(provider),
              ],

              if (provider.selectedMonth != null) ...[
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: provider.clearMonth,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Constant.limeAccent.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              DateFormat(
                                'MMMM yyyy',
                                'id_ID',
                              ).format(provider.selectedMonth!),
                              style: Constant.textSemiBold.copyWith(
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(LucideIcons.x500, size: 14),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Transaction List
              Expanded(
                child: provider.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Constant.limeAccent,
                        ),
                      )
                    : filteredTransactions.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        color: Constant.limeAccent,
                        backgroundColor: Constant.surfaceCard,
                        onRefresh: _loadData,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredTransactions.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final tx = filteredTransactions[index];
                            final t = tx.transaction;
                            final isTransfer =
                                t.type == TransactionType.transfer;
                            final isIncome = t.type == TransactionType.income;
                            final date = Utils.formatDateShort(t.date);

                            final label = (t.note?.isNotEmpty ?? false)
                                ? t.note!
                                : isTransfer
                                ? 'Transfer'
                                : (tx.category?.name ?? 'Unknown');

                            return InkWell(
                              onTap: () {
                                CustomNavigator.push(
                                  context,
                                  DetailHistoryView(data: tx),
                                ).then((result) {
                                  if (result == true) _loadData();
                                });
                              },
                              child: ListTileTransaction(
                                label: label,
                                nominal: Utils.formatIDR(t.amount),
                                date: isTransfer
                                    ? '$date • ${walletProvider.nameOf(t.walletId)} → ${walletProvider.nameOf(t.toWalletId)}'
                                    : '$date • ${walletProvider.nameOf(t.walletId)}',
                                icon: isTransfer
                                    ? const Icon(LucideIcons.arrowLeftRight)
                                    : (tx.category?.icon ??
                                          const Icon(LucideIcons.coins)),
                                bgIconColor: isTransfer
                                    ? Constant.greyLight
                                    : (tx.category?.bgColor ??
                                          Constant.greyLight),
                                nominalColor: isTransfer
                                    ? Constant.textSecondary
                                    : null,
                                isIncome: isIncome,
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateFilterButton(HistoryProvider provider) {
    return GestureDetector(
      onTap: () async {
        final picked = await DatePickerSheet.show(
          context: context,
          initialDate: provider.selectedDate ?? DateTime.now(),
          title: 'Filter Bulan',
        );
        if (picked != null) provider.setDate(picked);
      },
      child: AnimatedContainer(
        duration: Constant.durationShort,
        height: 48,
        constraints: const BoxConstraints(minWidth: 48),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Constant.surfaceDark,
          // color: provider.selectedDate != null
          //     ? Constant.limeAccent
          //     : Constant.surfaceDark,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.calendarDays500,
              color: Constant.limeAccent,
              // color: provider.selectedDate != null
              //     ? Constant.textPrimary
              //     : Constant.limeAccentDark,
              size: 24,
            ),
            if (provider.selectedDate != null) ...[
              const SizedBox(width: 8),
              Text(
                DateFormat('dd MMM', 'id_ID').format(provider.selectedDate!),
                style: Constant.textSemiBold.copyWith(
                  color: Constant.limeAccent,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: provider.clearDate,
                child: const Icon(
                  LucideIcons.x500,
                  size: 18,
                  color: Constant.limeAccent,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTypeFilterChips(HistoryProvider provider) {
    const types = ['Semua', 'Pemasukan', 'Pengeluaran'];
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: types.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final type = types[index];
          final isActive = provider.selectedType == type;
          return _FilterChip(
            label: type,
            isSelected: isActive,
            onTap: () => provider.setType(type),
          );
        },
      ),
    );
  }

  Widget _buildCategoryFilterChips(HistoryProvider provider) {
    final type = provider.selectedType == 'Pemasukan'
        ? TransactionType.income
        : TransactionType.expense;
    final expenseCategories = provider.categories
        .where((cat) => cat.type == type)
        .toList();

    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: expenseCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = expenseCategories[index];
          final isActive = provider.selectedCategory == cat.name;
          return _FilterChip(
            label: cat.name,
            icon: cat.icon,
            isSelected: isActive,
            onTap: () => provider.setCategory(isActive ? null : cat.name),
          );
        },
      ),
    );
  }

  Widget _buildWalletFilterChips(
    HistoryProvider provider,
    List<WalletModel> wallets,
  ) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: wallets.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _FilterChip(
              label: 'Semua Dompet',
              isSelected: provider.selectedWalletId == null,
              onTap: () => provider.setWallet(null),
            );
          }
          final w = wallets[index - 1];
          final isActive = provider.selectedWalletId == w.id;
          return _FilterChip(
            label: w.name,
            icon: Icon(WalletIcons.of(w.iconKey)),
            isSelected: isActive,
            onTap: () => provider.setWallet(isActive ? null : w.id),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Constant.limeAccent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                color: Constant.limeAccentDark,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada transaksi',
              style: Constant.textSemiBold.copyWith(
                color: Constant.textPrimary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Coba ubah filter atau cari dengan kata kunci lain',
              style: Constant.caption.copyWith(color: Constant.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final Icon? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Constant.durationShort,
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Constant.surfaceDark : Constant.surfaceCard,
          border: Border.all(
            color: isSelected ? Constant.surfaceDark : Constant.borderSubtle,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: Constant.shadowSm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              IconTheme(
                data: IconThemeData(
                  color: isSelected
                      ? Constant.limeAccent
                      : Constant.textPrimary,
                  size: 20,
                ),
                child: icon!,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Constant.limeAccent : Constant.textPrimary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
