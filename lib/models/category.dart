enum Category {
  education(emoji: '📚'),
  personal(emoji: '👤'),
  health(emoji: '🏥'),
  work(emoji: '💼'),
  leisure(emoji: '🎁'),
  travel(emoji: '✈️'),
  home(emoji: '🏠'),
  other(emoji: '📦');

  final String emoji;

  const Category ({required this.emoji});

  String formatName() {
    return '$emoji ${name[0].toUpperCase() + name.substring(1)}';
  }

  String toJson() => name;
  static Category fromJson(String json) => values.byName(json);

}