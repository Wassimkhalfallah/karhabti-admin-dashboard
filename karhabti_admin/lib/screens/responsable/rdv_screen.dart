import 'package:flutter/material.dart';
import '../../models/appointment_pro_model.dart';
import '../../services/garage_pro_service.dart';

class ResponsableRdvScreen extends StatefulWidget {
  final String garageId;
  const ResponsableRdvScreen({super.key, required this.garageId});

  @override
  State<ResponsableRdvScreen> createState() => _ResponsableRdvScreenState();
}

class _ResponsableRdvScreenState extends State<ResponsableRdvScreen> {
  final _service = GarageProService();
  AppointmentStatus? _status;
  bool _loading = true;
  List<AppointmentPro> _rdv = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await _service.getAppointments(garageId: widget.garageId, statut: _status);
    if (mounted) setState(() => _rdv = data);
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rendez-vous du garage')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: DropdownButtonFormField<AppointmentStatus?>(
              value: _status,
              items: [
                const DropdownMenuItem(value: null, child: Text('Tous')),
                ...AppointmentStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.label))),
              ],
              onChanged: (value) {
                setState(() => _status = value);
                _load();
              },
            ),
          ),
          if (_loading) const Expanded(child: Center(child: CircularProgressIndicator())),
          if (!_loading)
            Expanded(
              child: ListView.builder(
                itemCount: _rdv.length,
                itemBuilder: (_, i) {
                  final a = _rdv[i];
                  return ListTile(
                    title: Text('${a.immatriculation} - ${a.typePrestation}'),
                    subtitle: Text('${a.clientNom ?? 'Client'} | ${a.heureStr}'),
                    trailing: Wrap(spacing: 8, children: [
                      if (a.statut == AppointmentStatus.enAttente)
                        TextButton(
                          onPressed: () async {
                            await _service.confirmAppointment(a.id);
                            _load();
                          },
                          child: const Text('Confirmer'),
                        ),
                      if (a.statut != AppointmentStatus.annule)
                        TextButton(
                          onPressed: () async {
                            await _service.cancelAppointment(a.id, 'Annulé par responsable', 'garage');
                            _load();
                          },
                          child: const Text('Annuler'),
                        ),
                      if (a.statut == AppointmentStatus.confirme)
                        TextButton(
                          onPressed: () async {
                            await _service.completeAppointment(a.id);
                            _load();
                          },
                          child: const Text('Terminer'),
                        ),
                    ]),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
