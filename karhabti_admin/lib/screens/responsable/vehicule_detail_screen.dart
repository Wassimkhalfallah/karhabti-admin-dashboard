import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../models/piece_recommendation_model.dart';
import '../../models/piece_validation_model.dart';
import '../../services/responsable_technicien_service.dart';

class VehiculeDetailScreen extends StatefulWidget {
  final Map<String, dynamic> vehiculeData;
  const VehiculeDetailScreen({super.key, required this.vehiculeData});

  @override
  State<VehiculeDetailScreen> createState() => _VehiculeDetailScreenState();
}

class _VehiculeDetailScreenState extends State<VehiculeDetailScreen> {
  final _service = ResponsableTechnicienService();
  final _types = const [
    'batterie', 'freins', 'pneus', 'embrayage', 'courroie', 'amortisseurs', 'filtres', 'huile_moteur', 'refroidissement',
  ];
  bool _loading = true;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, PieceRecommendation?> _recs = {};

  @override
  void initState() {
    super.initState();
    for (final t in _types) {
      _controllers[t] = TextEditingController();
    }
    _load();
  }

  Future<void> _load() async {
    final immat = widget.vehiculeData['immatriculation'] as String;
    final all = await _service.getAllRecommendations(immat);
    for (final t in _types) {
      PieceRecommendation? rec;
      for (final item in all) {
        if (item.pieceType == t) {
          rec = item;
          break;
        }
      }
      _recs[t] = rec;
      _controllers[t]!.text = rec?.recommendation ?? '';
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.vehiculeData;
    final prediction = v['prediction'] as Map<String, dynamic>?;
    final client = v['client'] as Map<String, dynamic>?;
    final bars = _metricBars(prediction);
    return Scaffold(
      appBar: AppBar(title: Text('Détail ${v['immatriculation']}')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${v['marque']} ${v['modele']} - ${v['moteur']}'),
                Text('Client: ${client?['nom_client'] ?? '-'} | ${client?['telephone'] ?? '-'}'),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  child: BarChart(BarChartData(
                    borderData: FlBorderData(show: false),
                    titlesData: const FlTitlesData(topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false))),
                    barGroups: bars,
                  )),
                ),
                const SizedBox(height: 16),
                ..._types.map((t) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(t, style: const TextStyle(fontWeight: FontWeight.bold)),
                          TextField(
                            controller: _controllers[t],
                            maxLines: 2,
                            decoration: const InputDecoration(labelText: 'Recommandation'),
                          ),
                          const SizedBox(height: 8),
                          Wrap(spacing: 8, children: [
                            ElevatedButton(
                              onPressed: () async {
                                final me = await _service.getMyProfile();
                                if (me == null) return;
                                final rec = PieceRecommendation(
                                  id: _recs[t]?.id ?? '',
                                  responsableId: me.id,
                                  immatriculation: v['immatriculation'] as String,
                                  pieceType: t,
                                  pieceId: null,
                                  recommendation: _controllers[t]!.text.trim(),
                                  createdAt: DateTime.now(),
                                  updatedAt: DateTime.now(),
                                );
                                await _service.upsertRecommendation(rec);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Recommandation enregistrée')));
                                }
                              },
                              child: const Text('Enregistrer recommandation'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                final me = await _service.getMyProfile();
                                if (me == null) return;
                                await _service.validerRemplacement(
                                  PieceValidation(
                                    id: '',
                                    responsableId: me.id,
                                    immatriculation: v['immatriculation'] as String,
                                    pieceType: t,
                                    dateRemplacement: DateTime.now(),
                                    note: _controllers[t]!.text.trim().isEmpty ? null : _controllers[t]!.text.trim(),
                                  ),
                                );
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Remplacement validé')));
                                }
                              },
                              child: const Text('Valider remplacement'),
                            ),
                          ]),
                        ]),
                      ),
                    )),
              ]),
            ),
    );
  }

  List<BarChartGroupData> _metricBars(Map<String, dynamic>? p) {
    final metrics = <MapEntry<String, double>>[
      MapEntry('pneu', (p?['tire_wear'] as num?)?.toDouble() ?? 0),
      MapEntry('bat', (p?['battery_health'] as num?)?.toDouble() ?? 0),
      MapEntry('frein', (p?['brake_wear'] as num?)?.toDouble() ?? 0),
      MapEntry('huile', (p?['oil_change'] as num?)?.toDouble() ?? 0),
      MapEntry('cour', (p?['belt_risk'] as num?)?.toDouble() ?? 0),
      MapEntry('embr', (p?['clutch_wear'] as num?)?.toDouble() ?? 0),
      MapEntry('amort', (p?['ShockAbsorber_Wear'] as num?)?.toDouble() ?? 0),
    ];
    return List.generate(metrics.length, (i) {
      final y = metrics[i].value.clamp(0, 100).toDouble();
      final c = y < 40 ? Colors.green : y < 70 ? Colors.orange : Colors.red;
      return BarChartGroupData(x: i, barRods: [BarChartRodData(toY: y, color: c)]);
    });
  }
}
