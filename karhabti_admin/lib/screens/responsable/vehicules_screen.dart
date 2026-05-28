import 'package:flutter/material.dart';
import '../../services/responsable_technicien_service.dart';
import 'vehicule_detail_screen.dart';

class ResponsableVehiculesScreen extends StatefulWidget {
  final String garageId;
  const ResponsableVehiculesScreen({super.key, required this.garageId});

  @override
  State<ResponsableVehiculesScreen> createState() => _ResponsableVehiculesScreenState();
}

class _ResponsableVehiculesScreenState extends State<ResponsableVehiculesScreen> {
  final _service = ResponsableTechnicienService();
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
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _data.length,
      itemBuilder: (_, i) {
        final v = _data[i];
        final client = v['client'] as Map<String, dynamic>?;
        return ListTile(
          title: Text('${v['immatriculation']} - ${v['marque']} ${v['modele']}'),
          subtitle: Text(
            '${client?['nom_client'] ?? 'Client inconnu'} | ${client?['telephone'] ?? '-'}',
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VehiculeDetailScreen(vehiculeData: v),
            ),
          ),
        );
      },
    );
  }
}
