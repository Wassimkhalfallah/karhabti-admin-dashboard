import 'package:flutter/material.dart';
import '../../services/vehicle_service.dart';
import 'vehicule_detail_screen.dart';

class ResponsableVehiculesScreen extends StatefulWidget {
  final String garageId;
  const ResponsableVehiculesScreen({super.key, required this.garageId});

  @override
  State<ResponsableVehiculesScreen> createState() => _ResponsableVehiculesScreenState();
}

class _ResponsableVehiculesScreenState extends State<ResponsableVehiculesScreen> {
  final _service = VehicleService();
  bool _loading = true;
  List<Map<String, dynamic>> _data = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await _service.getVehiculesDuGarage(widget.garageId);
    if (mounted) setState(() => _data = data);
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Véhicules du garage')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _data.length,
              itemBuilder: (_, i) {
                final v = _data[i];
                final client = v['client'] as Map<String, dynamic>?;
                return ListTile(
                  title: Text('${v['immatriculation']} - ${v['marque']} ${v['modele']}'),
                  subtitle: Text('${client?['nom_client'] ?? 'Client inconnu'} | ${client?['telephone'] ?? '-'}'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VehiculeDetailScreen(vehiculeData: v),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
