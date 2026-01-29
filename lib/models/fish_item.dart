import 'package:hive/hive.dart';

part 'fish_item.g.dart';

@HiveType(typeId: 0)
class FishItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double pricePerKg;

  @HiveField(3)
  String? imagePath;

  @HiveField(4)
  bool isActive;

  FishItem({
    required this.id,
    required this.name,
    required this.pricePerKg,
    this.imagePath,
    this.isActive = true,
  });
}