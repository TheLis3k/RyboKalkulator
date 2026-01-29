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
        content: const Text('To usunie trwale całą dzisiejszą historię sprzedaży. Tej operacji nie można cofnąć.'),
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
            child: const Text('USUŃ WSZYSTKO', style: TextStyle(color: Colors.white)),
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
        valueListenable: Hive.box<Transaction>(DatabaseService.transactionBoxName).listenable(),
        builder: (context, box, _) {
          final transactions = box.values.toList().cast<Transaction>().reversed.toList();

          double totalCash = 0;
          double totalWeight = 0;
          for (var t in transactions) {
            totalCash += t.totalPrice;
            totalWeight += t.weightInKg;
          }

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blueGrey[900],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 5))
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text('UTARG', style: TextStyle(color: Colors.grey)),
                        Text(
                          '${totalCash.toStringAsFixed(2)} zł',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.greenAccent),
                        ),
                      ],
                    ),
                    Container(width: 1, height: 40, color: Colors.grey),
                    Column(
                      children: [
                        const Text('WAGA', style: TextStyle(color: Colors.grey)),
                        Text(
                          '${totalWeight.toStringAsFixed(3)} kg',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: transactions.isEmpty
                    ? const Center(child: Text("Brak sprzedaży dzisiaj."))
                    : ListView.builder(
                        itemCount: transactions.length,
                        itemBuilder: (ctx, i) {
                          final tr = transactions[i];
                          return ListTile(
                            leading: const Icon(Icons.monetization_on, color: Colors.white54),
                            title: Text(tr.fishNameSnapshot, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(DateFormat('HH:mm:ss').format(tr.date)),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('${tr.totalPrice.toStringAsFixed(2)} zł', style: const TextStyle(color: Colors.greenAccent, fontSize: 16)),
                                Text('${tr.weightInKg.toStringAsFixed(3)} kg', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[900],
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('ZAKOŃCZ DZIEŃ (Wyczyść)'),
                    onPressed: () => _confirmClear(context),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}