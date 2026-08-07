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
import 'widget/bubble_decoration_widget.dart';
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
      backgroundColor: Constant.violet50,
      body: homeProvider.isLoading
          ? Center(child: CircularProgressIndicator(color: Constant.white))
          : Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: MediaQuery.of(context).size.height * 0.28,
                  child: ClipRect(
                    child: Container(
                      color: const Color(0xFF3D1E6B),
                      child: CustomPaint(painter: BubbleDecorationWidget()),
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 32),
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
                                  style: Constant.bodyLarge.copyWith(
                                    fontSize: 24,
                                    color: Constant.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Intip keuanganmoo hari ini !",
                                  style: Constant.bodyLarge.copyWith(
                                    color: Constant.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            InkWell(
                              onTap: () {
                                CustomNavigator.push(
                                  context,
                                  const ProfileView(),
                                );
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Constant.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.person,
                                    color: Constant.greenPrime,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 36),
                        // Current Balance Card
                        _buildCurrentBalance(homeData),
                        const SizedBox(height: 16),

                        // ── Section Bawah (full-width, no padding issue) ──
                        _buildCashFlow(homeData),
                        const SizedBox(height: 24),

                        // today transactions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Transaksi Hari Ini",
                              style: Constant.textMedium.copyWith(
                                color: Constant.violetDarker,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView.separated(
                            itemCount: homeData?.todayTransactions.length ?? 0,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final transaction =
                                  homeData!.todayTransactions[index];
                              final isIncome =
                                  transaction.type == TransactionType.income;
                              return ListItemWidget(
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
                                color: transaction.color,
                                nominalColor: isIncome
                                    ? Constant.greenPrime
                                    : Constant.error,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCurrentBalance(HomeModel? homeData) {
    return CustomCard.elevated(
      borderRadius: 20,
      elevation: 16,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Sisa saldo mu",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Constant.violetDarker,
                ),
              ),
              Text(
                Utils.formatIDR(homeData?.balance ?? 0),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Constant.violetDarker,
                ),
              ),
            ],
          ),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Constant.foodsPrime,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(3, 5),
                ),
              ],
            ),
            child: Center(
              child: Image.asset(
                Assets.assetsIconsCowMascotPeeking,
                fit: BoxFit.contain,
                scale: 3,
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
          child: CustomCard.elevated(
            color: Constant.incomePrime,
            borderColor: Constant.incomePrime,
            borderRadius: 16,
            elevation: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Income",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Constant.violet50,
                        ),
                      ),
                      Text(
                        Utils.formatIDR(homeData?.totalIncome ?? 0),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Constant.violet50,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: Constant.violet50, size: 40),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Total Expenses
        Expanded(
          child: CustomCard.elevated(
            color: Constant.expensePrime,
            borderColor: Constant.expensePrime,
            borderRadius: 16,
            elevation: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Expense",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Constant.violet50,
                        ),
                      ),
                      Text(
                        Utils.formatIDR(homeData?.totalExpense ?? 0),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Constant.violet50,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_drop_up, color: Constant.violet50, size: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingBottomBar() {
    return SizedBox(
      height: 120,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // Background Bar
          Container(
            height: 75,
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Constant.violetDark,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildItem(
                  icon: Assets.assetsIconsClipboard,
                  label: "Riwayat",
                  onTap: () {
                    CustomNavigator.push(context, const HistoryView());
                  },
                ),
                const SizedBox(width: 60),
                _buildItem(
                  icon: Assets.assetsIconsBarChart,
                  label: "Insight",
                  onTap: () {
                    CustomNavigator.push(context, const InsightView());
                  },
                ),
              ],
            ),
          ),

          Positioned(
            top: -12,
            child: GestureDetector(
              onTap: () {
                CustomNavigator.push(context, const TransactionView());
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Constant.violet50,
                      // shape: BoxShape.circle,
                      borderRadius: BorderRadius.circular(45),
                    ),
                  ),
                  // Tombol utama
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Constant.expensePrime,
                          Color.lerp(
                            Constant.expensePrime,
                            Colors.black,
                            0.15,
                          )!,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add, size: 40, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Image.asset(icon, width: 35, height: 35),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Constant.violet50,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
