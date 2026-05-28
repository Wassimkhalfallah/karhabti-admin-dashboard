// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/appointment_pro_model.dart';
import '../../services/garage_pro_service.dart';

// ═══════════════════════════════════════════════════════════════
//  DESIGN TOKENS
// ═══════════════════════════════════════════════════════════════
class _L {
  static const bg = Color(0xFFF4F6FB);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF0F4FA);
  static const border = Color(0xFFE4EAF4);

  static const primary = Color(0xFF4F6FE8);
  static const primaryBg = Color(0xFFEEF2FF);
  static const primaryMid = Color(0xFFBFCAF9);

  static const success = Color(0xFF10B981);
  static const successBg = Color(0xFFECFDF5);
  static const danger = Color(0xFFC0444A);
  static const dangerBg = Color(0xFFFEF2F2);
  static const warning = Color(0xFFB07D2A);
  static const warningBg = Color(0xFFFFFBEB);
  static const info = Color(0xFF2E90B8);
  static const purple = Color(0xFF7B5EA7);
  static const purpleBg = Color(0xFFF5F0FF);

  static const textPri = Color(0xFF1E293B);
  static const textSec = Color(0xFF64748B);
  static const textMuted = Color(0xFF94A3B8);

  // Couleur par statut
  static Color statusColor(AppointmentStatus s) {
    switch (s) {
      case AppointmentStatus.enAttente:
        return warning;
      case AppointmentStatus.confirme:
        return success;
      case AppointmentStatus.annule:
        return danger;
      case AppointmentStatus.termine:
        return primary;
      case AppointmentStatus.noShow:
        return purple;
    }
  }

  static Color statusBg(AppointmentStatus s) {
    switch (s) {
      case AppointmentStatus.enAttente:
        return warningBg;
      case AppointmentStatus.confirme:
        return successBg;
      case AppointmentStatus.annule:
        return dangerBg;
      case AppointmentStatus.termine:
        return primaryBg;
      case AppointmentStatus.noShow:
        return purpleBg;
    }
  }

  static IconData statusIcon(AppointmentStatus s) {
    switch (s) {
      case AppointmentStatus.enAttente:
        return Icons.schedule_rounded;
      case AppointmentStatus.confirme:
        return Icons.check_circle_outline_rounded;
      case AppointmentStatus.annule:
        return Icons.cancel_outlined;
      case AppointmentStatus.termine:
        return Icons.task_alt_rounded;
      case AppointmentStatus.noShow:
        return Icons.person_off_outlined;
    }
  }
}

// ═══════════════════════════════════════════════════════════════
//  STYLES
// ═══════════════════════════════════════════════════════════════
class _S {
  static InputDecoration field(
    String label, {
    String? hint,
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: _L.textSec, fontSize: 13),
      hintStyle: const TextStyle(color: _L.textMuted, fontSize: 13),
      prefixIcon:
          icon != null ? Icon(icon, size: 17, color: _L.textMuted) : null,
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
      isDense: true,
    );
  }

  static BoxDecoration card({double radius = 16}) => BoxDecoration(
    color: _L.surface,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: _L.border),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF94A3B8).withOpacity(0.07),
        blurRadius: 14,
        offset: const Offset(0, 3),
      ),
    ],
  );
}

// ═══════════════════════════════════════════════════════════════
//  SHIMMER BOX
// ═══════════════════════════════════════════════════════════════
class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;
  const _ShimmerBox({
    required this.width,
    required this.height,
    this.radius = 8,
  });

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
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder:
          (_, __) => Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.radius),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFE8EDF5),
                  Color.lerp(
                    const Color(0xFFE8EDF5),
                    const Color(0xFFF8FAFF),
                    _anim.value,
                  )!,
                  const Color(0xFFE8EDF5),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  HOVER BUTTON
// ═══════════════════════════════════════════════════════════════
class _HoverBtn extends StatefulWidget {
  final Color color;
  final VoidCallback onTap;
  final Widget child;
  final EdgeInsets padding;
  const _HoverBtn({
    required this.color,
    required this.onTap,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
  });

  @override
  State<_HoverBtn> createState() => _HoverBtnState();
}

class _HoverBtnState extends State<_HoverBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: widget.padding,
          decoration: BoxDecoration(
            color:
                _hovered
                    ? widget.color.withOpacity(0.14)
                    : widget.color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color:
                  _hovered
                      ? widget.color.withOpacity(0.32)
                      : widget.color.withOpacity(0.18),
            ),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  PULSING ICON (empty state)
// ═══════════════════════════════════════════════════════════════
class _PulsingIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  const _PulsingIcon({required this.icon, required this.color});

  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulse = Tween<double>(
      begin: 0.93,
      end: 1.07,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _pulse,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              widget.color.withOpacity(0.13),
              widget.color.withOpacity(0.04),
            ],
          ),
          shape: BoxShape.circle,
          border: Border.all(color: widget.color.withOpacity(0.15)),
        ),
        child: Icon(widget.icon, size: 36, color: widget.color),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  SNACK HELPER
// ═══════════════════════════════════════════════════════════════
void _snack(
  BuildContext context,
  String msg, {
  bool isError = false,
  bool isWarning = false,
}) {
  final color =
      isError
          ? _L.danger
          : isWarning
          ? _L.warning
          : _L.success;
  final icon =
      isError
          ? Icons.error_outline_rounded
          : isWarning
          ? Icons.warning_amber_rounded
          : Icons.check_circle_outline_rounded;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              msg,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
      elevation: 4,
    ),
  );
}

// ═══════════════════════════════════════════════════════════════
//  ANIMATED DIALOG HELPER
// ═══════════════════════════════════════════════════════════════
Future<T?> _showAnimatedDialog<T>(
  BuildContext context,
  Widget dialog, {
  bool dismissible = true,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: dismissible,
    barrierLabel: 'Fermer',
    barrierColor: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.35),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, __, ___) => dialog,
    transitionBuilder: (_, anim, __, child) {
      final curve = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.06),
            end: Offset.zero,
          ).animate(curve),
          child: child,
        ),
      );
    },
  );
}

// ═══════════════════════════════════════════════════════════════
//  LIGHT THEME BUILDER
// ═══════════════════════════════════════════════════════════════
ThemeData _lightTheme() => ThemeData.light(useMaterial3: true).copyWith(
  scaffoldBackgroundColor: _L.bg,
  colorScheme: const ColorScheme.light(
    primary: _L.primary,
    surface: _L.surface,
    onSurface: _L.textPri,
  ),
  cardColor: _L.surface,
  canvasColor: _L.surface,
  dividerColor: _L.border,
  iconTheme: const IconThemeData(color: _L.textSec),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: _L.textPri),
    bodySmall: TextStyle(color: _L.textSec),
  ),
);

// ═══════════════════════════════════════════════════════════════
//  SCREEN
// ═══════════════════════════════════════════════════════════════
class AppointmentsScreen extends StatefulWidget {
  final String? garageId;

  const AppointmentsScreen({super.key, this.garageId});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with TickerProviderStateMixin {
  final GarageProService _service = GarageProService();
  late TabController _tabCtrl;
  bool _loading = true;
  List<AppointmentPro> _all = [];
  List<AppointmentPro> _today = [];
  AppointmentStatus? _statusFilter;
  final TextEditingController _searchCtrl = TextEditingController();
  String _search = '';

  // Animations
  late AnimationController _headerCtrl;
  late Animation<Offset> _headerSlide;
  late Animation<double> _headerFade;
  late AnimationController _contentCtrl;
  late Animation<double> _contentFade;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.addListener(() => setState(() {}));

    _headerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOutCubic));
    _headerFade = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);

    _contentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _contentFade = CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut);

    _searchCtrl.addListener(() {
      setState(() => _search = _searchCtrl.text);
    });

    _loadData();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    _headerCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    _contentCtrl.reset();
    _headerCtrl.reset();
    final gid = widget.garageId;
    final all = await _service.getAppointments(statut: _statusFilter, garageId: gid);
    final today = gid != null
        ? await _service.getAppointments(
            garageId: gid,
            dateDebut: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
            dateFin: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59, 59),
          )
        : await _service.getTodayAppointments();
    if (mounted) {
      setState(() {
        _all = all;
        _today = today;
        _loading = false;
      });
      _headerCtrl.forward();
      await Future.delayed(const Duration(milliseconds: 60));
      _contentCtrl.forward();
    }
  }

  List<AppointmentPro> get _filtered {
    if (_search.isEmpty) return _all;
    final q = _search.toLowerCase();
    return _all
        .where(
          (a) =>
              (a.clientNom ?? '').toLowerCase().contains(q) ||
              (a.garageNom ?? '').toLowerCase().contains(q) ||
              a.immatriculation.toLowerCase().contains(q) ||
              a.typePrestation.toLowerCase().contains(q),
        )
        .toList();
  }

  // ── Statistiques par statut ──
  Map<AppointmentStatus, int> get _stats {
    final m = <AppointmentStatus, int>{};
    for (final s in AppointmentStatus.values) {
      m[s] = _all.where((a) => a.statut == s).length;
    }
    return m;
  }

  // ════════════════════════ BUILD ════════════════════════
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _lightTheme(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header animé
          SlideTransition(
            position: _headerSlide,
            child: FadeTransition(opacity: _headerFade, child: _buildHeader()),
          ),
          // Stats bar
          if (!_loading)
            FadeTransition(opacity: _headerFade, child: _buildStatsBar()),
          // TabBar
          _buildTabBar(),
          // Toolbar
          _buildToolbar(),
          // Contenu
          Expanded(
            child:
                _loading
                    ? _buildSkeleton()
                    : FadeTransition(
                      opacity: _contentFade,
                      child: TabBarView(
                        controller: _tabCtrl,
                        children: [_buildAllList(), _buildTodayTimeline()],
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  //  HEADER
  // ─────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 14),
      decoration: BoxDecoration(
        color: _L.surface,
        border: const Border(bottom: BorderSide(color: _L.border)),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _L.primary.withOpacity(0.15),
                  _L.primary.withOpacity(0.06),
                ],
              ),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: _L.primary.withOpacity(0.2)),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: _L.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Gestion des Rendez-vous',
                style: TextStyle(
                  color: _L.textPri,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${_all.length} rendez-vous au total',
                style: const TextStyle(color: _L.textSec, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          // Bouton actualiser
          _HoverBtn(
            color: _L.primary,
            onTap: _loadData,
            child: Row(
              children: const [
                Icon(Icons.refresh_rounded, size: 15, color: _L.primary),
                SizedBox(width: 5),
                Text(
                  'Actualiser',
                  style: TextStyle(
                    color: _L.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Aujourd'hui badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
            decoration: BoxDecoration(
              color: _L.successBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _L.success.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                const Icon(Icons.today_rounded, size: 13, color: _L.success),
                const SizedBox(width: 5),
                Text(
                  '${_today.length} aujourd\'hui',
                  style: const TextStyle(
                    color: _L.success,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  //  STATS BAR
  // ─────────────────────────────────────────────────────
  Widget _buildStatsBar() {
    final stats = _stats;
    return Container(
      color: _L.surface,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children:
              AppointmentStatus.values.map((s) {
                final count = stats[s] ?? 0;
                final color = _L.statusColor(s);
                final isActive = _statusFilter == s;
                return GestureDetector(
                  onTap: () {
                    setState(() => _statusFilter = isActive ? null : s);
                    _loadData();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: isActive ? color.withOpacity(0.12) : _L.surfaceAlt,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isActive ? color.withOpacity(0.35) : _L.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _L.statusIcon(s),
                          size: 13,
                          color: isActive ? color : _L.textSec,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          s.label,
                          style: TextStyle(
                            color: isActive ? color : _L.textSec,
                            fontSize: 12,
                            fontWeight:
                                isActive ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isActive ? color.withOpacity(0.15) : _L.border,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$count',
                            style: TextStyle(
                              color: isActive ? color : _L.textSec,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  //  TAB BAR
  // ─────────────────────────────────────────────────────
  Widget _buildTabBar() {
    const tabs = [
      (Icons.list_alt_rounded, 'Tous les RDV'),
      (Icons.today_rounded, 'RDV aujourd\'hui'),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: const BoxDecoration(
        color: _L.surface,
        border: Border(bottom: BorderSide(color: _L.border)),
      ),
      child: Row(
        children:
            tabs.asMap().entries.map((e) {
              final i = e.key;
              final tab = e.value;
              final isActive = _tabCtrl.index == i;
              return GestureDetector(
                onTap: () {
                  _tabCtrl.animateTo(i);
                  setState(() {});
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isActive
                            ? _L.primary.withOpacity(0.10)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color:
                          isActive
                              ? _L.primary.withOpacity(0.28)
                              : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        tab.$1,
                        size: 15,
                        color: isActive ? _L.primary : _L.textSec,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        tab.$2,
                        style: TextStyle(
                          color: isActive ? _L.primary : _L.textSec,
                          fontWeight:
                              isActive ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  //  TOOLBAR
  // ─────────────────────────────────────────────────────
  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      decoration: const BoxDecoration(
        color: _L.surface,
        border: Border(bottom: BorderSide(color: _L.border)),
      ),
      child: Row(
        children: [
          // Recherche
          _SearchField(
            controller: _searchCtrl,
            onChanged: (_) => setState(() {}),
          ),
          const Spacer(),
          // Filtre statut badge actif
          if (_statusFilter != null)
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _L.statusBg(_statusFilter!),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _L.statusColor(_statusFilter!).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _L.statusIcon(_statusFilter!),
                    size: 12,
                    color: _L.statusColor(_statusFilter!),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _statusFilter!.label,
                    style: TextStyle(
                      color: _L.statusColor(_statusFilter!),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      setState(() => _statusFilter = null);
                      _loadData();
                    },
                    child: Icon(
                      Icons.close_rounded,
                      size: 12,
                      color: _L.statusColor(_statusFilter!),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(width: 8),
          // Compteur résultats
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
            decoration: BoxDecoration(
              color: _L.primaryBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _L.primaryMid.withOpacity(0.4)),
            ),
            child: Text(
              '${_filtered.length} résultat${_filtered.length != 1 ? 's' : ''}',
              style: const TextStyle(
                color: _L.primary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  //  SKELETON
  // ─────────────────────────────────────────────────────
  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 6,
      itemBuilder:
          (_, i) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: _S.card(radius: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _ShimmerBox(width: 80, height: 22, radius: 10),
                    const SizedBox(width: 10),
                    _ShimmerBox(width: 130, height: 14, radius: 5),
                  ],
                ),
                const SizedBox(height: 10),
                _ShimmerBox(width: 200, height: 12, radius: 5),
                const SizedBox(height: 6),
                _ShimmerBox(width: 160, height: 11, radius: 5),
              ],
            ),
          ),
    );
  }

  // ─────────────────────────────────────────────────────
  //  ALL LIST
  // ─────────────────────────────────────────────────────
  Widget _buildAllList() {
    final list = _filtered;
    if (list.isEmpty) {
      return _emptyState(
        icon: Icons.event_busy_rounded,
        color: _L.primary,
        label:
            _search.isNotEmpty
                ? 'Aucun résultat pour "$_search"'
                : 'Aucun rendez-vous trouvé',
        sub:
            _search.isNotEmpty
                ? 'Modifiez votre recherche ou réinitialisez les filtres.'
                : 'Les rendez-vous apparaîtront ici dès qu\'ils seront créés.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      itemCount: list.length,
      itemBuilder: (_, i) => _AnimatedCard(index: i, child: _rdvCard(list[i])),
    );
  }

  // ─────────────────────────────────────────────────────
  //  TODAY TIMELINE
  // ─────────────────────────────────────────────────────
  Widget _buildTodayTimeline() {
    if (_today.isEmpty) {
      return _emptyState(
        icon: Icons.event_available_rounded,
        color: _L.success,
        label: 'Aucun rendez-vous aujourd\'hui',
        sub: 'La journée est libre — profitez-en !',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      itemCount: _today.length,
      itemBuilder:
          (_, i) => _AnimatedCard(
            index: i,
            child: _timelineItem(_today[i], i, _today.length),
          ),
    );
  }

  Widget _timelineItem(AppointmentPro a, int index, int total) {
    final color = _L.statusColor(a.statut);
    final isLast = index == total - 1;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Colonne heure + trait
        SizedBox(
          width: 58,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(height: 14),
              Text(
                a.heureStr,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: _L.textPri,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Trait vertical + point
        Column(
          children: [
            Container(
              width: 2,
              height: 14,
              color: index == 0 ? Colors.transparent : color.withOpacity(0.3),
            ),
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: double.infinity,
                constraints: const BoxConstraints(minHeight: 60),
                color: color.withOpacity(0.3),
              ),
          ],
        ),
        const SizedBox(width: 12),
        // Card
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _rdvCard(a),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────
  //  RDV CARD
  // ─────────────────────────────────────────────────────
  Widget _rdvCard(AppointmentPro a) {
    final color = _L.statusColor(a.statut);
    return Container(
      decoration: _S.card(radius: 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          children: [
            // Bande colorée top
            Container(height: 3, color: color),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ligne 1 : badge statut + client + actions
                  Row(
                    children: [
                      _StatusBadge(a.statut),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          a.clientNom ?? 'Client',
                          style: const TextStyle(
                            color: _L.textPri,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _InlineActions(
                        appointment: a,
                        onAction: (action) => _handleAction(a, action),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Divider
                  Container(height: 0.8, color: _L.border),
                  const SizedBox(height: 8),
                  // Infos
                  _InfoRow(
                    icon: Icons.build_outlined,
                    color: _L.info,
                    label: a.typePrestation,
                  ),
                  const SizedBox(height: 4),
                  _InfoRow(
                    icon: Icons.garage_outlined,
                    color: _L.primary,
                    label: a.garageNom ?? 'Garage',
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _InfoRow(
                        icon: Icons.directions_car_outlined,
                        color: _L.textSec,
                        label: a.immatriculation,
                      ),
                      const SizedBox(width: 16),
                      _InfoRow(
                        icon: Icons.event_rounded,
                        color: _L.textSec,
                        label:
                            '${DateFormat('dd/MM/yyyy').format(a.dateRendezVous)} à ${a.heureStr}',
                      ),
                    ],
                  ),
                  // Motif annulation (si applicable)
                  if (a.statut == AppointmentStatus.annule &&
                      a.motifAnnulation != null &&
                      a.motifAnnulation!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: _L.dangerBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _L.danger.withOpacity(0.2)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 13,
                            color: _L.danger,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Motif : ${a.motifAnnulation}',
                              style: const TextStyle(
                                color: _L.danger,
                                fontSize: 11,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  //  EMPTY STATE
  // ─────────────────────────────────────────────────────
  Widget _emptyState({
    required IconData icon,
    required Color color,
    required String label,
    required String sub,
  }) {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutBack,
        builder: (_, v, child) => Transform.scale(scale: v, child: child),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 40),
          margin: const EdgeInsets.all(40),
          decoration: _S.card(radius: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PulsingIcon(icon: icon, color: color),
              const SizedBox(height: 20),
              Text(
                label,
                style: const TextStyle(
                  color: _L.textPri,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                sub,
                style: const TextStyle(color: _L.textSec, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  //  ACTIONS
  // ─────────────────────────────────────────────────────
  Future<void> _handleAction(AppointmentPro a, String action) async {
    switch (action) {
      case 'confirm':
        await _service.confirmAppointment(a.id);
        if (mounted) _snack(context, 'Rendez-vous confirmé avec succès');
        break;

      case 'cancel':
        final result = await _showRefuseDialog(a);
        if (result == null) return;
        await _service.cancelAppointment(a.id, result, 'admin');
        if (mounted) _snack(context, 'Rendez-vous annulé');
        break;

      case 'complete':
        await _service.completeAppointment(a.id);
        if (mounted) _snack(context, 'Rendez-vous marqué comme terminé');
        break;

      case 'noshow':
        await _service.markNoShow(a.id);
        if (mounted) {
          _snack(context, 'Rendez-vous marqué : no show', isWarning: true);
        }
        break;
    }
    _loadData();
  }

  // ─────────────────────────────────────────────────────
  //  DIALOG REFUS / ANNULATION
  // ─────────────────────────────────────────────────────
  Future<String?> _showRefuseDialog(AppointmentPro a) {
    return _showAnimatedDialog<String>(context, _RefuseDialog(appointment: a));
  }
}

// ═══════════════════════════════════════════════════════════════
//  DIALOG REFUS — avec raisons prédéfinies + champ libre
// ═══════════════════════════════════════════════════════════════
class _RefuseDialog extends StatefulWidget {
  final AppointmentPro appointment;
  const _RefuseDialog({required this.appointment});

  @override
  State<_RefuseDialog> createState() => _RefuseDialogState();
}

class _RefuseDialogState extends State<_RefuseDialog> {
  final _ctrl = TextEditingController();
  String? _selectedReason;
  bool _submitting = false;

  // Raisons prédéfinies
  static const _presets = [
    (Icons.event_busy_rounded, 'Créneau indisponible'),
    (Icons.build_outlined, 'Prestation non disponible'),
    (Icons.person_off_outlined, 'Technicien absent'),
    (Icons.directions_car_outlined, 'Véhicule non supporté'),
    (Icons.block_rounded, 'Garage complet'),
    (Icons.edit_note_rounded, 'Autre raison…'),
  ];

  bool get _isOther => _selectedReason == 'Autre raison…';
  bool get _canSubmit =>
      _selectedReason != null && (!_isOther || _ctrl.text.trim().isNotEmpty);

  String get _finalMotif =>
      _isOther ? _ctrl.text.trim() : (_selectedReason ?? '');

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _lightTheme(),
      child: Dialog(
        backgroundColor: _L.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: _L.border),
        ),
        elevation: 0,
        child: Container(
          width: 460,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── En-tête ──
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _L.danger.withOpacity(0.15),
                          _L.danger.withOpacity(0.06),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: _L.danger.withOpacity(0.22)),
                    ),
                    child: const Icon(
                      Icons.cancel_outlined,
                      color: _L.danger,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Annuler le rendez-vous',
                          style: TextStyle(
                            color: _L.textPri,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            letterSpacing: -0.2,
                          ),
                        ),
                        Text(
                          '${widget.appointment.clientNom ?? 'Client'} · ${widget.appointment.heureStr}',
                          style: const TextStyle(
                            color: _L.textSec,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: _L.surfaceAlt,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _L.border),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: _L.textSec,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(color: _L.border, height: 1),
              const SizedBox(height: 16),

              // ── Alerte info ──
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _L.warningBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _L.warning.withOpacity(0.3)),
                ),
                child: Row(
                  children: const [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 15,
                      color: _L.warning,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Le motif sera communiqué au client et conservé dans l\'historique.',
                        style: TextStyle(
                          color: _L.warning,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Label ──
              const Text(
                'Choisissez un motif *',
                style: TextStyle(
                  color: _L.textPri,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 10),

              // ── Raisons prédéfinies ──
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    _presets.map((p) {
                      final isSelected = _selectedReason == p.$2;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedReason = p.$2;
                            if (!_isOther) _ctrl.clear();
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? _L.danger.withOpacity(0.10)
                                    : _L.surfaceAlt,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color:
                                  isSelected
                                      ? _L.danger.withOpacity(0.35)
                                      : _L.border,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                p.$1,
                                size: 13,
                                color: isSelected ? _L.danger : _L.textSec,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                p.$2,
                                style: TextStyle(
                                  color: isSelected ? _L.danger : _L.textPri,
                                  fontSize: 12,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                ),
                              ),
                              if (isSelected) ...[
                                const SizedBox(width: 5),
                                const Icon(
                                  Icons.check_circle_rounded,
                                  size: 12,
                                  color: _L.danger,
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),
              ),

              // ── Champ libre (si Autre) ──
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                child:
                    _isOther
                        ? Padding(
                          padding: const EdgeInsets.only(top: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Précisez le motif *',
                                style: TextStyle(
                                  color: _L.textPri,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _ctrl,
                                maxLines: 3,
                                style: const TextStyle(
                                  color: _L.textPri,
                                  fontSize: 13,
                                ),
                                onChanged: (_) => setState(() {}),
                                decoration: _S.field(
                                  'Raison détaillée',
                                  hint:
                                      'Ex: Panne d\'équipement, absence de technicien spécialisé…',
                                  icon: Icons.edit_note_rounded,
                                ),
                              ),
                            ],
                          ),
                        )
                        : const SizedBox.shrink(),
              ),

              const SizedBox(height: 22),

              // ── Actions ──
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        _submitting ? null : () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: _L.textSec,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 11,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: _L.border),
                      ),
                    ),
                    child: const Text(
                      'Annuler',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _ConfirmBtn(
                    label: 'Confirmer l\'annulation',
                    color: _L.danger,
                    enabled: _canSubmit && !_submitting,
                    loading: _submitting,
                    onTap: () async {
                      setState(() => _submitting = true);
                      await Future.delayed(const Duration(milliseconds: 200));
                      if (mounted) Navigator.pop(context, _finalMotif);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  CONFIRM BUTTON (press scale)
// ═══════════════════════════════════════════════════════════════
class _ConfirmBtn extends StatefulWidget {
  final String label;
  final Color color;
  final bool enabled;
  final bool loading;
  final VoidCallback onTap;
  const _ConfirmBtn({
    required this.label,
    required this.color,
    required this.onTap,
    this.enabled = true,
    this.loading = false,
  });

  @override
  State<_ConfirmBtn> createState() => _ConfirmBtnState();
}

class _ConfirmBtnState extends State<_ConfirmBtn>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.enabled ? (_) => _ctrl.forward() : null,
      onTapUp:
          widget.enabled
              ? (_) {
                _ctrl.reverse();
                widget.onTap();
              }
              : null,
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedOpacity(
          opacity: widget.enabled ? 1.0 : 0.45,
          duration: const Duration(milliseconds: 180),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(10),
              boxShadow:
                  widget.enabled
                      ? [
                        BoxShadow(
                          color: widget.color.withOpacity(0.28),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                      : [],
            ),
            child:
                widget.loading
                    ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : Text(
                      widget.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  INLINE ACTIONS — boutons contextuels dans la card
// ═══════════════════════════════════════════════════════════════
class _InlineActions extends StatelessWidget {
  final AppointmentPro appointment;
  final ValueChanged<String> onAction;
  const _InlineActions({required this.appointment, required this.onAction});

  @override
  Widget build(BuildContext context) {
    final a = appointment;
    final buttons = <Widget>[];

    if (a.statut == AppointmentStatus.enAttente) {
      buttons.add(
        _actionBtn(
          icon: Icons.check_rounded,
          label: 'Confirmer',
          color: _L.success,
          onTap: () => onAction('confirm'),
        ),
      );
      buttons.add(const SizedBox(width: 5));
      buttons.add(
        _actionBtn(
          icon: Icons.close_rounded,
          label: 'Annuler',
          color: _L.danger,
          onTap: () => onAction('cancel'),
        ),
      );
    }

    if (a.statut == AppointmentStatus.confirme) {
      buttons.add(
        _actionBtn(
          icon: Icons.task_alt_rounded,
          label: 'Terminé',
          color: _L.primary,
          onTap: () => onAction('complete'),
        ),
      );
      buttons.add(const SizedBox(width: 5));
      buttons.add(
        _actionBtn(
          icon: Icons.person_off_outlined,
          label: 'No show',
          color: _L.purple,
          onTap: () => onAction('noshow'),
        ),
      );
      buttons.add(const SizedBox(width: 5));
      buttons.add(
        _actionBtn(
          icon: Icons.close_rounded,
          label: 'Annuler',
          color: _L.danger,
          onTap: () => onAction('cancel'),
        ),
      );
    }

    if (buttons.isEmpty) return const SizedBox.shrink();
    return Row(mainAxisSize: MainAxisSize.min, children: buttons);
  }

  Widget _actionBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: label,
      child: _HoverBtn(
        color: color,
        onTap: onTap,
        padding: const EdgeInsets.all(7),
        child: Icon(icon, size: 15, color: color),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  STATUS BADGE
// ═══════════════════════════════════════════════════════════════
class _StatusBadge extends StatelessWidget {
  final AppointmentStatus status;
  const _StatusBadge(this.status);

  @override
  Widget build(BuildContext context) {
    final color = _L.statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: _L.statusBg(status),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_L.statusIcon(status), size: 11, color: color),
          const SizedBox(width: 5),
          Text(
            status.label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  INFO ROW
// ═══════════════════════════════════════════════════════════════
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  const _InfoRow({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(color: _L.textSec, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  ANIMATED CARD (fade-in cascade)
// ═══════════════════════════════════════════════════════════════
class _AnimatedCard extends StatefulWidget {
  final Widget child;
  final int index;
  const _AnimatedCard({required this.child, required this.index});

  @override
  State<_AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<_AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    final delayed = CurvedAnimation(
      parent: _ctrl,
      curve: Interval(
        (widget.index * 0.07).clamp(0.0, 0.75),
        1.0,
        curve: Curves.easeOut,
      ),
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(delayed);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(delayed);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _opacity,
    child: SlideTransition(
      position: _slide,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: widget.child,
      ),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════
//  SEARCH FIELD (animated width + focus)
// ═══════════════════════════════════════════════════════════════
class _SearchField extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _SearchField({required this.controller, required this.onChanged});

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  final FocusNode _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: _focused ? 300 : 240,
      child: TextField(
        controller: widget.controller,
        focusNode: _focus,
        onChanged: widget.onChanged,
        style: const TextStyle(color: _L.textPri, fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Client, garage, immatriculation…',
          hintStyle: const TextStyle(color: _L.textMuted, fontSize: 13),
          prefixIcon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              Icons.search_rounded,
              key: ValueKey(_focused),
              size: 17,
              color: _focused ? _L.primary : _L.textMuted,
            ),
          ),
          suffixIcon:
              widget.controller.text.isNotEmpty
                  ? IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: _L.textMuted,
                    ),
                    onPressed: () {
                      widget.controller.clear();
                      widget.onChanged('');
                    },
                  )
                  : null,
          filled: true,
          fillColor: _focused ? _L.primaryBg : _L.surfaceAlt,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
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
          isDense: true,
        ),
      ),
    );
  }
}
