import 'package:flutter/material.dart';

IconData iconFromName(String? name) {
  const map = <String, IconData>{
    'shopping_cart': Icons.shopping_cart,
    'restaurant': Icons.restaurant,
    'home': Icons.home,
    'directions_car': Icons.directions_car,
    'local_gas_station': Icons.local_gas_station,
    'credit_card': Icons.credit_card,
    'health_and_safety': Icons.health_and_safety,
    'sports_esports': Icons.sports_esports,
    'school': Icons.school,
    'commute': Icons.commute,
    'lightbulb': Icons.lightbulb,
    'phone': Icons.phone,
    'smartphone': Icons.smartphone,
    'wifi': Icons.wifi,
    'local_hospital': Icons.local_hospital,
    'fitness_center': Icons.fitness_center,
    'movie': Icons.movie,
    'work': Icons.work,
    'business': Icons.business,
    'travel_explore': Icons.travel_explore,
    'savings': Icons.savings,
    'money': Icons.money,
    'account_balance': Icons.account_balance,
    'fastfood': Icons.fastfood,
    'coffee': Icons.coffee,
    'flight': Icons.flight,
    'hotel': Icons.hotel,
    'pets': Icons.pets,
    'child_care': Icons.child_care,
    'subscriptions': Icons.subscriptions,
    'music_note': Icons.music_note,
    'book': Icons.book,
    'sports': Icons.sports,
    'local_pharmacy': Icons.local_pharmacy,
    'local_laundry_service': Icons.local_laundry_service,
    'cleaning_services': Icons.cleaning_services,
    'construction': Icons.construction,
    'attach_money': Icons.attach_money,
    'trending_up': Icons.trending_up,
    'swap_horiz': Icons.swap_horiz,
    'category': Icons.category,
  };
  return map[name] ?? Icons.category;
}

Color colorFromHex(String? hex) {
  if (hex == null || hex.isEmpty) return const Color(0xFF6B7280);
  final cleaned = hex.replaceAll('#', '');
  if (cleaned.length == 6) {
    return Color(int.parse('FF$cleaned', radix: 16));
  }
  if (cleaned.length == 8) {
    return Color(int.parse(cleaned, radix: 16));
  }
  return const Color(0xFF6B7280);
}
