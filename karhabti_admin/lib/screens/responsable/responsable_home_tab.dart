import 'package:flutter/material.dart';
import '../../models/appointment_pro_model.dart';
import '../../services/garage_pro_service.dart';
import '../../services/responsable_technicien_service.dart';
import '../../theme/karhabti_tokens.dart';

class ResponsableHomeTab extends StatefulWidget {
  final String garageId;
  final void Function(int index)? onNavigate;

  const ResponsableHomeTab({
    super.key,
    required this.garageId,
    this.onNavigate,
  });

  @override
  State<ResponsableHomeTab> createState() => _ResponsableHomeTabState();
}

class _ResponsableHomeTabState extends State<ResponsableHomeTab> {
  final _service = ResponsableTechnicienService();
  final _garageService = GarageProService();
  bool _loading = true;
  int _rdvEnAttente = 0;
  int _rdvSemaine = 0;
  int _critical = 0;
  double _note = 0;
  String _garageNom = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final now = DateTime.now();
    final startDay = DateTime(now.year, now.month, now.day);
    final endDay = startDay.add(const Duration(days: 1));
    final weekEnd = startDay.add(const Duration(days: 7));

    final pendingToday = await _garageService.getAppointments(
      garageId: widget.garageId,
      statut: AppointmentStatus.enAttente,
      dateDebut: startDay,
      dateFin: endDay,
    );
    final confirmedWeek = await _garageService.getAppointments(
      garageId: widget.garageId,
      statut: AppointmentStatus.confirme,
      dateDebut: startDay,
      dateFin: weekEnd,
    );
    final vehicules = await _service.getVehiculesDuGarage(widget.garageId);
    final critical = vehicules.where((v) {
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

    final garage = await _garageService.getGarageById(widget.garageId);
    if (mounted) {
      setState(() {
        _rdvEnAttente = pendingToday.length;
        _rdvSemaine = confirmedWeek.length;
        _critical = critical;
        _note = garage?.noteMoyenne ?? 0;
        _garageNom = garage?.nom ?? 'Mon garage';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: KarhabtiTokens.gold));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _garageNom,
            style: const TextStyle(
              color: KarhabtiTokens.textPri,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tableau de bord responsable',
            style: TextStyle(color: KarhabtiTokens.textSec, fontSize: 13),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final w = (constraints.maxWidth - 36) / 4;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _kpiCard(w, 'RDV en attente (aujourd\'hui)', '$_rdvEnAttente', KarhabtiTokens.warning),
                  _kpiCard(w, 'RDV confirmés (7j)', '$_rdvSemaine', KarhabtiTokens.success),
                  _kpiCard(w, 'Maintenances critiques', '$_critical', KarhabtiTokens.danger),
                  _kpiCard(w, 'Note moyenne', _note.toStringAsFixed(1), KarhabtiTokens.gold),
                ],
              );
            },
          ),
          const SizedBox(height: 28),
          const Text(
            'Accès rapide',
            style: TextStyle(
              color: KarhabtiTokens.textPri,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _quickNav(1, 'Pièces', Icons.settings_rounded),
              _quickNav(2, 'Affectation', Icons.assignment_turned_in_rounded),
              _quickNav(3, 'Rendez-vous', Icons.calendar_month_rounded),
              _quickNav(4, 'Véhicules', Icons.directions_car_rounded),
              _quickNav(5, 'Mon garage', Icons.store_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kpiCard(double width, String title, String value, Color accent) {
    return SizedBox(
      width: width.clamp(160, 320),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: KarhabtiTokens.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: KarhabtiTokens.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: KarhabtiTokens.textSec, fontSize: 12)),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: accent,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickNav(int index, String label, IconData icon) {
    return InkWell(
      onTap: () => widget.onNavigate?.call(index),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: KarhabtiTokens.surfaceAlt,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: KarhabtiTokens.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: KarhabtiTokens.gold),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: KarhabtiTokens.textPri, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
