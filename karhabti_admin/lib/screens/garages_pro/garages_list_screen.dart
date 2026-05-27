// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import '../../models/garage_pro_model.dart';
import '../../services/garage_pro_service.dart';
import 'garage_form_screen.dart';
import 'garage_detail_screen.dart';

class GaragesListScreen extends StatefulWidget {
  const GaragesListScreen({super.key});

  @override
  State<GaragesListScreen> createState() => _GaragesListScreenState();
}

class _GaragesListScreenState extends State<GaragesListScreen>
    with SingleTickerProviderStateMixin {
  final GarageProService _service = GarageProService();
  late AnimationController _staggerCtrl;

  bool _isLoading = true;
  List<GaragePro> _garages = [];
  List<GaragePro> _filtered = [];
  String _search = '';
  String? _villeFilter;
  bool? _verifieFilter;
  bool? _actifFilter;
  List<String> _villes = [];
  final Set<String> _selected = {};

  // ─── Design tokens ────────────────────────────────────────────────────────
  static const _bg       = Color(0xFFF8FAFC);
  static const _surface  = Colors.white;
  static const _surface2 = Color(0xFFF1F5F9);
  static const _amber    = Color(0xFFF59E0B);
  static const _emerald  = Color(0xFF10B981);
  static const _sky      = Color(0xFF0EA5E9);
  static const _rose     = Color(0xFFf43f5e);
  static const _textPri  = Color(0xFF1E293B);
  static const _textSec  = Color(0xFF475569);
  static const _border   = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _loadData();
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final garages = await _service.getGarages();
    final villes  = await _service.getDistinctVilles();
    if (mounted) {
      setState(() {
        _garages   = garages;
        _villes    = villes;
        _applyFilters();
        _isLoading = false;
      });
      _staggerCtrl.forward(from: 0);
    }
  }

  void _applyFilters() {
    var r = List<GaragePro>.from(_garages);
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      r = r.where((g) =>
        g.nom.toLowerCase().contains(q) ||
        g.ville.toLowerCase().contains(q) ||
        g.adresse.toLowerCase().contains(q)).toList();
    }
    if (_villeFilter != null) r = r.where((g) => g.ville == _villeFilter).toList();
    if (_verifieFilter != null) r = r.where((g) => g.estVerifie == _verifieFilter).toList();
    if (_actifFilter != null)   r = r.where((g) => g.estActif == _actifFilter).toList();
    setState(() => _filtered = r);
  }

  // ─── KPI helpers ──────────────────────────────────────────────────────────
  int get _totalActifs    => _garages.where((g) => g.estActif).length;
  int get _totalVerifies  => _garages.where((g) => g.estVerifie).length;
  double get _noteMoyenne {
    final withNotes = _garages.where((g) => g.nombreAvis > 0);
    if (withNotes.isEmpty) return 0;
    return withNotes.map((g) => g.noteMoyenne).reduce((a, b) => a + b) / withNotes.length;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPageHeader(),
          if (!_isLoading) _buildKpiRow(),
          _buildToolbar(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: _amber))
                : _buildTable(),
          ),
        ],
      ),
    );
  }

  // ─── Page header ──────────────────────────────────────────────────────────

  Widget _buildPageHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  width: 4, height: 22,
                  decoration: BoxDecoration(
                    color: _amber,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Garages Professionnels',
                  style: TextStyle(
                    color: _textPri,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ]),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  'Annuaire & gestion des partenaires CARHABTI.',
                  style: TextStyle(color: _textSec, fontSize: 13),
                ),
              ),
            ],
          ),
          const Spacer(),
          // Refresh button
          _darkIconBtn(
            icon: Icons.refresh_rounded,
            tooltip: 'Actualiser',
            onTap: _loadData,
          ),
          const SizedBox(width: 10),
          // Add button
          GestureDetector(
            onTap: () => _openForm(null),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
              decoration: BoxDecoration(
                color: _amber,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: _amber.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.add_rounded, color: Colors.black, size: 17),
                  SizedBox(width: 7),
                  Text(
                    'Ajouter un garage',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── KPI row ──────────────────────────────────────────────────────────────

  Widget _buildKpiRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
      child: Row(
        children: [
          _kpiCard('Total garages',   '${_garages.length}',              Icons.store_rounded,         _sky,     '${_filtered.length} affichés'),
          const SizedBox(width: 12),
          _kpiCard('Actifs',          '$_totalActifs',                    Icons.visibility_rounded,    _emerald, 'sur ${_garages.length}'),
          const SizedBox(width: 12),
          _kpiCard('Vérifiés',        '$_totalVerifies',                  Icons.verified_rounded,      _amber,   '${_garages.length - _totalVerifies} en attente'),
          const SizedBox(width: 12),
          _kpiCard('Note moyenne',    _noteMoyenne.toStringAsFixed(1),    Icons.star_rounded,          _rose,    'sur 5.0'),
        ],
      ),
    );
  }

  Widget _kpiCard(String label, String value, IconData icon, Color color, String sub) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 19),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                      color: color,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    )),
                Text(label,
                    style: const TextStyle(
                        color: _textPri, fontSize: 12, fontWeight: FontWeight.w600)),
                Text(sub,
                    style: const TextStyle(color: _textSec, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Toolbar ──────────────────────────────────────────────────────────────

  Widget _buildToolbar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 12),
      child: Row(
        children: [
          // Search
          _darkSearch(),
          const SizedBox(width: 10),
          // Ville dropdown
          _darkDropdown(),
          const SizedBox(width: 10),
          // Filter chips
          _darkChip('Vérifiés', Icons.verified_rounded, _emerald,
              _verifieFilter == true,
              (v) { _verifieFilter = v ? true : null; _applyFilters(); }),
          const SizedBox(width: 8),
          _darkChip('Actifs', Icons.bolt_rounded, _sky,
              _actifFilter == true,
              (v) { _actifFilter = v ? true : null; _applyFilters(); }),
          const SizedBox(width: 8),
          // Results count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _border),
            ),
            child: Text(
              '${_filtered.length} résultat${_filtered.length > 1 ? 's' : ''}',
              style: const TextStyle(
                  color: _textSec, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          const Spacer(),
          // Bulk actions
          if (_selected.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _amber.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _amber.withOpacity(0.3)),
              ),
              child: Text(
                '${_selected.length} sélectionné${_selected.length > 1 ? 's' : ''}',
                style: const TextStyle(
                    color: _amber, fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 8),
            _outlineBtn('Vérifier', Icons.verified_rounded, _emerald, _bulkVerify),
            const SizedBox(width: 8),
            _outlineBtn('Désactiver', Icons.block_rounded, _rose, _bulkDeactivate),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _darkSearch() {
    return SizedBox(
      width: 260,
      child: TextField(
        style: const TextStyle(color: _textPri, fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Rechercher un garage...',
          hintStyle: const TextStyle(color: _textSec, fontSize: 13),
          prefixIcon: const Icon(Icons.search_rounded, size: 18, color: _textSec),
          filled: true,
          fillColor: _surface,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 11, horizontal: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _amber, width: 1.5),
          ),
        ),
        onChanged: (v) { _search = v; _applyFilters(); },
      ),
    );
  }

  Widget _darkDropdown() {
    return SizedBox(
      width: 155,
      child: DropdownButtonFormField<String>(
        initialValue: _villeFilter,
        dropdownColor: _surface2,
        style: const TextStyle(color: _textPri, fontSize: 13),
        iconEnabledColor: _textSec,
        decoration: InputDecoration(
          hintText: 'Toutes les villes',
          hintStyle: const TextStyle(color: _textSec, fontSize: 13),
          filled: true,
          fillColor: _surface,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 11, horizontal: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _amber, width: 1.5),
          ),
        ),
        items: [
          const DropdownMenuItem(value: null, child: Text('Toutes les villes')),
          ..._villes.map((v) => DropdownMenuItem(value: v, child: Text(v))),
        ],
        onChanged: (v) { _villeFilter = v; _applyFilters(); },
      ),
    );
  }

  Widget _darkChip(String label, IconData icon, Color color,
      bool selected, ValueChanged<bool> onSelected) {
    return GestureDetector(
      onTap: () => onSelected(!selected),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.15) : _surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? color.withOpacity(0.5) : _border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14,
                color: selected ? color : _textSec),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? color : _textSec,
                )),
          ],
        ),
      ),
    );
  }

  Widget _outlineBtn(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _darkIconBtn({required IconData icon, required String tooltip, required VoidCallback onTap}) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _border),
          ),
          child: Icon(icon, size: 17, color: _textSec),
        ),
      ),
    );
  }

  // ─── Table ────────────────────────────────────────────────────────────────

  Widget _buildTable() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
      child: Container(
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Theme(
            data: Theme.of(context).copyWith(
              cardColor: _surface,
              dividerColor: _border,
            ),
            child: DataTable2(
              columnSpacing: 12,
              horizontalMargin: 16,
              minWidth: 960,
              smRatio: 0.6,
              headingRowColor: WidgetStateProperty.all(_bg.withOpacity(0.6)),
              headingRowHeight: 44,
              dataRowHeight: 58,
              dividerThickness: 0.5,
              columns: [
                DataColumn2(label: _th(''), fixedWidth: 52),
                DataColumn2(label: _th('Garage'), size: ColumnSize.L),
                DataColumn2(label: _th('Ville'), fixedWidth: 110),
                DataColumn2(label: _th('Statut'), fixedWidth: 130),
                DataColumn2(label: _th('Note'), fixedWidth: 80),
                DataColumn2(label: _th('Spécialités'), size: ColumnSize.M),
                DataColumn2(label: _th('Ajouté'), fixedWidth: 88),
                DataColumn2(label: _th('Actions'), fixedWidth: 120),
              ],
              rows: _filtered.asMap().entries.map((entry) {
                final i = entry.key;
                final g = entry.value;
                return _buildRow(g, i);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  DataRow2 _buildRow(GaragePro g, int index) {
    final isSelected = _selected.contains(g.id);
    return DataRow2(
      selected: isSelected,
      color: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return _amber.withOpacity(0.06);
        }
        if (states.contains(WidgetState.hovered)) {
          return Colors.white.withOpacity(0.03);
        }
        return index.isEven ? Colors.transparent : Colors.white.withOpacity(0.02);
      }),
      onSelectChanged: (v) => setState(() =>
          v == true ? _selected.add(g.id) : _selected.remove(g.id)),
      cells: [
        // Avatar
        DataCell(
          g.photoCouverture != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(g.photoCouverture!,
                      width: 34, height: 34, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _avatarPlaceholder(g)),
                )
              : _avatarPlaceholder(g),
        ),
        // Nom + adresse
        DataCell(Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(g.nom,
                style: const TextStyle(
                    color: _textPri,
                    fontWeight: FontWeight.w700,
                    fontSize: 13)),
            const SizedBox(height: 2),
            Text(g.adresse,
                style: const TextStyle(color: _textSec, fontSize: 11),
                overflow: TextOverflow.ellipsis),
          ],
        )),
        // Ville
        DataCell(Row(children: [
          Container(
            width: 6, height: 6,
            decoration: const BoxDecoration(
                color: _sky, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(g.ville,
              style: const TextStyle(color: _textPri, fontSize: 12)),
        ])),
        // Statut badges
        DataCell(Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              _statusDot(g.estVerifie, _emerald),
              const SizedBox(width: 5),
              Text(g.estVerifie ? 'Vérifié' : 'Non vérifié',
                  style: TextStyle(
                      color: g.estVerifie ? _emerald : _textSec,
                      fontSize: 11, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              _statusDot(g.estActif, _sky),
              const SizedBox(width: 5),
              Text(g.estActif ? 'Actif' : 'Inactif',
                  style: TextStyle(
                      color: g.estActif ? _sky : _textSec,
                      fontSize: 11, fontWeight: FontWeight.w600)),
            ]),
          ],
        )),
        // Note
        DataCell(Row(children: [
          const Icon(Icons.star_rounded, color: _amber, size: 15),
          const SizedBox(width: 4),
          Text(g.noteMoyenne.toStringAsFixed(1),
              style: const TextStyle(
                  color: _amber, fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(width: 3),
          Text('(${g.nombreAvis})',
              style: const TextStyle(color: _textSec, fontSize: 10)),
        ])),
        // Spécialités
        DataCell(Wrap(
          spacing: 4,
          runSpacing: 4,
          children: g.specialites.take(2).map((s) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: _surface2,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(s,
                style: const TextStyle(
                    color: _textSec, fontSize: 10,
                    fontWeight: FontWeight.w500)),
          )).toList(),
        )),
        // Date
        DataCell(Text(
          DateFormat('dd/MM/yy').format(g.createdAt),
          style: const TextStyle(color: _textSec, fontSize: 11),
        )),
        // Actions
        DataCell(Row(children: [
          _actionBtn(Icons.visibility_rounded, _sky, () => _openDetail(g)),
          const SizedBox(width: 6),
          _actionBtn(Icons.edit_rounded, _amber, () => _openForm(g)),
          const SizedBox(width: 4),
          PopupMenuButton<String>(
            color: _surface2,
            iconColor: _textSec,
            iconSize: 17,
            itemBuilder: (_) => [
              _menuItem('verify',
                  g.estVerifie ? 'Dé-vérifier' : 'Vérifier',
                  g.estVerifie ? Icons.remove_done_rounded : Icons.verified_rounded,
                  _emerald),
              _menuItem('toggle',
                  g.estActif ? 'Désactiver' : 'Activer',
                  g.estActif ? Icons.block_rounded : Icons.check_circle_rounded,
                  g.estActif ? _rose : _sky),
            ],
            onSelected: (v) {
              if (v == 'verify') _toggleVerify(g);
              if (v == 'toggle') _toggleActive(g);
            },
          ),
        ])),
      ],
    );
  }

  // ─── Small helpers ────────────────────────────────────────────────────────

  Widget _th(String text) => Text(text,
      style: const TextStyle(
          color: _textSec, fontSize: 11,
          fontWeight: FontWeight.w700, letterSpacing: 0.6));

  Widget _avatarPlaceholder(GaragePro g) => Container(
    width: 34, height: 34,
    decoration: BoxDecoration(
      color: _surface2,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Center(
      child: Text(
        g.nom.isNotEmpty ? g.nom[0].toUpperCase() : 'G',
        style: const TextStyle(
            color: _amber, fontWeight: FontWeight.w800, fontSize: 14),
      ),
    ),
  );

  Widget _statusDot(bool active, Color color) => Container(
    width: 6, height: 6,
    decoration: BoxDecoration(
      color: active ? color : _surface2,
      shape: BoxShape.circle,
      border: Border.all(color: active ? color : _textSec, width: 1.2),
    ),
  );

  Widget _actionBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30, height: 30,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Icon(icon, size: 15, color: color),
      ),
    );
  }

  PopupMenuItem<String> _menuItem(String value, String label,
      IconData icon, Color color) {
    return PopupMenuItem(
      value: value,
      child: Row(children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(color: color, fontSize: 13)),
      ]),
    );
  }

  // ─── Actions ──────────────────────────────────────────────────────────────

  Future<void> _openForm(GaragePro? garage) async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (_) => GarageFormScreen(garage: garage),
    );
    if (result == true) _loadData();
  }

  void _openDetail(GaragePro garage) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => GarageDetailScreen(garageId: garage.id),
    ));
  }

  Future<void> _toggleVerify(GaragePro g) async {
    await _service.verifyGarage(g.id, !g.estVerifie);
    _loadData();
  }

  Future<void> _toggleActive(GaragePro g) async {
    await _service.updateGarage(g.id, {'est_actif': !g.estActif});
    _loadData();
  }

  Future<void> _bulkVerify() async {
    for (final id in _selected) {
      await _service.verifyGarage(id, true);
    }
    setState(() => _selected.clear());
    _loadData();
  }

  Future<void> _bulkDeactivate() async {
    for (final id in _selected) {
      await _service.updateGarage(id, {'est_actif': false});
    }
    setState(() => _selected.clear());
    _loadData();
  }
}