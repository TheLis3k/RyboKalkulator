import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/fish_item.dart';
import '../services/database_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _showFishDialog({FishItem? fish}) {
    final nameController = TextEditingController(text: fish?.name ?? '');
    final priceController = TextEditingController(text: fish?.pricePerKg.toString() ?? '');
    String? imagePath = fish?.imagePath;
    final isEditing = fish != null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(isEditing ? 'Edytuj rybę' : 'Dodaj rybę'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final picked = await picker.pickImage(
                        source: ImageSource.gallery, // Zmienimy na Camera w wersji na telefon
                        imageQuality: 50,
                        maxWidth: 600,
                      );
                      if (picked != null) {
                        setState(() => imagePath = picked.path);
                      }
                    },
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(8),
                        image: imagePath != null
                            ? DecorationImage(
                                image: FileImage(File(imagePath!)),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: imagePath == null
                          ? const Icon(Icons.camera_alt, size: 50)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nazwa ryby'),
                  ),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: 'Cena za kg (PLN)'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Anuluj'),
              ),
              ElevatedButton(
                onPressed: () {
                  final name = nameController.text;
                  final price = double.tryParse(priceController.text.replaceAll(',', '.')) ?? 0.0;

                  if (name.isEmpty || price <= 0) return;

                  final db = context.read<DatabaseService>();

                  if (isEditing) {
                    fish!.name = name;
                    fish.pricePerKg = price;
                    fish.imagePath = imagePath;
                    db.updateFish(fish);
                  } else {
                    final newFish = FishItem(
                      id: const Uuid().v4(),
                      name: name,
                      pricePerKg: price,
                      imagePath: imagePath,
                    );
                    db.addFish(newFish);
                  }
                  
                  // Wymuszamy odświeżenie widoku
                  (context as Element).markNeedsBuild();
                  setState(() {}); // Odśwież dialog (niepotrzebne, ale bezpieczne)
                  Navigator.pop(context);
                  // Odśwież główny ekran
                  this.setState(() {});
                },
                child: const Text('Zapisz'),
              ),
            ],
          );
        },
      ),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final db = context.watch<DatabaseService>();
    final fishList = db.getAllFish();

    return Scaffold(
      appBar: AppBar(title: const Text('Zarządzanie Rybami')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFishDialog(),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: fishList.length,
        itemBuilder: (context, index) {
          final fish = fishList[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
            leading: fish.imagePath != null
                  ? Image.file(File(fish.imagePath!), width: 50, height: 50, fit: BoxFit.cover)
                  : const Icon(Icons.set_meal),
              title: Text(fish.name),
              subtitle: Text('${fish.pricePerKg.toStringAsFixed(2)} zł/kg'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showFishDialog(fish: fish),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await db.deleteFish(fish);
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}