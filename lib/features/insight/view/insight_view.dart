import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constant.dart';
import '../../../core/widgets/custom_appbar.dart';
import '../../auth/provider/auth_provider.dart';
import '../provider/insight_provider.dart';
import 'widget/balance_tab.dart';
import 'widget/cash_flow_tab.dart';
import 'widget/spending_tab.dart';

class InsightView extends StatefulWidget {
  const InsightView({super.key});

  @override
  State<InsightView> createState() => _InsightViewState();
}

class _InsightViewState extends State<InsightView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Always start with current month
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        final now = DateTime.now();
        final currentMonth = DateTime(now.year, now.month, 1);
        context.read<InsightProvider>().changeMonth(currentMonth, user);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constant.bgNeutral,
      appBar: CustomAppBar.standard(
        title: 'Insight',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Constant.surfaceCard,
        foregroundColor: Constant.textPrimary,
      ),
      body: Consumer<InsightProvider>(
        builder: (context, provider, child) {
          final model = provider.insightModel;
          return Column(
            children: [
              // Month Selector
              _buildMonthSelector(provider),

              const SizedBox(height: 12),

              // Tab Bar
              _buildTabBar(),

              const SizedBox(height: 16),

              // Tab Content
              Expanded(
                child: provider.isLoading || model == null
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Constant.limeAccentDark,
                        ),
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          BalanceTab(
                            balanceData: model.balanceData,
                            dayLabels: model.dayLabels,
                          ),
                          CashFlowTab(
                            incomeData: model.incomeData,
                            expenseData: model.expenseData,
                            dayLabels: model.dayLabels,
                          ),
                          SpendingTab(
                            spendingByCategory: model.spendingByCategory,
                          ),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMonthSelector(InsightProvider provider) {
    final monthLabel = DateFormat(
      'MMMM yyyy',
      'id_ID',
    ).format(provider.selectedMonth);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Constant.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Constant.borderSubtle),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, size: 24),
              color: Constant.textSecondary,
              onPressed: () {
                final user = context.read<AuthProvider>().user;
                if (user != null) {
                  provider.changeMonth(
                    DateTime(
                      provider.selectedMonth.year,
                      provider.selectedMonth.month - 1,
                      1,
                    ),
                    user,
                  );
                }
              },
            ),
            Text(
              monthLabel,
              style: Constant.h6.copyWith(
                color: Constant.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, size: 24),
              color: Constant.textSecondary,
              onPressed: () {
                final user = context.read<AuthProvider>().user;
                if (user != null) {
                  provider.changeMonth(
                    DateTime(
                      provider.selectedMonth.year,
                      provider.selectedMonth.month + 1,
                      1,
                    ),
                    user,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Constant.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Constant.borderSubtle),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: Constant.limeAccentDark,
            borderRadius: BorderRadius.circular(12),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: Constant.textPrimary,
          unselectedLabelColor: Constant.textSecondary,
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(height: 40, text: 'Balance'),
            Tab(height: 40, text: 'Cash Flow'),
            Tab(height: 40, text: 'Spending'),
          ],
        ),
      ),
    );
  }
}
