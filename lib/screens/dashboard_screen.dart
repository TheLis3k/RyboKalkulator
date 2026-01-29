import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/fish_item.dart';
import '../models/transaction.dart' as model; // alias bo konflikt nazw z biblioteką
import '../services/database_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  
  // Funkcja wywoływana po kliknięciu w kafel z rybą
  void _showWeighingDialog(BuildContext context, FishItem fish) {
    final weightController = TextEditingController();
    final db = context.read<DatabaseService>();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(fish.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Cena: ${fish.pricePerKg.toStringAsFixed(2)} zł/kg'),
              const SizedBox(height: 20),
              TextField(
                controller: weightController,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Waga (kg)',
                  hintText: 'np. 0.350',
                  border: OutlineInputBorder(),
                  suffixText: 'kg',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Anuluj'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                // 1. Parsowanie wagi (zamiana przecinka na kropkę dla pewności)
                final weightText = weightController.text.replaceAll(',', '.');
                final weight = double.tryParse(weightText);

                if (weight == null || weight <= 0) return;

                // 2. Obliczenie ceny
                final totalPrice = weight * fish.pricePerKg;

                // 3. Stworzenie transakcji
                final transaction = model.Transaction(
                  id: const Uuid().v4(),
                  fishNameSnapshot: fish.name,
                  weightInKg: weight,
                  totalPrice: totalPrice,
                  date: DateTime.now(),
                );

                // 4. Zapis do bazy
                await db.addTransaction(transaction);

                if (ctx.mounted) {
                  Navigator.pop(ctx); // Zamknij okno
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Sprzedano: ${totalPrice.toStringAsFixed(2)} zł'),
                      duration: const Duration(seconds: 2),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('ZATWIERDŹ'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Pobieramy bazę
    final db = context.read<DatabaseService>();
    // Pobieramy listę ryb (tylko aktywne)
    final fishList = db.getAllFish();

    if (fishList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sailing, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            const Text('Brak ryb w menu.'),
            TextButton(
              onPressed: () {
                // Wymuszenie odświeżenia widoku (gdyby user wrócił z ustawień)
                setState(() {});
              },
              child: const Text('Odśwież'),
            )
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sprzedaż'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}), // Ręczne odświeżenie listy
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Dwie kolumny (na telefonie wygląda ok)
            childAspectRatio: 0.8, // Proporcje kafelka (wysokość vs szerokość)
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: fishList.length,
          itemBuilder: (context, index) {
            final fish = fishList[index];
            return Card(
              elevation: 4,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => _showWeighingDialog(context, fish),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ZDJĘCIE
                    Expanded(
                      flex: 3,
                      child: fish.imagePath != null
                          ? Image.file(
                              File(fish.imagePath!),
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: Colors.grey[800],
                              child: const Icon(Icons.set_meal, size: 50),
                            ),
                    ),
                    // OPIS
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              fish.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${fish.pricePerKg.toStringAsFixed(2)} zł/kg',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}