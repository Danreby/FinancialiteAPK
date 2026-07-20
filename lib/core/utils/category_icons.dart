/// Category icon set ported 1:1 from financialite (web)'s
/// `resources/js/Utils/categoryIcons.js`, so a category created on either
/// platform renders with the exact same glyph on the other -- coherence
/// between web and mobile, not two separate icon systems.
library;

/// Superset lookup (mirrors web's `ICON_MAP`): every icon key financialite
/// has ever offered, so legacy categories (created before a key was
/// removed from the picker) still render correctly here.
const Map<String, String> categoryEmojiMap = {
  'utensils': '🍴',
  'coffee': '☕',
  'pizza': '🍕',
  'hamburger': '🍔',
  'beer': '🍺',
  'cake': '🍰',
  'car': '🚗',
  'bus': '🚌',
  'train': '🚆',
  'plane': '✈️',
  'bicycle': '🚲',
  'fuel': '⛽',
  'home': '🏠',
  'bed': '🛏️',
  'couch': '🛋️',
  'bulb': '💡',
  'key': '🔑',
  'tools': '🔧',
  'heart': '❤️',
  'medical': '🏥',
  'pill': '💊',
  'dumbbell': '🏋️',
  'apple': '🍎',
  'tooth': '🦷',
  'book': '📚',
  'graduation': '🎓',
  'pencil': '✏️',
  'backpack': '🎒',
  'computer': '💻',
  'microscope': '🔬',
  'game': '🎮',
  'music': '🎵',
  'movie': '🎬',
  'camera': '📷',
  'ball': '⚽',
  'gift': '🎁',
  'dollar': '💰',
  'credit-card': '💳',
  'wallet': '👛',
  'bank': '🏦',
  'chart': '📊',
  'piggy': '🐷',
  'shopping': '🛒',
  'shopping-online': '🛍️',
  'phone': '📱',
  'shirt': '👕',
  'paw': '🐾',
  'scissors': '✂️',
  'umbrella': '☂️',
};

class CategoryIconOption {
  final String name;
  final String label;
  final String icon;
  const CategoryIconOption(
      {required this.name, required this.label, required this.icon});
}

/// The actual picker list shown when creating/editing a category --
/// mirrors web's `AVAILABLE_ICONS` exactly (same 17 active entries, same
/// order; web keeps 'coffee'/'bus' in the map but commented out of its own
/// picker, so they're omitted here too for parity).
const List<CategoryIconOption> categoryIconOptions = [
  CategoryIconOption(name: 'utensils', label: 'Talheres', icon: '🍴'),
  CategoryIconOption(name: 'piggy', label: 'Porquinho', icon: '🐷'),
  CategoryIconOption(name: 'pizza', label: 'Pizza', icon: '🍕'),
  CategoryIconOption(name: 'hamburger', label: 'Hambúrguer', icon: '🍔'),
  CategoryIconOption(name: 'car', label: 'Carro', icon: '🚗'),
  CategoryIconOption(name: 'fuel', label: 'Combustível', icon: '⛽'),
  CategoryIconOption(name: 'home', label: 'Casa', icon: '🏠'),
  CategoryIconOption(name: 'heart', label: 'Coração', icon: '❤️'),
  CategoryIconOption(name: 'medical', label: 'Médico', icon: '🏥'),
  CategoryIconOption(name: 'book', label: 'Livro', icon: '📚'),
  CategoryIconOption(name: 'game', label: 'Jogo', icon: '🎮'),
  CategoryIconOption(name: 'music', label: 'Música', icon: '🎵'),
  CategoryIconOption(name: 'dollar', label: 'Dinheiro', icon: '💰'),
  CategoryIconOption(name: 'credit-card', label: 'Cartão', icon: '💳'),
  CategoryIconOption(
      name: 'shopping-online', label: 'Compras Online', icon: '🛍️'),
  CategoryIconOption(name: 'phone', label: 'Telefone', icon: '📱'),
  CategoryIconOption(name: 'shirt', label: 'Roupa', icon: '👕'),
];

/// Returns the emoji for a stored category `icon` key, or null if [name]
/// doesn't match the (web-sourced) emoji set -- callers should fall back to
/// the legacy `iconFromName`/Material icon for categories created before
/// this set existed.
String? emojiForCategoryIcon(String? name) {
  if (name == null) return null;
  return categoryEmojiMap[name];
}
