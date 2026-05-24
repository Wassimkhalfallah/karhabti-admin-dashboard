// ignore_for_file: deprecated_member_use, curly_braces_in_flow_control_structures, duplicate_ignore

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../models/affectation_piece_model.dart';
import '../../services/affectation_pieces_service.dart';
import '../../services/vehicle_service.dart';
import '../../services/pieces_service.dart';

// ═══════════════════════════════════════════════════════════════
//  DESIGN TOKENS — Palette claire, calme & contemporaine
// ═══════════════════════════════════════════════════════════════
class _L {
  static const bg         = Color(0xFFF4F6FB);
  static const surface    = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF0F4FA);
  static const border     = Color(0xFFE4EAF4);

  static const primary    = Color(0xFF4F6FE8);
  static const primaryBg  = Color(0xFFEEF2FF);
  static const primaryMid = Color(0xFFBFCAF9);

  static const success    = Color(0xFF10B981);
  static const danger     = Color(0xFFEF4444);
  static const dangerBg   = Color(0xFFFEF2F2);
  static const info       = Color(0xFF0EA5E9);
  static const warning    = Color(0xFFF59E0B);
  static const warningBg  = Color(0xFFFFFBEB);

  static const textPri    = Color(0xFF1E293B);
  static const textSec    = Color(0xFF64748B);
  static const textMuted  = Color(0xFF94A3B8);

  // Couleurs par catégorie de pièce — tons doux et professionnels
  static const categoryColors = {
    'Pneus'                 : Color(0xFF5B73D4), // indigo doux
    'Huile Moteur'          : Color(0xFF2E90B8), // bleu acier
    'Filtres'               : Color(0xFF7B5EA7), // violet doux
    'Embrayage'             : Color(0xFF2D9E72), // vert sauge
    'Batterie'              : Color(0xFFB07D2A), // ambre sombre
    'Amortisseurs'          : Color(0xFF2A8FA8), // cyan ardoise
    'Freins'                : Color(0xFFC0444A), // rouge doux
    'Courroie'              : Color(0xFF9B5D7A), // rose poudré
    'Eau de Refroidissement': Color(0xFF3A7EC8), // bleu moyen
  };

  static const categoryIcons = {
    'Pneus'               : Icons.tire_repair_rounded,
    'Huile Moteur'        : Icons.oil_barrel_rounded,
    'Filtres'             : Icons.filter_alt_outlined,
    'Embrayage'           : Icons.settings_rounded,
    'Batterie'            : Icons.battery_charging_full_rounded,
    'Amortisseurs'        : Icons.directions_car_rounded,
    'Freins'              : Icons.disc_full_rounded,
    'Courroie'            : Icons.cable_rounded,
    'Eau de Refroidissement': Icons.water_drop_outlined,
  };
}

// ═══════════════════════════════════════════════════════════════
//  STYLES
// ═══════════════════════════════════════════════════════════════
class _S {
  static InputDecoration field(String label,
      {String? hint, IconData? icon, Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: _L.textSec, fontSize: 13),
      hintStyle: const TextStyle(color: _L.textMuted, fontSize: 13),
      prefixIcon: icon != null
          ? Icon(icon, size: 17, color: _L.textMuted)
          : null,
      suffixIcon: suffix,
      filled: true,
      fillColor: _L.surfaceAlt,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: _L.border)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: _L.border)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: _L.primary, width: 1.8)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: _L.danger)),
      isDense: true,
    );
  }

  static BoxDecoration card({double radius = 16}) => BoxDecoration(
        color: _L.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: _L.border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF94A3B8).withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      );
}

// ═══════════════════════════════════════════════════════════════
//  SHIMMER SKELETON
// ═══════════════════════════════════════════════════════════════
class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;
  const _ShimmerBox(
      {required this.width, required this.height, this.radius = 8});

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
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
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
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          gradient: LinearGradient(colors: [
            const Color(0xFFE8EDF5),
            Color.lerp(const Color(0xFFE8EDF5), const Color(0xFFF8FAFF),
                _anim.value)!,
            const Color(0xFFE8EDF5),
          ], stops: const [0.0, 0.5, 1.0]),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  HOVER BUTTON
// ═══════════════════════════════════════════════════════════════
class _HoverButton extends StatefulWidget {
  final Color color;
  final VoidCallback onTap;
  final Widget child;
  final EdgeInsets padding;

  const _HoverButton({
    required this.color,
    required this.onTap,
    required this.child,
    this.padding =
        const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
  });

  @override
  State<_HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<_HoverButton> {
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
            color: _hovered
                ? widget.color.withOpacity(0.14)
                : widget.color.withOpacity(0.07),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: _hovered
                  ? widget.color.withOpacity(0.3)
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
//  ADD BUTTON (gradient + press scale)
// ═══════════════════════════════════════════════════════════════
class _AddButton extends StatefulWidget {
  final VoidCallback onTap;
  final String label;
  final IconData icon;
  const _AddButton(
      {required this.onTap,
      this.label = 'Ajouter',
      this.icon = Icons.add_rounded});

  @override
  State<_AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<_AddButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 110));
    _scale = Tween<double>(begin: 1.0, end: 0.93)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF5B7AFF), Color(0xFF3D5CE8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(11),
            boxShadow: [
              BoxShadow(
                color: _L.primary.withOpacity(0.28),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 17, color: Colors.white),
              const SizedBox(width: 6),
              Text(widget.label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
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
class _ConfirmButton extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool loading;
  const _ConfirmButton(
      {required this.label,
      required this.color,
      required this.onTap,
      this.loading = false});

  @override
  State<_ConfirmButton> createState() => _ConfirmButtonState();
}

class _ConfirmButtonState extends State<_ConfirmButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.95)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null && !widget.loading;
    return GestureDetector(
      onTapDown: enabled ? (_) => _ctrl.forward() : null,
      onTapUp: enabled
          ? (_) {
              _ctrl.reverse();
              widget.onTap!();
            }
          : null,
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedOpacity(
          opacity: enabled ? 1.0 : 0.6,
          duration: const Duration(milliseconds: 180),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(10),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: widget.color.withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ]
                  : [],
            ),
            child: widget.loading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Text(widget.label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13)),
          ),
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
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.93, end: 1.07)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
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
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: RadialGradient(colors: [
            widget.color.withOpacity(0.14),
            widget.color.withOpacity(0.04),
          ]),
          shape: BoxShape.circle,
          border: Border.all(color: widget.color.withOpacity(0.16)),
        ),
        child: Icon(widget.icon, size: 38, color: widget.color),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  SEARCH FIELD (animated width + focus effect)
// ═══════════════════════════════════════════════════════════════
class _SearchField extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _SearchField(
      {required this.controller, required this.onChanged});

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  final FocusNode _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(
        () => setState(() => _focused = _focus.hasFocus));
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
      width: _focused ? 300 : 260,
      child: TextField(
        controller: widget.controller,
        focusNode: _focus,
        onChanged: widget.onChanged,
        style: const TextStyle(color: _L.textPri, fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Rechercher par immatriculation…',
          hintStyle: const TextStyle(color: _L.textMuted, fontSize: 13),
          prefixIcon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(Icons.search_rounded,
                key: ValueKey(_focused),
                size: 17,
                color: _focused ? _L.primary : _L.textMuted),
          ),
          suffixIcon: widget.controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded,
                      size: 16, color: _L.textMuted),
                  onPressed: () {
                    widget.controller.clear();
                    widget.onChanged('');
                  },
                )
              : null,
          filled: true,
          fillColor: _focused ? _L.primaryBg : _L.surfaceAlt,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(color: _L.border)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide: const BorderSide(color: _L.border)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(11),
              borderSide:
                  const BorderSide(color: _L.primary, width: 1.8)),
          isDense: true,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  SNACK HELPER
// ═══════════════════════════════════════════════════════════════
void _showSnack(BuildContext context, String msg,
    {bool isError = false, bool isWarning = false}) {
  final color = isError
      ? _L.danger
      : isWarning
          ? _L.warning
          : _L.success;
  final icon = isError
      ? Icons.error_outline_rounded
      : isWarning
          ? Icons.warning_amber_rounded
          : Icons.check_circle_outline_rounded;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 8),
        Expanded(
            child: Text(msg,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500))),
      ]),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(11)),
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
    BuildContext context, Widget dialog,
    {bool dismissible = true}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: dismissible,
    barrierLabel: 'Fermer',
    barrierColor: Colors.black.withOpacity(0.35),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, __, ___) => dialog,
    transitionBuilder: (_, anim, __, child) {
      final curve =
          CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(
                  begin: const Offset(0, 0.06), end: Offset.zero)
              .animate(curve),
          child: child,
        ),
      );
    },
  );
}

// ═══════════════════════════════════════════════════════════════
//  MIXIN PIECE SELECTOR — redessiné
// ═══════════════════════════════════════════════════════════════
mixin PieceSelectorMixin<T extends StatefulWidget> on State<T> {
  Widget buildPieceSelectorSection(
    String title,
    List<Map<String, dynamic>> pieces,
    List<dynamic> selectedIds,
    Function(List<dynamic>) onSelected,
  ) {
    final bool isRefroidissement = title == 'Eau de Refroidissement';
    final color =
        _L.categoryColors[title] ?? _L.primary;
    final icon = _L.categoryIcons[title] ?? Icons.build_outlined;
    final selectedCount = selectedIds.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _L.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selectedCount > 0
              ? color.withOpacity(0.3)
              : _L.border,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF94A3B8).withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête de section
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: selectedCount > 0
                  ? color.withOpacity(0.06)
                  : _L.surfaceAlt,
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(13)),
              border: Border(
                  bottom: BorderSide(
                      color: _L.border.withOpacity(0.7), width: 0.8)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color.withOpacity(0.2)),
                  ),
                  child: Icon(icon, size: 14, color: color),
                ),
                const SizedBox(width: 10),
                Text(title,
                    style: TextStyle(
                        color: selectedCount > 0 ? color : _L.textPri,
                        fontWeight: FontWeight.w700,
                        fontSize: 13)),
                const Spacer(),
                if (selectedCount > 0)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: color.withOpacity(0.25)),
                    ),
                    child: Text(
                      '$selectedCount sélectionné${selectedCount > 1 ? 's' : ''}',
                      style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
            ),
          ),

          // Liste des pièces
          if (pieces.isEmpty)
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                Icon(Icons.info_outline_rounded,
                    size: 15, color: _L.textMuted),
                const SizedBox(width: 8),
                const Text('Aucune pièce disponible',
                    style: TextStyle(
                        color: _L.textMuted,
                        fontSize: 12,
                        fontStyle: FontStyle.italic)),
              ]),
            )
          else
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  ...pieces
                      .take(5)
                      .toList()
                      .asMap()
                      .entries
                      .map((entry) {
                    final idx = entry.key;
                    final piece = entry.value;
                    final id = isRefroidissement
                        ? piece['id'].toString()
                        : piece['id'] as int;
                    final isChecked = selectedIds.contains(id);

                    String description =
                        '${piece['reference']} — ${piece['marque']}';
                    if (piece['type'] != null) {
                      description += '  ·  ${piece['type']}';
                    } else if (piece['nom'] != null)
                      // ignore: curly_braces_in_flow_control_structures
                      description += '  ·  ${piece['nom']}';
                    else if (piece['capacite'] != null)
                      // ignore: curly_braces_in_flow_control_structures
                      description += '  ·  ${piece['capacite']}';

                    return _PieceCheckItem(
                      description: description,
                      isChecked: isChecked,
                      color: color,
                      index: idx,
                      onChanged: (checked) {
                        final newList = List<dynamic>.from(selectedIds);
                        if (checked == true) {
                          newList.add(id);
                        } else {
                          newList.remove(id);
                        }
                        onSelected(newList);
                      },
                    );
                  }),
                  if (pieces.length > 5)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: _HoverButton(
                          color: color,
                          onTap: () => _showAllPiecesModal(
                            title,
                            pieces,
                            selectedIds,
                            onSelected,
                            isRefroidissement,
                            color,
                            icon,
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.expand_more_rounded,
                                size: 14, color: color),
                            const SizedBox(width: 4),
                            Text(
                              'Voir les ${pieces.length - 5} autres',
                              style: TextStyle(
                                  color: color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600),
                            ),
                          ]),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showAllPiecesModal(
    String title,
    List<Map<String, dynamic>> pieces,
    List<dynamic> selectedIds,
    Function(List<dynamic>) onSelected,
    bool isRefroidissement,
    Color color,
    IconData icon,
  ) {
    final dialogSelectedIds = List<dynamic>.from(selectedIds);
    final searchCtrl = TextEditingController();
    List<Map<String, dynamic>> filtered = List.from(pieces);

    _showAnimatedDialog(
      context,
      StatefulBuilder(
        builder: (ctx, setSt) {
          void filterPieces(String q) {
            setSt(() {
              filtered = q.isEmpty
                  ? List.from(pieces)
                  : pieces.where((p) {
                      final ref =
                          (p['reference'] ?? '').toString().toLowerCase();
                      final marque =
                          (p['marque'] ?? '').toString().toLowerCase();
                      return ref.contains(q.toLowerCase()) ||
                          marque.contains(q.toLowerCase());
                    }).toList();
            });
          }

          return Dialog(
            backgroundColor: _L.surface,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: _L.border)),
            elevation: 0,
            child: Container(
              width: 520,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          color.withOpacity(0.15),
                          color.withOpacity(0.06)
                        ]),
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(color: color.withOpacity(0.22)),
                      ),
                      child: Icon(icon, color: color, size: 17),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Sélection — $title',
                              style: const TextStyle(
                                  color: _L.textPri,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  letterSpacing: -0.2)),
                          Text(
                            '${dialogSelectedIds.length} sélectionné(s) · ${pieces.length} disponibles',
                            style: const TextStyle(
                                color: _L.textSec, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(ctx),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: _L.surfaceAlt,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _L.border),
                        ),
                        child: const Icon(Icons.close_rounded,
                            size: 16, color: _L.textSec),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  const Divider(color: _L.border, height: 1),
                  const SizedBox(height: 14),
                  // Search
                  TextField(
                    controller: searchCtrl,
                    onChanged: filterPieces,
                    style:
                        const TextStyle(color: _L.textPri, fontSize: 13),
                    decoration: _S.field('Rechercher…',
                        icon: Icons.search_rounded),
                  ),
                  const SizedBox(height: 12),
                  // List
                  Container(
                    constraints: const BoxConstraints(maxHeight: 360),
                    child: filtered.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text('Aucun résultat',
                                  style: const TextStyle(
                                      color: _L.textMuted, fontSize: 13)),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: filtered.length,
                            itemBuilder: (_, i) {
                              final piece = filtered[i];
                              final id = isRefroidissement
                                  ? piece['id'].toString()
                                  : piece['id'] as int;
                              final isChecked =
                                  dialogSelectedIds.contains(id);

                              String desc =
                                  '${piece['reference']} — ${piece['marque']}';
                              if (piece['type'] != null) {
                                desc += '  ·  ${piece['type']}';
                              } else if (piece['nom'] != null)
                                desc += '  ·  ${piece['nom']}';
                              else if (piece['capacite'] != null)
                                desc += '  ·  ${piece['capacite']}';

                              return _PieceCheckItem(
                                description: desc,
                                isChecked: isChecked,
                                color: color,
                                index: i,
                                onChanged: (checked) {
                                  setSt(() {
                                    if (checked == true) {
                                      dialogSelectedIds.add(id);
                                    } else {
                                      dialogSelectedIds.remove(id);
                                    }
                                  });
                                },
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 16),
                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: TextButton.styleFrom(
                          foregroundColor: _L.textSec,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 11),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: _L.border)),
                        ),
                        child: const Text('Annuler',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                      ),
                      const SizedBox(width: 10),
                      _ConfirmButton(
                        label: 'Confirmer',
                        color: color,
                        onTap: () {
                          onSelected(dialogSelectedIds);
                          Navigator.pop(ctx);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Kept for API compat
  void showAllPiecesDialog(
    String title,
    List<Map<String, dynamic>> pieces,
    List<dynamic> selectedIds,
    Function(List<dynamic>) onSelected,
  ) {
    final bool isRefroidissement = title == 'Eau de Refroidissement';
    final color = _L.categoryColors[title] ?? _L.primary;
    final icon = _L.categoryIcons[title] ?? Icons.build_outlined;
    _showAllPiecesModal(
        title, pieces, selectedIds, onSelected, isRefroidissement, color, icon);
  }
}

/// Item checkbox stylisé pour la sélection de pièces
class _PieceCheckItem extends StatelessWidget {
  final String description;
  final bool isChecked;
  final Color color;
  final int index;
  final ValueChanged<bool?> onChanged;

  const _PieceCheckItem({
    required this.description,
    required this.isChecked,
    required this.color,
    required this.index,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        color: isChecked ? color.withOpacity(0.06) : _L.surfaceAlt,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: isChecked ? color.withOpacity(0.25) : _L.border,
        ),
      ),
      child: InkWell(
        onTap: () => onChanged(!isChecked),
        borderRadius: BorderRadius.circular(9),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: isChecked ? color : _L.surface,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: isChecked
                        ? color
                        : _L.textMuted,
                    width: isChecked ? 0 : 1.5,
                  ),
                ),
                child: isChecked
                    ? const Icon(Icons.check_rounded,
                        size: 12, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  description,
                  style: TextStyle(
                    color: isChecked ? color : _L.textPri,
                    fontSize: 12,
                    fontWeight: isChecked
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  DIALOG AJOUT — redessiné
// ═══════════════════════════════════════════════════════════════
class _AddAffectationDialog extends StatefulWidget {
  const _AddAffectationDialog();

  @override
  State<_AddAffectationDialog> createState() => _AddAffectationDialogState();
}

class _AddAffectationDialogState extends State<_AddAffectationDialog>
    with PieceSelectorMixin {
  final _formKey = GlobalKey<FormState>();
  String? _selectedImmat;
  bool _loadingImmat = true;
  List<String> _immatriculations = [];
  bool _submitting = false;

  List<int> _selectedPneuIds = [];
  List<int> _selectedHuileMoteurIds = [];
  List<int> _selectedFiltreIds = [];
  List<int> _selectedEmbrayageIds = [];
  List<int> _selectedBatterieIds = [];
  List<int> _selectedAmortisseurIds = [];
  List<int> _selectedFreinIds = [];
  List<int> _selectedCourroieIds = [];
  List<String> _selectedRefroidissementIds = [];

  List<Map<String, dynamic>> _pneus = [];
  List<Map<String, dynamic>> _huilesMoteur = [];
  List<Map<String, dynamic>> _filtres = [];
  List<Map<String, dynamic>> _embrayages = [];
  List<Map<String, dynamic>> _batteries = [];
  List<Map<String, dynamic>> _amortisseurs = [];
  List<Map<String, dynamic>> _freins = [];
  List<Map<String, dynamic>> _courroies = [];
  List<Map<String, dynamic>> _refroidissements = [];

  bool _loadingPieces = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadImmatriculations();
    _loadAllPiecesData();
  }

  Future<void> _loadImmatriculations() async {
    setState(() => _loadingImmat = true);
    try {
      final vehicleService = VehicleService();
      final vehicles = await vehicleService.getAllVehicles();
      setState(() {
        _immatriculations =
            vehicles.map((v) => v.registrationNumber).toList();
        _loadingImmat = false;
      });
    } catch (e) {
      setState(() => _loadingImmat = false);
      if (mounted) _showSnack(context, 'Erreur chargement immatriculations : $e', isError: true);
    }
  }

  Future<void> _loadAllPiecesData() async {
    setState(() {
      _loadingPieces = true;
      _errorMessage = null;
    });
    try {
      final piecesService = PiecesService();
      final results = await Future.wait([
        piecesService.getPneusIdRef(),
        piecesService.getHuileMoteurIdRef(),
        piecesService.getFiltresIdRef(),
        piecesService.getEmbrayagesIdRef(),
        piecesService.getBatteriesIdRef(),
        piecesService.getAmortisseursIdRef(),
        piecesService.getFreinsIdRef(),
        piecesService.getCourroiesIdRef(),
        piecesService.getEauRefroidissementIdRef(),
      ]);
      setState(() {
        _pneus = results[0];
        _huilesMoteur = results[1];
        _filtres = results[2];
        _embrayages = results[3];
        _batteries = results[4];
        _amortisseurs = results[5];
        _freins = results[6];
        _courroies = results[7];
        _refroidissements = results[8];
        _loadingPieces = false;
      });
    } catch (e) {
      setState(() {
        _loadingPieces = false;
        _errorMessage = 'Erreur de chargement: $e';
      });
      if (mounted) _showSnack(context, 'Erreur chargement des pièces: $e', isError: true);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedImmat == null) return;

    final hasEmpty = [
      _selectedPneuIds,
      _selectedHuileMoteurIds,
      _selectedFiltreIds,
      _selectedEmbrayageIds,
      _selectedBatterieIds,
      _selectedAmortisseurIds,
      _selectedFreinIds,
      _selectedCourroieIds,
      _selectedRefroidissementIds,
    ].any((l) => l.isEmpty);

    if (hasEmpty) {
      _showSnack(context,
          'Au moins une pièce doit être sélectionnée dans chaque catégorie',
          isWarning: true);
      return;
    }

    setState(() => _submitting = true);
    try {
      final client = Supabase.instance.client;
      final service = AffectationPiecesService(client);
      final affectation = AffectationPiece(
        id: 0,
        fkImmatriculation: _selectedImmat!,
        fkEmbrayage: _selectedEmbrayageIds,
        fkPneus: _selectedPneuIds,
        fkBatterie: _selectedBatterieIds,
        fkAmortisseurs: _selectedAmortisseurIds,
        fkFreins: _selectedFreinIds,
        fkCourroie: _selectedCourroieIds,
        fkHuileMoteur: _selectedHuileMoteurIds,
        fkRefroidissement: _selectedRefroidissementIds,
        fkFiltres: _selectedFiltreIds,
      );
      await service.addAffectation(affectation);
      if (mounted) {
        Navigator.pop(context);
        _showSnack(context, 'Affectation ajoutée avec succès !');
      }
    } catch (e) {
      if (mounted) {
        _showSnack(context, 'Erreur lors de l\'ajout : $e', isError: true);
      }
    } finally {
      setState(() => _submitting = false);
    }
  }

  ThemeData get _lightTheme => ThemeData.light(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: _L.surface,
        colorScheme: const ColorScheme.light(
            primary: _L.primary, surface: _L.surface, onSurface: _L.textPri),
        cardColor: _L.surface, canvasColor: _L.surface, dividerColor: _L.border,
        iconTheme: const IconThemeData(color: _L.textSec),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: _L.textPri),
          bodySmall: TextStyle(color: _L.textSec),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _lightTheme,
      child: Dialog(
      backgroundColor: _L.surface,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: _L.border)),
      elevation: 0,
      child: Container(
        width: 620,
        constraints: const BoxConstraints(maxHeight: 720),
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    _L.primary.withOpacity(0.15),
                    _L.primary.withOpacity(0.06)
                  ]),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: _L.primary.withOpacity(0.22)),
                ),
                child: const Icon(Icons.add_link_rounded,
                    color: _L.primary, size: 20),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Nouvelle affectation',
                        style: TextStyle(
                            color: _L.textPri,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            letterSpacing: -0.2)),
                    Text('Associez des pièces à un véhicule',
                        style: TextStyle(color: _L.textSec, fontSize: 12)),
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
                      border: Border.all(color: _L.border)),
                  child: const Icon(Icons.close_rounded,
                      size: 16, color: _L.textSec),
                ),
              ),
            ]),
            const SizedBox(height: 8),
            const Divider(color: _L.border, height: 1),
            const SizedBox(height: 18),

            // ── Contenu ──
            Expanded(
              child: _loadingImmat || _loadingPieces
                  ? _buildLoadingContent()
                  : _errorMessage != null
                      ? _buildErrorContent()
                      : Form(
                          key: _formKey,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Dropdown immatriculation
                                _buildImmatDropdown(),
                                const SizedBox(height: 18),
                                // Label section pièces
                                _buildSectionLabel(
                                    'Sélection des pièces',
                                    Icons.build_circle_outlined,
                                    _L.info),
                                const SizedBox(height: 12),
                                AnimatedOpacity(
                                  opacity:
                                      _selectedImmat == null ? 0.35 : 1.0,
                                  duration:
                                      const Duration(milliseconds: 350),
                                  child: AbsorbPointer(
                                    absorbing: _selectedImmat == null,
                                    child: Column(
                                      children: [
                                        buildPieceSelectorSection('Pneus', _pneus, _selectedPneuIds, (ids) => setState(() => _selectedPneuIds = List<int>.from(ids))),
                                        buildPieceSelectorSection('Huile Moteur', _huilesMoteur, _selectedHuileMoteurIds, (ids) => setState(() => _selectedHuileMoteurIds = List<int>.from(ids))),
                                        buildPieceSelectorSection('Filtres', _filtres, _selectedFiltreIds, (ids) => setState(() => _selectedFiltreIds = List<int>.from(ids))),
                                        buildPieceSelectorSection('Embrayage', _embrayages, _selectedEmbrayageIds, (ids) => setState(() => _selectedEmbrayageIds = List<int>.from(ids))),
                                        buildPieceSelectorSection('Batterie', _batteries, _selectedBatterieIds, (ids) => setState(() => _selectedBatterieIds = List<int>.from(ids))),
                                        buildPieceSelectorSection('Amortisseurs', _amortisseurs, _selectedAmortisseurIds, (ids) => setState(() => _selectedAmortisseurIds = List<int>.from(ids))),
                                        buildPieceSelectorSection('Freins', _freins, _selectedFreinIds, (ids) => setState(() => _selectedFreinIds = List<int>.from(ids))),
                                        buildPieceSelectorSection('Courroie', _courroies, _selectedCourroieIds, (ids) => setState(() => _selectedCourroieIds = List<int>.from(ids))),
                                        buildPieceSelectorSection('Eau de Refroidissement', _refroidissements, _selectedRefroidissementIds, (ids) => setState(() => _selectedRefroidissementIds = List<String>.from(ids))),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
            ),

            const SizedBox(height: 20),
            // ── Actions ──
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              TextButton(
                onPressed: _submitting ? null : () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: _L.textSec,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 11),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: _L.border)),
                ),
                child: const Text('Annuler',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
              ),
              const SizedBox(width: 10),
              _ConfirmButton(
                label: 'Enregistrer',
                color: _L.primary,
                onTap: _submitting ? null : _submit,
                loading: _submitting,
              ),
            ]),
          ],
        ),
      ),
    ), // Dialog
    ); // Theme
  }

  Widget _buildLoadingContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        _ShimmerBox(width: double.infinity, height: 48, radius: 11),
        const SizedBox(height: 16),
        ...List.generate(
            5,
            (i) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ShimmerBox(
                    width: double.infinity, height: 80, radius: 14))),
      ],
    );
  }

  Widget _buildErrorContent() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
              color: _L.dangerBg, shape: BoxShape.circle),
          child: const Icon(Icons.error_outline_rounded,
              color: _L.danger, size: 28),
        ),
        const SizedBox(height: 14),
        Text(_errorMessage!,
            style: const TextStyle(color: _L.textSec, fontSize: 13),
            textAlign: TextAlign.center),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _loadAllPiecesData,
          icon: const Icon(Icons.refresh_rounded, size: 15),
          label: const Text('Réessayer'),
          style: ElevatedButton.styleFrom(
              backgroundColor: _L.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
        ),
      ]),
    );
  }

  Widget _buildImmatDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedImmat,
      style: const TextStyle(color: _L.textPri, fontSize: 13),
      icon: const Icon(Icons.keyboard_arrow_down_rounded,
          color: _L.textSec, size: 20),
      decoration: _S.field('Immatriculation du véhicule*',
          icon: Icons.directions_car_rounded),
      items: _immatriculations
          .map((immat) => DropdownMenuItem(
                value: immat,
                child: Text(immat,
                    style: const TextStyle(
                        color: _L.textPri, fontSize: 13)),
              ))
          .toList(),
      onChanged: (val) => setState(() => _selectedImmat = val),
      validator: (val) =>
          val == null ? 'Sélectionnez une immatriculation' : null,
      dropdownColor: _L.surface,
    );
  }

  Widget _buildSectionLabel(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 8),
        Text(label,
            style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: 0.3)),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  DIALOG MODIFICATION — redessiné
// ═══════════════════════════════════════════════════════════════
class _EditAffectationDialog extends StatefulWidget {
  final AffectationPiece affectation;
  const _EditAffectationDialog({required this.affectation});

  @override
  State<_EditAffectationDialog> createState() =>
      _EditAffectationDialogState();
}

class _EditAffectationDialogState extends State<_EditAffectationDialog>
    with PieceSelectorMixin {
  final _formKey = GlobalKey<FormState>();

  List<int> _selectedPneuIds = [];
  List<int> _selectedHuileMoteurIds = [];
  List<int> _selectedFiltreIds = [];
  List<int> _selectedEmbrayageIds = [];
  List<int> _selectedBatterieIds = [];
  List<int> _selectedAmortisseurIds = [];
  List<int> _selectedFreinIds = [];
  List<int> _selectedCourroieIds = [];
  List<String> _selectedRefroidissementIds = [];

  List<Map<String, dynamic>> _pneus = [];
  List<Map<String, dynamic>> _huilesMoteur = [];
  List<Map<String, dynamic>> _filtres = [];
  List<Map<String, dynamic>> _embrayages = [];
  List<Map<String, dynamic>> _batteries = [];
  List<Map<String, dynamic>> _amortisseurs = [];
  List<Map<String, dynamic>> _freins = [];
  List<Map<String, dynamic>> _courroies = [];
  List<Map<String, dynamic>> _refroidissements = [];

  bool _submitting = false;
  bool _loadingPieces = true;

  @override
  void initState() {
    super.initState();
    _selectedPneuIds = widget.affectation.fkPneus;
    _selectedHuileMoteurIds = widget.affectation.fkHuileMoteur;
    _selectedFiltreIds = widget.affectation.fkFiltres;
    _selectedEmbrayageIds = widget.affectation.fkEmbrayage;
    _selectedBatterieIds = widget.affectation.fkBatterie;
    _selectedAmortisseurIds = widget.affectation.fkAmortisseurs;
    _selectedFreinIds = widget.affectation.fkFreins;
    _selectedCourroieIds = widget.affectation.fkCourroie;
    _selectedRefroidissementIds = widget.affectation.fkRefroidissement;
    _loadAllPiecesData();
  }

  Future<void> _loadAllPiecesData() async {
    setState(() => _loadingPieces = true);
    try {
      final piecesService = PiecesService();
      final results = await Future.wait([
        piecesService.getPneusIdRef(),
        piecesService.getHuileMoteurIdRef(),
        piecesService.getFiltresIdRef(),
        piecesService.getEmbrayagesIdRef(),
        piecesService.getBatteriesIdRef(),
        piecesService.getAmortisseursIdRef(),
        piecesService.getFreinsIdRef(),
        piecesService.getCourroiesIdRef(),
        piecesService.getEauRefroidissementIdRef(),
      ]);
      setState(() {
        _pneus = results[0];
        _huilesMoteur = results[1];
        _filtres = results[2];
        _embrayages = results[3];
        _batteries = results[4];
        _amortisseurs = results[5];
        _freins = results[6];
        _courroies = results[7];
        _refroidissements = results[8];
        _loadingPieces = false;
      });
    } catch (e) {
      setState(() => _loadingPieces = false);
      if (mounted) {
        _showSnack(context, 'Erreur chargement des pièces: $e', isError: true);
      }
    }
  }

  Future<void> _submitEdit() async {
    if (!_formKey.currentState!.validate()) return;

    final hasEmpty = [
      _selectedPneuIds,
      _selectedHuileMoteurIds,
      _selectedFiltreIds,
      _selectedEmbrayageIds,
      _selectedBatterieIds,
      _selectedAmortisseurIds,
      _selectedFreinIds,
      _selectedCourroieIds,
      _selectedRefroidissementIds,
    ].any((l) => l.isEmpty);

    if (hasEmpty) {
      _showSnack(context,
          'Au moins une pièce doit être sélectionnée dans chaque catégorie',
          isWarning: true);
      return;
    }

    setState(() => _submitting = true);
    try {
      final client = Supabase.instance.client;
      final service = AffectationPiecesService(client);
      final updated = AffectationPiece(
        id: widget.affectation.id,
        fkImmatriculation: widget.affectation.fkImmatriculation,
        fkPneus: _selectedPneuIds,
        fkHuileMoteur: _selectedHuileMoteurIds,
        fkFiltres: _selectedFiltreIds,
        fkEmbrayage: _selectedEmbrayageIds,
        fkBatterie: _selectedBatterieIds,
        fkAmortisseurs: _selectedAmortisseurIds,
        fkFreins: _selectedFreinIds,
        fkCourroie: _selectedCourroieIds,
        fkRefroidissement: _selectedRefroidissementIds,
      );
      await service.updateAffectation(updated);
      if (mounted) {
        _showSnack(context, 'Affectation mise à jour avec succès');
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        _showSnack(context, 'Erreur lors de la mise à jour: $e', isError: true);
      }
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lightTheme = ThemeData.light(useMaterial3: true).copyWith(
      scaffoldBackgroundColor: _L.surface,
      colorScheme: const ColorScheme.light(
          primary: _L.primary, surface: _L.surface, onSurface: _L.textPri),
      cardColor: _L.surface, canvasColor: _L.surface, dividerColor: _L.border,
      iconTheme: const IconThemeData(color: _L.textSec),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: _L.textPri),
        bodySmall: TextStyle(color: _L.textSec),
      ),
    );
    return Theme(
      data: lightTheme,
      child: Dialog(
      backgroundColor: _L.surface,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: _L.border)),
      elevation: 0,
      child: Container(
        width: 580,
        constraints: const BoxConstraints(maxHeight: 720),
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    _L.info.withOpacity(0.15),
                    _L.info.withOpacity(0.06)
                  ]),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _L.info.withOpacity(0.22)),
                ),
                child: const Icon(Icons.edit_outlined,
                    color: _L.info, size: 20),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Modifier l\'affectation',
                        style: TextStyle(
                            color: _L.textPri,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            letterSpacing: -0.2)),
                    // Badge immatriculation
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _L.primaryBg,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: _L.primaryMid.withOpacity(0.4)),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.directions_car_rounded,
                            size: 11, color: _L.primary),
                        const SizedBox(width: 5),
                        Text(widget.affectation.fkImmatriculation,
                            style: const TextStyle(
                                color: _L.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                      ]),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: _L.surfaceAlt,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _L.border)),
                  child: const Icon(Icons.close_rounded,
                      size: 16, color: _L.textSec),
                ),
              ),
            ]),
            const SizedBox(height: 8),
            const Divider(color: _L.border, height: 1),
            const SizedBox(height: 18),

            // ── Contenu ──
            Expanded(
              child: _loadingPieces
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                          5,
                          (i) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _ShimmerBox(
                                  width: double.infinity,
                                  height: 80,
                                  radius: 14))),
                    )
                  : Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            buildPieceSelectorSection('Pneus', _pneus, _selectedPneuIds, (ids) => setState(() => _selectedPneuIds = List<int>.from(ids))),
                            buildPieceSelectorSection('Huile Moteur', _huilesMoteur, _selectedHuileMoteurIds, (ids) => setState(() => _selectedHuileMoteurIds = List<int>.from(ids))),
                            buildPieceSelectorSection('Filtres', _filtres, _selectedFiltreIds, (ids) => setState(() => _selectedFiltreIds = List<int>.from(ids))),
                            buildPieceSelectorSection('Embrayage', _embrayages, _selectedEmbrayageIds, (ids) => setState(() => _selectedEmbrayageIds = List<int>.from(ids))),
                            buildPieceSelectorSection('Batterie', _batteries, _selectedBatterieIds, (ids) => setState(() => _selectedBatterieIds = List<int>.from(ids))),
                            buildPieceSelectorSection('Amortisseurs', _amortisseurs, _selectedAmortisseurIds, (ids) => setState(() => _selectedAmortisseurIds = List<int>.from(ids))),
                            buildPieceSelectorSection('Freins', _freins, _selectedFreinIds, (ids) => setState(() => _selectedFreinIds = List<int>.from(ids))),
                            buildPieceSelectorSection('Courroie', _courroies, _selectedCourroieIds, (ids) => setState(() => _selectedCourroieIds = List<int>.from(ids))),
                            buildPieceSelectorSection('Eau de Refroidissement', _refroidissements, _selectedRefroidissementIds, (ids) => setState(() => _selectedRefroidissementIds = List<String>.from(ids))),
                          ],
                        ),
                      ),
                    ),
            ),

            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              TextButton(
                onPressed:
                    _submitting ? null : () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                    foregroundColor: _L.textSec,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 11),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: _L.border))),
                child: const Text('Annuler',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
              ),
              const SizedBox(width: 10),
              _ConfirmButton(
                label: 'Enregistrer',
                color: _L.info,
                onTap: _submitting ? null : _submitEdit,
                loading: _submitting,
              ),
            ]),
          ],
        ),
      ),
    ), // Dialog
    ); // Theme
  }
}

// ═══════════════════════════════════════════════════════════════
//  DATA SOURCE
// ═══════════════════════════════════════════════════════════════
class _AffectationDataSource extends DataTableSource {
  final List<AffectationPiece> _affectations;
  final Function(AffectationPiece) _onDelete;
  final Function(AffectationPiece) _onEdit;

  final Map<String, Map<dynamic, Map<String, dynamic>>> _pieceDetailsCache = {
    'pneus': {},
    'huileMoteur': {},
    'filtres': {},
    'embrayage': {},
    'batterie': {},
    'amortisseurs': {},
    'freins': {},
    'courroie': {},
    'refroidissement': {},
  };

  bool _loadingDetails = false;

  _AffectationDataSource(
      this._affectations, BuildContext context, this._onDelete, this._onEdit) {
    _loadAllPieceDetails();
  }

  Future<void> _loadAllPieceDetails() async {
    if (_loadingDetails) return;
    _loadingDetails = true;
    final piecesService = PiecesService();

    final Map<String, Set<dynamic>> allIds = {
      'pneus': <int>{},
      'huileMoteur': <int>{},
      'filtres': <int>{},
      'embrayage': <int>{},
      'batterie': <int>{},
      'amortisseurs': <int>{},
      'freins': <int>{},
      'courroie': <int>{},
      'refroidissement': <String>{},
    };

    for (final a in _affectations) {
      allIds['pneus']!.addAll(a.fkPneus);
      allIds['huileMoteur']!.addAll(a.fkHuileMoteur);
      allIds['filtres']!.addAll(a.fkFiltres);
      allIds['embrayage']!.addAll(a.fkEmbrayage);
      allIds['batterie']!.addAll(a.fkBatterie);
      allIds['amortisseurs']!.addAll(a.fkAmortisseurs);
      allIds['freins']!.addAll(a.fkFreins);
      allIds['courroie']!.addAll(a.fkCourroie);
      allIds['refroidissement']!.addAll(
          a.fkRefroidissement.map((id) => id.toString()));
    }

    try {
      final results = await Future.wait([
        piecesService.getPneusByIds((allIds['pneus']!).cast<int>().toList()),
        piecesService.getHuileMoteursByIds((allIds['huileMoteur']!).cast<int>().toList()),
        piecesService.getFiltresByIds((allIds['filtres']!).cast<int>().toList()),
        piecesService.getEmbrayagesByIds((allIds['embrayage']!).cast<int>().toList()),
        piecesService.getBatteriesByIds((allIds['batterie']!).cast<int>().toList()),
        piecesService.getAmortisseursByIds((allIds['amortisseurs']!).cast<int>().toList()),
        piecesService.getFreinsByIds((allIds['freins']!).cast<int>().toList()),
        piecesService.getCourroiesByIds((allIds['courroie']!).cast<int>().toList()),
        piecesService.getEauRefroidissementsByIds((allIds['refroidissement']!).cast<String>().toList()),
      ]);

      final keys = ['pneus','huileMoteur','filtres','embrayage','batterie','amortisseurs','freins','courroie','refroidissement'];
      for (int i = 0; i < keys.length; i++) {
        for (final piece in results[i]) {
          _pieceDetailsCache[keys[i]]![piece['id']] = piece;
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur chargement détails pièces: $e');
    } finally {
      _loadingDetails = false;
    }
  }

  String _getPieceDescription(String pieceType, dynamic id) {
    if (_pieceDetailsCache[pieceType]?.containsKey(id) != true) {
      return id.toString();
    }
    final piece = _pieceDetailsCache[pieceType]![id]!;
    String desc = '${piece['reference']} — ${piece['marque']}';
    if (piece['type'] != null) {
      desc += ' (${piece['type']})';
    } else if (piece['nom'] != null) desc += ' (${piece['nom']})';
    else if (piece['capacite'] != null) desc += ' (${piece['capacite']})';
    return desc;
  }

  Widget _buildPieceListWidget(String pieceType, List<dynamic> ids) {
    if (ids.isEmpty) {
      return const Text('—',
          style: TextStyle(color: _L.textMuted, fontSize: 12));
    }

    final color = _L.categoryColors.values
        .elementAt(_pieceTypeIndex(pieceType));

    // Max 2 lignes visibles → cellule de 88px ne déborde jamais
    const maxVisible = 2;
    final visible = ids.take(maxVisible).toList();
    final extra = ids.length - maxVisible;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badge compteur compact
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          decoration: BoxDecoration(
            color: color.withOpacity(0.09),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Text(
            '${ids.length} pièce${ids.length > 1 ? 's' : ''}',
            style: TextStyle(
                color: color, fontWeight: FontWeight.w700, fontSize: 9),
          ),
        ),
        const SizedBox(height: 3),
        // Items — Column pure, pas de ListView
        ...visible.map((id) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.only(right: 4, top: 1),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _getPieceDescription(pieceType, id),
                      style: const TextStyle(
                          fontSize: 10,
                          color: _L.textSec,
                          height: 1.3),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )),
        // Badge "+N" si surplus
        if (extra > 0)
          Text(
            '+$extra autre${extra > 1 ? 's' : ''}',
            style: TextStyle(
                fontSize: 9,
                color: color.withOpacity(0.8),
                fontWeight: FontWeight.w600),
          ),
      ],
    );
  }

  int _pieceTypeIndex(String type) {
    const order = [
      'pneus','huileMoteur','filtres','embrayage',
      'batterie','amortisseurs','freins','courroie','refroidissement'
    ];
    return order.indexOf(type).clamp(0, _L.categoryColors.length - 1);
  }

  @override
  DataRow getRow(int index) {
    final a = _affectations[index];
    return DataRow2(
      color: WidgetStateProperty.resolveWith<Color?>(
        (states) {
          if (states.contains(WidgetState.hovered)) {
            return _L.primary.withOpacity(0.05);
          }
          // Alternance explicite : blanc pur / bleu très pâle
          return index.isEven
              ? const Color(0xFFF7F9FF)
              : _L.surface;
        },
      ),
      cells: [
        DataCell(Text('#${a.id}',
            style: const TextStyle(
                color: _L.primary,
                fontWeight: FontWeight.w700,
                fontSize: 12))),
        DataCell(Row(children: [
          const Icon(Icons.directions_car_rounded,
              size: 13, color: _L.textSec),
          const SizedBox(width: 6),
          Flexible(
            child: Text(a.fkImmatriculation,
                style: const TextStyle(
                    color: _L.textPri,
                    fontWeight: FontWeight.w600,
                    fontSize: 12),
                overflow: TextOverflow.ellipsis),
          ),
        ])),
        DataCell(_buildPieceListWidget('pneus', a.fkPneus)),
        DataCell(_buildPieceListWidget('huileMoteur', a.fkHuileMoteur)),
        DataCell(_buildPieceListWidget('filtres', a.fkFiltres)),
        DataCell(_buildPieceListWidget('embrayage', a.fkEmbrayage)),
        DataCell(_buildPieceListWidget('batterie', a.fkBatterie)),
        DataCell(_buildPieceListWidget('amortisseurs', a.fkAmortisseurs)),
        DataCell(_buildPieceListWidget('freins', a.fkFreins)),
        DataCell(_buildPieceListWidget('courroie', a.fkCourroie)),
        DataCell(_buildPieceListWidget('refroidissement', a.fkRefroidissement)),
        DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
          _ActionBtn(
            icon: Icons.edit_outlined,
            color: _L.primary,
            tooltip: 'Modifier',
            onTap: () => _onEdit(a),
          ),
          const SizedBox(width: 5),
          _ActionBtn(
            icon: Icons.delete_outline_rounded,
            color: _L.danger,
            tooltip: 'Supprimer',
            onTap: () => _onDelete(a),
          ),
        ])),
      ],
    );
  }

  @override
  int get rowCount => _affectations.length;
  @override
  bool get isRowCountApproximate => false;
  @override
  int get selectedRowCount => 0;
}

/// Bouton action dans la table
class _ActionBtn extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;
  const _ActionBtn(
      {required this.icon,
      required this.color,
      required this.tooltip,
      required this.onTap});

  @override
  State<_ActionBtn> createState() => _ActionBtnState();
}

class _ActionBtnState extends State<_ActionBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: _hovered
                  ? widget.color.withOpacity(0.14)
                  : widget.color.withOpacity(0.07),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _hovered
                    ? widget.color.withOpacity(0.3)
                    : widget.color.withOpacity(0.18),
              ),
            ),
            child:
                Icon(widget.icon, size: 15, color: widget.color),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  MAIN SCREEN
// ═══════════════════════════════════════════════════════════════
class AffectationPiecesScreen extends StatefulWidget {
  const AffectationPiecesScreen({super.key});

  @override
  State<AffectationPiecesScreen> createState() =>
      _AffectationPiecesScreenState();
}

class _AffectationPiecesScreenState extends State<AffectationPiecesScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<AffectationPiece>> _affectationsFuture;
  int _rowsPerPage = 10;
  String _searchQuery = '';
  List<AffectationPiece> _filteredAffectations = [];
  final TextEditingController _searchCtrl = TextEditingController();

  // Animations
  late AnimationController _headerCtrl;
  late Animation<Offset>   _headerSlide;
  late Animation<double>   _headerFade;

  @override
  void initState() {
    super.initState();
    _affectationsFuture = _fetchAffectations();

    _headerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _headerSlide = Tween<Offset>(
            begin: const Offset(0, -0.1), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOutCubic));
    _headerFade = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
    _headerCtrl.forward();
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<List<AffectationPiece>> _fetchAffectations() async {
    try {
      final client = Supabase.instance.client;
      final service = AffectationPiecesService(client);
      final result = await service.getAllAffectations();
      _filterAffectations(result);
      return result;
    } catch (e) {
      debugPrint('ERREUR : $e');
      return [];
    }
  }

  void _filterAffectations(List<AffectationPiece> affectations) {
    if (_searchQuery.isEmpty) {
      _filteredAffectations = List.from(affectations);
      return;
    }
    final q = _searchQuery.toLowerCase();
    _filteredAffectations = affectations
        .where((a) =>
            a.fkImmatriculation.toLowerCase().contains(q) ||
            a.id.toString().contains(q))
        .toList();
  }

  void _showAddAffectationDialog() {
    _showAnimatedDialog(context, const _AddAffectationDialog()).then((_) {
      setState(() => _affectationsFuture = _fetchAffectations());
    });
  }

  Future<void> _deleteAffectation(AffectationPiece affectation) async {
    final confirmed = await _showAnimatedDialog<bool>(
      context,
      Dialog(
        backgroundColor: _L.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: _L.border)),
        elevation: 0,
        child: Container(
          width: 380,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: _L.dangerBg,
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                          color: _L.danger.withOpacity(0.22))),
                  child: const Icon(Icons.delete_outline_rounded,
                      color: _L.danger, size: 18),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('Confirmer la suppression',
                      style: TextStyle(
                          color: _L.textPri,
                          fontWeight: FontWeight.w800,
                          fontSize: 15)),
                ),
              ]),
              const SizedBox(height: 8),
              const Divider(color: _L.border, height: 1),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: _L.dangerBg,
                    borderRadius: BorderRadius.circular(11)),
                child: Row(children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: _L.danger, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Vous êtes sur le point de supprimer l\'affectation pour "${affectation.fkImmatriculation}". Cette action est irréversible.',
                      style: const TextStyle(
                          color: _L.danger, fontSize: 13, height: 1.4),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: TextButton.styleFrom(
                      foregroundColor: _L.textSec,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 11),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: _L.border))),
                  child: const Text('Annuler',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                ),
                const SizedBox(width: 10),
                _ConfirmButton(
                  label: 'Supprimer',
                  color: _L.danger,
                  onTap: () => Navigator.of(context).pop(true),
                ),
              ]),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      try {
        final client = Supabase.instance.client;
        final service = AffectationPiecesService(client);
        await service.deleteAffectation(affectation.id);
        setState(() => _affectationsFuture = _fetchAffectations());
        if (mounted) {
          _showSnack(context, 'Affectation supprimée avec succès');
        }
      } catch (e) {
        if (mounted) {
          _showSnack(context, 'Erreur lors de la suppression: $e',
              isError: true);
        }
      }
    }
  }

  Future<void> _editAffectation(AffectationPiece affectation) async {
    final result = await _showAnimatedDialog<bool>(
        context, _EditAffectationDialog(affectation: affectation));
    if (result == true) {
      setState(() => _affectationsFuture = _fetchAffectations());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Force le thème clair sur toute la page, quel que soit le thème de l'app
    return Theme(
      data: ThemeData.light(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: _L.bg,
        colorScheme: const ColorScheme.light(
          primary:   _L.primary,
          surface:   _L.surface,
          onSurface: _L.textPri,
          secondary: _L.primary,
        ),
        cardColor:   _L.surface,
        canvasColor: _L.surface,
        dividerColor: _L.border,
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: _L.surfaceAlt,
          labelStyle: TextStyle(color: _L.textSec),
          hintStyle:  TextStyle(color: _L.textMuted),
        ),
        iconTheme: const IconThemeData(color: _L.textSec),
        dropdownMenuTheme: DropdownMenuThemeData(
          menuStyle: MenuStyle(
            backgroundColor: WidgetStateProperty.all(_L.surface),
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge:  TextStyle(color: _L.textPri),
          bodyMedium: TextStyle(color: _L.textPri),
          bodySmall:  TextStyle(color: _L.textSec),
        ),
      ),
      child: Scaffold(
        backgroundColor: _L.bg,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header animé ──
            SlideTransition(
              position: _headerSlide,
              child: FadeTransition(
                opacity: _headerFade,
                child: _buildHeader(),
              ),
            ),
            // ── Toolbar ──
            _buildToolbar(),
            // ── Contenu principal ──
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  //  HEADER
  // ─────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      decoration: BoxDecoration(
        color: _L.surface,
        border: const Border(bottom: BorderSide(color: _L.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icône principale
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                _L.primary.withOpacity(0.15),
                _L.primary.withOpacity(0.06),
              ]),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _L.primary.withOpacity(0.22)),
            ),
            child: const Icon(Icons.link_rounded,
                color: _L.primary, size: 22),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Affectation des Pièces',
                  style: TextStyle(
                      color: _L.textPri,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4)),
              SizedBox(height: 2),
              Text('Associez des pièces à vos véhicules',
                  style: TextStyle(color: _L.textSec, fontSize: 12)),
            ],
          ),
          const Spacer(),
          // Stat pill
          _statPill(Icons.link_outlined, 'Véhicules liés', _L.primary),
          const SizedBox(width: 8),
          _statPill(Icons.build_outlined, '9 catégories', _L.info),
          const SizedBox(width: 16),
          // Bouton ajouter
          _AddButton(
            onTap: _showAddAffectationDialog,
            label: 'Nouvelle affectation',
            icon: Icons.add_link_rounded,
          ),
        ],
      ),
    );
  }

  Widget _statPill(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 5),
        Text(label,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────
  //  TOOLBAR
  // ─────────────────────────────────────────────────────
  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 11, 20, 11),
      decoration: const BoxDecoration(
        color: _L.surface,
        border: Border(bottom: BorderSide(color: _L.border)),
      ),
      child: Row(children: [
        _SearchField(
          controller: _searchCtrl,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
              _affectationsFuture.then(_filterAffectations);
            });
          },
        ),
        const Spacer(),
        // Compteur
        FutureBuilder<List<AffectationPiece>>(
          future: _affectationsFuture,
          builder: (_, snap) {
            final count = snap.hasData ? snap.data!.length : 0;
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Container(
                key: ValueKey(count),
                padding: const EdgeInsets.symmetric(
                    horizontal: 13, vertical: 6),
                decoration: BoxDecoration(
                  color: _L.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: _L.primary.withOpacity(0.22)),
                ),
                child: Text(
                  '$count affectation${count != 1 ? 's' : ''}',
                  style: const TextStyle(
                      color: _L.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
            );
          },
        ),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────
  //  BODY
  // ─────────────────────────────────────────────────────
  Widget _buildBody() {
    return FutureBuilder<List<AffectationPiece>>(
      future: _affectationsFuture,
      builder: (context, snapshot) {
        // Loading state — shimmer
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildSkeletonTable();
        }

        // Error state
        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        final allAffectations = snapshot.data ?? [];
        final affectations = _searchQuery.isNotEmpty
            ? _filteredAffectations
            : allAffectations;

        // Empty state
        if (affectations.isEmpty) {
          return _buildEmptyState(allAffectations);
        }

        // Table
        return _buildTable(affectations, allAffectations);
      },
    );
  }

  Widget _buildSkeletonTable() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: _S.card(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header row
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: _L.surfaceAlt,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [80.0, 140.0, 100.0, 100.0, 100.0].map((w) =>
                  Padding(
                    padding: const EdgeInsets.only(right: 28),
                    child: _ShimmerBox(width: w, height: 12, radius: 5),
                  )).toList(),
              ),
            ),
            // Rows
            ...List.generate(7, (i) => Container(
              height: 100,
              decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: _L.border.withOpacity(0.5), width: 0.8)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(children: [
                _ShimmerBox(width: 50, height: 22, radius: 6),
                const SizedBox(width: 28),
                _ShimmerBox(width: 120, height: 22, radius: 6),
                const SizedBox(width: 28),
                ...[90.0, 80.0, 80.0].map((w) => Padding(
                  padding: const EdgeInsets.only(right: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ShimmerBox(width: 50, height: 12, radius: 5),
                      const SizedBox(height: 6),
                      _ShimmerBox(width: w, height: 10, radius: 4),
                      const SizedBox(height: 4),
                      _ShimmerBox(width: w * 0.7, height: 10, radius: 4),
                    ],
                  ),
                )),
              ]),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutBack,
        builder: (_, v, child) => Transform.scale(scale: v, child: child),
        child: Container(
          padding: const EdgeInsets.all(36),
          margin: const EdgeInsets.all(24),
          decoration: _S.card(radius: 20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                  color: _L.dangerBg, shape: BoxShape.circle),
              child: const Icon(Icons.error_outline_rounded,
                  color: _L.danger, size: 34),
            ),
            const SizedBox(height: 18),
            const Text('Erreur de chargement',
                style: TextStyle(
                    color: _L.textPri,
                    fontWeight: FontWeight.w800,
                    fontSize: 17)),
            const SizedBox(height: 10),
            Text(error,
                style: const TextStyle(color: _L.textSec, fontSize: 13),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () =>
                  setState(() => _affectationsFuture = _fetchAffectations()),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: _L.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11)),
                  elevation: 0),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildEmptyState(List<AffectationPiece> allAffectations) {
    final isSearch = _searchQuery.isNotEmpty;
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeOutBack,
        builder: (_, v, child) => Transform.scale(scale: v, child: child),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 44),
          margin: const EdgeInsets.all(40),
          decoration: _S.card(radius: 20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _PulsingIcon(
              icon: isSearch
                  ? Icons.search_off_rounded
                  : Icons.assignment_late_outlined,
              color: isSearch ? _L.warning : _L.primary,
            ),
            const SizedBox(height: 20),
            Text(
              isSearch
                  ? 'Aucun résultat pour "$_searchQuery"'
                  : 'Aucune affectation trouvée',
              style: const TextStyle(
                  color: _L.textPri,
                  fontWeight: FontWeight.w800,
                  fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              isSearch
                  ? 'Essayez un autre terme de recherche.'
                  : 'Commencez par créer une première affectation.',
              style: const TextStyle(color: _L.textSec, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (isSearch)
              _HoverButton(
                color: _L.warning,
                onTap: () {
                  setState(() {
                    _searchQuery = '';
                    _searchCtrl.clear();
                    _filterAffectations(allAffectations);
                  });
                },
                child: Row(mainAxisSize: MainAxisSize.min, children: const [
                  Icon(Icons.clear_rounded, size: 14, color: _L.warning),
                  SizedBox(width: 5),
                  Text('Effacer la recherche',
                      style: TextStyle(
                          color: _L.warning,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ]),
              )
            else
              _AddButton(
                onTap: _showAddAffectationDialog,
                label: 'Nouvelle affectation',
                icon: Icons.add_link_rounded,
              ),
          ]),
        ),
      ),
    );
  }

  Widget _buildTable(List<AffectationPiece> affectations,
      List<AffectationPiece> allAffectations) {
    final dataSource = _AffectationDataSource(
        affectations, context, _deleteAffectation, _editAffectation);

    // ── Thème clair forcé pour toute la table ──────────────────────
    // L'app utilise un ThemeData sombre ; on l'écrase ici pour que
    // PaginatedDataTable2 et ses enfants (fond, textes, dividers,
    // pagination) affichent toujours des couleurs claires.
    final lightTheme = ThemeData.light(useMaterial3: true).copyWith(
      scaffoldBackgroundColor: _L.surface,
      colorScheme: const ColorScheme.light(
        primary:    _L.primary,
        surface:    _L.surface,
        onSurface:  _L.textPri,
        secondary:  _L.primary,
      ),
      cardColor:      _L.surface,
      canvasColor:    _L.surface,
      dividerColor:   _L.border,
      iconTheme:      const IconThemeData(color: _L.textSec),
      textTheme: const TextTheme(
        bodyMedium:  TextStyle(color: _L.textPri, fontSize: 13),
        bodySmall:   TextStyle(color: _L.textSec, fontSize: 12),
        labelSmall:  TextStyle(color: _L.textSec, fontSize: 11),
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(_L.surfaceAlt),
        dataRowColor: WidgetStateProperty.resolveWith<Color?>(
          (states) {
            if (states.contains(WidgetState.hovered)) {
              return _L.primary.withOpacity(0.04);
            }
            return _L.surface;
          },
        ),
        headingTextStyle: const TextStyle(
          color:      _L.textSec,
          fontWeight: FontWeight.w700,
          fontSize:   11,
          letterSpacing: 0.5,
        ),
        dataTextStyle: const TextStyle(color: _L.textPri, fontSize: 12),
        dividerThickness: 0.8,
      ),
    );

    return Theme(
      data: lightTheme,
      child: Container(
        margin: const EdgeInsets.all(20),
        decoration: _S.card(),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: PaginatedDataTable2(
            columnSpacing: 10,
            horizontalMargin: 12,
            minWidth: 1500,
            rowsPerPage: _rowsPerPage,
            dataRowHeight: 88,
            showCheckboxColumn: false,
            dividerThickness: 0.8,
            showFirstLastButtons: true,
            renderEmptyRowsInTheEnd: false,
            source: dataSource,
            headingRowColor: WidgetStateProperty.all(_L.surfaceAlt),
            headingTextStyle: const TextStyle(
              color:      _L.textSec,
              fontWeight: FontWeight.w700,
              fontSize:   11,
              letterSpacing: 0.5,
            ),
            onRowsPerPageChanged: (value) =>
                setState(() => _rowsPerPage = value!),
            availableRowsPerPage: const [5, 10, 20, 50],
            header: Row(children: [
              const Text('Affectations de pièces',
                  style: TextStyle(
                      color:      _L.textPri,
                      fontWeight: FontWeight.w800,
                      fontSize:   16,
                      letterSpacing: -0.3)),
              const Spacer(),
              if (_searchQuery.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _L.warningBg,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(color: _L.warning.withOpacity(0.3)),
                  ),
                  child: Text(
                    '${affectations.length} résultat(s)',
                    style: const TextStyle(
                        color:      _L.warning,
                        fontSize:   12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 6),
                _HoverButton(
                  color: _L.textMuted,
                  onTap: () {
                    setState(() {
                      _searchQuery = '';
                      _searchCtrl.clear();
                      _filterAffectations(allAffectations);
                    });
                  },
                  padding: const EdgeInsets.all(6),
                  child: const Icon(Icons.close_rounded,
                      size: 14, color: _L.textMuted),
                ),
              ],
            ]),
            columns: [
              DataColumn2(label: const Text('ID'),            size: ColumnSize.S),
              DataColumn2(label: const Text('Immatriculation'), size: ColumnSize.L),
              const DataColumn2(label: Text('Pneus')),
              const DataColumn2(label: Text('Huile Moteur')),
              const DataColumn2(label: Text('Filtres')),
              const DataColumn2(label: Text('Embrayage')),
              const DataColumn2(label: Text('Batterie')),
              const DataColumn2(label: Text('Amortisseurs')),
              const DataColumn2(label: Text('Freins')),
              const DataColumn2(label: Text('Courroie')),
              const DataColumn2(label: Text('Refroidissement')),
              DataColumn2(label: const Text('Actions'),       size: ColumnSize.S),
            ],
          ),
        ),
      ),
    );
  }
}