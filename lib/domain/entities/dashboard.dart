import 'package:equatable/equatable.dart';

class DashboardData extends Equatable {
  final double totalBalance;
  final double totalIncome;
  final double totalExpense;
  final double monthlyBudget;
  final double budgetSpent;
  final double budgetPercentage;
  final double savingsTotal;
  final int pendingBills;
  final double healthScore;
  final List<MonthlyChartData> monthlyChart;
  final List<CategorySpending> topCategories;
  final List<UpcomingBill> upcomingBills;

  const DashboardData({
    this.totalBalance = 0,
    this.totalIncome = 0,
    this.totalExpense = 0,
    this.monthlyBudget = 0,
    this.budgetSpent = 0,
    this.budgetPercentage = 0,
    this.savingsTotal = 0,
    this.pendingBills = 0,
    this.healthScore = 0,
    this.monthlyChart = const [],
    this.topCategories = const [],
    this.upcomingBills = const [],
  });

  double get balance => totalIncome - totalExpense;

  @override
  List<Object?> get props => [totalBalance, totalIncome, totalExpense, healthScore];
}

class MonthlyChartData extends Equatable {
  final String month;
  final double income;
  final double expense;

  const MonthlyChartData({
    required this.month,
    required this.income,
    required this.expense,
  });

  @override
  List<Object?> get props => [month, income, expense];
}

class CategorySpending extends Equatable {
  final String name;
  final String? icon;
  final String? color;
  final double amount;
  final double percentage;

  const CategorySpending({
    required this.name,
    this.icon,
    this.color,
    required this.amount,
    required this.percentage,
  });

  @override
  List<Object?> get props => [name, amount];
}

class UpcomingBill extends Equatable {
  final int id;
  final String title;
  final double amount;
  final int dueDay;
  final String? categoryName;

  const UpcomingBill({
    required this.id,
    required this.title,
    required this.amount,
    required this.dueDay,
    this.categoryName,
  });

  @override
  List<Object?> get props => [id, title];
}
