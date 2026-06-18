const Map<String, String> allergenEmoji = {
  'Apio': '🥬',
  'Cacao': '🍫',
  'Trigo': '🌾',
  'Huevo': '🥚',
  'Leche': '🥛',
  'Mani': '🥜',
  'Mariscos': '🦐',
  'Mostaza': '🟡',
  'Nuez': '🌰',
  'Palta': '🥑',
  'Pescado': '🐟',
  'Sesamo': '⚪',
  'Soya': '🌱',
  'Sulfitos': '🍷',
};

String emojiForAllergen(String name) {
  final normalized = _normalize(name);
  for (final entry in allergenEmoji.entries) {
    if (_normalize(entry.key) == normalized) return entry.value;
  }
  return '⚠️';
}

String _normalize(String s) => s
    .toLowerCase()
    .replaceAll('á', 'a')
    .replaceAll('é', 'e')
    .replaceAll('í', 'i')
    .replaceAll('ó', 'o')
    .replaceAll('ú', 'u')
    .replaceAll('ü', 'u')
    .replaceAll('ñ', 'n');
