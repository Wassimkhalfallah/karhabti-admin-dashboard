// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../theme/karhabti_tokens.dart';
import '../models/nav_models.dart';

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  SIDEBAR SECTION â€” Collapsable animÃ©e
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
class SidebarSection extends StatefulWidget {
  final NavSection section;
  final bool        isOpen;
  final int         selectedIndex;
  final VoidCallback           onToggle;
  final void Function(int)     onSelectItem;

  const SidebarSection({
    required this.section,
    required this.isOpen,
    required this.selectedIndex,
    required this.onToggle,
    required this.onSelectItem,
  });

  @override
  State<SidebarSection> createState() => SidebarSectionState();
}

class SidebarSectionState extends State<SidebarSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _expand;
  late Animation<double>   _rotate;

  @override
  void initState() {
    super.initState();
    _ctrl   = AnimationController(vsync: this, duration: const Duration(milliseconds: 280));
    _expand = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _rotate = Tween<double>(begin: 0.0, end: 0.5)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    if (widget.isOpen) _ctrl.value = 1.0;
  }

  @override
  void didUpdateWidget(SidebarSection old) {
    super.didUpdateWidget(old);
    if (widget.isOpen != old.isOpen) {
      widget.isOpen ? _ctrl.forward() : _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sec = widget.section;

    return Column(
      children: [
        // En-tÃªte de section cliquable
        InkWell(
          onTap: widget.onToggle,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 14, 6),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: sec.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Icon(sec.sectionIcon, size: 13, color: sec.accentColor),
                ),
                const SizedBox(width: 9),
                Text(sec.label.toUpperCase(),
                    style: TextStyle(
                      color: sec.accentColor.withOpacity(0.85),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    )),
                const Spacer(),
                RotationTransition(
                  turns: _rotate,
                  child: Icon(Icons.expand_more_rounded,
                      size: 16, color: KarhabtiTokens.textMuted),
                ),
              ],
            ),
          ),
        ),
        // Items animÃ©s
        SizeTransition(
          sizeFactor: _expand,
          child: FadeTransition(
            opacity: _expand,
            child: Column(
              children: sec.items.map((item) {
                final isSelected = widget.selectedIndex == item.index;
                return SidebarItemTile(
                  item:       item,
                  isSelected: isSelected,
                  accent:     sec.accentColor,
                  onTap:      () => widget.onSelectItem(item.index),
                );
              }).toList(),
            ),
          ),
        ),
        // SÃ©parateur bas de section
        Container(
          margin: const EdgeInsets.fromLTRB(18, 8, 18, 0),
          height: 1,
          color: KarhabtiTokens.border.withOpacity(0.5),
        ),
      ],
    );
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  SIDEBAR ITEM â€” Tile animÃ©
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
class SidebarItemTile extends StatefulWidget {
  final NavItem    item;
  final bool        isSelected;
  final Color       accent;
  final VoidCallback onTap;

  const SidebarItemTile({
    required this.item,
    required this.isSelected,
    required this.accent,
    required this.onTap,
  });

  @override
  State<SidebarItemTile> createState() => SidebarItemTileState();
}

class SidebarItemTileState extends State<SidebarItemTile>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  late AnimationController _selCtrl;
  late Animation<double>   _selAnim;

  @override
  void initState() {
    super.initState();
    _selCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 220));
    _selAnim = CurvedAnimation(parent: _selCtrl, curve: Curves.easeOutQuart);
    if (widget.isSelected) _selCtrl.value = 1.0;
  }

  @override
  void didUpdateWidget(SidebarItemTile old) {
    super.didUpdateWidget(old);
    if (widget.isSelected != old.isSelected) {
      widget.isSelected ? _selCtrl.forward() : _selCtrl.reverse();
    }
  }

  @override
  void dispose() {
    _selCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent;

    return MouseRegion(
      onEnter:  (_) => setState(() => _hovered = true),
      onExit:   (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          child: AnimatedBuilder(
            animation: _selAnim,
            builder: (_, child) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 42,
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? accent.withOpacity(0.12)
                      : _hovered
                          ? KarhabtiTokens.surfaceAlt
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: widget.isSelected
                      ? Border.all(color: accent.withOpacity(0.25))
                      : Border.all(color: Colors.transparent),
                ),
                child: Row(
                  children: [
                    // Indicateur latÃ©ral
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutQuart,
                      width: 3,
                      height: widget.isSelected ? 24 : 0,
                      margin: const EdgeInsets.only(left: 1),
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: widget.isSelected
                            ? [BoxShadow(color: accent.withOpacity(0.5), blurRadius: 6)]
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // IcÃ´ne
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: widget.isSelected
                            ? accent.withOpacity(0.18)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        widget.item.icon,
                        size: 17,
                        color: widget.isSelected ? accent : KarhabtiTokens.textSec,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Label
                    Expanded(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 180),
                        style: TextStyle(
                          color: widget.isSelected ? accent : KarhabtiTokens.textSec,
                          fontWeight: widget.isSelected
                              ? FontWeight.w700
                              : FontWeight.w400,
                          fontSize: 13,
                        ),
                        child: Text(widget.item.label,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ),
                    // Badge
                    if (widget.item.badge != null) ...[
                      Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: (widget.item.badgeColor ?? KarhabtiTokens.gold)
                              .withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: (widget.item.badgeColor ?? KarhabtiTokens.gold)
                                .withOpacity(0.35),
                          ),
                        ),
                        child: Text(
                          widget.item.badge!,
                          style: TextStyle(
                            color: widget.item.badgeColor ?? KarhabtiTokens.gold,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  TOP BAR â€” Recherche globale
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
class TopBarSearch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 36,
      child: TextField(
        style: const TextStyle(color: KarhabtiTokens.textPri, fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Recherche globaleâ€¦',
          hintStyle: const TextStyle(color: KarhabtiTokens.textMuted, fontSize: 12),
          prefixIcon: const Icon(Icons.search_rounded, color: KarhabtiTokens.textMuted, size: 17),
          suffixIcon: Container(
            margin: const EdgeInsets.all(6),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: KarhabtiTokens.surfaceAlt,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: KarhabtiTokens.border),
            ),
            child: const Text('âŒ˜K',
                style: TextStyle(color: KarhabtiTokens.textMuted, fontSize: 10,
                    fontWeight: FontWeight.w600)),
          ),
          filled: true,
          fillColor: KarhabtiTokens.surfaceAlt,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: KarhabtiTokens.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: KarhabtiTokens.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: KarhabtiTokens.gold, width: 1.5),
          ),
          isDense: true,
        ),
      ),
    );
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  TOP BAR â€” Bouton notifications
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
class NotificationButton extends StatefulWidget {
  final int  count;
  final bool isActive;
  final VoidCallback onTap;

  const NotificationButton({
    required this.count,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<NotificationButton> createState() => NotificationButtonState();
}

class NotificationButtonState extends State<NotificationButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double>   _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.6, end: 1.0)
        .animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Notifications',
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: widget.isActive
                ? KarhabtiTokens.gold.withOpacity(0.12)
                : KarhabtiTokens.surfaceAlt,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.isActive
                  ? KarhabtiTokens.gold.withOpacity(0.35)
                  : KarhabtiTokens.border,
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                widget.isActive
                    ? Icons.notifications_rounded
                    : Icons.notifications_outlined,
                size: 18,
                color: widget.isActive ? KarhabtiTokens.gold : KarhabtiTokens.textSec,
              ),
              if (widget.count > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (_, __) => Opacity(
                      opacity: _pulseAnim.value,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                        decoration: BoxDecoration(
                          color: KarhabtiTokens.danger,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: KarhabtiTokens.danger.withOpacity(0.5),
                                blurRadius: 4),
                          ],
                        ),
                        child: Center(
                          child: Text('${widget.count}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              )),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  PANNEAU DE NOTIFICATIONS
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
class NotificationsPanel extends StatefulWidget {
  final VoidCallback onClose;
  const NotificationsPanel({required this.onClose});

  @override
  State<NotificationsPanel> createState() => NotificationsPanelState();
}

class NotificationsPanelState extends State<NotificationsPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset>   _slide;
  late Animation<double>   _fade;

  static const _notifs = [
    (
      icon: Icons.shopping_cart_rounded,
      color: KarhabtiTokens.success,
      title: 'Nouvelle commande piÃ¨ces',
      desc:  'Ref. CMD-2041 vient d\'Ãªtre validÃ©e',
      time:  'Il y a 5 min',
      isNew: true,
    ),
    (
      icon: Icons.warning_amber_rounded,
      color: KarhabtiTokens.warning,
      title: 'Stock bas dÃ©tectÃ©',
      desc:  'Filtre Ã  huile â€” 3 unitÃ©s restantes',
      time:  'Il y a 2 h',
      isNew: true,
    ),
    (
      icon: Icons.person_add_rounded,
      color: KarhabtiTokens.info,
      title: 'Nouveau client inscrit',
      desc:  'Ahmed B. vient de crÃ©er un compte',
      time:  'Hier',
      isNew: false,
    ),
    (
      icon: Icons.error_outline_rounded,
      color: KarhabtiTokens.danger,
      title: 'Erreur de synchronisation',
      desc:  'Supabase â€” tentative Ã©chouÃ©e Ã  03:12',
      time:  'Il y a 3 jours',
      isNew: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 280));
    _slide = Tween<Offset>(begin: const Offset(0.06, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child: Container(
          width: 340,
          constraints: const BoxConstraints(maxHeight: 500),
          margin: const EdgeInsets.only(right: 12, top: 6),
          decoration: BoxDecoration(
            color: KarhabtiTokens.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: KarhabtiTokens.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 28,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _panelHeader(),
              const Divider(height: 1, color: KarhabtiTokens.border),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _notifs.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: KarhabtiTokens.border, indent: 16, endIndent: 16),
                  itemBuilder: (_, i) => _notifTile(_notifs[i], i),
                ),
              ),
              _panelFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _panelHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: KarhabtiTokens.gold.withOpacity(0.12),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: KarhabtiTokens.gold.withOpacity(0.25)),
            ),
            child: const Icon(Icons.notifications_rounded, color: KarhabtiTokens.gold, size: 16),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Notifications',
                  style: TextStyle(
                    color: KarhabtiTokens.textPri,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  )),
              Text('${_notifs.where((n) => n.isNew).length} nouvelles',
                  style: const TextStyle(color: KarhabtiTokens.textMuted, fontSize: 11)),
            ],
          ),
          const Spacer(),
          Tooltip(
            message: 'Tout marquer comme lu',
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.done_all_rounded, size: 16, color: KarhabtiTokens.textSec),
              ),
              onTap: () {},
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: widget.onClose,
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.close_rounded, size: 16, color: KarhabtiTokens.textSec),
            ),
          ),
        ],
      ),
    );
  }

  Widget _notifTile(dynamic n, int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      color: n.isNew ? KarhabtiTokens.gold.withOpacity(0.03) : Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (n.color as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: (n.color as Color).withOpacity(0.2)),
              ),
              child: Icon(n.icon as IconData, color: n.color as Color, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(n.title as String,
                            style: const TextStyle(
                              color: KarhabtiTokens.textPri,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            )),
                      ),
                      if (n.isNew as bool)
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: KarhabtiTokens.gold,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: KarhabtiTokens.gold.withOpacity(0.6),
                                  blurRadius: 4)
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(n.desc as String,
                      style: const TextStyle(color: KarhabtiTokens.textSec, fontSize: 12, height: 1.4)),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          size: 11, color: KarhabtiTokens.textMuted),
                      const SizedBox(width: 4),
                      Text(n.time as String,
                          style: const TextStyle(color: KarhabtiTokens.textMuted, fontSize: 11)),
                      if (n.isNew as bool) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: KarhabtiTokens.gold.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: KarhabtiTokens.gold.withOpacity(0.3)),
                          ),
                          child: const Text('NOUVEAU',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: KarhabtiTokens.gold,
                                letterSpacing: 0.4,
                              )),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              color: KarhabtiTokens.surfaceAlt,
              icon: const Icon(Icons.more_vert_rounded,
                  size: 15, color: KarhabtiTokens.textMuted),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: KarhabtiTokens.border),
              ),
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'read',
                    child: Text('Marquer comme lu',
                        style: TextStyle(color: KarhabtiTokens.textPri, fontSize: 13))),
                const PopupMenuItem(value: 'delete',
                    child: Text('Supprimer',
                        style: TextStyle(color: KarhabtiTokens.danger, fontSize: 13))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _panelFooter() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: KarhabtiTokens.border)),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        color: KarhabtiTokens.surfaceAlt,
      ),
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          minimumSize: const Size(double.infinity, 0),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Voir toutes les notifications',
                style: TextStyle(
                  color: KarhabtiTokens.gold,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                )),
            SizedBox(width: 6),
            Icon(Icons.arrow_forward_rounded, size: 14, color: KarhabtiTokens.gold),
          ],
        ),
      ),
    );
  }
}
