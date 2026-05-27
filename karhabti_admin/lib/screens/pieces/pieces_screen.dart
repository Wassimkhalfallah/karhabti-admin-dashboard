// ignore_for_file: unused_field, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:karhabti_admin/models/piece_models.dart';
import 'package:karhabti_admin/services/pieces_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:data_table_2/data_table_2.dart';

// ═══════════════════════════════════════════════════════════════
//  DESIGN TOKENS — Palette apaisée, propre & contemporaine
// ═══════════════════════════════════════════════════════════════
class _L {
  // Fonds
  static const bg         = Color(0xFFF3F6FB);   // bleu-gris très doux
  static const surface    = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF0F5FF);   // indigo poudré léger
  static const border     = Color(0xFFE4EAF4);

  // Accents principaux
  static const primary    = Color(0xFF4C6EF5);   // indigo lumineux
  static const primaryBg  = Color(0xFFEEF2FF);
  static const primaryMid = Color(0xFFBAC8FF);

  // Sémantiques
  static const success    = Color(0xFF12B886);
  static const successBg  = Color(0xFFE6FCF5);
  static const danger     = Color(0xFFFA5252);
  static const dangerBg   = Color(0xFFFFF5F5);
  static const warning    = Color(0xFFFD7E14);
  static const warningBg  = Color(0xFFFFF3E0);
  static const info       = Color(0xFF228BE6);
  static const infoBg     = Color(0xFFE7F5FF);

  // Texte
  static const textPri    = Color(0xFF1A1F36);
  static const textSec    = Color(0xFF6B7A99);
  static const textMuted  = Color(0xFFA8B4CC);

  // Tabs par catégorie (palette harmonieuse)
  static const tabColors = [
    Color(0xFF4C6EF5), // Pneus      — indigo
    Color(0xFF228BE6), // Vidange    — bleu
    Color(0xFF7950F2), // Amortisseurs — violet
    Color(0xFFF59F00), // Batteries  — ambre
    Color(0xFF12B886), // Embrayages — émeraude
    Color(0xFFE03131), // Freins     — rouge
    Color(0xFF0CA678), // Courroies  — jade
  ];
}

// ═══════════════════════════════════════════════════════════════
//  STYLES partagés
// ═══════════════════════════════════════════════════════════════
class _S {
  static InputDecoration field(String label, {
    String? hint, IconData? icon, String? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: _L.textSec, fontSize: 13),
      hintStyle: const TextStyle(color: _L.textMuted, fontSize: 13),
      prefixIcon: icon != null ? Icon(icon, size: 16, color: _L.textMuted) : null,
      suffixText: suffix,
      suffixStyle: const TextStyle(color: _L.textSec, fontSize: 13),
      filled: true,
      fillColor: _L.surfaceAlt,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: _L.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: _L.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: _L.primary, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: _L.danger),
      ),
      isDense: true,
    );
  }

  static BoxDecoration card({double radius = 16}) => BoxDecoration(
    color: _L.surface,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: _L.border),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF4C6EF5).withOpacity(0.04),
        blurRadius: 20,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: Colors.black.withOpacity(0.03),
        blurRadius: 6,
        offset: const Offset(0, 1),
      ),
    ],
  );
}

// ═══════════════════════════════════════════════════════════════
//  SHIMMER LOADING WIDGET
// ═══════════════════════════════════════════════════════════════
class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;
  const _ShimmerBox({required this.width, required this.height, this.radius = 8});

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat();
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          gradient: LinearGradient(
            begin: Alignment(-1.5 + _anim.value * 3, 0),
            end: Alignment(-0.5 + _anim.value * 3, 0),
            colors: const [
              Color(0xFFEBF0FB),
              Color(0xFFF7FAFF),
              Color(0xFFEBF0FB),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  SCREEN
// ═══════════════════════════════════════════════════════════════
class PiecesScreen extends StatefulWidget {
  const PiecesScreen({super.key});

  @override
  State<PiecesScreen> createState() => _PiecesScreenState();
}

class _PiecesScreenState extends State<PiecesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  TabController? _vidangeTabController;
  final PiecesService _piecesService = PiecesService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  final Map<String, dynamic> _filters = {};
  String _sortColumn = 'reference';
  bool _sortAscending = true;

  // Form controllers
  final _referenceCtrl   = TextEditingController();
  final _marqueCtrl      = TextEditingController();
  final _prixCtrl        = TextEditingController();
  final _paysCtrl        = TextEditingController();
  final _dimensionCtrl   = TextEditingController();
  final _typeCtrl        = TextEditingController();
  final _qualiteCtrl     = TextEditingController();
  final _positionCtrl    = TextEditingController();
  final _viscositeCtrl   = TextEditingController();
  final _poidsCtrl       = TextEditingController();
  final _nomCtrl         = TextEditingController();
  final _capaciteCtrl    = TextEditingController();
  final _demarrageCtrl   = TextEditingController();
  final _diametreCtrl    = TextEditingController();
  final _nombreDentsCtrl = TextEditingController();
  final _pompeCtrl       = TextEditingController();

  final List<String> _tabTitles = [
    'Pneus', 'Vidange', 'Amortisseurs',
    'Batteries', 'Embrayages', 'Freins', 'Courroies',
  ];
  static const List<IconData> _tabIcons = [
    Icons.tire_repair_rounded,
    Icons.oil_barrel_rounded,
    Icons.directions_car_rounded,
    Icons.battery_charging_full_rounded,
    Icons.settings_rounded,
    Icons.disc_full_rounded,
    Icons.cable_rounded,
  ];

  List<Pneu>               _pneus               = [];
  List<HuileMoteur>        _huileMoteur         = [];
  List<Filtre>             _filtres             = [];
  List<EauRefroidissement> _eauRefroidissement  = [];
  List<Amortisseur>        _amortisseurs        = [];
  List<Batterie>           _batteries           = [];
  List<Embrayage>          _embrayages          = [];
  List<Frein>              _freins              = [];
  List<Courroie>           _courroies           = [];

  // Animations
  late AnimationController _fadeCtrl;
  late Animation<double>   _fadeAnim;
  late AnimationController _headerCtrl;
  late Animation<double>   _headerAnim;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabTitles.length, vsync: this);
    _vidangeTabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() { if (!_tabController.indexIsChanging) setState(() {}); });
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
      _loadAllData();
    });

    _fadeCtrl   = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim   = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic);
    _headerCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _headerAnim = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOutQuart);

    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _vidangeTabController?.dispose();
    _searchController.dispose();
    _fadeCtrl.dispose();
    _headerCtrl.dispose();
    for (final c in [
      _referenceCtrl, _marqueCtrl, _prixCtrl, _paysCtrl,
      _dimensionCtrl, _typeCtrl, _qualiteCtrl, _positionCtrl,
      _viscositeCtrl, _poidsCtrl, _nomCtrl, _capaciteCtrl,
      _demarrageCtrl, _diametreCtrl, _nombreDentsCtrl, _pompeCtrl,
    ]) { c.dispose(); }
    super.dispose();
  }

  // ── Chargement ──────────────────────────────────────────────
  Future<void> _loadAllData() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    _fadeCtrl.reset();
    _headerCtrl.reset();
    try {
      await Future.wait([
        _load(() async => setState(() async => _pneus              = await _piecesService.getPneus(orderBy: _sortColumn, ascending: _sortAscending, filters: _searchQuery.isNotEmpty ? {'name': _searchQuery, ..._filters} : _filters))),
        _load(() async => setState(() async => _huileMoteur        = await _piecesService.getHuileMoteurs(orderBy: _sortColumn, ascending: _sortAscending, filters: _searchQuery.isNotEmpty ? {'name': _searchQuery, ..._filters} : _filters))),
        _load(() async => setState(() async => _filtres            = await _piecesService.getFiltres(orderBy: _sortColumn, ascending: _sortAscending, filters: _searchQuery.isNotEmpty ? {'name': _searchQuery, ..._filters} : _filters))),
        _load(() async => setState(() async => _eauRefroidissement = await _piecesService.getEauRefroidissements(orderBy: _sortColumn, ascending: _sortAscending, filters: _searchQuery.isNotEmpty ? {'name': _searchQuery, ..._filters} : _filters))),
        _load(() async => setState(() async => _amortisseurs       = await _piecesService.getAmortisseurs(orderBy: _sortColumn, ascending: _sortAscending, filters: _searchQuery.isNotEmpty ? {'name': _searchQuery, ..._filters} : _filters))),
        _load(() async => setState(() async => _batteries          = await _piecesService.getBatteries(orderBy: _sortColumn, ascending: _sortAscending, filters: _searchQuery.isNotEmpty ? {'name': _searchQuery, ..._filters} : _filters))),
        _load(() async => setState(() async => _embrayages         = await _piecesService.getEmbrayages(orderBy: _sortColumn, ascending: _sortAscending, filters: _searchQuery.isNotEmpty ? {'name': _searchQuery, ..._filters} : _filters))),
        _load(() async => setState(() async => _freins             = await _piecesService.getFreins(orderBy: _sortColumn, ascending: _sortAscending, filters: _searchQuery.isNotEmpty ? {'name': _searchQuery, ..._filters} : _filters))),
        _load(() async => setState(() async => _courroies          = await _piecesService.getCourroies(orderBy: _sortColumn, ascending: _sortAscending, filters: _searchQuery.isNotEmpty ? {'name': _searchQuery, ..._filters} : _filters))),
      ]);
      setState(() => _isLoading = false);
      _headerCtrl.forward();
      _fadeCtrl.forward();
    } catch (e) {
      setState(() { _isLoading = false; _errorMessage = e.toString(); });
    }
  }

  Future<void> _load(Future<void> Function() fn) async { try { await fn(); } catch (_) {} }

  // ════════════════════════ BUILD ═════════════════════════════
  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildLoadingState();
    if (_errorMessage != null) return _buildErrorState();
    return _buildContent();
  }

  // ── Loading shimmer ──────────────────────────────────────────
  Widget _buildLoadingState() {
    return Scaffold(
      backgroundColor: _L.bg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header shimmer
          Container(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
            color: _L.surface,
            child: Row(children: [
              _ShimmerBox(width: 48, height: 48, radius: 14),
              const SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _ShimmerBox(width: 180, height: 18, radius: 6),
                const SizedBox(height: 6),
                _ShimmerBox(width: 120, height: 12, radius: 4),
              ]),
              const Spacer(),
              _ShimmerBox(width: 90, height: 34, radius: 10),
            ]),
          ),
          // Tab shimmer
          Container(
            color: _L.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: List.generate(7, (i) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _ShimmerBox(width: 80 + i * 4.0, height: 32, radius: 20),
              )),
            ),
          ),
          // Toolbar shimmer
          Container(
            color: _L.surface,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Row(children: [
              _ShimmerBox(width: 260, height: 38, radius: 11),
              const SizedBox(width: 10),
              _ShimmerBox(width: 80, height: 34, radius: 9),
              const SizedBox(width: 6),
              _ShimmerBox(width: 70, height: 34, radius: 9),
            ]),
          ),
          // Table shimmer
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: _S.card(),
                child: Column(
                  children: [
                    Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: _L.surfaceAlt,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: List.generate(6, (i) => Padding(
                          padding: const EdgeInsets.only(right: 40),
                          child: _ShimmerBox(width: 60 + i * 8.0, height: 12, radius: 4),
                        )),
                      ),
                    ),
                    ...List.generate(8, (i) => Container(
                      height: 56,
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: _L.border.withOpacity(0.5))),
                        color: i.isEven ? _L.surface : _L.bg.withOpacity(0.4),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          _ShimmerBox(width: 40, height: 40, radius: 10),
                          const SizedBox(width: 16),
                          _ShimmerBox(width: 80 + (i * 7 % 40).toDouble(), height: 13, radius: 4),
                          const SizedBox(width: 40),
                          _ShimmerBox(width: 60 + (i * 5 % 30).toDouble(), height: 13, radius: 4),
                          const Spacer(),
                          _ShimmerBox(width: 60, height: 24, radius: 6),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Error state ──────────────────────────────────────────────
  Widget _buildErrorState() {
    return Scaffold(
      backgroundColor: _L.bg,
      body: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          builder: (_, v, child) => Opacity(
            opacity: v,
            child: Transform.translate(offset: Offset(0, 20 * (1 - v)), child: child),
          ),
          child: Container(
            padding: const EdgeInsets.all(32),
            margin: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: _S.card(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: const BoxDecoration(color: _L.dangerBg, shape: BoxShape.circle),
                  child: const Icon(Icons.cloud_off_rounded, color: _L.danger, size: 34),
                ),
                const SizedBox(height: 18),
                const Text('Connexion impossible',
                    style: TextStyle(color: _L.textPri, fontWeight: FontWeight.w800, fontSize: 17)),
                const SizedBox(height: 8),
                Text(_errorMessage!,
                    style: const TextStyle(color: _L.textSec, fontSize: 13, height: 1.5),
                    textAlign: TextAlign.center),
                const SizedBox(height: 24),
                _PressableButton(
                  onTap: _loadAllData,
                  color: _L.primary,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh_rounded, size: 16, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Réessayer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Main content ─────────────────────────────────────────────
  Widget _buildContent() {
    return Scaffold(
      backgroundColor: _L.bg,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            _buildTabBar(),
            _buildToolbar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const ClampingScrollPhysics(),
                children: [
                  _buildPneusTable(),
                  _buildVidangeTabView(),
                  _buildAmortisseursTable(),
                  _buildBatteriesTable(),
                  _buildEmbrayagesTable(),
                  _buildFreinsTable(),
                  _buildCourroiesTable(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  HEADER modernisé
  // ══════════════════════════════════════════════════════════════
  Widget _buildHeader() {
    final idx = _tabController.index;
    final color = _L.tabColors[idx];
    final counts = [
      _pneus.length,
      _huileMoteur.length + _filtres.length + _eauRefroidissement.length,
      _amortisseurs.length, _batteries.length,
      _embrayages.length, _freins.length, _courroies.length,
    ];
    final total = counts.fold(0, (a, b) => a + b);

    return AnimatedBuilder(
      animation: _headerAnim,
      builder: (_, child) => Opacity(
        opacity: _headerAnim.value,
        child: Transform.translate(
          offset: Offset(0, -8 * (1 - _headerAnim.value)),
          child: child,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        decoration: BoxDecoration(
          color: _L.surface,
          border: const Border(bottom: BorderSide(color: _L.border)),
          boxShadow: [
            BoxShadow(
              color: _L.primary.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icône animée
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.15), color.withOpacity(0.07)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withOpacity(0.22)),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
                  child: child,
                ),
                child: Icon(_tabIcons[idx], color: color, size: 22, key: ValueKey(idx)),
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Gestion des Pièces',
                    style: TextStyle(
                      color: _L.textPri,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    )),
                const SizedBox(height: 2),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween(begin: const Offset(0.1, 0), end: Offset.zero)
                          .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
                      child: child,
                    ),
                  ),
                  child: Text(
                    '${counts[idx]} ${_tabTitles[idx].toLowerCase()} · $total pièces au total',
                    key: ValueKey(idx),
                    style: const TextStyle(color: _L.textSec, fontSize: 12),
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Stat pills
            _statPill(Icons.inventory_2_outlined, '$total pièces', _L.primary),
            const SizedBox(width: 8),
            _statPill(Icons.category_outlined, '${_tabTitles.length} catégories', _L.info),
            const SizedBox(width: 14),
            // Bouton Ajouter avec animation
            _PressableButton(
              onTap: () => _showAddEditPieceDialog(),
              color: _L.primary,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, size: 17, color: Colors.white),
                  SizedBox(width: 6),
                  Text('Ajouter', style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statPill(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  TAB BAR — pill indicator animé
  // ══════════════════════════════════════════════════════════════
  Widget _buildTabBar() {
    return Container(
      color: _L.surface,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: _PillTabIndicator(
          color: _L.tabColors[_tabController.index],
          radius: 22,
        ),
        labelColor: _L.tabColors[_tabController.index],
        unselectedLabelColor: _L.textSec,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12.5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        tabAlignment: TabAlignment.start,
        tabs: _tabTitles.asMap().entries.map((e) {
          final i = e.key;
          final isActive = _tabController.index == i;
          final tabColor = _L.tabColors[i];
          return Tab(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_tabIcons[i],
                      size: 14,
                      color: isActive ? tabColor : _L.textMuted),
                  const SizedBox(width: 6),
                  Text(e.value),
                  const SizedBox(width: 5),
                  // Badge count
                  _CountBadge(
                    count: _getCountForTab(i),
                    color: tabColor,
                    active: isActive,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  int _getCountForTab(int i) {
    switch (i) {
      case 0: return _pneus.length;
      case 1: return _huileMoteur.length + _filtres.length + _eauRefroidissement.length;
      case 2: return _amortisseurs.length;
      case 3: return _batteries.length;
      case 4: return _embrayages.length;
      case 5: return _freins.length;
      case 6: return _courroies.length;
      default: return 0;
    }
  }

  // ══════════════════════════════════════════════════════════════
  //  TOOLBAR
  // ══════════════════════════════════════════════════════════════
  Widget _buildToolbar() {
    final idx = _tabController.index;
    final color = _L.tabColors[idx];
    final count = _getCountForTab(idx);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      decoration: const BoxDecoration(
        color: _L.surface,
        border: Border(bottom: BorderSide(color: _L.border)),
      ),
      child: Row(
        children: [
          // Champ recherche
          SizedBox(
            width: 270,
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: _L.textPri, fontSize: 13),
              decoration: _S.field('Rechercher une pièce…', icon: Icons.search_rounded),
            ),
          ),
          const SizedBox(width: 10),
          _toolbarBtn(Icons.filter_list_rounded, 'Filtrer', _L.primary, _showFilterDialog),
          const SizedBox(width: 6),
          _toolbarBtn(Icons.swap_vert_rounded, 'Trier', _L.info, _showSortDialog),
          const SizedBox(width: 6),
          _toolbarBtn(Icons.file_download_outlined, 'Exporter', _L.success, _exportData),
          const Spacer(),
          // Compteur animé
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: ScaleTransition(
                scale: Tween(begin: 0.85, end: 1.0).animate(
                    CurvedAnimation(parent: anim, curve: Curves.easeOutBack)),
                child: child,
              ),
            ),
            child: Container(
              key: ValueKey('$idx-$count'),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.07),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withOpacity(0.18)),
              ),
              child: Text(
                '$count résultat${count != 1 ? 's' : ''}',
                style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toolbarBtn(IconData icon, String label, Color color, VoidCallback onTap) {
    return Tooltip(
      message: label,
      child: _PressableButton(
        onTap: onTap,
        color: color,
        outlined: true,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
            Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  TABLE GÉNÉRIQUE
  // ══════════════════════════════════════════════════════════════
  Widget _tableContainer({
    required List<DataColumn2> columns,
    required List<DataRow2> rows,
    required String emptyLabel,
    required String emptyAddLabel,
    required int tabIndex,
  }) {
    final color = _L.tabColors[tabIndex];

    if (rows.isEmpty) {
      return _emptyState(icon: _tabIcons[tabIndex], color: color,
          label: emptyLabel, addLabel: emptyAddLabel);
    }

    return Container(
      margin: const EdgeInsets.all(18),
      decoration: _S.card(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: DataTable2(
          columnSpacing: 16,
          horizontalMargin: 18,
          minWidth: 700,
          headingRowColor: WidgetStateProperty.all(_L.surfaceAlt),
          headingRowHeight: 44,
          dataRowHeight: 58,
          dividerThickness: 0,
          border: TableBorder(
            horizontalInside: BorderSide(color: _L.border.withOpacity(0.7), width: 1),
          ),
          dataRowColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return _L.primary.withOpacity(0.035);
            }
            return null;
          }),
          sortColumnIndex: null,
          columns: columns,
          rows: rows,
        ),
      ),
    );
  }

  Widget _emptyState({
    required IconData icon, required Color color,
    required String label, required String addLabel,
  }) {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        builder: (_, v, child) => Opacity(
          opacity: v,
          child: Transform.translate(offset: Offset(0, 16 * (1 - v)), child: child),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 44),
          margin: const EdgeInsets.all(40),
          constraints: const BoxConstraints(maxWidth: 380),
          decoration: _S.card(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [color.withOpacity(0.12), color.withOpacity(0.04)],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withOpacity(0.12)),
                ),
                child: Icon(icon, size: 36, color: color),
              ),
              const SizedBox(height: 20),
              Text(label,
                  style: const TextStyle(color: _L.textPri, fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: 7),
              const Text('Aucune pièce de ce type n\'a encore été ajoutée.',
                  style: TextStyle(color: _L.textSec, fontSize: 13, height: 1.5),
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              _PressableButton(
                onTap: () => _showAddEditPieceDialog(),
                color: color,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                    const SizedBox(width: 7),
                    Text(addLabel, style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Colonnes ──────────────────────────────────────────────────
  DataColumn2 _col(String label, {
    bool sortable = false, String? sortKey,
    ColumnSize size = ColumnSize.M, bool numeric = false,
  }) {
    return DataColumn2(
      label: Text(label.toUpperCase(),
          style: const TextStyle(
            color: _L.textMuted,
            fontWeight: FontWeight.w700,
            fontSize: 10.5,
            letterSpacing: 0.7,
          )),
      size: size,
      numeric: numeric,
      onSort: sortable && sortKey != null
          ? (_, asc) => _sortData(sortKey, asc)
          : null,
    );
  }

  // ── Cellules ──────────────────────────────────────────────────
  DataCell _textCell(String text, {bool bold = false, Color? color}) => DataCell(
    Text(text,
        style: TextStyle(
          color: color ?? _L.textPri,
          fontSize: 13,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          letterSpacing: bold ? -0.2 : 0,
        )),
  );

  DataCell _priceCell(double prix) => DataCell(
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: _L.successBg,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: _L.success.withOpacity(0.18)),
      ),
      child: Text('${prix.toStringAsFixed(2)} DT',
          style: const TextStyle(
            color: _L.success,
            fontWeight: FontWeight.w700,
            fontSize: 12,
            letterSpacing: 0.1,
          )),
    ),
  );

  DataCell _badgeCell(String? text) => DataCell(
    text != null && text != 'N/A'
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: _L.primaryBg,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: _L.primaryMid.withOpacity(0.35)),
            ),
            child: Text(text,
                style: const TextStyle(
                    color: _L.primary, fontSize: 11, fontWeight: FontWeight.w600)),
          )
        : Text('—', style: const TextStyle(color: _L.textMuted, fontSize: 13)),
  );

  DataCell _actionsCell(Piece piece) => DataCell(
    Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _actionBtn(Icons.edit_rounded, _L.primary,
            () => _showAddEditPieceDialog(piece: piece), 'Modifier'),
        const SizedBox(width: 6),
        _actionBtn(Icons.delete_rounded, _L.danger,
            () => _showDeleteConfirmationDialog(piece), 'Supprimer'),
      ],
    ),
  );

  Widget _actionBtn(IconData icon, Color color, VoidCallback onTap, String tooltip) {
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 400),
      child: _PressableButton(
        onTap: onTap,
        color: color,
        outlined: true,
        compact: true,
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }

  Widget _buildImageCell(String imageUrl, {double size = 42}) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: _L.border),
        color: _L.surfaceAlt,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: imageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => const Center(
                  child: SizedBox(width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 1.5, color: _L.primary)),
                ),
                errorWidget: (_, __, ___) =>
                    const Icon(Icons.image_not_supported_outlined, color: _L.textMuted, size: 16),
              )
            : const Icon(Icons.image_not_supported_outlined, color: _L.textMuted, size: 16),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  TABLES PAR CATÉGORIE
  // ══════════════════════════════════════════════════════════════

  Widget _buildPneusTable() => _tableContainer(
    tabIndex: 0,
    emptyLabel: 'Aucun pneu trouvé',
    emptyAddLabel: 'Ajouter un pneu',
    columns: [
      _col('', size: ColumnSize.S),
      _col('Référence', sortable: true, sortKey: 'reference', size: ColumnSize.L),
      _col('Marque', sortable: true, sortKey: 'marque'),
      _col('Dimension'),
      _col('Type'),
      _col('Prix', sortable: true, sortKey: 'prix'),
      _col('Actions', size: ColumnSize.S),
    ],
    rows: _pneus.map((p) => DataRow2(cells: [
      DataCell(_buildImageCell(p.imageUrl)),
      _textCell(p.reference, bold: true),
      _textCell(p.marque),
      _badgeCell(p.dimension ?? 'N/A'),
      _badgeCell(p.type ?? 'N/A'),
      _priceCell(p.prix),
      _actionsCell(p),
    ])).toList(),
  );

  Widget _buildVidangeTabView() {
    return Column(
      children: [
        Container(
          color: _L.surfaceAlt,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: TabBar(
            controller: _vidangeTabController,
            isScrollable: true,
            indicatorSize: TabBarIndicatorSize.label,
            indicator: UnderlineTabIndicator(
              borderSide: const BorderSide(color: _L.info, width: 2.5),
              borderRadius: BorderRadius.circular(2),
            ),
            labelColor: _L.info,
            unselectedLabelColor: _L.textSec,
            labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
            tabAlignment: TabAlignment.start,
            tabs: const [
              Tab(child: Row(children: [
                Icon(Icons.oil_barrel_rounded, size: 14), SizedBox(width: 5), Text('Huile Moteur')])),
              Tab(child: Row(children: [
                Icon(Icons.filter_alt_outlined, size: 14), SizedBox(width: 5), Text('Filtres')])),
              Tab(child: Row(children: [
                Icon(Icons.water_drop_outlined, size: 14), SizedBox(width: 5), Text('Eau de Refroidissement')])),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _vidangeTabController,
            children: [
              _buildHuileMoteurTable(),
              _buildFiltresTable(),
              _buildEauRefroidissementTable(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHuileMoteurTable() => _tableContainer(
    tabIndex: 1,
    emptyLabel: 'Aucune huile moteur trouvée',
    emptyAddLabel: 'Ajouter une huile moteur',
    columns: [
      _col('', size: ColumnSize.S),
      _col('Specifications', sortable: true, sortKey: 'reference', size: ColumnSize.L),
      _col('Marque', sortable: true, sortKey: 'marque'),
      _col('Type'),
      _col('Viscosité'),
      _col('Contenance'),
      _col('Origine'),
      _col('Prix', sortable: true, sortKey: 'prix'),
      _col('Actions', size: ColumnSize.S),
    ],
    rows: _huileMoteur.map((h) => DataRow2(cells: [
      DataCell(_buildImageCell(h.imageUrl)),
      _textCell(h.reference, bold: true),
      _textCell(h.marque),
      _badgeCell(h.type ?? 'N/A'),
      _badgeCell(h.viscosite ?? 'N/A'),
      _textCell(h.poids != null ? '${h.poids} L' : '—', color: _L.textSec),
      _textCell(h.paysConstructeur ?? '—', color: _L.textSec),
      _priceCell(h.prix),
      _actionsCell(h),
    ])).toList(),
  );

  Widget _buildFiltresTable() => _tableContainer(
    tabIndex: 1,
    emptyLabel: 'Aucun filtre trouvé',
    emptyAddLabel: 'Ajouter un filtre',
    columns: [
      _col('', size: ColumnSize.S),
      _col('Spécifications', sortable: true, sortKey: 'reference', size: ColumnSize.L),
      _col('Marque', sortable: true, sortKey: 'marque'),
      _col('Nom'),
      _col('Prix', sortable: true, sortKey: 'prix'),
      _col('Actions', size: ColumnSize.S),
    ],
    rows: _filtres.map((f) => DataRow2(cells: [
      DataCell(_buildImageCell(f.imageUrl)),
      _textCell(f.reference, bold: true),
      _textCell(f.marque),
      _textCell(f.nom),
      _priceCell(f.prix),
      _actionsCell(f),
    ])).toList(),
  );

  Widget _buildEauRefroidissementTable() => _tableContainer(
    tabIndex: 1,
    emptyLabel: 'Aucune eau de refroidissement trouvée',
    emptyAddLabel: 'Ajouter une eau',
    columns: [
      _col('', size: ColumnSize.S),
      _col('Référence', sortable: true, sortKey: 'reference', size: ColumnSize.L),
      _col('Marque', sortable: true, sortKey: 'marque'),
      _col('Nom'), _col('Type'),
      _col('Prix', sortable: true, sortKey: 'prix'),
      _col('Actions', size: ColumnSize.S),
    ],
    rows: _eauRefroidissement.map((e) => DataRow2(cells: [
      DataCell(_buildImageCell(e.imageUrl)),
      _textCell(e.reference, bold: true),
      _textCell(e.marque), _textCell(e.nom),
      _badgeCell(e.type ?? 'N/A'),
      _priceCell(e.prix), _actionsCell(e),
    ])).toList(),
  );

  Widget _buildAmortisseursTable() => _tableContainer(
    tabIndex: 2,
    emptyLabel: 'Aucun amortisseur trouvé',
    emptyAddLabel: 'Ajouter un amortisseur',
    columns: [
      _col('', size: ColumnSize.S),
      _col('Référence', sortable: true, sortKey: 'reference', size: ColumnSize.L),
      _col('Marque', sortable: true, sortKey: 'marque'),
      _col('Pays d\'origine'),
      _col('Prix', sortable: true, sortKey: 'prix'),
      _col('Actions', size: ColumnSize.S),
    ],
    rows: _amortisseurs.map((a) => DataRow2(cells: [
      DataCell(_buildImageCell(a.imageUrl)),
      _textCell(a.reference, bold: true),
      _textCell(a.marque),
      _textCell(a.paysConstructeur ?? '—', color: _L.textSec),
      _priceCell(a.prix), _actionsCell(a),
    ])).toList(),
  );

  Widget _buildBatteriesTable() => _tableContainer(
    tabIndex: 3,
    emptyLabel: 'Aucune batterie trouvée',
    emptyAddLabel: 'Ajouter une batterie',
    columns: [
      _col('', size: ColumnSize.S),
      _col('Référence', sortable: true, sortKey: 'reference', size: ColumnSize.L),
      _col('Marque', sortable: true, sortKey: 'marque'),
      _col('Capacité'), _col('Démarrage'),
      _col('Prix', sortable: true, sortKey: 'prix'),
      _col('Actions', size: ColumnSize.S),
    ],
    rows: _batteries.map((b) => DataRow2(cells: [
      DataCell(_buildImageCell(b.imageUrl)),
      _textCell(b.reference, bold: true),
      _textCell(b.marque),
      _badgeCell(b.capacite ?? 'N/A'),
      _textCell(b.demarrage ?? '—', color: _L.textSec),
      _priceCell(b.prix), _actionsCell(b),
    ])).toList(),
  );

  Widget _buildEmbrayagesTable() => _tableContainer(
    tabIndex: 4,
    emptyLabel: 'Aucun embrayage trouvé',
    emptyAddLabel: 'Ajouter un embrayage',
    columns: [
      _col('', size: ColumnSize.S),
      _col('Référence', sortable: true, sortKey: 'reference', size: ColumnSize.L),
      _col('Marque', sortable: true, sortKey: 'marque'),
      _col('Diamètre'),
      _col('Prix', sortable: true, sortKey: 'prix'),
      _col('Actions', size: ColumnSize.S),
    ],
    rows: _embrayages.map((e) => DataRow2(cells: [
      DataCell(_buildImageCell(e.imageUrl)),
      _textCell(e.reference, bold: true),
      _textCell(e.marque),
      _badgeCell(e.diametre != null ? '${e.diametre} mm' : 'N/A'),
      _priceCell(e.prix), _actionsCell(e),
    ])).toList(),
  );

  Widget _buildFreinsTable() => _tableContainer(
    tabIndex: 5,
    emptyLabel: 'Aucun frein trouvé',
    emptyAddLabel: 'Ajouter un frein',
    columns: [
      _col('', size: ColumnSize.S),
      _col('Référence', sortable: true, sortKey: 'reference', size: ColumnSize.L),
      _col('Marque', sortable: true, sortKey: 'marque'),
      _col('Type'), _col('Position'),
      _col('Prix', sortable: true, sortKey: 'prix'),
      _col('Actions', size: ColumnSize.S),
    ],
    rows: _freins.map((f) => DataRow2(cells: [
      DataCell(_buildImageCell(f.imageUrl)),
      _textCell(f.reference, bold: true),
      _textCell(f.marque),
      _badgeCell(f.type ?? 'N/A'),
      _textCell(f.position ?? '—', color: _L.textSec),
      _priceCell(f.prix), _actionsCell(f),
    ])).toList(),
  );

  Widget _buildCourroiesTable() => _tableContainer(
    tabIndex: 6,
    emptyLabel: 'Aucune courroie trouvée',
    emptyAddLabel: 'Ajouter une courroie',
    columns: [
      _col('', size: ColumnSize.S),
      _col('Référence', sortable: true, sortKey: 'reference', size: ColumnSize.L),
      _col('Marque', sortable: true, sortKey: 'marque'),
      _col('Nbre dents'), _col('Pompe'),
      _col('Prix', sortable: true, sortKey: 'prix'),
      _col('Actions', size: ColumnSize.S),
    ],
    rows: _courroies.map((c) => DataRow2(cells: [
      DataCell(_buildImageCell(c.imageUrl)),
      _textCell(c.reference, bold: true),
      _textCell(c.marque),
      _badgeCell(c.nombreDents != null ? '${c.nombreDents}' : 'N/A'),
      _textCell(c.pompe ?? '—', color: _L.textSec),
      _priceCell(c.prix), _actionsCell(c),
    ])).toList(),
  );

  // ══════════════════════════════════════════════════════════════
  //  DIALOGS
  // ══════════════════════════════════════════════════════════════

  void _showFilterDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (_) => _AnimatedDialog(
        child: _StyledDialog(
          title: 'Filtrer les pièces',
          icon: Icons.filter_list_rounded,
          iconColor: _L.primary,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                style: const TextStyle(fontSize: 13, color: _L.textPri),
                decoration: _S.field('Marque', icon: Icons.business_outlined, hint: 'Ex : Michelin'),
                onChanged: (v) => _filters['marque'] = v,
              ),
              const SizedBox(height: 14),
              TextField(
                style: const TextStyle(fontSize: 13, color: _L.textPri),
                decoration: _S.field('Prix minimum', icon: Icons.attach_money_rounded, hint: 'Ex : 50'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (v) { if (v.isNotEmpty) _filters['prix_min'] = double.parse(v); },
              ),
              const SizedBox(height: 14),
              TextField(
                style: const TextStyle(fontSize: 13, color: _L.textPri),
                decoration: _S.field('Prix maximum', icon: Icons.attach_money_rounded, hint: 'Ex : 500'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (v) { if (v.isNotEmpty) _filters['prix_max'] = double.parse(v); },
              ),
            ],
          ),
          onConfirm: () { Navigator.pop(context); _loadAllData(); },
          confirmLabel: 'Appliquer',
        ),
      ),
    );
  }

  void _showSortDialog() {
    String tempCol = _sortColumn;
    bool tempAsc   = _sortAscending;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (_) => _AnimatedDialog(
        child: StatefulBuilder(
          builder: (ctx, setSt) => _StyledDialog(
            title: 'Trier les pièces',
            icon: Icons.swap_vert_rounded,
            iconColor: _L.info,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Colonne', style: TextStyle(
                    color: _L.textSec, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                const SizedBox(height: 10),
                ...[
                  ('reference', 'Référence', Icons.tag_rounded),
                  ('marque',    'Marque',    Icons.business_outlined),
                  ('prix',      'Prix',      Icons.attach_money_rounded),
                ].map((item) {
                  final isActive = tempCol == item.$1;
                  return GestureDetector(
                    onTap: () => setSt(() => tempCol = item.$1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      margin: const EdgeInsets.only(bottom: 7),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                      decoration: BoxDecoration(
                        color: isActive ? _L.primaryBg : _L.surfaceAlt,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isActive ? _L.primaryMid : _L.border),
                      ),
                      child: Row(
                        children: [
                          Icon(item.$3, size: 15,
                              color: isActive ? _L.primary : _L.textSec),
                          const SizedBox(width: 10),
                          Text(item.$2,
                              style: TextStyle(
                                color: isActive ? _L.primary : _L.textPri,
                                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                                fontSize: 13,
                              )),
                          if (isActive) ...[
                            const Spacer(),
                            const Icon(Icons.check_circle_rounded, size: 15, color: _L.primary),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                const Text('Ordre', style: TextStyle(
                    color: _L.textSec, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _orderToggle(Icons.arrow_upward_rounded, 'Croissant', tempAsc, () => setSt(() => tempAsc = true))),
                    const SizedBox(width: 8),
                    Expanded(child: _orderToggle(Icons.arrow_downward_rounded, 'Décroissant', !tempAsc, () => setSt(() => tempAsc = false))),
                  ],
                ),
              ],
            ),
            onConfirm: () {
              Navigator.pop(context);
              setState(() { _sortColumn = tempCol; _sortAscending = tempAsc; });
              _loadAllData();
            },
            confirmLabel: 'Appliquer',
          ),
        ),
      ),
    );
  }

  Widget _orderToggle(IconData icon, String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: active ? _L.infoBg : _L.surfaceAlt,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: active ? _L.info.withOpacity(0.4) : _L.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: active ? _L.info : _L.textSec),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(
              color: active ? _L.info : _L.textSec,
              fontWeight: active ? FontWeight.w700 : FontWeight.w400,
              fontSize: 12,
            )),
          ],
        ),
      ),
    );
  }

  void _showAddEditPieceDialog({Piece? piece}) {
    final pieceType = _getCurrentPieceType();
    final bool isEdit = piece != null;
    _resetFormFields();
    if (isEdit) _populateFormFields(piece);

    final idx    = _tabController.index;
    final vidIdx = _vidangeTabController?.index ?? 0;
    final suffixes    = ['pneu', 'vidange', 'amortisseur', 'batterie', 'embrayage', 'frein', 'courroie'];
    final vidSuffixes = ['huile moteur', 'filtre', 'eau de refroidissement'];
    final suffix = idx == 1 ? vidSuffixes[vidIdx] : suffixes[idx];
    final title  = '${isEdit ? 'Modifier' : 'Ajouter'} ${_article(suffix)} $suffix';

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (_) => _AnimatedDialog(
        child: _StyledDialog(
          title: title,
          icon: isEdit ? Icons.edit_rounded : Icons.add_rounded,
          iconColor: _L.primary,
          wide: true,
          content: _buildPieceForm(pieceType, isEdit),
          onConfirm: () {
            if (_validateForm()) {
              Navigator.pop(context);
              _savePiece(pieceType, isEdit ? piece.id : null);
            }
          },
          confirmLabel: isEdit ? 'Enregistrer' : 'Ajouter',
        ),
      ),
    );
  }

  String _article(String suffix) {
    final vowels = ['a', 'e', 'é', 'i', 'o', 'u'];
    if (vowels.contains(suffix[0].toLowerCase())) return "l'";
    return suffix == 'huile moteur' || suffix == 'eau de refroidissement' ? 'une ' : 'un ';
  }

  Widget _buildPieceForm(String pieceType, bool isEdit) {
    final commonFields = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isEdit) ...[
          GestureDetector(
            onTap: _uploadImage,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: _L.primaryBg,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: _L.primaryMid.withOpacity(0.4)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload_outlined, color: _L.primary, size: 22),
                  SizedBox(width: 10),
                  Text('Télécharger une image',
                      style: TextStyle(color: _L.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
        ],
        _formField(_referenceCtrl, 'Référence *', icon: Icons.tag_rounded),
        const SizedBox(height: 12),
        _formField(_marqueCtrl, 'Marque *', icon: Icons.business_outlined),
        const SizedBox(height: 12),
        _formField(_prixCtrl, 'Prix (DT) *',
            icon: Icons.attach_money_rounded, suffix: 'DT',
            number: true, decimal: true),
        const SizedBox(height: 12),
        _formField(_paysCtrl, 'Pays d\'origine', icon: Icons.flag_outlined),
        const SizedBox(height: 12),
      ],
    );

    Widget specificFields;
    switch (pieceType) {
      case 'Pneu':
        specificFields = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _formField(_dimensionCtrl, 'Dimension', icon: Icons.straighten_rounded),
          const SizedBox(height: 12),
          _formField(_typeCtrl, 'Type', icon: Icons.category_outlined),
          const SizedBox(height: 12),
          _formField(_qualiteCtrl, 'Qualité', icon: Icons.stars_rounded),
          const SizedBox(height: 12),
          _formField(_positionCtrl, 'Position', icon: Icons.location_on_outlined),
        ]);
        break;
      case 'HuileMoteur':
        specificFields = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _formField(_typeCtrl, 'Type d\'huile', icon: Icons.category_outlined),
          const SizedBox(height: 12),
          _formField(_viscositeCtrl, 'Viscosité', icon: Icons.opacity_rounded, hint: 'Ex : 5W-30'),
          const SizedBox(height: 12),
          _formField(_poidsCtrl, 'Contenance (L)', icon: Icons.scale_rounded, suffix: 'L', number: true, decimal: true),
        ]);
        break;
      case 'Filtre':
        specificFields = _formField(_nomCtrl, 'Nom', icon: Icons.label_outlined);
        break;
      case 'EauRefroidissement':
        specificFields = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _formField(_nomCtrl, 'Nom', icon: Icons.label_outlined),
          const SizedBox(height: 12),
          _formField(_typeCtrl, 'Type', icon: Icons.category_outlined),
          const SizedBox(height: 12),
          _formField(_poidsCtrl, 'Contenance (L)', icon: Icons.scale_rounded, suffix: 'L', number: true, decimal: true),
        ]);
        break;
      case 'Batterie':
        specificFields = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _formField(_capaciteCtrl, 'Capacité', icon: Icons.battery_charging_full_rounded),
          const SizedBox(height: 12),
          _formField(_demarrageCtrl, 'Catégorie', icon: Icons.start_rounded),
        ]);
        break;
      case 'Embrayage':
        specificFields = _formField(_diametreCtrl, 'Diamètre', icon: Icons.straighten_rounded);
        break;
      case 'Frein':
        specificFields = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _formField(_typeCtrl, 'Type', icon: Icons.category_outlined),
          const SizedBox(height: 12),
          _formField(_positionCtrl, 'Position', icon: Icons.location_on_outlined),
        ]);
        break;
      case 'Courroie':
        specificFields = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _formField(_nombreDentsCtrl, 'Nombre de dents', icon: Icons.numbers_rounded, number: true),
          const SizedBox(height: 12),
          _formField(_pompeCtrl, 'Pompe', icon: Icons.water_rounded),
        ]);
        break;
      default:
        specificFields = const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _formSection('Informations générales', Icons.info_outline_rounded, _L.primary),
        const SizedBox(height: 14),
        commonFields,
        if (pieceType != 'Amortisseur') ...[
          _formSection('Caractéristiques', Icons.settings_outlined, _L.info),
          const SizedBox(height: 14),
          specificFields,
        ],
      ],
    );
  }

  Widget _formSection(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: color.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(
              color: color, fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 0.3)),
        ],
      ),
    );
  }

  Widget _formField(TextEditingController ctrl, String label, {
    String? hint, IconData? icon, String? suffix,
    bool number = false, bool decimal = false,
  }) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: _L.textPri, fontSize: 13),
      keyboardType: decimal
          ? const TextInputType.numberWithOptions(decimal: true)
          : number ? TextInputType.number : TextInputType.text,
      inputFormatters: decimal
          ? [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))]
          : number ? [FilteringTextInputFormatter.digitsOnly] : null,
      decoration: _S.field(label, hint: hint, icon: icon, suffix: suffix),
    );
  }

  void _showDeleteConfirmationDialog(Piece piece) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (_) => _AnimatedDialog(
        child: _StyledDialog(
          title: 'Confirmer la suppression',
          icon: Icons.delete_rounded,
          iconColor: _L.danger,
          content: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _L.dangerBg,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: _L.danger.withOpacity(0.15)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded, color: _L.danger, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'La pièce "${piece.reference}" sera supprimée définitivement. Cette action est irréversible.',
                    style: const TextStyle(color: _L.danger, fontSize: 13, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          onConfirm: () { Navigator.pop(context); _deletePiece(piece); },
          confirmLabel: 'Supprimer',
          confirmColor: _L.danger,
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  LOGIQUE MÉTIER
  // ══════════════════════════════════════════════════════════════

  String _getCurrentPieceType() {
    final m = _tabController.index;
    final v = _vidangeTabController?.index ?? 0;
    if (m == 0) return 'Pneu';
    if (m == 1) return ['HuileMoteur', 'Filtre', 'EauRefroidissement'][v];
    return ['', 'Amortisseur', 'Batterie', 'Embrayage', 'Frein', 'Courroie'][m];
  }

  void _resetFormFields() {
    for (final c in [
      _referenceCtrl, _marqueCtrl, _prixCtrl, _paysCtrl,
      _dimensionCtrl, _typeCtrl, _qualiteCtrl, _positionCtrl,
      _viscositeCtrl, _poidsCtrl, _nomCtrl, _capaciteCtrl,
      _demarrageCtrl, _diametreCtrl, _nombreDentsCtrl, _pompeCtrl,
    ]) { c.clear(); }
  }

  void _populateFormFields(Piece piece) {
    _referenceCtrl.text = piece.reference;
    _marqueCtrl.text    = piece.marque;
    _prixCtrl.text      = piece.prix.toString();
    _paysCtrl.text      = piece.paysConstructeur ?? '';
    if (piece is Pneu)               { _dimensionCtrl.text = piece.dimension ?? ''; _typeCtrl.text = piece.type ?? ''; _qualiteCtrl.text = piece.qualite ?? ''; _positionCtrl.text = piece.position ?? ''; }
    else if (piece is HuileMoteur)   { _typeCtrl.text = piece.type ?? ''; _viscositeCtrl.text = piece.viscosite ?? ''; _poidsCtrl.text = piece.poids?.toString() ?? ''; }
    else if (piece is Filtre)        { _nomCtrl.text = piece.nom; }
    else if (piece is EauRefroidissement) { _nomCtrl.text = piece.nom; _typeCtrl.text = piece.type ?? ''; _poidsCtrl.text = piece.poids?.toString() ?? ''; }
    else if (piece is Batterie)      { _capaciteCtrl.text = piece.capacite ?? ''; _demarrageCtrl.text = piece.demarrage ?? ''; }
    else if (piece is Embrayage)     { _diametreCtrl.text = piece.diametre?.toString() ?? ''; }
    else if (piece is Frein)         { _typeCtrl.text = piece.type ?? ''; _positionCtrl.text = piece.position ?? ''; }
    else if (piece is Courroie)      { _nombreDentsCtrl.text = piece.nombreDents?.toString() ?? ''; _pompeCtrl.text = piece.pompe ?? ''; }
  }

  bool _validateForm() {
    if (_referenceCtrl.text.isEmpty) { _snack('La référence est obligatoire', isError: true); return false; }
    if (_marqueCtrl.text.isEmpty)    { _snack('La marque est obligatoire', isError: true); return false; }
    if (_prixCtrl.text.isEmpty)      { _snack('Le prix est obligatoire', isError: true); return false; }
    try { double.parse(_prixCtrl.text); } catch (_) { _snack('Le prix doit être un nombre valide', isError: true); return false; }
    return true;
  }

  void _snack(String msg, {bool isError = false}) {
    final color = isError ? _L.danger : _L.success;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
            color: Colors.white, size: 14),
        ),
        const SizedBox(width: 10),
        Text(msg, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ]),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      duration: const Duration(seconds: 3),
      elevation: 4,
    ));
  }

  void _uploadImage() => _snack('Fonctionnalité d\'upload à implémenter');
  void _exportData()  => _snack('Exportation en cours…');

  void _sortData(String col, bool asc) {
    setState(() { _sortColumn = col; _sortAscending = asc; });
    _loadAllData();
  }

  Future<void> _deletePiece(Piece piece) async {
    setState(() => _isLoading = true);
    try {
      bool success = false;
      if (piece is Pneu)               { success = await _piecesService.deletePneu(piece.id);               if (success) _loadAllData(); }
      else if (piece is HuileMoteur)   { success = await _piecesService.deleteHuileMoteur(piece.id);        if (success) _loadAllData(); }
      else if (piece is Filtre)        { success = await _piecesService.deleteFiltre(piece.id);             if (success) _loadAllData(); }
      else if (piece is EauRefroidissement) { success = await _piecesService.deleteEauRefroidissement(piece.id); if (success) _loadAllData(); }
      else if (piece is Amortisseur)   { success = await _piecesService.deleteAmortisseur(piece.id);        if (success) _loadAllData(); }
      else if (piece is Batterie)      { success = await _piecesService.deleteBatterie(piece.id);           if (success) _loadAllData(); }
      else if (piece is Embrayage)     { success = await _piecesService.deleteEmbrayage(piece.id);          if (success) _loadAllData(); }
      else if (piece is Frein)         { success = await _piecesService.deleteFrein(piece.id);              if (success) _loadAllData(); }
      else if (piece is Courroie)      { success = await _piecesService.deleteCourroie(piece.id);           if (success) _loadAllData(); }
      _snack(success ? 'Pièce supprimée avec succès' : 'Erreur lors de la suppression', isError: !success);
    } catch (e) {
      _snack('Erreur : $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _savePiece(String pieceType, String? id) async {
    setState(() => _isLoading = true);
    try {
      Piece piece;
      switch (pieceType) {
        case 'Pneu':
          piece = Pneu(id: id ?? '', imageUrl: '', reference: _referenceCtrl.text, marque: _marqueCtrl.text, prix: double.parse(_prixCtrl.text), paysConstructeur: _paysCtrl.text.isEmpty ? null : _paysCtrl.text, dimension: _dimensionCtrl.text.isEmpty ? null : _dimensionCtrl.text, type: _typeCtrl.text.isEmpty ? null : _typeCtrl.text, qualite: _qualiteCtrl.text.isEmpty ? null : _qualiteCtrl.text, position: _positionCtrl.text.isEmpty ? null : _positionCtrl.text);
          break;
        case 'HuileMoteur':
          piece = HuileMoteur(id: id ?? '', imageUrl: '', reference: _referenceCtrl.text, marque: _marqueCtrl.text, prix: double.parse(_prixCtrl.text), paysConstructeur: _paysCtrl.text.isEmpty ? null : _paysCtrl.text, type: _typeCtrl.text.isEmpty ? null : _typeCtrl.text, viscosite: _viscositeCtrl.text.isEmpty ? null : _viscositeCtrl.text, poids: _poidsCtrl.text.isEmpty ? null : double.tryParse(_poidsCtrl.text));
          break;
        case 'Filtre':
          piece = Filtre(id: id ?? '', imageUrl: '', reference: _referenceCtrl.text, marque: _marqueCtrl.text, prix: double.parse(_prixCtrl.text), paysConstructeur: _paysCtrl.text.isEmpty ? null : _paysCtrl.text, nom: _nomCtrl.text);
          break;
        case 'EauRefroidissement':
          piece = EauRefroidissement(id: id ?? '', imageUrl: '', reference: _referenceCtrl.text, marque: _marqueCtrl.text, prix: double.parse(_prixCtrl.text), paysConstructeur: _paysCtrl.text.isEmpty ? null : _paysCtrl.text, nom: _nomCtrl.text, type: _typeCtrl.text.isEmpty ? null : _typeCtrl.text, poids: _poidsCtrl.text.isEmpty ? null : double.tryParse(_poidsCtrl.text));
          break;
        case 'Amortisseur':
          piece = Amortisseur(id: id ?? '', imageUrl: '', reference: _referenceCtrl.text, marque: _marqueCtrl.text, type: _typeCtrl.text.isEmpty ? null : _typeCtrl.text, prix: double.parse(_prixCtrl.text), paysConstructeur: _paysCtrl.text.isEmpty ? null : _paysCtrl.text, position: _positionCtrl.text.isEmpty ? null : _positionCtrl.text);
          break;
        case 'Batterie':
          piece = Batterie(id: id ?? '', imageUrl: '', reference: _referenceCtrl.text, marque: _marqueCtrl.text, prix: double.parse(_prixCtrl.text), paysConstructeur: _paysCtrl.text.isEmpty ? null : _paysCtrl.text, capacite: _capaciteCtrl.text.isEmpty ? null : _capaciteCtrl.text, demarrage: _demarrageCtrl.text.isEmpty ? null : _demarrageCtrl.text);
          break;
        case 'Embrayage':
          piece = Embrayage(id: id ?? '', imageUrl: '', reference: _referenceCtrl.text, marque: _marqueCtrl.text, prix: double.parse(_prixCtrl.text), paysConstructeur: _paysCtrl.text.isEmpty ? null : _paysCtrl.text, diametre: _diametreCtrl.text.isEmpty ? null : double.tryParse(_diametreCtrl.text));
          break;
        case 'Frein':
          piece = Frein(id: id ?? '', imageUrl: '', reference: _referenceCtrl.text, marque: _marqueCtrl.text, prix: double.parse(_prixCtrl.text), paysConstructeur: _paysCtrl.text.isEmpty ? null : _paysCtrl.text, type: _typeCtrl.text.isEmpty ? null : _typeCtrl.text, position: _positionCtrl.text.isEmpty ? null : _positionCtrl.text);
          break;
        case 'Courroie':
          piece = Courroie(id: id ?? '', imageUrl: '', reference: _referenceCtrl.text, marque: _marqueCtrl.text, prix: double.parse(_prixCtrl.text), paysConstructeur: _paysCtrl.text.isEmpty ? null : _paysCtrl.text, nombreDents: _nombreDentsCtrl.text.isEmpty ? null : int.tryParse(_nombreDentsCtrl.text), pompe: _pompeCtrl.text.isEmpty ? null : _pompeCtrl.text);
          break;
        default:
          throw Exception('Type inconnu');
      }

      bool success = false;
      if (id == null) {
        if (piece is Pneu)               { success = (await _piecesService.createPneu(piece))               != null; }
        else if (piece is HuileMoteur)   { success = (await _piecesService.createHuileMoteur(piece))        != null; }
        else if (piece is Filtre)        { success = (await _piecesService.createFiltre(piece))             != null; }
        else if (piece is EauRefroidissement) { success = (await _piecesService.createEauRefroidissement(piece)) != null; }
        else if (piece is Amortisseur)   { success = (await _piecesService.createAmortisseur(piece))        != null; }
        else if (piece is Batterie)      { success = (await _piecesService.createBatterie(piece))           != null; }
        else if (piece is Embrayage)     { success = (await _piecesService.createEmbrayage(piece))          != null; }
        else if (piece is Frein)         { success = (await _piecesService.createFrein(piece))              != null; }
        else if (piece is Courroie)      { success = (await _piecesService.createCourroie(piece))           != null; }
      } else {
        if (piece is Pneu)               { success = (await _piecesService.updatePneu(piece))               != null; }
        else if (piece is HuileMoteur)   { success = (await _piecesService.updateHuileMoteur(piece))        != null; }
        else if (piece is Filtre)        { success = (await _piecesService.updateFiltre(piece))             != null; }
        else if (piece is EauRefroidissement) { success = (await _piecesService.updateEauRefroidissement(piece)) != null; }
        else if (piece is Amortisseur)   { success = (await _piecesService.updateAmortisseur(piece))        != null; }
        else if (piece is Batterie)      { success = (await _piecesService.updateBatterie(piece))           != null; }
        else if (piece is Embrayage)     { success = (await _piecesService.updateEmbrayage(piece))          != null; }
        else if (piece is Frein)         { success = (await _piecesService.updateFrein(piece))              != null; }
        else if (piece is Courroie)      { success = (await _piecesService.updateCourroie(piece))           != null; }
      }

      _snack(success ? 'Pièce sauvegardée avec succès' : 'Erreur lors de la sauvegarde', isError: !success);
      if (success) _loadAllData();
    } catch (e) {
      _snack('Erreur : $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

// ═══════════════════════════════════════════════════════════════
//  PRESSABLE BUTTON — micro-animation scale sur tap
// ═══════════════════════════════════════════════════════════════
class _PressableButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color color;
  final bool outlined;
  final bool compact;

  const _PressableButton({
    required this.child,
    required this.onTap,
    required this.color,
    this.outlined = false,
    this.compact  = false,
  });

  @override
  State<_PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<_PressableButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween(begin: 1.0, end: 0.94).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) { _ctrl.reverse(); widget.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: widget.compact
              ? const EdgeInsets.all(7)
              : widget.outlined
                  ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                  : const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          decoration: BoxDecoration(
            color: widget.outlined
                ? widget.color.withOpacity(0.07)
                : widget.color,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.outlined
                  ? widget.color.withOpacity(0.22)
                  : Colors.transparent,
            ),
            boxShadow: widget.outlined
                ? []
                : [
                    BoxShadow(
                      color: widget.color.withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  COUNT BADGE animé dans les tabs
// ═══════════════════════════════════════════════════════════════
class _CountBadge extends StatelessWidget {
  final int count;
  final Color color;
  final bool active;

  const _CountBadge({required this.count, required this.color, required this.active});

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: active ? color.withOpacity(0.15) : _L.textMuted.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          color: active ? color : _L.textMuted,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  PILL TAB INDICATOR personnalisé
// ═══════════════════════════════════════════════════════════════
class _PillTabIndicator extends Decoration {
  final Color color;
  final double radius;
  const _PillTabIndicator({required this.color, required this.radius});

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) =>
      _PillPainter(color: color, radius: radius, onChanged: onChanged);
}

class _PillPainter extends BoxPainter {
  final Color color;
  final double radius;
  _PillPainter({required this.color, required this.radius, VoidCallback? onChanged})
      : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    final Paint paint = Paint()..color = color.withOpacity(0.1);
    final Paint paintBorder = Paint()
      ..color = color.withOpacity(0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final size = cfg.size ?? Size.zero;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(offset.dx + 2, offset.dy + 4, size.width - 4, size.height - 8),
      Radius.circular(radius),
    );
    canvas.drawRRect(rect, paint);
    canvas.drawRRect(rect, paintBorder);
  }
}

// ═══════════════════════════════════════════════════════════════
//  DIALOG AVEC ANIMATION D'ENTRÉE
// ═══════════════════════════════════════════════════════════════
class _AnimatedDialog extends StatefulWidget {
  final Widget child;
  const _AnimatedDialog({required this.child});

  @override
  State<_AnimatedDialog> createState() => _AnimatedDialogState();
}

class _AnimatedDialogState extends State<_AnimatedDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 280));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: Tween(begin: 0.92, end: 1.0).animate(_scale),
        child: widget.child,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  STYLED DIALOG modernisé
// ═══════════════════════════════════════════════════════════════
class _StyledDialog extends StatelessWidget {
  final String      title;
  final IconData    icon;
  final Color       iconColor;
  final Widget      content;
  final VoidCallback onConfirm;
  final String      confirmLabel;
  final Color?      confirmColor;
  final bool        wide;

  const _StyledDialog({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.content,
    required this.onConfirm,
    required this.confirmLabel,
    this.confirmColor,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: _L.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: _L.border),
      ),
      elevation: 8,
      child: Container(
        width: wide ? 500 : 400,
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── En-tête ──────────────────────────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        iconColor.withOpacity(0.15),
                        iconColor.withOpacity(0.07),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: iconColor.withOpacity(0.2)),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(title,
                      style: const TextStyle(
                        color: _L.textPri,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        letterSpacing: -0.2,
                      )),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: _L.surfaceAlt,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _L.border),
                    ),
                    child: const Icon(Icons.close_rounded, size: 15, color: _L.textSec),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(color: _L.border, height: 20),
            // ── Contenu ──────────────────────────────────────────
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 500),
              child: SingleChildScrollView(child: content),
            ),
            const SizedBox(height: 22),
            // ── Actions ──────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _PressableButton(
                  onTap: () => Navigator.pop(context),
                  color: _L.textSec,
                  outlined: true,
                  child: const Text('Annuler',
                      style: TextStyle(
                          color: _L.textSec, fontWeight: FontWeight.w600, fontSize: 13)),
                ),
                const SizedBox(width: 10),
                _PressableButton(
                  onTap: onConfirm,
                  color: confirmColor ?? _L.primary,
                  child: Text(confirmLabel,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}