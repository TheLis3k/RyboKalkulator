import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 1)
class Transaction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String fishNameSnapshot;

  @HiveField(2)
  final double weightInKg;

  @HiveField(3)
  final double totalPrice;

  @HiveField(4)
  final DateTime date;

  Transaction({
    required this.id,
    required this.fishNameSnapshot,
    required this.weightInKg,
    required this.totalPrice,
    required this.date,
  });
}