import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/fish_item.dart';
import '../models/transaction.dart'
    as model; // alias bo konflikt nazw z biblioteką
import '../services/database_service.dart';
import '../services/locale_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  void _showWeighingDialog(BuildContext context, FishItem fish) {
    final db = context.read<DatabaseService>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _WeighingDialog(
        fish: fish,
        onClose: () => Navigator.pop(ctx),
        db: db,
        onSaved: (totalPrice) {
          Navigator.pop(ctx);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Sprzedano: ${totalPrice.toStringAsFixed(2)} zł'),
                duration: const Duration(seconds: 2),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Pobieramy bazę
    final db = context.read<DatabaseService>();
    // Pobieramy aktualny język
    final localeService = context.watch<LocaleService>();
    final languageCode = localeService.languageCode;
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
        title: SegmentedButton<String>(
          segments: const [
            ButtonSegment<String>(value: 'pl', label: Text('PL')),
            ButtonSegment<String>(value: 'en', label: Text('EN')),
            ButtonSegment<String>(value: 'de', label: Text('DE')),
          ],
          selected: {localeService.languageCode},
          onSelectionChanged: (Set<String> selected) {
            localeService.setLocale(Locale(selected.first));
          },
          style: const ButtonStyle(
            visualDensity: VisualDensity.compact,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}), // Ręczne odświeżenie listy
          )
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Na wąskich lub niskich ekranach wyższe karty = więcej miejsca na tekst
          final shortestSide = MediaQuery.sizeOf(context).shortestSide;
          final aspectRatio = shortestSide < 360 ? 0.72 : 0.8;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: aspectRatio,
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
                                  fit: BoxFit.contain,
                                )
                              : Container(
                                  color: Colors.grey[800],
                                  child: const Icon(Icons.set_meal, size: 50),
                                ),
                        ),
                        // OPIS – FittedBox zapobiega overflow na małych ekranach
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    fish.getLocalizedName(languageCode),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${fish.pricePerKg.toStringAsFixed(2)} zł/kg',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _WeighingDialog extends StatefulWidget {
  final FishItem fish;
  final VoidCallback onClose;
  final DatabaseService db;
  final ValueChanged<double> onSaved;

  const _WeighingDialog({
    required this.fish,
    required this.onClose,
    required this.db,
    required this.onSaved,
  });

  @override
  State<_WeighingDialog> createState() => _WeighingDialogState();
}

class _WeighingDialogState extends State<_WeighingDialog> {
  String _weightStr = '';

  double? get _weight => double.tryParse(_weightStr.replaceAll(',', '.'));
  double get _totalPrice => (_weight ?? 0) * widget.fish.pricePerKg;

  void _onKey(String key) {
    setState(() {
      if (key == '⌫') {
        if (_weightStr.isNotEmpty) {
          _weightStr = _weightStr.substring(0, _weightStr.length - 1);
        }
        return;
      }
      if (key == ',' || key == '.') {
        if (!_weightStr.contains('.') && !_weightStr.contains(',')) {
          _weightStr += ',';
        }
        return;
      }
      if (_weightStr == '0' && key != ',') {
        _weightStr = key;
      } else {
        _weightStr += key;
      }
    });
  }

  Future<void> _save() async {
    final w = _weight;
    if (w == null || w <= 0) return;
    final totalPrice = w * widget.fish.pricePerKg;
    final transaction = model.Transaction(
      id: const Uuid().v4(),
      fishNameSnapshot: widget.fish.name,
      weightInKg: w,
      totalPrice: totalPrice,
      date: DateTime.now(),
    );
    await widget.db.addTransaction(transaction);
    widget.onSaved(totalPrice);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final dialogHeight = size.height * 0.92;
    final isCompact = size.height < 600;

    return Dialog(
      insetPadding:
          EdgeInsets.symmetric(vertical: size.height * 0.04, horizontal: 12),
      child: SizedBox(
        height: dialogHeight,
        child: Material(
          borderRadius: BorderRadius.circular(16),
          child: SafeArea(
            child: Column(
              children: [
                // Nazwa ryby | Cena za kg (np. 22,31) | X
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      16, isCompact ? 4 : 8, 4, isCompact ? 4 : 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.fish.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: isCompact ? 18 : null,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        widget.fish.pricePerKg
                            .toStringAsFixed(2)
                            .replaceAll('.', ','),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: isCompact ? 14 : 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: widget.onClose,
                        icon: const Icon(Icons.close),
                        iconSize: isCompact ? 28 : 32,
                        style: IconButton.styleFrom(
                          minimumSize:
                              Size(isCompact ? 40 : 48, isCompact ? 40 : 48),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Cena wyliczona zł (kolor) + liczba kg + waga wpisana
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      16, isCompact ? 6 : 12, 16, isCompact ? 6 : 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _weight != null && _weight! > 0
                            ? '${_totalPrice.toStringAsFixed(2)} zł'
                            : '0,00 zł',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                          fontSize: isCompact ? 22 : null,
                        ),
                      ),
                      SizedBox(height: isCompact ? 6 : 10),
                      Text(
                        '${_weightStr.isEmpty ? '0' : _weightStr} kg',
                        style: theme.textTheme.titleLarge?.copyWith(
                          letterSpacing: 1,
                          fontFamily: 'monospace',
                          fontSize: isCompact ? 18 : null,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Klawiatura – wypełnia resztę, przyciski skalują się w pionie
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      const keys = [
                        ['1', '2', '3'],
                        ['4', '5', '6'],
                        ['7', '8', '9'],
                        [',', '0', '⌫'],
                      ];
                      final padding = isCompact ? 6.0 : 12.0;
                      final availableW = constraints.maxWidth - padding * 2;
                      final btnW = (availableW - 16) / 3;

                      return Padding(
                        padding: EdgeInsets.all(padding),
                        child: Column(
                          children: List.generate(4, (rowIndex) {
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: isCompact ? 2 : 4),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: List.generate(3, (colIndex) {
                                    final key = keys[rowIndex][colIndex];
                                    return SizedBox(
                                      width: btnW,
                                      child: Material(
                                        color: key == '⌫'
                                            ? theme.colorScheme
                                                .surfaceContainerHighest
                                            : theme.colorScheme
                                                .surfaceContainerHigh,
                                        borderRadius: BorderRadius.circular(10),
                                        child: InkWell(
                                          onTap: () => _onKey(key),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Center(
                                            child: key == '⌫'
                                                ? Icon(
                                                    Icons.backspace_outlined,
                                                    color: theme
                                                        .colorScheme.onSurface,
                                                    size: isCompact ? 22 : 28,
                                                  )
                                                : Text(
                                                    key,
                                                    style: theme
                                                        .textTheme.titleLarge
                                                        ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize:
                                                          isCompact ? 20 : 24,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            );
                          }),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
                // Wyczyść | Zapisz
                Padding(
                  padding: EdgeInsets.all(isCompact ? 8 : 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => _weightStr = ''),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                vertical: isCompact ? 12 : 16),
                          ),
                          child: const Text('Wyczyść'),
                        ),
                      ),
                      SizedBox(width: isCompact ? 12 : 16),
                      Expanded(
                        child: FilledButton(
                          onPressed:
                              _weight != null && _weight! > 0 ? _save : null,
                          style: FilledButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                vertical: isCompact ? 12 : 16),
                          ),
                          child: const Text('Zapisz'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
