import '../../core/utils/json_helpers.dart';
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
      final status = (m['status'] ?? '').toString();
      return status != 'paid';
    }).length;

    final pendingBill = stats.toDouble('current_month_pending_bill');
    final debitTotal = stats.toDouble('current_month_debit_total');

    return DashboardDataModel(
      totalBalance: stats.toDouble('remaining_money'),
      totalIncome: stats.toDouble('total_monthly_income'),
      totalExpense: (pendingBill + debitTotal),
      pendingBillAmount: pendingBill,
      monthDebitTotal: debitTotal,
      monthlyBudget: 0,
      budgetSpent: 0,
      budgetPercentage: 0,
      savingsTotal: 0,
      pendingBills: pendingBillCount,
      healthScore: financialHealth.toDouble('score'),
      monthlyChart: monthlySummary.map((item) {
        final m = item as Map<String, dynamic>;
        return MonthlyChartDataModel(
          month: m['month_key'] as String? ?? '',
          income: m.toDouble('credit_total'),
          expense: m.toDouble('debit_total'),
        );
      }).toList(),
      topCategories: topCategoriesList.map((item) {
        final m = item as Map<String, dynamic>;
        return CategorySpendingModel(
          name: m['category_name'] as String? ?? 'Sem categoria',
          icon: m['category_icon'] as String?,
          color: m['category_color'] as String?,
          amount: m.toDouble('total'),
          percentage: 0,
        );
      }).toList(),
      upcomingBills: upcomingBillsList.map((item) {
        final m = item as Map<String, dynamic>;
        return UpcomingBillModel(
          id: m.toInt('id'),
          title: m['title'] as String,
          amount: m.toDouble('amount'),
          dueDay: m.toInt('due_day'),
          dueDate: m.dateTime('due_date') ?? m.dateTime('date'),
          status: m['status'] as String? ?? 'pending',
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
      income: json.toDouble('income'),
      expense: json.toDouble('expense'),
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
      amount: json.toDouble('amount'),
      percentage: json.toDouble('percentage'),
    );
  }
}

class UpcomingBillModel extends UpcomingBill {
  const UpcomingBillModel(
      {required super.id,
      required super.title,
      required super.amount,
      required super.dueDay,
  super.dueDate,
  super.status,
      super.categoryName});

  factory UpcomingBillModel.fromJson(Map<String, dynamic> json) {
    return UpcomingBillModel(
      id: json['id'] as int,
      title: json['title'] as String,
      amount: json.toDouble('amount'),
      dueDay: json['due_day'] as int,
      dueDate: json.dateTime('due_date') ?? json.dateTime('date'),
      status: json['status'] as String? ?? 'pending',
      categoryName: json['category_name'] as String?,
    );
  }
}
