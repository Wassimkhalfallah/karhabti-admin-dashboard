// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../models/vehicle_model.dart';
import '../../services/vehicle_service.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// DESIGN TOKENS — Light Pro (cohérent avec affectation_pieces_screen)
// ═══════════════════════════════════════════════════════════════════════════════

class _T {
  static const bg       = Color(0xFFF8FAFC);
  static const surface  = Color(0xFFFFFFFF);
  static const surface2 = Color(0xFFF1F5F9);
  static const border   = Color(0xFFE2E8F0);
  static const primary  = Color(0xFF6366F1);
  static const emerald  = Color(0xFF10B981);
  static const amber    = Color(0xFFF59E0B);
  static const rose     = Color(0xFFEF4444);
  static const sky      = Color(0xFF0EA5E9);
  static const violet   = Color(0xFF8B5CF6);
  static const textPri  = Color(0xFF1E293B);
  static const textSec  = Color(0xFF64748B);
  static const textHint = Color(0xFF94A3B8);
}

// Carburant → couleur
Color _fuelColor(String fuel) {
  switch (fuel.toLowerCase()) {
    case 'essence':   return _T.rose;
    case 'diesel':    return _T.amber;
    case 'électrique':return _T.emerald;
    case 'hybride':   return _T.violet;
    case 'gpl':       return _T.sky;
    default:          return _T.textSec;
  }
}

IconData _fuelIcon(String fuel) {
  switch (fuel.toLowerCase()) {
    case 'électrique': return Icons.electric_bolt_rounded;
    case 'hybride':    return Icons.recycling_rounded;
    default:           return Icons.local_gas_station_rounded;
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MAIN SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen>
    with SingleTickerProviderStateMixin {
  final VehicleService _vehicleService = VehicleService();

  List<Vehicle> _vehicles = [];
  bool _isLoading = true;
  bool _isError = false;
  String _errorMessage = '';
  Map<String, int> _vehicleCounts = {
    'total': 0, 'particulier': 0, 'professionnel': 0,
  };

  String _searchQuery  = '';
  String _selectedType = 'Tous';
  String _sortColumn   = 'immatriculation';
  bool _sortAscending  = true;
  int _currentPage     = 1;
  final int _rowsPerPage = 10;

  final _formKey = GlobalKey<FormState>();
  final _brandCtrl        = TextEditingController();
  final _modelCtrl        = TextEditingController();
  final _registrationCtrl = TextEditingController();
  final _yearCtrl         = TextEditingController();
  final _totalKmCtrl      = TextEditingController();
  final _dailyKmCtrl      = TextEditingController();

  final List<String> _vehicleTypes = ['Tous', 'Particulier', 'Professionnel'];
  final List<String> _fuelTypes    = ['Essence','Diesel','Électrique','Hybride','GPL'];
  String _selectedFuelType = 'Essence';
  String _selectedUserId   = '';
  List<Map<String, dynamic>> _clients = [];
  Vehicle? _selectedVehicle;

  late AnimationController _staggerCtrl;

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _loadData();
    _loadClients();
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    for (final c in [_brandCtrl, _modelCtrl, _registrationCtrl,
                     _yearCtrl, _totalKmCtrl, _dailyKmCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  // ─── Data ─────────────────────────────────────────────────────────────────

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _isError = false; });
    try {
      List<Vehicle> vehicles = await _vehicleService.getAllVehicles(
        orderBy: _sortColumn,
        ascending: _sortAscending,
        limit: null, offset: null, filters: null,
        searchQuery: _searchQuery,
      );
      if (_selectedType != 'Tous') {
        vehicles = vehicles
            .where((v) => v.type.toLowerCase() == _selectedType.toLowerCase())
            .toList();
      }
      final int start = (_currentPage - 1) * _rowsPerPage;
      final int end   = start + _rowsPerPage;
      if (start < vehicles.length) {
        vehicles = vehicles.sublist(start, end < vehicles.length ? end : vehicles.length);
      } else {
        vehicles = [];
      }
      final counts = await _vehicleService.countVehiclesByType();
      setState(() {
        _vehicles = vehicles;
        _vehicleCounts = counts;
        _isLoading = false;
      });
      _staggerCtrl.forward(from: 0);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isError = true;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _loadClients() async {
    setState(() {
      _clients = [
        {'id': '1', 'name': 'Jean Dupont'},
        {'id': '2', 'name': 'Marie Martin'},
        {'id': '3', 'name': 'Ahmed Ben Ali'},
        {'id': '4', 'name': 'Sophia Trabelsi'},
      ];
    });
  }

  void _resetForm() {
    for (final c in [_brandCtrl, _modelCtrl, _registrationCtrl,
                     _yearCtrl, _totalKmCtrl, _dailyKmCtrl]) {
      c.clear();
    }
    setState(() {
      _selectedFuelType = 'Essence';
      _selectedUserId   = '';
      _selectedVehicle  = null;
    });
  }

  Future<void> _exportVehicles() async {
    try {
      final csvData  = await _vehicleService.exportVehiclesToCSV();
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/vehicules_${DateTime.now().millisecondsSinceEpoch}.csv';
      await File(path).writeAsString(csvData);
      if (mounted) _toast('Exporté avec succès : $path', success: true);
    } catch (e) {
      _toast('Erreur exportation : $e');
    }
  }

  Future<void> _saveVehicle(bool isEdit) async {
    if (!_formKey.currentState!.validate()) return;
    try {
      final vehicle = Vehicle(
        brand: _brandCtrl.text.trim(),
        model: _modelCtrl.text.trim(),
        year: int.parse(_yearCtrl.text),
        registrationNumber: _registrationCtrl.text.trim(),
        totalKm: double.tryParse(_totalKmCtrl.text) ?? 0,
        dailyKm: double.tryParse(_dailyKmCtrl.text) ?? 0,
        fuelType: _selectedFuelType.toLowerCase(),
        userId: _selectedUserId,
        type: _selectedType == 'Tous' ? 'particulier' : _selectedType.toLowerCase(),
        createdAt: isEdit ? _selectedVehicle!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
      );
      if (isEdit) {
        await _vehicleService.updateVehicle(vehicle);
        _toast('Véhicule modifié avec succès', success: true);
      } else {
        await _vehicleService.createVehicle(vehicle);
        _toast('Véhicule ajouté avec succès', success: true);
      }
      _loadData();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      _toast('Erreur : $e');
    }
  }

  Future<void> _deleteVehicle(String immat) async {
    try {
      await _vehicleService.deleteVehicle(immat);
      _toast('Véhicule supprimé avec succès', success: true);
      _loadData();
    } catch (e) {
      _toast('Erreur suppression : $e');
    }
  }

  void _toast(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(success ? Icons.check_circle_rounded : Icons.error_outline_rounded,
            color: Colors.white, size: 15),
        const SizedBox(width: 10),
        Expanded(child: Text(msg, style: const TextStyle(fontSize: 13))),
      ]),
      backgroundColor: success ? _T.emerald : _T.rose,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
  }

  String _cap(String t) =>
      t.isEmpty ? '' : t[0].toUpperCase() + t.substring(1).toLowerCase();

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _T.bg,
      body: _isError ? _buildError() : _buildContent(),
    );
  }

  // ─── Error state ──────────────────────────────────────────────────────────

  Widget _buildError() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 64, height: 64,
        decoration: BoxDecoration(
          color: _T.rose.withOpacity(0.09),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.error_outline_rounded, color: _T.rose, size: 30),
      ),
      const SizedBox(height: 16),
      const Text('Erreur de chargement',
          style: TextStyle(color: _T.textPri, fontSize: 16,
              fontWeight: FontWeight.w800)),
      const SizedBox(height: 6),
      Text(_errorMessage,
          style: const TextStyle(color: _T.textSec, fontSize: 13)),
      const SizedBox(height: 20),
      ElevatedButton.icon(
        onPressed: _loadData,
        icon: const Icon(Icons.refresh_rounded, size: 16),
        label: const Text('Réessayer'),
        style: ElevatedButton.styleFrom(
          backgroundColor: _T.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    ]),
  );

  // ─── Main content ─────────────────────────────────────────────────────────

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPageHeader(),
        _buildKpiRow(),
        _buildToolbar(),
        Expanded(child: _buildTableArea()),
      ],
    );
  }

  // ─── Page header ──────────────────────────────────────────────────────────

  Widget _buildPageHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 26, 28, 16),
      decoration: const BoxDecoration(
        color: _T.surface,
        border: Border(bottom: BorderSide(color: _T.border)),
      ),
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 4, height: 22,
              decoration: BoxDecoration(
                color: _T.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            const Text('Gestion des Véhicules',
                style: TextStyle(
                    color: _T.textPri, fontSize: 21,
                    fontWeight: FontWeight.w800, letterSpacing: -0.4)),
          ]),
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.only(left: 16),
            child: Text('Visualisez et gérez les véhicules enregistrés dans CARHABTI.',
                style: TextStyle(color: _T.textSec, fontSize: 13)),
          ),
        ]),
        const Spacer(),
        _iconBtn(Icons.refresh_rounded, _loadData, 'Actualiser'),
        const SizedBox(width: 10),
        _iconBtn(Icons.download_rounded, _exportVehicles, 'Exporter CSV'),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => _showAddEditDialog(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
            decoration: BoxDecoration(
              color: _T.primary,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(
                color: _T.primary.withOpacity(0.28),
                blurRadius: 14, offset: const Offset(0, 4),
              )],
            ),
            child: const Row(children: [
              Icon(Icons.add_rounded, color: Colors.white, size: 17),
              SizedBox(width: 7),
              Text('Ajouter un véhicule',
                  style: TextStyle(color: Colors.white,
                      fontWeight: FontWeight.w700, fontSize: 13)),
            ]),
          ),
        ),
      ]),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: _T.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _T.border),
          ),
          child: Icon(icon, size: 17, color: _T.textSec),
        ),
      ),
    );
  }

  // ─── KPI row ──────────────────────────────────────────────────────────────

  Widget _buildKpiRow() {
    final total      = _vehicleCounts['total'] ?? 0;
    final part       = _vehicleCounts['particulier'] ?? 0;
    final pro        = _vehicleCounts['professionnel'] ?? 0;
    final partPct    = total > 0 ? (part * 100 / total).round() : 0;
    final proPct     = total > 0 ? (pro  * 100 / total).round() : 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 18, 28, 0),
      child: Row(children: [
        _kpiCard('Total véhicules',     '$total', Icons.directions_car_rounded,
                 _T.primary, 'Base CARHABTI',
                 onTap: () { setState(() => _selectedType = 'Tous'); _loadData(); }, index: 0),
        const SizedBox(width: 12),
        _kpiCard('Particuliers',        '$part',  Icons.person_rounded,
                 _T.emerald, '$partPct% du total',
                 onTap: () { setState(() => _selectedType = 'Particulier'); _loadData(); }, index: 1),
        const SizedBox(width: 12),
        _kpiCard('Professionnels',      '$pro',   Icons.business_center_rounded,
                 _T.amber, '$proPct% du total',
                 onTap: () { setState(() => _selectedType = 'Professionnel'); _loadData(); }, index: 2),
        const SizedBox(width: 12),
        _kpiCard('Export',              'CSV',    Icons.download_rounded,
                 _T.violet, 'Format CSV/Excel',
                 onTap: _exportVehicles, index: 3),
      ]),
    );
  }

  Widget _kpiCard(String label, String value, IconData icon, Color color,
      String sub, {required VoidCallback onTap, required int index}) {
    final isActive = (label == 'Particuliers' && _selectedType == 'Particulier') ||
                     (label == 'Professionnels' && _selectedType == 'Professionnel') ||
                     (label == 'Total véhicules' && _selectedType == 'Tous');
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isActive ? color.withOpacity(0.06) : _T.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isActive ? color.withOpacity(0.35) : _T.border,
              width: isActive ? 1.5 : 1,
            ),
          ),
          child: Row(children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 19),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(value,
                  style: TextStyle(color: color, fontSize: 22,
                      fontWeight: FontWeight.w900, letterSpacing: -0.5)),
              Text(label,
                  style: const TextStyle(color: _T.textPri, fontSize: 12,
                      fontWeight: FontWeight.w600)),
              Text(sub, style: const TextStyle(color: _T.textSec, fontSize: 11)),
            ]),
          ]),
        ),
      )
      .animate(delay: Duration(milliseconds: 80 * index))
      .fadeIn(duration: 350.ms)
      .slideY(begin: 0.15, end: 0, duration: 350.ms, curve: Curves.easeOut),
    );
  }

  // ─── Toolbar ──────────────────────────────────────────────────────────────

  Widget _buildToolbar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 8),
      child: Row(children: [
        // Search
        SizedBox(
          width: 320,
          child: TextField(
            style: const TextStyle(color: _T.textPri, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Immatriculation, marque, modèle...',
              hintStyle: const TextStyle(color: _T.textHint, fontSize: 13),
              prefixIcon: const Icon(Icons.search_rounded, size: 18, color: _T.textHint),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 15, color: _T.textHint),
                      onPressed: () { setState(() => _searchQuery = ''); _loadData(); },
                    )
                  : null,
              filled: true, fillColor: _T.surface, isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 11, horizontal: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _T.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _T.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _T.primary, width: 1.5)),
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
            onSubmitted: (_) => _loadData(),
          ),
        ),
        const SizedBox(width: 10),
        // Type filter chips
        ..._vehicleTypes.map((t) {
          final sel = _selectedType == t;
          final color = t == 'Particulier' ? _T.emerald
                      : t == 'Professionnel' ? _T.amber
                      : _T.primary;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedType = t);
                _loadData();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: sel ? color.withOpacity(0.12) : _T.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: sel ? color.withOpacity(0.4) : _T.border,
                    width: sel ? 1.5 : 1,
                  ),
                ),
                child: Text(t,
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600,
                        color: sel ? color : _T.textSec)),
              ),
            ),
          );
        }),
        const Spacer(),
        // Results count
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: _T.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _T.border),
          ),
          child: Text(
            '${_vehicles.length} résultat${_vehicles.length > 1 ? 's' : ''}',
            style: const TextStyle(color: _T.textSec, fontSize: 12,
                fontWeight: FontWeight.w500),
          ),
        ),
      ]),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  // ─── Table area ───────────────────────────────────────────────────────────

  Widget _buildTableArea() {
    if (_isLoading) {
      return const Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          CircularProgressIndicator(color: _T.primary, strokeWidth: 2.5),
          SizedBox(height: 14),
          Text('Chargement des véhicules...',
              style: TextStyle(color: _T.textSec, fontSize: 13)),
        ]),
      );
    }
    if (_vehicles.isEmpty) return _buildEmpty();

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
      child: Container(
        decoration: BoxDecoration(
          color: _T.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _T.border),
          boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12, offset: const Offset(0, 3),
          )],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(children: [
            // Table header
            _buildTableHeader(),
            // DataTable
            Expanded(
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: _T.border,
                  cardColor: _T.surface,
                ),
                child: DataTable2(
                  columnSpacing: 12,
                  horizontalMargin: 20,
                  minWidth: 700,
                  headingRowHeight: 44,
                  dataRowHeight: 54,
                  dividerThickness: 0.8,
                  headingRowColor: WidgetStateProperty.all(_T.surface2),
                  headingTextStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: _T.textSec,
                    letterSpacing: 0.4,
                  ),
                  sortColumnIndex: _sortColumn == 'immatriculation' ? 0
                      : _sortColumn == 'marque' ? 1
                      : _sortColumn == 'annee'  ? 3 : null,
                  sortAscending: _sortAscending,
                  columns: [
                    DataColumn2(
                      label: const Text('Immatriculation'),
                      size: ColumnSize.M,
                      onSort: (_, asc) {
                        setState(() { _sortColumn = 'immatriculation'; _sortAscending = asc; });
                        _loadData();
                      },
                    ),
                    DataColumn2(
                      label: const Text('Marque'),
                      onSort: (_, asc) {
                        setState(() { _sortColumn = 'marque'; _sortAscending = asc; });
                        _loadData();
                      },
                    ),
                    DataColumn2(label: const Text('Modèle')),
                    DataColumn2(
                      label: const Text('Année'),
                      fixedWidth: 80,
                      numeric: true,
                      onSort: (_, asc) {
                        setState(() { _sortColumn = 'annee'; _sortAscending = asc; });
                        _loadData();
                      },
                    ),
                    DataColumn2(label: const Text('Type'), fixedWidth: 120),
                    DataColumn2(label: const Text('Carburant'), fixedWidth: 120),
                    DataColumn2(label: const Text('Client'), size: ColumnSize.M),
                    DataColumn2(label: const Text('Actions'), fixedWidth: 110),
                  ],
                  rows: _vehicles.asMap().entries.map((e) =>
                      _buildRow(e.value, e.key)).toList(),
                ),
              ),
            ),
            // Pagination
            _buildPagination(),
          ]),
        ),
      ).animate().fadeIn(duration: 400.ms, delay: 300.ms)
       .slideY(begin: 0.05, end: 0, duration: 400.ms, curve: Curves.easeOut),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _T.border)),
      ),
      child: Row(children: [
        const Text('Liste des véhicules',
            style: TextStyle(color: _T.textPri, fontSize: 14,
                fontWeight: FontWeight.w800)),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _T.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${_vehicles.length} / ${_vehicleCounts['total']} véhicule${(_vehicleCounts['total'] ?? 0) > 1 ? 's' : ''}',
            style: const TextStyle(color: _T.primary, fontSize: 11,
                fontWeight: FontWeight.w700),
          ),
        ),
        if (_selectedType != 'Tous') ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _T.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(_selectedType,
                style: const TextStyle(color: _T.amber, fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ]),
    );
  }

  DataRow2 _buildRow(Vehicle v, int index) {
    final isParticulier = v.type.toLowerCase() == 'particulier';
    final typeColor  = isParticulier ? _T.emerald : _T.amber;
    final fuelColor  = _fuelColor(v.fuelType);

    return DataRow2(
      color: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered)) {
          return _T.primary.withOpacity(0.04);
        }
        return index.isEven ? Colors.transparent : _T.surface2.withOpacity(0.45);
      }),
      cells: [
        // Immatriculation
        DataCell(Row(children: [
          Container(
            width: 7, height: 7,
            decoration: BoxDecoration(color: _T.emerald, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(v.registrationNumber,
              style: const TextStyle(color: _T.textPri,
                  fontWeight: FontWeight.w700, fontSize: 13)),
        ])),
        // Marque
        DataCell(Text(v.brand,
            style: const TextStyle(color: _T.textPri, fontWeight: FontWeight.w600))),
        // Modèle
        DataCell(Text(v.model,
            style: const TextStyle(color: _T.textSec, fontSize: 13))),
        // Année
        DataCell(Text(v.year.toString(),
            style: const TextStyle(color: _T.textSec, fontSize: 13))),
        // Type badge
        DataCell(_chip(
          isParticulier ? 'Particulier' : 'Professionnel',
          typeColor,
          isParticulier ? Icons.person_rounded : Icons.business_center_rounded,
        )),
        // Carburant badge
        DataCell(_chip(_cap(v.fuelType), fuelColor, _fuelIcon(v.fuelType))),
        // Client
        DataCell(v.clientName != null
            ? Row(children: [
                Container(
                  width: 26, height: 26,
                  decoration: BoxDecoration(
                    color: _T.violet.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Center(
                    child: Text(
                      (v.clientName ?? 'N')[0].toUpperCase(),
                      style: const TextStyle(color: _T.violet,
                          fontWeight: FontWeight.w800, fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(v.clientName!,
                    style: const TextStyle(color: _T.textPri, fontSize: 13)),
              ])
            : const Text('—', style: TextStyle(color: _T.textHint, fontSize: 13))),
        // Actions
        DataCell(Row(children: [
          _actionBtn(Icons.visibility_rounded, _T.sky,
              () => _showDetailsDialog(context, v)),
          const SizedBox(width: 6),
          _actionBtn(Icons.edit_rounded, _T.primary,
              () => _prepareEdit(v)),
          const SizedBox(width: 6),
          _actionBtn(Icons.delete_outline_rounded, _T.rose,
              () => _showDeleteDialog(context, v.registrationNumber)),
        ])),
      ],
    );
  }

  Widget _chip(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 5),
        Text(label,
            style: TextStyle(color: color, fontSize: 11,
                fontWeight: FontWeight.w700)),
      ]),
    );
  }

  Widget _actionBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 29, height: 29,
        decoration: BoxDecoration(
          color: color.withOpacity(0.09),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }

  Widget _buildPagination() {
    final total = _vehicleCounts['total'] ?? 0;
    final totalPages = (total / _rowsPerPage).ceil();
    if (totalPages <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _T.border)),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _pageBtn(Icons.chevron_left_rounded, _currentPage > 1, () {
          setState(() => _currentPage--);
          _loadData();
        }),
        const SizedBox(width: 12),
        Text('Page $_currentPage / $totalPages',
            style: const TextStyle(color: _T.textSec, fontSize: 13,
                fontWeight: FontWeight.w600)),
        const SizedBox(width: 12),
        _pageBtn(Icons.chevron_right_rounded, _currentPage < totalPages, () {
          setState(() => _currentPage++);
          _loadData();
        }),
      ]),
    );
  }

  Widget _pageBtn(IconData icon, bool enabled, VoidCallback onTap) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: enabled ? _T.primary.withOpacity(0.08) : _T.surface2,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: enabled ? _T.primary.withOpacity(0.25) : _T.border),
        ),
        child: Icon(icon, size: 18,
            color: enabled ? _T.primary : _T.textHint),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 70, height: 70,
          decoration: BoxDecoration(
            color: _T.surface2,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _T.border),
          ),
          child: const Icon(Icons.no_crash_outlined,
              size: 30, color: _T.textHint),
        ),
        const SizedBox(height: 16),
        const Text('Aucun véhicule trouvé',
            style: TextStyle(color: _T.textPri, fontSize: 15,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        const Text('Ajoutez un véhicule ou modifiez vos critères',
            style: TextStyle(color: _T.textSec, fontSize: 13)),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () => _showAddEditDialog(context),
          icon: const Icon(Icons.add_rounded, size: 16),
          label: const Text('Ajouter un véhicule'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _T.primary, foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ]),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DIALOGS
  // ═══════════════════════════════════════════════════════════════════════════

  // ─── Details dialog ───────────────────────────────────────────────────────

  void _showDetailsDialog(BuildContext context, Vehicle v) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 580,
          decoration: BoxDecoration(
            color: _T.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _T.border),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12),
                blurRadius: 40, offset: const Offset(0, 12))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _T.primary.withOpacity(0.04),
                  border: const Border(
                    bottom: BorderSide(color: _T.border),
                    left: BorderSide(color: _T.primary, width: 3),
                  ),
                ),
                child: Row(children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: _T.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.directions_car_rounded,
                        color: _T.primary, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${v.brand} ${v.model}',
                          style: const TextStyle(color: _T.textPri, fontSize: 16,
                              fontWeight: FontWeight.w800)),
                      Text(v.registrationNumber,
                          style: const TextStyle(color: _T.textSec, fontSize: 13)),
                    ]),
                  ),
                  _chip(
                    v.type.toLowerCase() == 'particulier' ? 'Particulier' : 'Professionnel',
                    v.type.toLowerCase() == 'particulier' ? _T.emerald : _T.amber,
                    v.type.toLowerCase() == 'particulier'
                        ? Icons.person_rounded
                        : Icons.business_center_rounded,
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: _T.textSec, size: 18),
                    onPressed: () => Navigator.pop(context),
                    splashRadius: 16, padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ]),
              ),

              // Body
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(children: [
                  Row(children: [
                    Expanded(child: _detailTile('Année', v.year.toString(),
                        Icons.calendar_today_rounded, _T.primary)),
                    Expanded(child: _detailTile('Carburant', _cap(v.fuelType),
                        _fuelIcon(v.fuelType), _fuelColor(v.fuelType))),
                    Expanded(child: _detailTile('Client',
                        v.clientName ?? 'Non assigné',
                        Icons.person_rounded, _T.violet)),
                  ]),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _T.surface2,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _T.border),
                    ),
                    child: Row(children: [
                      Expanded(child: _detailTile('Kilométrage total',
                          '${v.totalKm?.toStringAsFixed(0) ?? "0"} km',
                          Icons.speed_rounded, _T.primary)),
                      Expanded(child: _detailTile('Km quotidien',
                          '${v.dailyKm?.toStringAsFixed(0) ?? "0"} km/j',
                          Icons.timeline_rounded, _T.emerald)),
                    ]),
                  ),
                ]),
              ),

              // Footer
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: _T.border))),
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _T.textSec,
                      side: const BorderSide(color: _T.border),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Fermer'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _prepareEdit(v);
                    },
                    icon: const Icon(Icons.edit_rounded, size: 15),
                    label: const Text('Modifier'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _T.primary, foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _detailTile(String label, String value, IconData icon, Color color) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: _T.textSec, fontSize: 11)),
      ]),
      const SizedBox(height: 4),
      Text(value,
          style: const TextStyle(color: _T.textPri, fontSize: 13,
              fontWeight: FontWeight.w700)),
    ]);
  }

  // ─── Add / Edit dialog ────────────────────────────────────────────────────

  void _prepareEdit(Vehicle v) {
    _selectedVehicle = v;
    _brandCtrl.text        = v.brand;
    _modelCtrl.text        = v.model;
    _yearCtrl.text         = v.year.toString();
    _registrationCtrl.text = v.registrationNumber;
    _totalKmCtrl.text      = v.totalKm?.toString() ?? '0';
    _dailyKmCtrl.text      = v.dailyKm?.toString() ?? '0';
    _selectedFuelType      = _cap(v.fuelType);
    _selectedUserId        = v.userId;
    _selectedType          = _cap(v.type);
    _showAddEditDialog(context, isEdit: true);
  }

  void _showAddEditDialog(BuildContext context, {bool isEdit = false}) {
    if (isEdit && _selectedVehicle == null) return;
    if (!isEdit) _resetForm();

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDS) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Container(
            width: 620,
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.88),
            decoration: BoxDecoration(
              color: _T.bg,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.14),
                  blurRadius: 48, offset: const Offset(0, 16))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(children: [
                // Header
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 18, 14, 18),
                  decoration: const BoxDecoration(
                    color: _T.surface,
                    border: Border(bottom: BorderSide(color: _T.border)),
                  ),
                  child: Row(children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: isEdit ? _T.amber.withOpacity(0.1) : _T.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isEdit ? Icons.edit_rounded : Icons.add_rounded,
                        color: isEdit ? _T.amber : _T.primary, size: 18,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(isEdit ? 'Modifier le véhicule' : 'Nouveau véhicule',
                            style: const TextStyle(color: _T.textPri, fontSize: 16,
                                fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                        Text(isEdit
                            ? _selectedVehicle!.registrationNumber
                            : 'Renseignez les informations du véhicule',
                            style: const TextStyle(color: _T.textSec, fontSize: 12)),
                      ]),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: _T.textSec, size: 18),
                      onPressed: () => Navigator.pop(ctx),
                      splashRadius: 16, padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ]),
                ),

                // Form body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(22),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Row 1: Marque + Modèle
                          Row(children: [
                            Expanded(child: _formField(_brandCtrl, 'Marque *',
                                hint: 'Ex: Renault',
                                icon: Icons.directions_car_rounded, required: true)),
                            const SizedBox(width: 14),
                            Expanded(child: _formField(_modelCtrl, 'Modèle *',
                                hint: 'Ex: Clio',
                                icon: Icons.model_training_rounded, required: true)),
                          ]),
                          const SizedBox(height: 14),
                          // Row 2: Immat + Année
                          Row(children: [
                            Expanded(child: _formField(_registrationCtrl,
                                'Immatriculation *',
                                hint: '123 TU 4567',
                                icon: Icons.badge_rounded, required: true)),
                            const SizedBox(width: 14),
                            SizedBox(width: 120, child: _formField(_yearCtrl, 'Année *',
                                hint: '2020',
                                icon: Icons.calendar_today_rounded,
                                required: true,
                                keyboard: TextInputType.number)),
                          ]),
                          const SizedBox(height: 14),
                          // Row 3: Km total + Km quotidien
                          Row(children: [
                            Expanded(child: _formField(_totalKmCtrl, 'Kilométrage total',
                                hint: '75000',
                                icon: Icons.speed_rounded,
                                keyboard: TextInputType.number)),
                            const SizedBox(width: 14),
                            Expanded(child: _formField(_dailyKmCtrl, 'Km / jour',
                                hint: '50',
                                icon: Icons.timeline_rounded,
                                keyboard: TextInputType.number)),
                          ]),
                          const SizedBox(height: 14),
                          // Row 4: Carburant + Type
                          Row(children: [
                            Expanded(child: _formDropdown<String>(
                              label: 'Carburant',
                              icon: Icons.local_gas_station_rounded,
                              value: _selectedFuelType,
                              items: _fuelTypes,
                              itemLabel: (v) => v,
                              onChanged: (v) => setDS(() => _selectedFuelType = v!),
                            )),
                            const SizedBox(width: 14),
                            Expanded(child: _formDropdown<String>(
                              label: 'Type de véhicule',
                              icon: Icons.category_rounded,
                              value: _selectedType == 'Tous' ? 'Particulier' : _selectedType,
                              items: ['Particulier', 'Professionnel'],
                              itemLabel: (v) => v,
                              onChanged: (v) => setDS(() => _selectedType = v!),
                            )),
                          ]),
                          const SizedBox(height: 14),
                          // Client
                          _formDropdown<String>(
                            label: 'Client propriétaire',
                            icon: Icons.person_rounded,
                            value: _selectedUserId.isEmpty ? null : _selectedUserId,
                            items: _clients.map((c) => c['id'] as String).toList(),
                            itemLabel: (id) => _clients
                                .firstWhere((c) => c['id'] == id,
                                    orElse: () => {'name': id})['name'] as String,
                            onChanged: (v) => setDS(() => _selectedUserId = v ?? ''),
                            nullable: true,
                            nullLabel: 'Non assigné',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Footer
                Container(
                  padding: const EdgeInsets.fromLTRB(22, 12, 22, 16),
                  decoration: const BoxDecoration(
                    color: _T.surface,
                    border: Border(top: BorderSide(color: _T.border)),
                  ),
                  child: Row(children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _T.textSec,
                        side: const BorderSide(color: _T.border),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Annuler'),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () => _saveVehicle(isEdit),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isEdit ? _T.amber : _T.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(isEdit ? Icons.save_rounded : Icons.add_rounded,
                            size: 16),
                        const SizedBox(width: 8),
                        Text(isEdit ? 'Enregistrer les modifications' : 'Créer le véhicule',
                            style: const TextStyle(fontWeight: FontWeight.w700)),
                      ]),
                    ),
                  ]),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Delete dialog ────────────────────────────────────────────────────────

  void _showDeleteDialog(BuildContext context, String immat) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _T.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _T.border),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1),
                blurRadius: 30, offset: const Offset(0, 10))],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: _T.rose.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.delete_outline_rounded,
                  color: _T.rose, size: 24),
            ),
            const SizedBox(height: 16),
            const Text('Supprimer le véhicule',
                style: TextStyle(color: _T.textPri, fontSize: 16,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              'Voulez-vous supprimer le véhicule $immat ?\nCette action est irréversible.',
              style: const TextStyle(color: _T.textSec, fontSize: 13, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _T.textSec,
                    side: const BorderSide(color: _T.border),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Annuler'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _deleteVehicle(immat);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _T.rose,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Supprimer',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  // ─── Form helpers ─────────────────────────────────────────────────────────

  Widget _formField(
    TextEditingController ctrl,
    String label, {
    String? hint,
    IconData? icon,
    bool required = false,
    TextInputType? keyboard,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboard,
      style: const TextStyle(color: _T.textPri, fontSize: 13.5),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'Champ requis' : null
          : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _T.textSec, fontSize: 13),
        hintText: hint,
        hintStyle: const TextStyle(color: _T.textHint, fontSize: 13),
        prefixIcon: icon != null
            ? Icon(icon, size: 17, color: _T.textHint)
            : null,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        filled: true, fillColor: _T.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _T.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _T.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _T.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _T.rose)),
      ),
    );
  }

  Widget _formDropdown<T>({
    required String label,
    required IconData icon,
    required T? value,
    required List<T> items,
    required String Function(T) itemLabel,
    required void Function(T?) onChanged,
    bool nullable = false,
    String nullLabel = 'Sélectionner',
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      style: const TextStyle(color: _T.textPri, fontSize: 13.5),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _T.textSec, fontSize: 13),
        prefixIcon: Icon(icon, size: 17, color: _T.textHint),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        filled: true, fillColor: _T.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _T.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _T.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _T.primary, width: 1.5)),
      ),
      items: [
        if (nullable)
          DropdownMenuItem<T>(value: null, child: Text(nullLabel,
              style: const TextStyle(color: _T.textHint))),
        ...items.map((i) => DropdownMenuItem<T>(
            value: i,
            child: Text(itemLabel(i)))),
      ],
      onChanged: onChanged,
    );
  }
}