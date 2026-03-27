import '../../domain/entities/dashboard.dart';

class DashboardDataModel extends DashboardData {
  const DashboardDataModel({
    super.totalBalance,
    super.totalIncome,
    super.totalExpense,
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
    List<MonthlyChartData> chart = [];
    if (json['monthly_chart'] != null) {
      chart = (json['monthly_chart'] as List).map((c) => MonthlyChartDataModel.fromJson(c)).toList();
    }

    List<CategorySpending> categories = [];
    if (json['top_categories'] != null) {
      categories = (json['top_categories'] as List).map((c) => CategorySpendingModel.fromJson(c)).toList();
    }

    List<UpcomingBill> upcoming = [];
    if (json['upcoming_bills'] != null) {
      upcoming = (json['upcoming_bills'] as List).map((b) => UpcomingBillModel.fromJson(b)).toList();
    }

    return DashboardDataModel(
      totalBalance: (json['total_balance'] as num? ?? 0).toDouble(),
      totalIncome: (json['total_income'] as num? ?? 0).toDouble(),
      totalExpense: (json['total_expense'] as num? ?? 0).toDouble(),
      monthlyBudget: (json['monthly_budget'] as num? ?? 0).toDouble(),
      budgetSpent: (json['budget_spent'] as num? ?? 0).toDouble(),
      budgetPercentage: (json['budget_percentage'] as num? ?? 0).toDouble(),
      savingsTotal: (json['savings_total'] as num? ?? 0).toDouble(),
      pendingBills: json['pending_bills'] as int? ?? 0,
      healthScore: (json['health_score'] as num? ?? 0).toDouble(),
      monthlyChart: chart,
      topCategories: categories,
      upcomingBills: upcoming,
    );
  }
}

class MonthlyChartDataModel extends MonthlyChartData {
  const MonthlyChartDataModel({required super.month, required super.income, required super.expense});

  factory MonthlyChartDataModel.fromJson(Map<String, dynamic> json) {
    return MonthlyChartDataModel(
      month: json['month'] as String,
      income: (json['income'] as num? ?? 0).toDouble(),
      expense: (json['expense'] as num? ?? 0).toDouble(),
    );
  }
}

class CategorySpendingModel extends CategorySpending {
  const CategorySpendingModel({required super.name, super.icon, super.color, required super.amount, required super.percentage});

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
  const UpcomingBillModel({required super.id, required super.title, required super.amount, required super.dueDay, super.categoryName});

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
