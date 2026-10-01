class InsightModel {
  final List<double> balanceData;
  final List<String> dayLabels;
  final List<double> incomeData;
  final List<double> expenseData;
  final Map<String, double> expenseByCategory;
  final Map<String, double> incomeByCategory;
  final double openingBalance;
  final double prevIncome;
  final double prevExpense;
  final int expenseCount;
  final int visibleDays;

  InsightModel({
    required this.balanceData,
    required this.dayLabels,
    required this.incomeData,
    required this.expenseData,
    required this.expenseByCategory,
    required this.incomeByCategory,
    required this.openingBalance,
    required this.prevIncome,
    required this.prevExpense,
    required this.expenseCount,
    required this.visibleDays,
  });
}
