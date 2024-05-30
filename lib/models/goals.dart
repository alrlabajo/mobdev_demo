import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goals_app/models/category.dart';
import 'package:goals_app/models/frequency.dart';

class Goals {
  String? id;
  String name;
  double price;
  Category category;
  Frequency frequency;
  DateTime targetDate;

  Goals({
    this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.frequency,
    required this.targetDate,
  });

  get savingsPerFrequency => null;

  // Convert Goal object to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'category': category.toString(),
      'frequency': frequency.toString(),
      'targetDate': Timestamp.fromDate(targetDate),
    };
  }

  // Create Goal object from JSON
  factory Goals.fromJson(Map<String, dynamic> json) {
    return Goals(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      category: Category.values.firstWhere((e) => e.toString() == json['category']),
      frequency: Frequency.values.firstWhere((e) => e.toString() == json['frequency']),
      targetDate: (json['targetDate'] as Timestamp).toDate(),
    );
  }
}
