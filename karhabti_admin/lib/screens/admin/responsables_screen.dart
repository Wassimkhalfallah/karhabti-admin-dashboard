import 'package:flutter/material.dart';
import '../../models/responsable_technicien_model.dart';
import '../../services/responsable_technicien_service.dart';

class ResponsablesScreen extends StatefulWidget {
  const ResponsablesScreen({super.key});

  @override
  State<ResponsablesScreen> createState() => _ResponsablesScreenState();
}

class _ResponsablesScreenState extends State<ResponsablesScreen> {
  final _service = ResponsableTechnicienService();
  bool _loading = true;
  List<ResponsableTechnicien> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final rows = await _service.getAllByAdminView();
    if (mounted) setState(() => _items = rows);
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: ElevatedButton(
                      onPressed: () => _openCreateDialog(),
                      child: const Text('Créer un responsable'),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (_, i) {
                      final r = _items[i];
                      return ListTile(
                        title: Text(r.nomComplet),
                        subtitle: Text('Garage: ${r.garageId ?? 'Aucun'} | Créé: ${r.createdAt.toLocal()}'),
                        trailing: Switch(
                          value: r.estActif,
                          onChanged: (v) async {
                            await _service.toggleActif(r.id, v);
                            _load();
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _openCreateDialog() async {
    final form = GlobalKey<FormState>();
    final userIdCtrl = TextEditingController();
    final nomCtrl = TextEditingController();
    final telCtrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nouveau responsable'),
        content: Form(
          key: form,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
              controller: userIdCtrl,
              decoration: const InputDecoration(labelText: 'User ID (uuid auth.users)'),
              validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
            ),
            TextFormField(
              controller: nomCtrl,
              decoration: const InputDecoration(labelText: 'Nom complet'),
              validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
            ),
            TextFormField(controller: telCtrl, decoration: const InputDecoration(labelText: 'Téléphone')),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              if (!form.currentState!.validate()) return;
              await _service.createResponsable(
                userId: userIdCtrl.text.trim(),
                nomComplet: nomCtrl.text.trim(),
                telephone: telCtrl.text.trim().isEmpty ? null : telCtrl.text.trim(),
              );
              if (mounted) Navigator.pop(context);
              _load();
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }
}
