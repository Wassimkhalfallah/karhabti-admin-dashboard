// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import '../../models/appointment_pro_model.dart';
import '../../services/garage_pro_service.dart';

// ══════════════════════════════════════════════════════════════════════════════
// DESIGN TOKENS — Karhabti RDV
// fond blanc pur, accents doux, doré karhabti
// ══════════════════════════════════════════════════════════════════════════════
class _C {
  // Surfaces
  static const bg         = Color(0xFFFFFFFF);
  static const surface    = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF7F9FF);
  static const border     = Color(0xFFEAEEF8);

  // Karhabti doré
  static const gold       = Color(0xFFE6A817);
  static const goldLight  = Color(0xFFFFF4D9);

  // Bleu accent
  static const blue       = Color(0xFF4A6CF7);
  static const blueLight  = Color(0xFFEEF1FF);

  // Statuts
  static const waiting    = Color(0xFFF59E0B);
  static const waitingBg  = Color(0xFFFFFBEB);
  static const confirmed  = Color(0xFF10B981);
  static const confirmedBg= Color(0xFFECFDF5);
  static const cancelled  = Color(0xFFEF4444);
  static const cancelledBg= Color(0xFFFFF1F1);
  static const done       = Color(0xFF8B5CF6);
  static const doneBg     = Color(0xFFF5F3FF);
  static const noshow     = Color(0xFF94A3B8);
  static const noshowBg   = Color(0xFFF1F5F9);

  // Textes
  static const textPri    = Color(0xFF0F172A);
  static const textSec    = Color(0xFF64748B);
  static const textMute   = Color(0xFFB0BEC5);

  // Ombres
  static List<BoxShadow> card = [
    const BoxShadow(color: Color(0x0C0F172A), blurRadius: 10, offset: Offset(0, 2)),
    const BoxShadow(color: Color(0x070F172A), blurRadius: 24, offset: Offset(0, 8)),
  ];
  static List<BoxShadow> pill(Color c) => [
    BoxShadow(color: c.withOpacity(0.24), blurRadius: 10, offset: const Offset(0, 4)),
  ];
}

// ══════════════════════════════════════════════════════════════════════════════
// SCREEN
// ══════════════════════════════════════════════════════════════════════════════
class ResponsableRdvScreen extends StatefulWidget {
  final String garageId;
  const ResponsableRdvScreen({super.key, required this.garageId});

  @override
  State<ResponsableRdvScreen> createState() => _ResponsableRdvScreenState();
}

class _ResponsableRdvScreenState extends State<ResponsableRdvScreen>
    with TickerProviderStateMixin {
  final _service = GarageProService();

  AppointmentStatus? _status;
  bool _loading = true;
  List<AppointmentPro> _rdv = [];

  late AnimationController _listCtrl;
  late AnimationController _statsCtrl;
  late Animation<double>   _statsFade;
  late Animation<Offset>   _statsSlide;

  // ── Compteurs ─────────────────────────────────────────────────────────────
  int get _total     => _rdv.length;
  int get _waiting   => _count(AppointmentStatus.enAttente);
  int get _confirmed => _count(AppointmentStatus.confirme);
  int get _cancelled => _count(AppointmentStatus.annule);
  int get _done      => _rdv.where((r) {
    final s = r.statut;
    return s != AppointmentStatus.enAttente &&
           s != AppointmentStatus.confirme  &&
           s != AppointmentStatus.annule;
  }).length;

  int _count(AppointmentStatus s) =>
      _rdv.where((r) => r.statut == s).length;

  // ── Couleurs statut ───────────────────────────────────────────────────────
  Color _accent(AppointmentStatus s) => switch (s) {
    AppointmentStatus.enAttente => _C.waiting,
    AppointmentStatus.confirme  => _C.confirmed,
    AppointmentStatus.annule    => _C.cancelled,
    _                           => _C.done,
  };
  Color _accentBg(AppointmentStatus s) => switch (s) {
    AppointmentStatus.enAttente => _C.waitingBg,
    AppointmentStatus.confirme  => _C.confirmedBg,
    AppointmentStatus.annule    => _C.cancelledBg,
    _                           => _C.doneBg,
  };
  IconData _icon(AppointmentStatus s) => switch (s) {
    AppointmentStatus.enAttente => Icons.hourglass_top_rounded,
    AppointmentStatus.confirme  => Icons.check_circle_rounded,
    AppointmentStatus.annule    => Icons.cancel_rounded,
    _                           => Icons.done_all_rounded,
  };

  // ── Cycle de vie ─────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _listCtrl  = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 750));
    _statsCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 500));
    _statsFade  = CurvedAnimation(parent: _statsCtrl, curve: Curves.easeOut);
    _statsSlide = Tween<Offset>(
            begin: const Offset(0, -0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _statsCtrl, curve: Curves.easeOutCubic));
    _load();
  }

  @override
  void dispose() {
    _listCtrl.dispose();
    _statsCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _listCtrl.reset();
    _statsCtrl.reset();
    final data = await _service.getAppointments(
        garageId: widget.garageId, statut: _status);
    if (!mounted) return;
    setState(() { _rdv = data; _loading = false; });
    _statsCtrl.forward();
    _listCtrl.forward();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.surfaceAlt,
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildHeader(),
        if (!_loading) _buildStatsRow(),
        _buildFilterSection(),
        const Divider(height: 1, thickness: 1, color: _C.border),
        Expanded(child: _buildBody()),
      ]),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      color: _C.surface,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        // Icône calendrier doré
        Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
            color: _C.goldLight,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(
                color: _C.gold.withOpacity(0.22),
                blurRadius: 14, offset: const Offset(0, 4))],
          ),
          child: const Icon(Icons.calendar_month_rounded, color: _C.gold, size: 26),
        ),
        const SizedBox(width: 16),

        // Titre
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Gestion des Rendez-vous',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                    color: _C.textPri, letterSpacing: -0.4, height: 1.1)),
            if (!_loading)
              Text('$_total rendez-vous au total',
                  style: const TextStyle(fontSize: 13, color: _C.textSec,
                      fontWeight: FontWeight.w500)),
          ],
        )),

        // Actualiser
        _HBtn(label: 'Actualiser', icon: Icons.refresh_rounded,
            color: _C.blue, bg: _C.blueLight, onTap: _load),
        const SizedBox(width: 10),

        // Aujourd'hui
        _HBtn(label: "Aujourd'hui", icon: Icons.today_rounded,
            color: _C.gold, bg: _C.goldLight, onTap: () {}),
      ]),
    );
  }

  // ── Stats ─────────────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return FadeTransition(
      opacity: _statsFade,
      child: SlideTransition(
        position: _statsSlide,
        child: Container(
          color: _C.surface,
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Row(children: [
            _Stat(n: _waiting,   label: 'En attente', icon: Icons.hourglass_top_rounded,
                color: _C.waiting,   bg: _C.waitingBg),
            const SizedBox(width: 8),
            _Stat(n: _confirmed, label: 'Confirmé',   icon: Icons.check_circle_rounded,
                color: _C.confirmed, bg: _C.confirmedBg),
            const SizedBox(width: 8),
            _Stat(n: _cancelled, label: 'Annulé',     icon: Icons.cancel_rounded,
                color: _C.cancelled, bg: _C.cancelledBg),
            const SizedBox(width: 8),
            _Stat(n: _done,      label: 'Terminé',    icon: Icons.done_all_rounded,
                color: _C.done,      bg: _C.doneBg),
            const SizedBox(width: 8),
            _Stat(n: 0,          label: 'No show',    icon: Icons.person_off_rounded,
                color: _C.noshow,    bg: _C.noshowBg),
          ]),
        ),
      ),
    );
  }

  // ── Filtres ───────────────────────────────────────────────────────────────
  Widget _buildFilterSection() {
    return Container(
      color: _C.surface,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // Vue tabs
        Row(children: [
          _ViewTab(label: 'Tous les RDV',    icon: Icons.list_alt_rounded,
              selected: true,  onTap: () {}),
          const SizedBox(width: 8),
          _ViewTab(label: "RDV aujourd'hui", icon: Icons.today_rounded,
              selected: false, onTap: () {}),
        ]),
        const SizedBox(height: 12),

        // Recherche + compteur
        Row(children: [
          Expanded(
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: _C.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _C.border),
              ),
              child: const Row(children: [
                SizedBox(width: 12),
                Icon(Icons.search_rounded, color: _C.textMute, size: 18),
                SizedBox(width: 8),
                Text('Client, garage, immatricula...',
                    style: TextStyle(color: _C.textMute, fontSize: 13)),
              ]),
            ),
          ),
          const SizedBox(width: 12),
          if (!_loading)
            _CountBadge(count: _rdv.length),
        ]),
        const SizedBox(height: 12),

        // Chips statut
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            _SChip(label: 'Tous', icon: Icons.apps_rounded,
                color: _C.blue, bg: _C.blueLight,
                selected: _status == null,
                onTap: () { setState(() => _status = null); _load(); }),
            ...AppointmentStatus.values.map((s) => Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _SChip(
                label: s.label,
                icon: _icon(s),
                color: _accent(s),
                bg: _accentBg(s),
                selected: _status == s,
                onTap: () { setState(() => _status = s); _load(); },
              ),
            )),
          ]),
        ),
      ]),
    );
  }

  // ── Body ─────────────────────────────────────────────────────────────────
  Widget _buildBody() {
    if (_loading) return _buildLoader();
    if (_rdv.isEmpty) return _buildEmpty();
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      itemCount: _rdv.length,
      itemBuilder: (_, i) {
        return AnimatedBuilder(
          animation: _listCtrl,
          builder: (ctx, child) {
            final delay    = (i * 0.08).clamp(0.0, 0.56);
            final t        = ((_listCtrl.value - delay) / 0.36).clamp(0.0, 1.0);
            final progress = Curves.easeOutCubic.transform(t);
            return Opacity(
              opacity: progress,
              child: Transform.translate(
                offset: Offset(0, 22 * (1 - progress)),
                child: child,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _RdvCard(
              appt:       _rdv[i],
              accent:     _accent(_rdv[i].statut),
              accentBg:   _accentBg(_rdv[i].statut),
              statusIcon: _icon(_rdv[i].statut),
              onConfirm:  () async {
                await _service.confirmAppointment(_rdv[i].id); _load();
              },
              onCancel:   () async {
                await _service.cancelAppointment(
                    _rdv[i].id, 'Annulé par responsable', 'garage');
                _load();
              },
              onComplete: () async {
                await _service.completeAppointment(_rdv[i].id); _load();
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoader() {
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      SizedBox(
        width: 46, height: 46,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: const AlwaysStoppedAnimation(_C.gold),
          backgroundColor: _C.goldLight,
        ),
      ),
      const SizedBox(height: 14),
      const Text('Chargement des rendez-vous…',
          style: TextStyle(color: _C.textSec, fontSize: 14)),
    ]));
  }

  Widget _buildEmpty() {
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 84, height: 84,
        decoration: BoxDecoration(
          color: _C.goldLight,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: _C.gold.withOpacity(0.2),
              blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: const Icon(Icons.calendar_today_rounded, size: 40, color: _C.gold),
      ),
      const SizedBox(height: 20),
      const Text('Aucun rendez-vous',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
              color: _C.textPri)),
      const SizedBox(height: 6),
      const Text('Aucun résultat pour ce filtre',
          style: TextStyle(fontSize: 14, color: _C.textSec)),
      const SizedBox(height: 22),
      GestureDetector(
        onTap: () { setState(() => _status = null); _load(); },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
          decoration: BoxDecoration(
            color: _C.goldLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _C.gold.withOpacity(0.35)),
          ),
          child: const Text('Voir tous les RDV',
              style: TextStyle(color: _C.gold, fontSize: 14,
                  fontWeight: FontWeight.w700)),
        ),
      ),
    ]));
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CARTE RDV
// ══════════════════════════════════════════════════════════════════════════════
class _RdvCard extends StatefulWidget {
  final AppointmentPro appt;
  final Color accent;
  final Color accentBg;
  final IconData statusIcon;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final VoidCallback onComplete;

  const _RdvCard({
    required this.appt, required this.accent, required this.accentBg,
    required this.statusIcon, required this.onConfirm,
    required this.onCancel, required this.onComplete,
  });

  @override
  State<_RdvCard> createState() => _RdvCardState();
}

class _RdvCardState extends State<_RdvCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hCtrl;
  late Animation<double>   _hAnim;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _hCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 200));
    _hAnim = CurvedAnimation(parent: _hCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() { _hCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final a      = widget.appt;
    final col    = widget.accent;
    final soft   = widget.accentBg;
    final canAct = a.statut == AppointmentStatus.enAttente ||
                   a.statut == AppointmentStatus.confirme;

    // Motif annulation — accès sécurisé
    String? motif;
    try {
      final m = (a as dynamic).motifAnnulation as String?;
      if (m != null && m.isNotEmpty) motif = m;
    } catch (_) {}

    // Nom garage — accès sécurisé
    String garageNom = 'Garage';
    try {
      final g = (a as dynamic).garageNom as String?;
      if (g != null && g.isNotEmpty) garageNom = g;
    } catch (_) {}

    return MouseRegion(
      onEnter: (_) { setState(() => _hovered = true);  _hCtrl.forward(); },
      onExit:  (_) { setState(() => _hovered = false); _hCtrl.reverse(); },
      child: AnimatedBuilder(
        animation: _hAnim,
        builder: (ctx, child) => Container(
          decoration: BoxDecoration(
            color: _C.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Color.lerp(_C.border, col.withOpacity(0.4), _hAnim.value)!,
              width: _hovered ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Color.lerp(
                    const Color(0x0C0F172A),
                    col.withOpacity(0.14),
                    _hAnim.value)!,
                blurRadius: 10 + 18 * _hAnim.value,
                offset: Offset(0, 2 + 5 * _hAnim.value),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: child,
        ),
        child: IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [

            // ── Bande colorée verticale gauche ───────────────────────────
            Container(
              width: 6,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [col, col.withOpacity(0.35)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // ── Contenu ──────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Ligne 1 : statut badge + client + actions rapides ─
                    Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                      // Badge statut
                      _StatusPill(
                        icon: widget.statusIcon,
                        label: a.statut.label,
                        color: col,
                        bg: soft,
                      ),
                      const SizedBox(width: 12),
                      // Client
                      Expanded(child: Text(
                        a.clientNom ?? 'Client',
                        style: const TextStyle(fontSize: 15,
                            fontWeight: FontWeight.w700, color: _C.textPri),
                        overflow: TextOverflow.ellipsis,
                      )),
                      // Boutons rapides ✓ ✗
                      if (canAct) ...[
                        if (a.statut == AppointmentStatus.enAttente)
                          _QBtn(icon: Icons.check_rounded,
                              color: _C.confirmed, onTap: widget.onConfirm),
                        if (a.statut != AppointmentStatus.annule) ...[
                          const SizedBox(width: 6),
                          _QBtn(icon: Icons.close_rounded,
                              color: _C.cancelled, onTap: widget.onCancel),
                        ],
                      ],
                    ]),

                    const SizedBox(height: 10),

                    // ── Ligne 2 : prestation ─────────────────────────────
                    _InfoRow(
                      icon: Icons.build_circle_outlined,
                      iconColor: col,
                      text: a.typePrestation,
                      bold: false,
                    ),
                    const SizedBox(height: 5),

                    // ── Ligne 3 : garage ──────────────────────────────────
                    _InfoRow(
                      icon: Icons.store_mall_directory_outlined,
                      iconColor: _C.textMute,
                      text: garageNom,
                    ),
                    const SizedBox(height: 5),

                    // ── Ligne 4 : immat + date ────────────────────────────
                    Row(children: [
                      const Icon(Icons.directions_car_outlined,
                          size: 14, color: _C.textMute),
                      const SizedBox(width: 7),
                      Text(a.immatriculation,
                          style: const TextStyle(fontSize: 13,
                              color: _C.textSec, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 18),
                      const Icon(Icons.calendar_today_outlined,
                          size: 14, color: _C.textMute),
                      const SizedBox(width: 7),
                      Expanded(child: Text(a.heureStr,
                          style: const TextStyle(fontSize: 13,
                              color: _C.textSec))),
                    ]),

                    // ── Motif annulation ──────────────────────────────────
                    if (motif != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 9),
                        decoration: BoxDecoration(
                          color: _C.cancelledBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: _C.cancelled.withOpacity(0.22)),
                        ),
                        child: Row(children: [
                          const Icon(Icons.info_outline_rounded,
                              size: 14, color: _C.cancelled),
                          const SizedBox(width: 8),
                          Expanded(child: Text('Motif : $motif',
                              style: const TextStyle(fontSize: 12,
                                  color: _C.cancelled,
                                  fontWeight: FontWeight.w500))),
                        ]),
                      ),
                    ],

                    // ── Actions complètes ──────────────────────────────────
                    if (canAct) ...[
                      const SizedBox(height: 12),
                      const Divider(height: 1, color: _C.border),
                      const SizedBox(height: 12),
                      Row(children: [
                        if (a.statut == AppointmentStatus.enAttente) ...[
                          Expanded(child: _ABtn(
                            label: 'Confirmer',
                            icon: Icons.check_circle_rounded,
                            color: _C.confirmed,
                            filled: true,
                            onTap: widget.onConfirm,
                          )),
                          const SizedBox(width: 8),
                        ],
                        if (a.statut == AppointmentStatus.confirme) ...[
                          Expanded(child: _ABtn(
                            label: 'Terminer',
                            icon: Icons.done_all_rounded,
                            color: _C.done,
                            filled: true,
                            onTap: widget.onComplete,
                          )),
                          const SizedBox(width: 8),
                        ],
                        Expanded(child: _ABtn(
                          label: 'Annuler',
                          icon: Icons.cancel_rounded,
                          color: _C.cancelled,
                          filled: false,
                          onTap: widget.onCancel,
                        )),
                      ]),
                    ],
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// WIDGETS ATOMIQUES
// ══════════════════════════════════════════════════════════════════════════════

/// Bouton header (Actualiser / Aujourd'hui)
class _HBtn extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color bg;
  final VoidCallback onTap;
  const _HBtn({required this.label, required this.icon,
      required this.color, required this.bg, required this.onTap});
  @override State<_HBtn> createState() => _HBtnState();
}
class _HBtnState extends State<_HBtn> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this,
      duration: const Duration(milliseconds: 100));
  late final Animation<double> _s = Tween<double>(begin: 1.0, end: 0.93)
      .animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
  @override void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => ScaleTransition(
    scale: _s,
    child: GestureDetector(
      onTapDown: (_) => _c.forward(),
      onTapUp:   (_) { _c.reverse(); widget.onTap(); },
      onTapCancel: () => _c.reverse(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: widget.bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: widget.color.withOpacity(0.25)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(widget.icon, size: 16, color: widget.color),
          const SizedBox(width: 7),
          Text(widget.label, style: TextStyle(color: widget.color,
              fontSize: 13, fontWeight: FontWeight.w700)),
        ]),
      ),
    ),
  );
}

/// Pilule stat (En attente N …)
class _Stat extends StatelessWidget {
  final int n;
  final String label;
  final IconData icon;
  final Color color;
  final Color bg;
  const _Stat({required this.n, required this.label,
      required this.icon, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 8),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 10,
                color: color.withOpacity(0.8), fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis),
            Text('$n', style: TextStyle(fontSize: 17, color: color,
                fontWeight: FontWeight.w800, height: 1.15)),
          ],
        )),
      ]),
    ),
  );
}

/// Onglet vue
class _ViewTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _ViewTab({required this.label, required this.icon,
      required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? _C.blueLight : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: selected ? _C.blue.withOpacity(0.3) : _C.border),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 15, color: selected ? _C.blue : _C.textSec),
        const SizedBox(width: 7),
        Text(label, style: TextStyle(fontSize: 13,
            color: selected ? _C.blue : _C.textSec,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
      ]),
    ),
  );
}

/// Chip filtre statut
class _SChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color bg;
  final bool selected;
  final VoidCallback onTap;
  const _SChip({required this.label, required this.icon,
      required this.color, required this.bg,
      required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? color : Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
            color: selected ? color : _C.border, width: 1.5),
        boxShadow: selected ? _C.pill(color) : [],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: selected ? Colors.white : color),
        const SizedBox(width: 6),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 160),
          style: TextStyle(
            color: selected ? Colors.white : _C.textSec,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
          child: Text(label),
        ),
      ]),
    ),
  );
}

/// Badge compteur "N résultats"
class _CountBadge extends StatelessWidget {
  final int count;
  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: _C.blueLight,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: _C.blue.withOpacity(0.2)),
    ),
    child: Text('$count résultat${count > 1 ? 's' : ''}',
        style: const TextStyle(color: _C.blue, fontSize: 12,
            fontWeight: FontWeight.w700)),
  );
}

/// Badge statut arrondi (dans la carte)
class _StatusPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bg;
  const _StatusPill({required this.icon, required this.label,
      required this.color, required this.bg});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: color),
      const SizedBox(width: 5),
      Text(label, style: TextStyle(color: color, fontSize: 12,
          fontWeight: FontWeight.w700)),
    ]),
  );
}

/// Ligne info (icône + texte)
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;
  final bool bold;
  const _InfoRow({required this.icon, required this.iconColor,
      required this.text, this.bold = false});

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 14, color: iconColor),
    const SizedBox(width: 7),
    Expanded(child: Text(text,
        style: TextStyle(fontSize: 13, color: _C.textSec,
            fontWeight: bold ? FontWeight.w600 : FontWeight.w400),
        overflow: TextOverflow.ellipsis)),
  ]);
}

/// Bouton action rapide (✓ ✗ icône seul)
class _QBtn extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _QBtn({required this.icon, required this.color, required this.onTap});
  @override State<_QBtn> createState() => _QBtnState();
}
class _QBtnState extends State<_QBtn> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this,
      duration: const Duration(milliseconds: 100));
  late final Animation<double> _s = Tween<double>(begin: 1.0, end: 0.84)
      .animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
  @override void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => ScaleTransition(
    scale: _s,
    child: GestureDetector(
      onTapDown: (_) => _c.forward(),
      onTapUp:   (_) { _c.reverse(); widget.onTap(); },
      onTapCancel: () => _c.reverse(),
      child: Container(
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: widget.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: widget.color.withOpacity(0.3)),
        ),
        child: Icon(widget.icon, size: 16, color: widget.color),
      ),
    ),
  );
}

/// Bouton action pleine largeur (Confirmer / Terminer / Annuler)
class _ABtn extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool filled;
  final VoidCallback onTap;
  const _ABtn({required this.label, required this.icon,
      required this.color, required this.filled, required this.onTap});
  @override State<_ABtn> createState() => _ABtnState();
}
class _ABtnState extends State<_ABtn> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this,
      duration: const Duration(milliseconds: 100));
  late final Animation<double> _s = Tween<double>(begin: 1.0, end: 0.95)
      .animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
  @override void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final fg = widget.filled ? Colors.white : widget.color;
    return ScaleTransition(
      scale: _s,
      child: GestureDetector(
        onTapDown: (_) => _c.forward(),
        onTapUp:   (_) { _c.reverse(); widget.onTap(); },
        onTapCancel: () => _c.reverse(),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: widget.filled
                ? widget.color
                : widget.color.withOpacity(0.07),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.filled ? widget.color : widget.color.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: widget.filled ? _C.pill(widget.color) : [],
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(widget.icon, size: 15, color: fg),
            const SizedBox(width: 6),
            Text(widget.label, style: TextStyle(color: fg,
                fontSize: 13, fontWeight: FontWeight.w700)),
          ]),
        ),
      ),
    );
  }
}