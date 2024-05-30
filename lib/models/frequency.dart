enum Frequency {
  daily (daysInBetween: 1),
  weekly (daysInBetween: 7),
  biweekly (daysInBetween: 14),
  monthly (daysInBetween: 30);

  final int daysInBetween;

  const Frequency ({required this.daysInBetween});

  String formatName() {
    return name[0].toUpperCase() + name.substring(1);
  }

  String toJson() => name;
  static Frequency fromJson(String json) => values.byName(json);
}