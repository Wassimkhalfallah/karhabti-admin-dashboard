import 'package:flutter/material.dart';

class NavSection {
  final String label;
  final IconData sectionIcon;
  final Color accentColor;
  final List<NavItem> items;

  const NavSection({
    required this.label,
    required this.sectionIcon,
    required this.accentColor,
    required this.items,
  });
}

class NavItem {
  final String label;
  final IconData icon;
  final int index;
  final String? badge;
  final Color? badgeColor;

  const NavItem({
    required this.label,
    required this.icon,
    required this.index,
    this.badge,
    this.badgeColor,
  });
}
