// ignore_for_file: unused_field, use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import '../../services/garage_pro_service.dart';
import '../garages_pro/garage_form_screen.dart';

// ─────────────────────────────────────────────
//  Design tokens
// ─────────────────────────────────────────────
class _K {
  static const bg = Color(0xFFFAFBFF);
  static const surface = Colors.white;
  static const surfaceAlt = Color(0xFFF3F6FF);
  static const primary = Color(0xFF4A6CF7);
  static const primaryLight = Color(0xFFEEF2FF);
  static const accent = Color(0xFF06D6A0);
  static const accentLight = Color(0xFFE6FBF5);
  static const danger = Color(0xFFFF6B6B);
  static const dangerLight = Color(0xFFFFEEEE);
  static const warning = Color(0xFFFFB347);
  static const warningLight = Color(0xFFFFF3E0);
  static const textPrimary = Color(0xFF1A2340);
  static const textSecondary = Color(0xFF6B7A99);
  static const border = Color(0xFFE8ECF4);
  static const shadow = Color(0x0D1A2340);

  static const r12 = Radius.circular(12);
  static const r16 = Radius.circular(16);
  static const r20 = Radius.circular(20);
  static const r24 = Radius.circular(24);

  static const fast = Duration(milliseconds: 200);
  static const medium = Duration(milliseconds: 350);
  static const slow = Duration(milliseconds: 500);
}

// ─────────────────────────────────────────────
//  Screen
// ─────────────────────────────────────────────
class MonGarageScreen extends StatefulWidget {
  final String garageId;
  const MonGarageScreen({super.key, required this.garageId});

  @override
  State<MonGarageScreen> createState() => _MonGarageScreenState();
}

class _MonGarageScreenState extends State<MonGarageScreen>
    with TickerProviderStateMixin {
  final _service = GarageProService();
  bool _loading = true;
  Map<String, dynamic>? _garage;

  late final AnimationController _pageCtrl;
  late final Animation<double> _pageFade;
  late final Animation<Offset> _pageSlide;

  @override
  void initState() {
    super.initState();
    _pageCtrl = AnimationController(vsync: this, duration: _K.slow);
    _pageFade = CurvedAnimation(parent: _pageCtrl, curve: Curves.easeOut);
    _pageSlide = Tween<Offset>(
      begin: const Offset(0, 0.10),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _pageCtrl, curve: Curves.easeOutCubic));
    _load();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final g = await _service.getGarageById(widget.garageId);
    if (!mounted) return;
    setState(() {
      _garage = g?.toMap();
      _loading = false;
    });
    _pageCtrl.forward(from: 0);
  }

  Future<void> _openEditGarage() async {
    final g = await _service.getGarageById(widget.garageId);
    if (!context.mounted || g == null) return;
    await showDialog(
      context: context,
      builder: (_) => GarageFormScreen(garage: g),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _K.bg,
      body: SafeArea(
        child:
            _loading
                ? _buildLoader()
                : _garage == null
                ? _buildNotFound()
                : _buildContent(),
      ),
    );
  }

  // ── Loader ──────────────────────────────────
  Widget _buildLoader() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(strokeWidth: 3, color: _K.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Chargement du garage…',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: _K.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Not found ───────────────────────────────
  Widget _buildNotFound() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _K.dangerLight,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.garage_rounded, color: _K.danger, size: 34),
          ),
          const SizedBox(height: 16),
          Text(
            'Garage introuvable',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _K.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Vérifiez l\'identifiant du garage',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: _K.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Main content ────────────────────────────
  Widget _buildContent() {
    final g = _garage!;
    final nom = g['nom'] as String? ?? '—';
    final adresse = g['adresse'] as String? ?? '';
    final ville = g['ville'] as String? ?? '';
    final tel = g['telephone'] as String?;
    final email = g['email'] as String?;
    final siret = g['siret'] as String?;
    final estActif = g['est_actif'] as bool? ?? true;

    return FadeTransition(
      opacity: _pageFade,
      child: SlideTransition(
        position: _pageSlide,
        child: CustomScrollView(
          slivers: [
            // ── Hero header ──────────────────
            SliverToBoxAdapter(child: _buildHero(nom, ville, estActif)),

            // ── Info cards ───────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 16),
                  _SectionTitle(title: 'Informations générales'),
                  const SizedBox(height: 10),
                  _InfoCard(
                    items: [
                      _InfoRow(
                        icon: Icons.location_on_rounded,
                        label: 'Adresse',
                        value: adresse.isNotEmpty ? adresse : '—',
                        color: _K.primary,
                      ),
                      _InfoRow(
                        icon: Icons.location_city_rounded,
                        label: 'Ville',
                        value: ville.isNotEmpty ? ville : '—',
                        color: _K.primary,
                      ),
                      if (tel != null && tel.isNotEmpty)
                        _InfoRow(
                          icon: Icons.phone_rounded,
                          label: 'Téléphone',
                          value: tel,
                          color: _K.accent,
                        ),
                      if (email != null && email.isNotEmpty)
                        _InfoRow(
                          icon: Icons.email_rounded,
                          label: 'E-mail',
                          value: email,
                          color: _K.accent,
                        ),
                      if (siret != null && siret.isNotEmpty)
                        _InfoRow(
                          icon: Icons.badge_rounded,
                          label: 'SIRET',
                          value: siret,
                          color: _K.textSecondary,
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _SectionTitle(title: 'Statut'),
                  const SizedBox(height: 10),
                  _StatusCard(estActif: estActif),
                  const SizedBox(height: 28),
                  _EditButton(onPressed: _openEditGarage),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Hero section ────────────────────────────
  Widget _buildHero(String nom, String ville, bool estActif) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3A5BD9), Color(0xFF7B8FF7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.all(_K.r24),
        boxShadow: [
          BoxShadow(
            color: _K.primary.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Garage icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: const BorderRadius.all(_K.r16),
            ),
            child: const Icon(
              Icons.garage_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          // Name + location
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nom,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                if (ville.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 12,
                        color: Colors.white.withOpacity(0.75),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        ville,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.80),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color:
                  estActif
                      ? Colors.white.withOpacity(0.22)
                      : Colors.black.withOpacity(0.18),
              borderRadius: const BorderRadius.all(_K.r12),
              border: Border.all(
                color: Colors.white.withOpacity(0.30),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: estActif ? const Color(0xFF06D6A0) : Colors.white54,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  estActif ? 'Actif' : 'Inactif',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Section title
// ─────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4A6CF7), Color(0xFF7B8FF7)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.all(_K.r12),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _K.textPrimary,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Info row model
// ─────────────────────────────────────────────
class _InfoRow {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}

// ─────────────────────────────────────────────
//  Info card
// ─────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final List<_InfoRow> items;
  const _InfoCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _K.surface,
        borderRadius: const BorderRadius.all(_K.r20),
        border: Border.all(color: _K.border, width: 1.2),
        boxShadow: const [
          BoxShadow(color: _K.shadow, blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children:
            items.asMap().entries.map((e) {
              final row = e.value;
              final isLast = e.key == items.length - 1;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 13,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: row.color.withOpacity(0.10),
                            borderRadius: const BorderRadius.all(_K.r12),
                          ),
                          child: Icon(row.icon, size: 16, color: row.color),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                row.label,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 10,
                                  color: _K.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                row.value,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  color: _K.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: _K.border,
                      indent: 62,
                    ),
                ],
              );
            }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Status card
// ─────────────────────────────────────────────
class _StatusCard extends StatelessWidget {
  final bool estActif;
  const _StatusCard({required this.estActif});

  @override
  Widget build(BuildContext context) {
    final color = estActif ? _K.accent : _K.warning;
    final bgColor = estActif ? _K.accentLight : _K.warningLight;
    final icon =
        estActif ? Icons.check_circle_rounded : Icons.pause_circle_rounded;
    final label = estActif ? 'Garage actif' : 'Garage inactif';
    final sub =
        estActif
            ? 'Votre garage est visible et opérationnel.'
            : 'Votre garage est actuellement suspendu.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.all(_K.r16),
        border: Border.all(color: color.withOpacity(0.25), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11.5,
                    color: _K.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Edit button
// ─────────────────────────────────────────────
class _EditButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _EditButton({required this.onPressed});

  @override
  State<_EditButton> createState() => _EditButtonState();
}

class _EditButtonState extends State<_EditButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: _K.fast, value: 1.0);
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) {
          _ctrl.reverse();
          widget.onPressed();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4A6CF7), Color(0xFF7B8FF7)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: const BorderRadius.all(_K.r16),
            boxShadow: [
              BoxShadow(
                color: _K.primary.withOpacity(0.32),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.edit_rounded, color: Colors.white, size: 18),
              SizedBox(width: 10),
              Text(
                'Modifier les informations',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
