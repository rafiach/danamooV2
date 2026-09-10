import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/constant.dart';
import '../../../core/utils/utils.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/custom_navigator.dart';
import '../../../data/models/transaction_model.dart';
import '../../../generated/assets.dart';

import '../../auth/provider/auth_provider.dart';

import '../../history/view/history_view.dart';
import '../../insight/view/insight_view.dart';
import '../../profile/view/profile_view.dart';
import '../../transaction/view/transaction_view.dart';
import '../model/home_model.dart';
import '../provider/home_provider.dart';
import 'widget/list_item_widget.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context.read<HomeProvider>().fetchData(user);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final homeData = homeProvider.homeModel;

    return Scaffold(
      bottomNavigationBar: SafeArea(child: _buildFloatingBottomBar()),
      backgroundColor: Constant.bgNeutral,
      body: homeProvider.isLoading
          ? Center(child: CircularProgressIndicator(color: Constant.limeAccent))
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "DANAMOO",
                              style: Constant.h4.copyWith(
                                fontSize: 24,
                                color: Constant.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Intip keuanganmu hari ini !",
                              style: Constant.bodyMedium.copyWith(
                                color: Constant.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        InkWell(
                          onTap: () {
                            CustomNavigator.push(context, const ProfileView());
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Constant.surfaceCard,
                              shape: BoxShape.circle,
                              border: Border.all(color: Constant.borderSubtle),
                              boxShadow: Constant.shadowSm,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.person,
                                color: Constant.limeAccent,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Hero Balance Card
                    _buildHeroBalance(homeData),
                    const SizedBox(height: 16),

                    // Cash Flow Cards
                    _buildCashFlow(homeData),
                    const SizedBox(height: 24),

                    // Today Transactions Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Transaksi Hari Ini",
                          style: Constant.textSemiBold.copyWith(
                            color: Constant.textPrimary,
                            fontSize: 16,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            CustomNavigator.push(context, const HistoryView());
                          },
                          child: Text(
                            'Lihat Semua',
                            style: Constant.textMedium.copyWith(
                              color: Constant.limeAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Today Transactions List
                    Expanded(
                      child: homeData?.todayTransactions.isEmpty ?? true
                          ? _buildEmptyTransactions()
                          : ListView.separated(
                              itemCount:
                                  homeData?.todayTransactions.length ?? 0,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final transaction =
                                    homeData!.todayTransactions[index];
                                final isIncome =
                                    transaction.type == TransactionType.income;
                                return ListTileTransaction(
                                  label:
                                      (transaction.note != null &&
                                          transaction.note!.isNotEmpty)
                                      ? transaction.note!
                                      : transaction.label,
                                  nominal:
                                      '${isIncome ? '+' : '-'} ${Utils.formatIDR(transaction.amount)}',
                                  date: Utils.formatDateTimeToTime(
                                    transaction.date,
                                  ),
                                  icon: transaction.icon.isNotEmpty
                                      ? transaction.icon
                                      : Assets.assetsIconsDollar,
                                  isIncome: isIncome,
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeroBalance(HomeModel? homeData) {
    return CustomCard.hero(
      borderRadius: 24,
      padding: const EdgeInsets.all(20),
      borderColor: Constant.limeAccent.withValues(alpha: 0.3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Sisa saldo mu",
                style: Constant.bodyMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                Utils.formatIDR(homeData?.balance ?? 0),
                style: Constant.h2.copyWith(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Constant.limeAccent, width: 2),
            ),
            child: Center(
              child: Icon(
                Icons.account_balance_wallet,
                color: Constant.limeAccent,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCashFlow(HomeModel? homeData) {
    return Row(
      children: [
        // Total Income
        Expanded(
          child: CustomCard.surface(
            borderRadius: 16,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Income",
                        style: Constant.bodySmall.copyWith(
                          color: Constant.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Utils.formatIDR(homeData?.totalIncome ?? 0),
                        style: Constant.textSemiBold.copyWith(
                          color: Constant.limeAccent,
                          fontSize: 18,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Constant.limeAccent.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_downward,
                    color: Constant.limeAccent,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Total Expenses
        Expanded(
          child: CustomCard.surface(
            borderRadius: 16,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Expense",
                        style: Constant.bodySmall.copyWith(
                          color: Constant.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Utils.formatIDR(homeData?.totalExpense ?? 0),
                        style: Constant.textSemiBold.copyWith(
                          color: Constant.expenseRed,
                          fontSize: 18,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Constant.expenseRed.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_upward,
                    color: Constant.expenseRed,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyTransactions() {
    return Center(
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
              color: Constant.limeAccent,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada transaksi hari ini',
            style: Constant.textSemiBold.copyWith(
              color: Constant.textPrimary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Mulai catat pengeluaran atau pemasukanmu',
            style: Constant.caption.copyWith(color: Constant.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingBottomBar() {
    return Container(
      height: 88,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Constant.surfaceDark,
        borderRadius: BorderRadius.circular(24),
        boxShadow: Constant.shadowLg,
      ),
      child: Stack(
        children: [
          // Background indicator for active item
          // _BottomNavIndicator(),
          // Nav Items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.history,
                label: "Riwayat",
                index: 0,
                onTap: () {
                  CustomNavigator.push(context, const HistoryView());
                },
              ),
              _buildNavItem(
                icon: Icons.add,
                label: "",
                index: 1,
                isFab: true,
                onTap: () {
                  CustomNavigator.push(context, const TransactionView());
                },
              ),
              _buildNavItem(
                icon: Icons.analytics_outlined,
                label: "Insight",
                index: 2,
                onTap: () {
                  CustomNavigator.push(context, const InsightView());
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required VoidCallback onTap,
    bool isFab = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: isFab ? 72 : 80,
        height: 88,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isFab)
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Constant.limeAccent, Constant.limeAccentDark],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Constant.limeAccent.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, size: 28, color: Colors.white),
              )
            else
              Icon(icon, color: Constant.textWhite, size: 24),
            if (!isFab) ...[
              const SizedBox(height: 4),
              Text(
                label,
                style: Constant.caption.copyWith(
                  color: Constant.textWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BottomNavIndicator extends StatelessWidget {
  const _BottomNavIndicator();

  @override
  Widget build(BuildContext context) {
    const margin = 16.0;
    // Show indicator under History (left item) by default
    final leftPosition = margin;

    return Positioned(
      left: leftPosition,
      bottom: 8,
      child: Container(
        width: 60,
        height: 4,
        decoration: BoxDecoration(
          color: Constant.limeAccent,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
