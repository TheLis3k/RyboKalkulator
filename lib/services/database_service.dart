import 'package:hive_flutter/hive_flutter.dart';
import '../models/fish_item.dart';
import '../models/transaction.dart';

class DatabaseService {
  static const String fishBoxName = 'fish_box';
  static const String transactionBoxName = 'transaction_box';

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(FishItemAdapter());
    Hive.registerAdapter(TransactionAdapter());
    await Hive.openBox<FishItem>(fishBoxName);
    await Hive.openBox<Transaction>(transactionBoxName);
  }

  Box<FishItem> get _fishBox => Hive.box<FishItem>(fishBoxName);

  List<FishItem> getAllFish() {
    return _fishBox.values.where((fish) => fish.isActive).toList();
  }

  Future<void> addFish(FishItem fish) async {
    await _fishBox.put(fish.id, fish);
  }

  Future<void> updateFish(FishItem fish) async {
    await fish.save();
  }

  Future<void> deleteFish(FishItem fish) async {
    fish.isActive = false;
    await fish.save();
  }

  Box<Transaction> get _transactionBox => Hive.box<Transaction>(transactionBoxName);

  List<Transaction> getTodayTransactions() {
    return _transactionBox.values.toList().cast<Transaction>();
  }

  Future<void> addTransaction(Transaction transaction) async {
    await _transactionBox.put(transaction.id, transaction);
  }

  Future<void> clearHistory() async {
    await _transactionBox.clear();
  }

  double getTodayTotalWeight() {
    var list = getTodayTransactions();
    if (list.isEmpty) return 0.0;
    return list.fold(0.0, (sum, item) => sum + item.weightInKg);
  }

  double getTodayTotalPrice() {
    var list = getTodayTransactions();
    if (list.isEmpty) return 0.0;
    return list.fold(0.0, (sum, item) => sum + item.totalPrice);
  }
}