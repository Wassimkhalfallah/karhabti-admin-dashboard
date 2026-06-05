import 'package:flutter/material.dart';
import '../../models/appointment_pro_model.dart';
import '../../services/responsable_technicien_service.dart';
import '../../services/garage_pro_service.dart';
import 'rdv_screen.dart';
import 'vehicules_screen.dart';
import 'mon_garage_screen.dart';

// ── Design tokens (palette douce & lumineuse) ──────────────────────────────
const _kPrimary   = Color(0xFF5B6EF5);
const _kPrimaryLt = Color(0xFF818CF8);
const _kTeal      = Color(0xFF06C8B4);
const _kOrange    = Color(0xFFFF8C42);
const _kGold      = Color(0xFFFFB931);
const _kBg        = Color(0xFFF8FAFF);
const _kTextPri   = Color(0xFF1A1D2E);
const _kTextSec   = Color(0xFF64748B);

class ResponsableDashboardScreen extends StatefulWidget {
  const ResponsableDashboardScreen({super.key});

  @override
  State<ResponsableDashboardScreen> createState() =>
      _ResponsableDashboardScreenState();
}

class _ResponsableDashboardScreenState
    extends State<ResponsableDashboardScreen> with TickerProviderStateMixin {
  final _service      = ResponsableTechnicienService();
  final _garageService = GarageProService();

  bool    _loading      = true;
  int     _rdvEnAttente = 0;
  int     _rdvSemaine   = 0;
  int     _critical     = 0;
  double  _note         = 0;
  String? _garageId;

  late AnimationController _fadeCtrl;
  late AnimationController _slideCtrl;
  late Animation<double>   _fadeAnim;
  late List<Animation<Offset>> _slideAnims;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700));
    _slideCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1000));

    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideAnims = List.generate(8, (i) {
      final start = (i * 0.07).clamp(0.0, 0.6);
      final end   = (start + 0.5).clamp(0.0, 1.0);
      return Tween<Offset>(begin: const Offset(0, 0.28), end: Offset.zero)
          .animate(CurvedAnimation(
            parent: _slideCtrl,
            curve: Interval(start, end, curve: Curves.easeOutCubic),
          ));
    });
    _load();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _fadeCtrl.reset();
    _slideCtrl.reset();

    final profile = await _service.getMyProfile();
    if (profile?.garageId == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    _garageId = profile!.garageId;

    final now      = DateTime.now();
    final startDay = DateTime(now.year, now.month, now.day);
    final endDay   = startDay.add(const Duration(days: 1));
    final weekEnd  = startDay.add(const Duration(days: 7));

    final pendingToday = await _garageService.getAppointments(
      garageId: _garageId, statut: AppointmentStatus.enAttente,
      dateDebut: startDay, dateFin: endDay,
    );
    final confirmedWeek = await _garageService.getAppointments(
      garageId: _garageId, statut: AppointmentStatus.confirme,
      dateDebut: startDay, dateFin: weekEnd,
    );
    final vehicules = await _service.getVehiculesDuGarage(_garageId!);
    _critical = vehicules.where((v) {
      final p = v['prediction'] as Map<String, dynamic>?;
      if (p == null) return false;
      return [
        p['tire_wear'], p['battery_health'], p['brake_wear'],
        p['oil_change'], p['belt_risk'], p['clutch_wear'], p['ShockAbsorber_Wear'],
      ].any((e) => (e as num?) != null && e! >= 70);
    }).length;

    final garage = await _garageService.getGarageById(_garageId!);
    if (mounted) {
      setState(() {
        _rdvEnAttente = pendingToday.length;
        _rdvSemaine   = confirmedWeek.length;
        _note         = garage?.noteMoyenne ?? 0;
        _loading      = false;
      });
      _fadeCtrl.forward();
      _slideCtrl.forward();
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: _kBg,
        body: Center(child: _PulsingLoader()),
      );
    }

    return Scaffold(
      backgroundColor: _kBg,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Stat section ─────────────────────────────────────
              SlideTransition(
                position: _slideAnims[0],
                child: _sectionHeader('Statistiques clés', Icons.bar_chart_rounded),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.35,
                children: [
                  SlideTransition(position: _slideAnims[1],
                    child: _statCard('RDV en attente', '$_rdvEnAttente', "Aujourd'hui",
                        Icons.pending_actions_rounded, const Color(0xFFEEF2FF), _kPrimary)),
                  SlideTransition(position: _slideAnims[2],
                    child: _statCard('RDV confirmés', '$_rdvSemaine', '7 prochains jours',
                        Icons.event_available_rounded, const Color(0xFFE0FFF9), _kTeal)),
                  SlideTransition(position: _slideAnims[3],
                    child: _statCard('Maintenances', '$_critical', 'Cas critiques',
                        Icons.warning_amber_rounded, const Color(0xFFFFF4ED), _kOrange)),
                  SlideTransition(position: _slideAnims[4],
                    child: _statCard('Note Garage', _note.toStringAsFixed(1), 'Moyenne actuelle',
                        Icons.star_rounded, const Color(0xFFFFFBEB), _kGold)),
                ],
              ),

              const SizedBox(height: 36),

              // ── Quick actions ─────────────────────────────────────
              SlideTransition(
                position: _slideAnims[5],
                child: _sectionHeader('Actions rapides', Icons.flash_on_rounded),
              ),
              const SizedBox(height: 16),
              SlideTransition(
                position: _slideAnims[6],
                child: _menuItem(
                  title: 'Gestion des Rendez-vous',
                  subtitle: 'Consulter et valider les demandes',
                  icon: Icons.calendar_month_rounded,
                  gradient: const LinearGradient(
                    colors: [_kPrimary, _kPrimaryLt],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  onTap: _garageId == null ? null
                      : () => Navigator.push(context, _slide(ResponsableRdvScreen(garageId: _garageId!))),
                ),
              ),
              const SizedBox(height: 12),
              SlideTransition(
                position: _slideAnims[6],
                child: _menuItem(
                  title: 'Suivi des Véhicules',
                  subtitle: 'État et prédictions de maintenance',
                  icon: Icons.directions_car_rounded,
                  gradient: const LinearGradient(
                    colors: [_kTeal, Color(0xFF34D9C3)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  onTap: _garageId == null ? null
                      : () => Navigator.push(context, _slide(ResponsableVehiculesScreen(garageId: _garageId!))),
                ),
              ),
              const SizedBox(height: 12),
              SlideTransition(
                position: _slideAnims[7],
                child: _menuItem(
                  title: 'Profil du Garage',
                  subtitle: 'Paramètres et informations',
                  icon: Icons.store_rounded,
                  gradient: const LinearGradient(
                    colors: [_kOrange, Color(0xFFFFAD75)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  onTap: _garageId == null ? null
                      : () => Navigator.push(context, _slide(MonGarageScreen(garageId: _garageId!))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      title: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_kPrimary, _kPrimaryLt],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.dashboard_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tableau de bord',
                style: TextStyle(color: _kTextPri, fontSize: 17,
                    fontWeight: FontWeight.w800, height: 1.1)),
              Text('Responsable technicien',
                style: TextStyle(color: _kTextSec, fontSize: 11,
                    fontWeight: FontWeight.w400)),
            ],
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: _kPrimary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded, color: _kPrimary, size: 20),
            tooltip: 'Actualiser',
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: const Color(0xFFF0F2FF)),
      ),
    );
  }

  // ── Section header ────────────────────────────────────────────────────────

  Widget _sectionHeader(String title, IconData icon) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: _kPrimary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: _kPrimary, size: 15),
      ),
      const SizedBox(width: 10),
      Text(title, style: const TextStyle(
        fontSize: 16, fontWeight: FontWeight.w800,
        color: _kTextPri, letterSpacing: 0.2)),
    ]);
  }

  // ── Stat card ─────────────────────────────────────────────────────────────

  Widget _statCard(String title, String value, String subtitle,
      IconData icon, Color bgColor, Color accent) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(
          color: accent.withOpacity(0.10),
          blurRadius: 18, offset: const Offset(0, 6))],
        border: Border.all(color: accent.withOpacity(0.08)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accent, accent.withOpacity(0.3)])),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(10)),
                          child: Icon(icon, color: accent, size: 18)),
                        Text(value, style: TextStyle(
                          fontSize: 26, fontWeight: FontWeight.w800,
                          color: accent)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12,
                            fontWeight: FontWeight.w600, color: _kTextPri)),
                        const SizedBox(height: 2),
                        Text(subtitle, style: const TextStyle(
                          fontSize: 10, color: _kTextSec)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Menu action card ──────────────────────────────────────────────────────

  Widget _menuItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required LinearGradient gradient,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: gradient.colors.first.withOpacity(0.07),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(
                    color: gradient.colors.first.withOpacity(0.28),
                    blurRadius: 12, offset: const Offset(0, 4))]),
                child: Icon(icon, color: Colors.white, size: 26)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700,
                      color: _kTextPri)),
                    const SizedBox(height: 3),
                    Text(subtitle, style: const TextStyle(
                      fontSize: 12, color: _kTextSec)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: gradient.colors.first.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.arrow_forward_ios_rounded,
                  color: gradient.colors.first, size: 13)),
            ]),
          ),
        ),
      ),
    );
  }

  // ── Page transition ───────────────────────────────────────────────────────

  Route<dynamic> _slide(Widget page) => PageRouteBuilder(
    pageBuilder: (_, a, __) => page,
    transitionsBuilder: (_, a, __, child) => SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0), end: Offset.zero,
      ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
      child: child,
    ),
  );
}

// ── Pulsing loader widget ─────────────────────────────────────────────────

class _PulsingLoader extends StatefulWidget {
  const _PulsingLoader();
  @override
  State<_PulsingLoader> createState() => _PulsingLoaderState();
}

class _PulsingLoaderState extends State<_PulsingLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.88, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 68, height: 68,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_kPrimary, _kPrimaryLt],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(
              color: _kPrimary.withOpacity(0.28),
              blurRadius: 22, offset: const Offset(0, 8))]),
          child: const Icon(Icons.dashboard_rounded, color: Colors.white, size: 34)),
        const SizedBox(height: 22),
        const SizedBox(
          width: 28, height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(_kPrimary))),
      ]),
    );
  }
}
