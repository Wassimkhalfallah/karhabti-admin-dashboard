// ignore_for_file: unused_field, deprecated_member_use

import 'package:flutter/material.dart';
import '../garages_pro/garage_form_screen.dart';

// ─────────────────────────────────────────────
//  Design tokens (shared with responsables_screen)
// ─────────────────────────────────────────────
class _K {
  static const bg           = Color(0xFFFAFBFF);
  static const surface      = Colors.white;
  static const surfaceAlt   = Color(0xFFF3F6FF);
  static const primary      = Color(0xFF4A6CF7);
  static const primaryLight = Color(0xFFEEF2FF);
  static const accent       = Color(0xFF06D6A0);
  static const accentLight  = Color(0xFFE6FBF5);
  static const textPrimary  = Color(0xFF1A2340);
  static const textSecondary= Color(0xFF6B7A99);
  static const border       = Color(0xFFE8ECF4);

  static const r12 = Radius.circular(12);
  static const r16 = Radius.circular(16);
  static const r20 = Radius.circular(20);
  static const r24 = Radius.circular(24);

  static const fast   = Duration(milliseconds: 200);
  static const medium = Duration(milliseconds: 350);
  static const slow   = Duration(milliseconds: 600);
}

// ─────────────────────────────────────────────
//  Screen
// ─────────────────────────────────────────────
class ResponsableGarageSetupScreen extends StatefulWidget {
  const ResponsableGarageSetupScreen({super.key});

  @override
  State<ResponsableGarageSetupScreen> createState() =>
      _ResponsableGarageSetupScreenState();
}

class _ResponsableGarageSetupScreenState
    extends State<ResponsableGarageSetupScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _fade;
  late final Animation<Offset>   _slide;
  late final Animation<double>   _iconScale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: _K.slow);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _iconScale = Tween<double>(begin: 0.6, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _openCreateGarage() async {
    await showDialog(
      context: context,
      builder: (_) => const GarageFormScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _K.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4A6CF7), Color(0xFF7B8FF7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.all(_K.r12),
                      boxShadow: [
                        BoxShadow(
                          color: _K.primary.withOpacity(0.28),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.garage_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Configuration du garage',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _K.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),

            // ── Main content ─────────────────────────────
            Expanded(
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Illustration badge
                          ScaleTransition(
                            scale: _iconScale,
                            child: Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    _K.primary.withOpacity(0.12),
                                    _K.accent.withOpacity(0.10),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Outer ring
                                  Container(
                                    width: 90,
                                    height: 90,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: _K.primary.withOpacity(0.18),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: _K.primaryLight,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.garage_rounded,
                                        color: _K.primary, size: 32),
                                  ),
                                  // Plus badge
                                  Positioned(
                                    right: 12,
                                    bottom: 12,
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: _K.accent,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.white, width: 2),
                                      ),
                                      child: const Icon(Icons.add_rounded,
                                          color: Colors.white, size: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          // Title
                          Text(
                            'Bienvenue sur Karhabti',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: _K.textPrimary,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Pour commencer, créez votre garage.\nVous pourrez ensuite gérer vos véhicules\net vos rendez-vous.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13.5,
                              height: 1.6,
                              color: _K.textSecondary,
                            ),
                          ),

                          const SizedBox(height: 36),

                          // Info card
                          _InfoCard(),

                          const SizedBox(height: 32),

                          // CTA button
                          _CreateGarageButton(onPressed: _openCreateGarage),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Info card (steps)
// ─────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final steps = [
      (Icons.edit_note_rounded, 'Renseignez les informations de votre garage'),
      (Icons.people_alt_rounded, 'Gérez vos techniciens et responsables'),
      (Icons.directions_car_rounded, 'Suivez les véhicules et interventions'),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _K.surface,
        borderRadius: const BorderRadius.all(_K.r20),
        border: Border.all(color: _K.border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0D1A2340),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: steps.asMap().entries.map((e) {
          final isLast = e.key == steps.length - 1;
          return Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: _K.primaryLight,
                      borderRadius: const BorderRadius.all(_K.r12),
                    ),
                    child: Icon(e.value.$1, size: 16, color: _K.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      e.value.$2,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12.5,
                        color: _K.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              if (!isLast)
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 6, bottom: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 2,
                        height: 16,
                        decoration: BoxDecoration(
                          color: _K.border,
                          borderRadius: BorderRadius.all(_K.r12),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  CTA button
// ─────────────────────────────────────────────
class _CreateGarageButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _CreateGarageButton({required this.onPressed});

  @override
  State<_CreateGarageButton> createState() => _CreateGarageButtonState();
}

class _CreateGarageButtonState extends State<_CreateGarageButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: _K.fast, value: 1.0);
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
              Icon(Icons.add_business_rounded,
                  color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text(
                'Créer mon garage',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
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