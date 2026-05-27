import 'package:flutter/material.dart';
import '../../models/appointment_pro_model.dart';
import '../../services/responsable_technicien_service.dart';
import '../../services/garage_pro_service.dart';
import 'rdv_screen.dart';
import 'vehicules_screen.dart';
import 'mon_garage_screen.dart';

class ResponsableDashboardScreen extends StatefulWidget {
  const ResponsableDashboardScreen({super.key});

  @override
  State<ResponsableDashboardScreen> createState() => _ResponsableDashboardScreenState();
}

class _ResponsableDashboardScreenState extends State<ResponsableDashboardScreen> {
  final _service = ResponsableTechnicienService();
  final _garageService = GarageProService();
  bool _loading = true;
  int _rdvEnAttente = 0;
  int _rdvSemaine = 0;
  int _critical = 0;
  double _note = 0;
  String? _garageId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final profile = await _service.getMyProfile();
    if (profile?.garageId == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    _garageId = profile!.garageId;
    final now = DateTime.now();
    final startDay = DateTime(now.year, now.month, now.day);
    final endDay = startDay.add(const Duration(days: 1));
    final weekEnd = startDay.add(const Duration(days: 7));

    final pendingToday = await _garageService.getAppointments(
      garageId: _garageId,
      statut: AppointmentStatus.enAttente,
      dateDebut: startDay,
      dateFin: endDay,
    );
    final confirmedWeek = await _garageService.getAppointments(
      garageId: _garageId,
      statut: AppointmentStatus.confirme,
      dateDebut: startDay,
      dateFin: weekEnd,
    );
    final vehicules = await _service.getVehiculesDuGarage(_garageId!);
    _critical = vehicules.where((v) {
      final p = v['prediction'] as Map<String, dynamic>?;
      if (p == null) return false;
      final values = [
        p['tire_wear'],
        p['battery_health'],
        p['brake_wear'],
        p['oil_change'],
        p['belt_risk'],
        p['clutch_wear'],
        p['ShockAbsorber_Wear'],
      ];
      return values.any((e) => (e as num?) != null && e >= 70);
    }).length;

    final garage = await _garageService.getGarageById(_garageId!);
    if (mounted) {
      setState(() {
        _rdvEnAttente = pendingToday.length;
        _rdvSemaine = confirmedWeek.length;
        _note = garage?.noteMoyenne ?? 0;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Responsable technicien')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                _stat('RDV en attente (aujourd\'hui)', '$_rdvEnAttente'),
                const SizedBox(width: 12),
                _stat('RDV confirmés (7j)', '$_rdvSemaine'),
                const SizedBox(width: 12),
                _stat('Maintenances critiques', '$_critical'),
                const SizedBox(width: 12),
                _stat('Note moyenne garage', _note.toStringAsFixed(1)),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ElevatedButton(
                  onPressed: _garageId == null
                      ? null
                      : () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ResponsableRdvScreen(garageId: _garageId!)),
                          ),
                  child: const Text('Rendez-vous'),
                ),
                ElevatedButton(
                  onPressed: _garageId == null
                      ? null
                      : () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ResponsableVehiculesScreen(garageId: _garageId!)),
                          ),
                  child: const Text('Véhicules'),
                ),
                ElevatedButton(
                  onPressed: _garageId == null
                      ? null
                      : () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => MonGarageScreen(garageId: _garageId!)),
                          ),
                  child: const Text('Mon garage'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String title, String value) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ]),
        ),
      ),
    );
  }
}
