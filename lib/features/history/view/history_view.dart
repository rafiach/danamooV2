import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constant.dart';
import '../../../core/utils/utils.dart';
import '../../../core/widgets/custom_appbar.dart';
import '../../../core/widgets/custom_navigator.dart';
import '../../../core/widgets/custom_textfield.dart';
import '../../../data/models/transaction_model.dart';
import '../../../generated/assets.dart';
import '../../auth/provider/auth_provider.dart';
import '../../home/view/widget/list_item_widget.dart';
import '../provider/history_provider.dart';
import 'detail_history_view.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HistoryProvider>();
    final filteredTransactions = provider.filteredTransactions;

    return Scaffold(
      backgroundColor: Constant.violetDarker,
      appBar: CustomAppBar.standard(
        title: 'History',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => CustomNavigator.pop(context),
        ),
        backgroundColor: Constant.violetDarker,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: CustomTextField.search(
                      controller: _searchController,
                      onChanged: provider.setSearchQuery,
                      onClear: () => provider.setSearchQuery(''),
                      hint: 'Search',
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () async {
                      final picked = await Utils.pickDate(
                        context,
                        initialDate: provider.selectedDate ?? DateTime.now(),
                      );
                      if (picked != null) provider.setDate(picked);
                    },
                    child: Container(
                      height: 52,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: provider.selectedDate != null
                            ? Constant.expensePrime
                            : Constant.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_month_rounded,
                            color: Constant.violetDarker,
                            size: 24,
                          ),
                          if (provider.selectedDate != null) ...[
                            const SizedBox(width: 6),
                            Text(
                              DateFormat(
                                'MMM yyyy',
                              ).format(provider.selectedDate!),
                              style: TextStyle(
                                color: Constant.violetDarker,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: provider.clearDate,
                              child: Icon(
                                Icons.close_rounded,
                                size: 15,
                                color: Constant.violetDarker,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Row(
                children: ['All', 'Income', 'Expense'].map((type) {
                  final isActive = provider.selectedType == type;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => provider.setType(type),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? Constant.expensePrime
                              : Constant.violet50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          type,
                          style: TextStyle(
                            color: isActive
                                ? Constant.violetDarker
                                : Constant.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (provider.selectedType == 'Expense') ...[
                const SizedBox(height: 5),
                Divider(color: Constant.violet50, thickness: 1.0),
                const SizedBox(height: 5),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: provider.isLoading
                        ? [
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ]
                        : provider.categories
                              .where(
                                (cat) => cat.type == TransactionType.expense,
                              )
                              .map((cat) {
                                final isActive =
                                    provider.selectedCategory == cat.name;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: GestureDetector(
                                    onTap: () => provider.setCategory(
                                      isActive
                                          ? null
                                          : cat.name, // toggle off jika tap ulang
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isActive
                                            ? Constant.expensePrime
                                            : Constant.violet50,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        cat.name,
                                        style: TextStyle(
                                          color: isActive
                                              ? Constant.violetDarker
                                              : Constant.textPrimary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              })
                              .toList(),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Expanded(
                child: provider.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : filteredTransactions.isEmpty
                    ? Utils.emptyState(
                        Assets.assetsIconsCowMascotEmpty,
                        "Tidak ada transaksi yang ditemukan",
                        "Coba cari dengan filter lain",
                        textColor: Constant.violet50,
                      )
                    : RefreshIndicator(
                        color: Constant.violetDarker,
                        backgroundColor: Colors.white,
                        onRefresh: () => _loadData(),
                        child: ListView.separated(
                          itemCount: filteredTransactions.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final tx = filteredTransactions[index];
                            final label =
                                (tx.transaction.note != null &&
                                    tx.transaction.note!.isNotEmpty)
                                ? tx.transaction.note!
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
                              child: ListItemWidget(
                                label: label,
                                nominal: Utils.formatIDR(tx.transaction.amount),
                                date: Utils.formatDateShort(
                                  tx.transaction.date,
                                ),
                                icon:
                                    tx.category?.icon ??
                                    Assets.assetsIconsDollar,
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
}
