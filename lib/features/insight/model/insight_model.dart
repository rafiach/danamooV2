class InsightModel {
  final List<double> balanceData;
  final List<String> dayLabels;
  final List<double> incomeData;
  final List<double> expenseData;
  final Map<String, double> spendingByCategory;

  InsightModel({
    required this.balanceData,
    required this.dayLabels,
    required this.incomeData,
    required this.expenseData,
    required this.spendingByCategory,
  });
}
