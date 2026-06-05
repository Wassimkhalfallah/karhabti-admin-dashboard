import 'package:flutter/material.dart';
import '../../models/appointment_pro_model.dart';
import '../../services/garage_pro_service.dart';
import '../../services/responsable_technicien_service.dart';

// ── Palette douce & lumineuse ─────────────────────────────────────────────
const _kPrimary   = Color(0xFF5B6EF5);
const _kPrimaryLt = Color(0xFF818CF8);
const _kTeal      = Color(0xFF06C8B4);
const _kOrange    = Color(0xFFFF8C42);
const _kGold      = Color(0xFFFFB931);
const _kViolet    = Color(0xFF8B5CF6);
const _kBg        = Color(0xFFF8FAFF);
const _kTextPri   = Color(0xFF1A1D2E);
const _kTextSec   = Color(0xFF64748B);

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

class _ResponsableHomeTabState extends State<ResponsableHomeTab>
    with SingleTickerProviderStateMixin {
  final _service      = ResponsableTechnicienService();
  final _garageService = GarageProService();

  bool   _loading      = true;
  int    _rdvEnAttente = 0;
  int    _rdvSemaine   = 0;
  int    _critical     = 0;
  double _note         = 0;
  String _garageNom    = '';

  late AnimationController _animCtrl;
  late List<Animation<double>>   _fadeAnims;
  late List<Animation<Offset>>   _slideAnims;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _fadeAnims = List.generate(6, (i) {
      final s = (i * 0.10).clamp(0.0, 0.6);
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animCtrl,
            curve: Interval(s, (s + 0.45).clamp(0, 1), curve: Curves.easeOut)));
    });
    _slideAnims = List.generate(6, (i) {
      final s = (i * 0.10).clamp(0.0, 0.6);
      return Tween<Offset>(begin: const Offset(0, 0.22), end: Offset.zero)
          .animate(CurvedAnimation(parent: _animCtrl,
              curve: Interval(s, (s + 0.45).clamp(0, 1),
                  curve: Curves.easeOutCubic)));
    });
    _load();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _animCtrl.reset();

    final now      = DateTime.now();
    final startDay = DateTime(now.year, now.month, now.day);
    final endDay   = startDay.add(const Duration(days: 1));
    final weekEnd  = startDay.add(const Duration(days: 7));

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
    final critical  = vehicules.where((v) {
      final p = v['prediction'] as Map<String, dynamic>?;
      if (p == null) return false;
      return [
        p['tire_wear'], p['battery_health'], p['brake_wear'],
        p['oil_change'], p['belt_risk'], p['clutch_wear'],
        p['ShockAbsorber_Wear'],
      ].any((e) => (e as num?) != null && e! >= 70);
    }).length;

    final garage = await _garageService.getGarageById(widget.garageId);
    if (mounted) {
      setState(() {
        _rdvEnAttente = pendingToday.length;
        _rdvSemaine   = confirmedWeek.length;
        _critical     = critical;
        _note         = garage?.noteMoyenne ?? 0;
        _garageNom    = garage?.nom ?? 'Mon garage';
        _loading      = false;
      });
      _animCtrl.forward();
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(
        color: _kBg,
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(_kPrimary),
          ),
        ),
      );
    }

    return Container(
      color: _kBg,
      child: RefreshIndicator(
        onRefresh: _load,
        color: _kPrimary,
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Hero header ─────────────────────────────────────────
              FadeTransition(
                opacity: _fadeAnims[0],
                child: SlideTransition(
                  position: _slideAnims[0],
                  child: _buildHeroHeader(),
                ),
              ),
              const SizedBox(height: 28),

              // ── KPI label ───────────────────────────────────────────
              FadeTransition(
                opacity: _fadeAnims[1],
                child: SlideTransition(
                  position: _slideAnims[1],
                  child: _sectionLabel('Indicateurs clés'),
                ),
              ),
              const SizedBox(height: 14),

              // ── KPI grid ────────────────────────────────────────────
              FadeTransition(
                opacity: _fadeAnims[2],
                child: SlideTransition(
                  position: _slideAnims[2],
                  child: _buildKpiGrid(),
                ),
              ),
              const SizedBox(height: 28),

              // ── Quick nav label ────────────────────────────────────
              FadeTransition(
                opacity: _fadeAnims[3],
                child: SlideTransition(
                  position: _slideAnims[3],
                  child: _sectionLabel('Accès rapide'),
                ),
              ),
              const SizedBox(height: 14),

              // ── Quick nav chips ────────────────────────────────────
              FadeTransition(
                opacity: _fadeAnims[4],
                child: SlideTransition(
                  position: _slideAnims[4],
                  child: _buildQuickNav(),
                ),
              ),
              const SizedBox(height: 28),

              // ── Status summary ─────────────────────────────────────
              FadeTransition(
                opacity: _fadeAnims[5],
                child: SlideTransition(
                  position: _slideAnims[5],
                  child: _buildStatusSummary(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Hero header ───────────────────────────────────────────────────────────

  Widget _buildHeroHeader() {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Bonjour 👋'
        : hour < 18 ? 'Bon après-midi 👋'
        : 'Bonsoir 👋';

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_kPrimary, _kPrimaryLt],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _kPrimary.withOpacity(0.28),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(greeting,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 14,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                Text(
                  _garageNom,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 4),
                const Text('Tableau de bord responsable technicien      ',
                    style: TextStyle(color: Colors.white60, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 58, height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.store_rounded, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  // ── Section label ─────────────────────────────────────────────────────────

  Widget _sectionLabel(String text) {
    return Row(children: [
      Container(
        width: 4, height: 18,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_kPrimary, _kPrimaryLt],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 10),
      Text(text,
          style: const TextStyle(
            color: _kTextPri, fontSize: 15,
            fontWeight: FontWeight.w700, letterSpacing: 0.2)),
    ]);
  }

  // ── KPI grid ─────────────────────────────────────────────────────────────

  Widget _buildKpiGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = (constraints.maxWidth - 36) / 4;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _kpiCard(w, "RDV en attente\n(aujourd'hui)", '$_rdvEnAttente',
                _kPrimary, Icons.pending_actions_rounded, const Color(0xFFEEF2FF)),
            _kpiCard(w, 'RDV confirmés\n(7 jours)', '$_rdvSemaine',
                _kTeal, Icons.event_available_rounded, const Color(0xFFE0FFF9)),
            _kpiCard(w, 'Maintenances\ncritiques', '$_critical',
                _kOrange, Icons.warning_amber_rounded, const Color(0xFFFFF4ED)),
            _kpiCard(w, 'Note\nmoyenne', _note.toStringAsFixed(1),
                _kGold, Icons.star_rounded, const Color(0xFFFFFBEB)),
          ],
        );
      },
    );
  }

  Widget _kpiCard(double width, String title, String value,
      Color accent, IconData icon, Color bgColor) {
    return SizedBox(
      width: width.clamp(150.0, 320.0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(
            color: accent.withOpacity(0.09),
            blurRadius: 16, offset: const Offset(0, 6))],
          border: Border(left: BorderSide(color: accent, width: 3.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(9)),
                  child: Icon(icon, size: 16, color: accent)),
                Text(value,
                    style: TextStyle(
                      color: accent, fontSize: 28,
                      fontWeight: FontWeight.w800, height: 1)),
              ],
            ),
            const SizedBox(height: 10),
            Text(title,
                style: const TextStyle(
                  color: _kTextSec, fontSize: 12, height: 1.4)),
          ],
        ),
      ),
    );
  }

  // ── Quick nav chips ───────────────────────────────────────────────────────

  Widget _buildQuickNav() {
    final items = [
      (1, 'Pièces',        Icons.settings_rounded,             _kPrimary),
      (2, 'Affectation',   Icons.assignment_turned_in_rounded, _kTeal),
      (3, 'Rendez-vous',   Icons.calendar_month_rounded,       _kOrange),
      (4, 'Véhicules',     Icons.directions_car_rounded,       _kViolet),
      (5, 'Mon garage',    Icons.store_rounded,                _kGold),
    ];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items.map((item) =>
        _quickNavChip(item.$1, item.$2, item.$3, item.$4)).toList(),
    );
  }

  Widget _quickNavChip(int index, String label, IconData icon, Color color) {
    return InkWell(
      onTap: () => widget.onNavigate?.call(index),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(
            color: color.withOpacity(0.10),
            blurRadius: 10, offset: const Offset(0, 4))],
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 15, color: color)),
          const SizedBox(width: 9),
          Text(label,
              style: const TextStyle(
                color: _kTextPri, fontSize: 13,
                fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  // ── Status summary card ───────────────────────────────────────────────────

  Widget _buildStatusSummary() {
    final isAlert = _critical > 0 || _rdvEnAttente > 0;
    final color   = isAlert ? _kOrange : _kTeal;
    final message = isAlert
        ? '$_critical maintenance${_critical > 1 ? 's' : ''} critique${_critical > 1 ? 's' : ''}'
            '${_rdvEnAttente > 0 ? ' • $_rdvEnAttente RDV en attente' : ''}'
        : 'Tout est en ordre aujourd\'hui 🎉';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.20)),
        boxShadow: [BoxShadow(
          color: color.withOpacity(0.07),
          blurRadius: 14, offset: const Offset(0, 5))],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.10),
            borderRadius: BorderRadius.circular(12)),
          child: Icon(
            isAlert ? Icons.notifications_active_rounded
                    : Icons.check_circle_rounded,
            color: color, size: 22)),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAlert ? 'Attention requise' : 'Statut du garage',
              style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(height: 3),
            Text(message,
                style: const TextStyle(
                  fontSize: 12, color: _kTextSec, height: 1.4)),
          ],
        )),
      ]),
    );
  }
}
