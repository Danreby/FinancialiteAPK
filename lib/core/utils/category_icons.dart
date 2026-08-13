/// Category icon set ported 1:1 from financialite (web)'s
/// `resources/js/Utils/categoryIcons.js` category keys, but rendered as
/// monochrome Material glyphs instead of color emoji: emoji glyphs come
/// from the platform's own emoji font, which renders at inconsistent
/// baselines/metrics across devices (showing up off-center inside the
/// circular badges) and can't be tinted to match a category's color or the
/// app's dark/light background -- a vector [IconData] can.
library;

import 'package:flutter/material.dart';

/// Superset lookup (mirrors web's `ICON_MAP`): every icon key financialite
/// has ever offered, so legacy categories (created before a key was
/// removed from the picker) still render correctly here.
const Map<String, IconData> categoryIconDataMap = {
  'utensils': Icons.restaurant,
  'coffee': Icons.coffee,
  'pizza': Icons.local_pizza,
  'hamburger': Icons.lunch_dining,
  'beer': Icons.sports_bar,
  'cake': Icons.cake,
  'car': Icons.directions_car,
  'bus': Icons.directions_bus,
  'train': Icons.train,
  'plane': Icons.flight,
  'bicycle': Icons.pedal_bike,
  'fuel': Icons.local_gas_station,
  'home': Icons.home,
  'bed': Icons.king_bed,
  'couch': Icons.weekend,
  'bulb': Icons.lightbulb,
  'key': Icons.vpn_key,
  'tools': Icons.build,
  'heart': Icons.favorite,
  'medical': Icons.local_hospital,
  'pill': Icons.medication,
  'dumbbell': Icons.fitness_center,
  'apple': Icons.apple,
  'tooth': Icons.medical_services,
  'book': Icons.menu_book,
  'graduation': Icons.school,
  'pencil': Icons.edit,
  'backpack': Icons.backpack,
  'computer': Icons.computer,
  'microscope': Icons.biotech,
  'game': Icons.sports_esports,
  'music': Icons.music_note,
  'movie': Icons.movie,
  'camera': Icons.photo_camera,
  'ball': Icons.sports_soccer,
  'gift': Icons.card_giftcard,
  'dollar': Icons.attach_money,
  'credit-card': Icons.credit_card,
  'wallet': Icons.account_balance_wallet,
  'bank': Icons.account_balance,
  'chart': Icons.bar_chart,
  'piggy': Icons.savings,
  'shopping': Icons.shopping_cart,
  'shopping-online': Icons.shopping_bag,
  'phone': Icons.smartphone,
  'shirt': Icons.checkroom,
  'paw': Icons.pets,
  'scissors': Icons.content_cut,
  'umbrella': Icons.umbrella,
};

class CategoryIconOption {
  final String name;
  final String label;
  final IconData icon;
  const CategoryIconOption(
      {required this.name, required this.label, required this.icon});
}

/// The actual picker list shown when creating/editing a category --
/// mirrors web's `AVAILABLE_ICONS` exactly (same 17 active entries, same
/// order; web keeps 'coffee'/'bus' in the map but commented out of its own
/// picker, so they're omitted here too for parity).
const List<CategoryIconOption> categoryIconOptions = [
  CategoryIconOption(name: 'utensils', label: 'Talheres', icon: Icons.restaurant),
  CategoryIconOption(name: 'piggy', label: 'Porquinho', icon: Icons.savings),
  CategoryIconOption(name: 'pizza', label: 'Pizza', icon: Icons.local_pizza),
  CategoryIconOption(name: 'hamburger', label: 'Hambúrguer', icon: Icons.lunch_dining),
  CategoryIconOption(name: 'car', label: 'Carro', icon: Icons.directions_car),
  CategoryIconOption(name: 'fuel', label: 'Combustível', icon: Icons.local_gas_station),
  CategoryIconOption(name: 'home', label: 'Casa', icon: Icons.home),
  CategoryIconOption(name: 'heart', label: 'Coração', icon: Icons.favorite),
  CategoryIconOption(name: 'medical', label: 'Médico', icon: Icons.local_hospital),
  CategoryIconOption(name: 'book', label: 'Livro', icon: Icons.menu_book),
  CategoryIconOption(name: 'game', label: 'Jogo', icon: Icons.sports_esports),
  CategoryIconOption(name: 'music', label: 'Música', icon: Icons.music_note),
  CategoryIconOption(name: 'dollar', label: 'Dinheiro', icon: Icons.attach_money),
  CategoryIconOption(name: 'credit-card', label: 'Cartão', icon: Icons.credit_card),
  CategoryIconOption(
      name: 'shopping-online', label: 'Compras Online', icon: Icons.shopping_bag),
  CategoryIconOption(name: 'phone', label: 'Telefone', icon: Icons.smartphone),
  CategoryIconOption(name: 'shirt', label: 'Roupa', icon: Icons.checkroom),
];

/// Returns the [IconData] for a stored category `icon` key, or null if
/// [name] doesn't match the (web-sourced) icon set -- callers should fall
/// back to the legacy `iconFromName`/Material icon for categories created
/// before this set existed.
IconData? iconDataForCategoryIcon(String? name) {
  if (name == null) return null;
  return categoryIconDataMap[name];
}
