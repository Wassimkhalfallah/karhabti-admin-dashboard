// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/prestation_pro_model.dart';
import '../../services/garage_pro_service.dart';

class PrestationsScreen extends StatefulWidget {
  const PrestationsScreen({super.key});

  @override
  State<PrestationsScreen> createState() => _PrestationsScreenState();
}

class _PrestationsScreenState extends State<PrestationsScreen> {
  final GarageProService _service = GarageProService();
  bool _loading = true;
  List<PrestationPro> _prestations = [];
  String? _catFilter;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final list = await _service.getPrestations(categorie: _catFilter);
    if (mounted) {
      setState(() {
        _prestations = list;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildToolbar(),
        Expanded(
          child:
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildGrid(),
        ),
      ],
    );
  }

  Widget _buildToolbar() {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            DropdownButton<String?>(
              value: _catFilter,
              hint: const Text('Catégorie'),
              items: [
                const DropdownMenuItem(value: null, child: Text('Toutes')),
                ...PrestationPro.defaultCatalog.map(
                  (c) => DropdownMenuItem(
                    value: c['categorie'] as String,
                    child: Text(c['categorie'] as String),
                  ),
                ),
              ],
              onChanged: (v) {
                _catFilter = v;
                _loadData();
              },
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _addPrestation,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Ajouter une prestation'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    if (_prestations.isEmpty) {
      return const Center(child: Text('Aucune prestation'));
    }

    // Group by category
    final grouped = <String, List<PrestationPro>>{};
    for (final p in _prestations) {
      grouped.putIfAbsent(p.categorie, () => []).add(p);
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children:
          grouped.entries
              .map((entry) => _categorySection(entry.key, entry.value))
              .toList(),
    );
  }

  Widget _categorySection(String category, List<PrestationPro> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            category,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: items.map((p) => _prestationCard(p)).toList(),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _prestationCard(PrestationPro p) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color:
              p.actif
                  ? AppTheme.lightGreyColor
                  : AppTheme.dangerColor.withOpacity(0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    p.libelle,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      decoration: p.actif ? null : TextDecoration.lineThrough,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  itemBuilder:
                      (_) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Modifier'),
                        ),
                        PopupMenuItem(
                          value: 'toggle',
                          child: Text(p.actif ? 'Désactiver' : 'Activer'),
                        ),
                      ],
                  onSelected: (v) {
                    if (v == 'edit') _editPrestation(p);
                    if (v == 'toggle') _togglePrestation(p);
                  },
                ),
              ],
            ),
            if (p.prixDefaut != null)
              Text(
                '${p.prixDefaut!.toStringAsFixed(2)} TND',
                style: TextStyle(color: AppTheme.greyColor, fontSize: 12),
              ),
            if (p.dureeDefaut != null)
              Text(
                '${p.dureeDefaut} min',
                style: TextStyle(color: AppTheme.greyColor, fontSize: 12),
              ),
            if (!p.actif)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.dangerColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Désactivé',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.dangerColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _addPrestation() async {
    final data = await _showForm(null);
    if (data != null) {
      await _service.createPrestation(data);
      _loadData();
    }
  }

  Future<void> _editPrestation(PrestationPro p) async {
    final data = await _showForm(p);
    if (data != null) {
      await _service.updatePrestation(p.id, data);
      _loadData();
    }
  }

  Future<Map<String, dynamic>?> _showForm(PrestationPro? p) async {
    final codeCtrl = TextEditingController(text: p?.code ?? '');
    final libelleCtrl = TextEditingController(text: p?.libelle ?? '');
    final catCtrl = TextEditingController(text: p?.categorie ?? '');
    final prixCtrl = TextEditingController(
      text: p?.prixDefaut?.toStringAsFixed(2) ?? '',
    );
    final dureeCtrl = TextEditingController(
      text: p?.dureeDefaut?.toString() ?? '',
    );

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(
              p == null ? 'Ajouter une prestation' : 'Modifier la prestation',
            ),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: codeCtrl,
                    decoration: const InputDecoration(labelText: 'Code'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: libelleCtrl,
                    decoration: const InputDecoration(labelText: 'Libellé *'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: catCtrl,
                    decoration: const InputDecoration(labelText: 'Catégorie *'),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: prixCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Prix (TND)',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: dureeCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Durée (min)',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (libelleCtrl.text.isEmpty || catCtrl.text.isEmpty) {
                    return;
                  }
                  Navigator.pop(context, {
                    'code': codeCtrl.text.trim(),
                    'libelle': libelleCtrl.text.trim(),
                    'categorie': catCtrl.text.trim(),
                    'prix_defaut': double.tryParse(prixCtrl.text),
                    'duree_defaut': int.tryParse(dureeCtrl.text),
                    'actif': p?.actif ?? true,
                    'tri': p?.tri ?? 0,
                  });
                },
                child: const Text('Enregistrer'),
              ),
            ],
          ),
    );
  }

  Future<void> _togglePrestation(PrestationPro p) async {
    await _service.updatePrestation(p.id, {'actif': !p.actif});
    _loadData();
  }
}
