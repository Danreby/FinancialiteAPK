import '../../domain/entities/dashboard.dart';

class DashboardDataModel extends DashboardData {
  const DashboardDataModel({
    super.totalBalance,
    super.totalIncome,
    super.totalExpense,
    super.pendingBillAmount,
    super.monthDebitTotal,
    super.monthlyBudget,
    super.budgetSpent,
    super.budgetPercentage,
    super.savingsTotal,
    super.pendingBills,
    super.healthScore,
    super.monthlyChart,
    super.topCategories,
    super.upcomingBills,
  });

  factory DashboardDataModel.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] as Map<String, dynamic>? ?? {};
    final insights = json['insights'] as Map<String, dynamic>? ?? {};
    final financialHealth =
        insights['financial_health'] as Map<String, dynamic>? ?? {};
    final upcomingBillsList = insights['upcoming_bills'] as List? ?? [];
    final monthlySummary = stats['monthly_summary'] as List? ?? [];
    final topCategoriesList = stats['top_spending_categories'] as List? ?? [];

    final pendingBillCount = upcomingBillsList.where((b) {
      final m = b as Map<String, dynamic>;
      return m['is_overdue'] == true || m['status'] == 'overdue';
    }).length;

    final pendingBill = (stats['current_month_pending_bill'] as num? ?? 0).toDouble();
    final debitTotal = (stats['current_month_debit_total'] as num? ?? 0).toDouble();

    return DashboardDataModel(
      totalBalance: (stats['remaining_money'] as num? ?? 0).toDouble(),
      totalIncome: (stats['total_monthly_income'] as num? ?? 0).toDouble(),
      totalExpense: (pendingBill + debitTotal),
      pendingBillAmount: pendingBill,
      monthDebitTotal: debitTotal,
      monthlyBudget: 0,
      budgetSpent: 0,
      budgetPercentage: 0,
      savingsTotal: 0,
      pendingBills: pendingBillCount,
      healthScore: (financialHealth['score'] as num? ?? 0).toDouble(),
      monthlyChart: monthlySummary.map((item) {
        final m = item as Map<String, dynamic>;
        return MonthlyChartDataModel(
          month: m['month_key'] as String? ?? '',
          income: (m['credit_total'] as num? ?? 0).toDouble(),
          expense: (m['debit_total'] as num? ?? 0).toDouble(),
        );
      }).toList(),
      topCategories: topCategoriesList.map((item) {
        final m = item as Map<String, dynamic>;
        return CategorySpendingModel(
          name: m['category_name'] as String? ?? 'Sem categoria',
          icon: m['category_icon'] as String?,
          color: m['category_color'] as String?,
          amount: (m['total'] as num? ?? 0).toDouble(),
          percentage: 0,
        );
      }).toList(),
      upcomingBills: upcomingBillsList.map((item) {
        final m = item as Map<String, dynamic>;
        return UpcomingBillModel(
          id: (m['id'] as num).toInt(),
          title: m['title'] as String,
          amount: (m['amount'] as num? ?? 0).toDouble(),
          dueDay: m['due_day'] as int? ?? 0,
          categoryName: null,
        );
      }).toList(),
    );
  }
}

class MonthlyChartDataModel extends MonthlyChartData {
  const MonthlyChartDataModel(
      {required super.month, required super.income, required super.expense});

  factory MonthlyChartDataModel.fromJson(Map<String, dynamic> json) {
    return MonthlyChartDataModel(
      month: json['month'] as String,
      income: (json['income'] as num? ?? 0).toDouble(),
      expense: (json['expense'] as num? ?? 0).toDouble(),
    );
  }
}

class CategorySpendingModel extends CategorySpending {
  const CategorySpendingModel(
      {required super.name,
      super.icon,
      super.color,
      required super.amount,
      required super.percentage});

  factory CategorySpendingModel.fromJson(Map<String, dynamic> json) {
    return CategorySpendingModel(
      name: json['name'] as String,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      amount: (json['amount'] as num? ?? 0).toDouble(),
      percentage: (json['percentage'] as num? ?? 0).toDouble(),
    );
  }
}

class UpcomingBillModel extends UpcomingBill {
  const UpcomingBillModel(
      {required super.id,
      required super.title,
      required super.amount,
      required super.dueDay,
      super.categoryName});

  factory UpcomingBillModel.fromJson(Map<String, dynamic> json) {
    return UpcomingBillModel(
      id: json['id'] as int,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      dueDay: json['due_day'] as int,
      categoryName: json['category_name'] as String?,
    );
  }
}
