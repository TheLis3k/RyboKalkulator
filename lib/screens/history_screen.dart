import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../services/database_service.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Zakończyć dzień?'),
        content: const Text(
            'To usunie trwale całą dzisiejszą historię sprzedaży. Tej operacji nie można cofnąć.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Anuluj'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final db = context.read<DatabaseService>();
              await db.clearHistory();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('USUŃ WSZYSTKO',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Raport Dnia'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
            onPressed: () => _confirmClear(context),
            tooltip: "Wyczyść historię",
          )
        ],
      ),
      body: ValueListenableBuilder<Box<Transaction>>(
        valueListenable:
            Hive.box<Transaction>(DatabaseService.transactionBoxName)
                .listenable(),
        builder: (context, box, _) {
          final all = box.values.toList().cast<Transaction>();
          final transactions = List<Transaction>.from(all)
            ..sort((a, b) => b.date.compareTo(a.date)); // najnowsze first

          double totalCash = 0;
          double totalWeight = 0;
          for (var t in transactions) {
            totalCash += t.totalPrice;
            totalWeight += t.weightInKg;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${totalCash.toStringAsFixed(2)} zł',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${totalWeight.toStringAsFixed(2)} kg',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: transactions.isEmpty
                    ? const Center(child: Text("Brak sprzedaży dzisiaj."))
                    : ListView.builder(
                        itemCount: transactions.length,
                        itemBuilder: (ctx, i) {
                          final tr = transactions[i];
                          return ListTile(
                            leading: Icon(Icons.monetization_on,
                                color: Theme.of(context).colorScheme.primary),
                            title: Text(tr.fishNameSnapshot,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle:
                                Text(DateFormat('HH:mm:ss').format(tr.date)),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${tr.totalPrice.toStringAsFixed(2)} zł',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text('${tr.weightInKg.toStringAsFixed(3)} kg',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
