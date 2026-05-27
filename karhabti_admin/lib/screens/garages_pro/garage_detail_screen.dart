// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/garage_pro_model.dart';
import '../../models/appointment_pro_model.dart';
import '../../models/review_pro_model.dart';
import '../../services/garage_pro_service.dart';
import 'garage_form_screen.dart';

class GarageDetailScreen extends StatefulWidget {
  final String garageId;
  const GarageDetailScreen({super.key, required this.garageId});

  @override
  State<GarageDetailScreen> createState() => _GarageDetailScreenState();
}

class _GarageDetailScreenState extends State<GarageDetailScreen>
    with SingleTickerProviderStateMixin {
  final GarageProService _service = GarageProService();
  late TabController _tabCtrl;

  GaragePro? _garage;
  List<AppointmentPro> _appointments = [];
  List<ReviewPro> _reviews = [];
  bool _loading = true;

  // ─── Design tokens (cohérents avec la liste) ──────────────────────────────
  static const _bg = Color(0xFF0F172A);
  static const _surface = Color(0xFF1E293B);
  static const _surface2 = Color(0xFF334155);
  static const _amber = Color(0xFFF59E0B);
  static const _emerald = Color(0xFF10B981);
  static const _sky = Color(0xFF0EA5E9);
  static const _rose = Color(0xFFf43f5e);
  static const _violet = Color(0xFF8B5CF6);
  static const _textPri = Color(0xFFF1F5F9);
  static const _textSec = Color(0xFF94A3B8);
  static const _border = Color(0xFF334155);

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final g = await _service.getGarageById(widget.garageId);
    final rdv = await _service.getGarageAppointments(widget.garageId);
    final avis = await _service.getGarageReviews(widget.garageId);
    if (mounted) {
      setState(() {
        _garage = g;
        _appointments = rdv;
        _reviews = avis;
        _loading = false;
      });
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: _bg,
        body: Center(child: CircularProgressIndicator(color: _amber)),
      );
    }

    final g = _garage!;
    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          _buildHeader(g),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _buildInfoTab(g),
                _buildRdvTab(),
                _buildAvisTab(),
                _buildHistoriqueTab(g),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Header hero ──────────────────────────────────────────────────────────

  Widget _buildHeader(GaragePro g) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        border: const Border(bottom: BorderSide(color: _border)),
      ),
      child: Column(
        children: [
          // Cover photo + overlay
          Stack(
            children: [
              SizedBox(
                height: 160,
                width: double.infinity,
                child:
                    g.photoCouverture != null
                        ? Image.network(
                          g.photoCouverture!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _coverPlaceholder(),
                        )
                        : _coverPlaceholder(),
              ),
              // Gradient overlay
              Container(
                height: 160,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, _surface],
                  ),
                ),
              ),
              // Back + Edit buttons
              Positioned(
                top: 12,
                left: 16,
                child: _glassBtn(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => Navigator.pop(context),
                ),
              ),
              Positioned(
                top: 12,
                right: 16,
                child: Row(
                  children: [
                    _glassBtn(icon: Icons.refresh_rounded, onTap: _loadData),
                    const SizedBox(width: 8),
                    _glassBtn(
                      icon: Icons.edit_rounded,
                      color: _amber,
                      onTap: () async {
                        final result = await showDialog<bool>(
                          context: context,
                          barrierColor: Colors.black.withOpacity(0.7),
                          builder: (_) => GarageFormScreen(garage: g),
                        );
                        if (result == true) _loadData();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Infos principales
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Logo circle
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _surface2,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _amber.withOpacity(0.4),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      g.nom.isNotEmpty ? g.nom[0].toUpperCase() : 'G',
                      style: const TextStyle(
                        color: _amber,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Nom + badges
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        g.nom,
                        style: const TextStyle(
                          color: _textPri,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _headerBadge(
                            g.estVerifie ? 'Vérifié' : 'Non vérifié',
                            Icons.verified_rounded,
                            g.estVerifie ? _emerald : _textSec,
                          ),
                          const SizedBox(width: 8),
                          _headerBadge(
                            g.estActif ? 'Actif' : 'Inactif',
                            Icons.circle,
                            g.estActif ? _sky : _rose,
                          ),
                          const SizedBox(width: 8),
                          _headerBadge(
                            g.accepteRdvEnLigne ? 'RDV en ligne' : 'Pas de RDV',
                            Icons.calendar_today_rounded,
                            g.accepteRdvEnLigne ? _violet : _textSec,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Note + avis
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: _amber, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          g.noteMoyenne.toStringAsFixed(1),
                          style: const TextStyle(
                            color: _amber,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${g.nombreAvis} avis',
                      style: const TextStyle(color: _textSec, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassBtn({
    required IconData icon,
    required VoidCallback onTap,
    Color color = _textPri,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.45),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Icon(icon, size: 17, color: color),
      ),
    );
  }

  Widget _headerBadge(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 5),
          Text(
            label,
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

  Widget _coverPlaceholder() => Container(
    color: _surface2,
    child: Center(child: Icon(Icons.store_rounded, size: 48, color: _textSec)),
  );

  // ─── Tab bar ──────────────────────────────────────────────────────────────

  Widget _buildTabBar() {
    return Container(
      color: _surface,
      child: TabBar(
        controller: _tabCtrl,
        indicatorColor: _amber,
        indicatorWeight: 2.5,
        labelColor: _amber,
        unselectedLabelColor: _textSec,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontSize: 13),
        tabs: [
          _tab(Icons.info_rounded, 'Informations'),
          _tab(
            Icons.calendar_month_rounded,
            'Rendez-vous (${_appointments.length})',
          ),
          _tab(Icons.reviews_rounded, 'Avis (${_reviews.length})'),
          _tab(Icons.history_rounded, 'Historique'),
        ],
      ),
    );
  }

  Tab _tab(IconData icon, String label) => Tab(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [Icon(icon, size: 15), const SizedBox(width: 7), Text(label)],
    ),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 1 — INFORMATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildInfoTab(GaragePro g) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Ligne principale
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _infoCard(
                      'Informations générales',
                      Icons.store_rounded,
                      _sky,
                      [
                        _row('Nom', g.nom),
                        _row('Adresse', g.adresse),
                        _row('Ville', g.ville),
                        if (g.codePostal != null)
                          _row('Code postal', g.codePostal!),
                        if (g.description != null)
                          _row('Description', g.description!),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _infoCard(
                      'Contact',
                      Icons.contact_phone_rounded,
                      _emerald,
                      [
                        if (g.telephone != null)
                          _row('Téléphone', g.telephone!),
                        if (g.telephoneSecondaire != null)
                          _row('Tél. secondaire', g.telephoneSecondaire!),
                        if (g.email != null) _row('Email', g.email!),
                        if (g.siteWeb != null) _row('Site web', g.siteWeb!),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    _infoCard('Paramètres', Icons.tune_rounded, _violet, [
                      _rowWidget(
                        'Vérifié',
                        _dot(
                          g.estVerifie,
                          _emerald,
                          g.estVerifie ? 'Oui' : 'Non',
                        ),
                      ),
                      _rowWidget(
                        'Actif',
                        _dot(g.estActif, _sky, g.estActif ? 'Oui' : 'Non'),
                      ),
                      _rowWidget(
                        'RDV en ligne',
                        _dot(
                          g.accepteRdvEnLigne,
                          _violet,
                          g.accepteRdvEnLigne ? 'Oui' : 'Non',
                        ),
                      ),
                      _row('Délai confirmation', '${g.delaiConfirmation}h max'),
                    ]),
                    const SizedBox(height: 16),
                    _infoCard('Localisation', Icons.pin_drop_rounded, _amber, [
                      _row('Latitude', g.latitude.toStringAsFixed(6)),
                      _row('Longitude', g.longitude.toStringAsFixed(6)),
                      if (g.googlePlaceId != null)
                        _row('Google Place ID', g.googlePlaceId!),
                    ]),
                    const SizedBox(height: 16),
                    _infoCard(
                      'Spécialités',
                      Icons.build_circle_rounded,
                      _rose,
                      [
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children:
                              g.specialites
                                  .map(
                                    (s) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _rose.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: _rose.withOpacity(0.25),
                                        ),
                                      ),
                                      child: Text(
                                        s,
                                        style: const TextStyle(
                                          color: _rose,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Horaires (full width)
          _infoCard('Horaires d\'ouverture', Icons.schedule_rounded, _amber, [
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.5,
              children:
                  [
                    'lundi',
                    'mardi',
                    'mercredi',
                    'jeudi',
                    'vendredi',
                    'samedi',
                    'dimanche',
                  ].map((j) => _horaireCard(j, g)).toList(),
            ),
          ]),
          // Photos sup
          if (g.photos.isNotEmpty) ...[
            const SizedBox(height: 16),
            _infoCard('Galerie photos', Icons.photo_library_rounded, _violet, [
              SizedBox(
                height: 90,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: g.photos.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder:
                      (_, i) => ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          g.photos[i],
                          width: 120,
                          height: 90,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) => Container(
                                width: 120,
                                height: 90,
                                color: _surface2,
                                child: const Icon(
                                  Icons.broken_image_rounded,
                                  color: _textSec,
                                ),
                              ),
                        ),
                      ),
                ),
              ),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _infoCard(
    String title,
    IconData icon,
    Color color,
    List<Widget> children,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              border: Border(
                bottom: BorderSide(color: color.withOpacity(0.12)),
                left: BorderSide(color: color, width: 3),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 9),
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: const TextStyle(color: _textSec, fontSize: 12),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: _textPri,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _rowWidget(String label, Widget widget) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: const TextStyle(color: _textSec, fontSize: 12),
          ),
        ),
        widget,
      ],
    ),
  );

  Widget _dot(bool active, Color color, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          color: active ? color : _surface2,
          shape: BoxShape.circle,
          border: Border.all(color: active ? color : _textSec, width: 1.2),
        ),
      ),
      const SizedBox(width: 7),
      Text(
        label,
        style: TextStyle(
          color: active ? color : _textSec,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );

  Widget _horaireCard(String jour, GaragePro g) {
    final info = g.getHoraireJour(jour);
    final hData = g.horaires[jour] as Map<String, dynamic>?;
    final isOpen = hData?['ouvert'] as bool? ?? false;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isOpen ? _amber.withOpacity(0.07) : _surface2.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isOpen ? _amber.withOpacity(0.25) : _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            jour[0].toUpperCase() + jour.substring(1),
            style: TextStyle(
              color: isOpen ? _amber : _textSec,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            info,
            style: TextStyle(
              color: isOpen ? _textPri : _textSec,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 2 — RENDEZ-VOUS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildRdvTab() {
    if (_appointments.isEmpty) {
      return _emptyState(
        Icons.calendar_today_rounded,
        'Aucun rendez-vous',
        'Les rendez-vous apparaîtront ici',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _appointments.length,
      itemBuilder: (_, i) => _rdvCard(_appointments[i]),
    );
  }

  Widget _rdvCard(AppointmentPro a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: a.statut.color, width: 3),
          top: BorderSide(color: _border),
          right: BorderSide(color: _border),
          bottom: BorderSide(color: _border),
        ),
      ),
      child: Row(
        children: [
          // Date badge
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: a.statut.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('dd').format(a.dateRendezVous),
                  style: TextStyle(
                    color: a.statut.color,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  DateFormat('MMM').format(a.dateRendezVous).toUpperCase(),
                  style: TextStyle(
                    color: a.statut.color,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.typePrestation,
                  style: const TextStyle(
                    color: _textPri,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(
                      Icons.directions_car_rounded,
                      size: 12,
                      color: _textSec,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      a.immatriculation,
                      style: const TextStyle(color: _textSec, fontSize: 12),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.schedule_rounded,
                      size: 12,
                      color: _textSec,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      a.heureStr,
                      style: const TextStyle(color: _textSec, fontSize: 12),
                    ),
                  ],
                ),
                if (a.clientNom != null) ...[
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_rounded,
                        size: 12,
                        color: _textSec,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        a.clientNom!,
                        style: const TextStyle(color: _textSec, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // Statut badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: a.statut.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              a.statut.label,
              style: TextStyle(
                color: a.statut.color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 3 — AVIS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildAvisTab() {
    if (_reviews.isEmpty) {
      return _emptyState(
        Icons.reviews_rounded,
        'Aucun avis',
        'Les avis clients apparaîtront ici',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _reviews.length,
      itemBuilder: (_, i) => _avisCard(_reviews[i]),
    );
  }

  Widget _avisCard(ReviewPro r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _violet.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Center(
                  child: Text(
                    (r.clientNom ?? 'C').isNotEmpty
                        ? (r.clientNom ?? 'C')[0].toUpperCase()
                        : 'C',
                    style: const TextStyle(
                      color: _violet,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.clientNom ?? 'Client anonyme',
                      style: const TextStyle(
                        color: _textPri,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < r.note
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: _amber,
                          size: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Visibilité badge + toggle
              GestureDetector(
                onTap: () => _toggleVisibility(r),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color:
                        r.estVisible
                            ? _emerald.withOpacity(0.1)
                            : _rose.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          r.estVisible
                              ? _emerald.withOpacity(0.3)
                              : _rose.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        r.estVisible
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                        size: 12,
                        color: r.estVisible ? _emerald : _rose,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        r.estVisible ? 'Visible' : 'Masqué',
                        style: TextStyle(
                          color: r.estVisible ? _emerald : _rose,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Commentaire
          if (r.commentaire != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _border),
              ),
              child: Text(
                r.commentaire!,
                style: const TextStyle(
                  color: _textSec,
                  fontSize: 12.5,
                  height: 1.5,
                ),
              ),
            ),
          ],

          // Réponse garage
          if (r.aReponse) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _violet.withOpacity(0.06),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _violet.withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.reply_rounded, size: 14, color: _violet),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      r.reponseGarage!,
                      style: const TextStyle(
                        color: _textSec,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Actions
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _textActionBtn(
                icon:
                    r.estVisible
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                label: r.estVisible ? 'Masquer' : 'Afficher',
                color: r.estVisible ? _rose : _emerald,
                onTap: () => _toggleVisibility(r),
              ),
              const SizedBox(width: 10),
              _textActionBtn(
                icon: Icons.reply_rounded,
                label: r.aReponse ? 'Modifier la réponse' : 'Répondre',
                color: _violet,
                onTap: () => _replyToReview(r),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _textActionBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 4 — HISTORIQUE
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildHistoriqueTab(GaragePro g) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _infoCard('Horodatage', Icons.history_rounded, _sky, [
            _row(
              'Créé le',
              DateFormat('dd/MM/yyyy à HH:mm').format(g.createdAt),
            ),
            _row(
              'Dernière mise à jour',
              DateFormat('dd/MM/yyyy à HH:mm').format(g.updatedAt),
            ),
            _row('Slug URL', g.slug),
          ]),
          const SizedBox(height: 16),
          _infoCard('Journal d\'audit', Icons.shield_rounded, _textSec, [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _border),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: _textSec,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Les modifications détaillées sont disponibles via '
                      'le journal d\'audit Supabase dans la section Administration.',
                      style: TextStyle(
                        color: _textSec,
                        fontSize: 12.5,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ],
      ),
    );
  }

  // ─── Shared ───────────────────────────────────────────────────────────────

  Widget _emptyState(IconData icon, String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _border),
            ),
            child: Icon(icon, size: 30, color: _textSec),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: _textPri,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(color: _textSec, fontSize: 13)),
        ],
      ),
    );
  }

  // ─── Dialogs ──────────────────────────────────────────────────────────────

  Future<void> _toggleVisibility(ReviewPro r) async {
    await _service.toggleReviewVisibility(r.id, !r.estVisible);
    _loadData();
  }

  Future<void> _replyToReview(ReviewPro r) async {
    final ctrl = TextEditingController(text: r.reponseGarage ?? '');
    final reponse = await showDialog<String>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder:
          (_) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: 480,
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _border),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dialog header
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
                    decoration: BoxDecoration(
                      color: _violet.withOpacity(0.08),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      border: Border(
                        bottom: BorderSide(color: _violet.withOpacity(0.2)),
                        left: BorderSide(color: _violet, width: 3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.reply_rounded,
                          color: _violet,
                          size: 16,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Répondre à l\'avis',
                            style: TextStyle(
                              color: _violet,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            color: _textSec,
                            size: 18,
                          ),
                          onPressed: () => Navigator.pop(context),
                          splashRadius: 16,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        TextField(
                          controller: ctrl,
                          maxLines: 4,
                          style: const TextStyle(color: _textPri, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Votre réponse officielle...',
                            hintStyle: const TextStyle(color: _textSec),
                            filled: true,
                            fillColor: _bg,
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
                              borderSide: const BorderSide(
                                color: _violet,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _surface2,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Annuler',
                                      style: TextStyle(
                                        color: _textSec,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context, ctrl.text),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _violet,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _violet.withOpacity(0.35),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Publier la réponse',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
    if (reponse != null && reponse.trim().isNotEmpty) {
      await _service.replyToReview(r.id, reponse.trim());
      _loadData();
    }
  }
}
