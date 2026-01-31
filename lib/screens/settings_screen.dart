import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/fish_item.dart';
import '../services/database_service.dart';
import '../services/locale_service.dart';
import '../services/theme_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _showFishDialog({FishItem? fish}) {
    final nameController = TextEditingController(text: fish?.name ?? '');
    final nameEnController = TextEditingController(text: fish?.nameEn ?? '');
    final nameDeController = TextEditingController(text: fish?.nameDe ?? '');
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
                    controller: nameEnController,
                    decoration: const InputDecoration(labelText: 'Nazwa po angielsku'),
                  ),
                  TextField(
                    controller: nameDeController,
                    decoration: const InputDecoration(labelText: 'Nazwa po niemiecku'),
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
                  final nameEn = nameEnController.text.trim().isEmpty ? null : nameEnController.text.trim();
                  final nameDe = nameDeController.text.trim().isEmpty ? null : nameDeController.text.trim();
                  final price = double.tryParse(priceController.text.replaceAll(',', '.')) ?? 0.0;

                  if (name.isEmpty || price <= 0) return;

                  final db = context.read<DatabaseService>();

                  if (isEditing) {
                    fish.name = name;
                    fish.nameEn = nameEn;
                    fish.nameDe = nameDe;
                    fish.pricePerKg = price;
                    fish.imagePath = imagePath;
                    db.updateFish(fish);
                  } else {
                    final newFish = FishItem(
                      id: const Uuid().v4(),
                      name: name,
                      pricePerKg: price,
                      imagePath: imagePath,
                      nameEn: nameEn,
                      nameDe: nameDe,
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
    final themeService = context.watch<ThemeService>();
    final localeService = context.watch<LocaleService>();
    final fishList = db.getAllFish();

    return Scaffold(
      appBar: AppBar(title: const Text('Ustawienia')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFishDialog(),
        child: const Icon(Icons.add),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode),
                  label: Text('Jasny'),
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode),
                  label: Text('Ciemny'),
                ),
              ],
              selected: {themeService.themeMode},
              onSelectionChanged: (Set<ThemeMode> selected) {
                themeService.setThemeMode(selected.first);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment<String>(value: 'pl', label: Text('PL')),
                ButtonSegment<String>(value: 'en', label: Text('EN')),
                ButtonSegment<String>(value: 'de', label: Text('DE')),
              ],
              selected: {localeService.languageCode},
              onSelectionChanged: (Set<String> selected) {
                localeService.setLocale(Locale(selected.first));
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text('Twoje ryby', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ...List.generate(fishList.length, (index) {
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
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Usunąć rybę?'),
                            content: Text(
                              'Czy na pewno usunąć „${fish.name}"?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Anuluj'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Usuń'),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          await db.deleteFish(fish);
                          setState(() {});
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}