import 'package:flutter/material.dart';
import '../../services/garage_pro_service.dart';
import '../garages_pro/garage_form_screen.dart';

class MonGarageScreen extends StatefulWidget {
  final String garageId;
  const MonGarageScreen({super.key, required this.garageId});

  @override
  State<MonGarageScreen> createState() => _MonGarageScreenState();
}

class _MonGarageScreenState extends State<MonGarageScreen> {
  final _service = GarageProService();
  bool _loading = true;
  Map<String, dynamic>? _garage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final g = await _service.getGarageById(widget.garageId);
    if (mounted) setState(() => _garage = g?.toMap());
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon garage')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _garage == null
              ? const Center(child: Text('Garage introuvable'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_garage!['nom'] ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('${_garage!['adresse'] ?? ''}, ${_garage!['ville'] ?? ''}'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () async {
                          await showDialog(context: context, builder: (_) => const GarageFormScreen());
                          _load();
                        },
                        child: const Text('Modifier'),
                      ),
                    ],
                  ),
                ),
    );
  }
}
