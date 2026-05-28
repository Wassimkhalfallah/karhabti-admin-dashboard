// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/karhabti_tokens.dart';
import '../models/nav_models.dart';
import '../services/auth_service.dart';
import 'karhabti_shell_widgets.dart';

class KarhabtiShellConfig {
  final String consoleSubtitle;
  final String footerRoleTitle;
  final String footerRoleSubtitle;
  final IconData footerIcon;
  final List<String> titles;
  final List<Widget> pages;
  final List<NavSection> sections;
  final List<bool> initialSectionOpen;
  final int profilePageIndex;

  const KarhabtiShellConfig({
    required this.consoleSubtitle,
    required this.footerRoleTitle,
    required this.footerRoleSubtitle,
    this.footerIcon = Icons.admin_panel_settings_rounded,
    required this.titles,
    required this.pages,
    required this.sections,
    required this.initialSectionOpen,
    required this.profilePageIndex,
  });
}

class KarhabtiDashboardShell extends StatefulWidget {
  final KarhabtiShellConfig config;

  const KarhabtiDashboardShell({super.key, required this.config});

  @override
  State<KarhabtiDashboardShell> createState() => KarhabtiDashboardShellState();
}

class KarhabtiDashboardShellState extends State<KarhabtiDashboardShell>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late List<bool> _sectionOpen;
  bool _showNotifications = false;

  late AnimationController _shellCtrl;
  late Animation<double> _shellFade;
  late AnimationController _pageCtrl;
  late Animation<Offset> _pageSlide;
  late Animation<double> _pageFade;

  KarhabtiShellConfig get _cfg => widget.config;

  @override
  void initState() {
    super.initState();
    _sectionOpen = List<bool>.from(_cfg.initialSectionOpen);

    _shellCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _shellFade = CurvedAnimation(parent: _shellCtrl, curve: Curves.easeOut);
    _shellCtrl.forward();

    _pageCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _pageSlide = Tween<Offset>(begin: const Offset(0.04, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _pageCtrl, curve: Curves.easeOutCubic));
    _pageFade = CurvedAnimation(parent: _pageCtrl, curve: Curves.easeOut);
    _pageCtrl.forward();
  }

  @override
  void dispose() {
    _shellCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  void goToPage(int index) {
    if (_selectedIndex == index) return;
    _pageCtrl.reverse().then((_) {
      if (!mounted) return;
      setState(() => _selectedIndex = index);
      _pageCtrl.forward();
    });
    if (_showNotifications) setState(() => _showNotifications = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KarhabtiTokens.bg,
      body: FadeTransition(
        opacity: _shellFade,
        child: Row(
          children: [
            _buildSidebar(),
            Expanded(
              child: Column(
                children: [
                  _buildTopBar(),
                  Expanded(child: _buildMainContent()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero).animate(
        CurvedAnimation(parent: _shellCtrl, curve: Curves.easeOutQuart),
      ),
      child: Container(
        width: KarhabtiTokens.sidebarW,
        decoration: const BoxDecoration(
          color: KarhabtiTokens.surface,
          border: Border(right: BorderSide(color: KarhabtiTokens.border)),
        ),
        child: Column(
          children: [
            _buildSidebarLogo(),
            _buildSidebarSearch(),
            Expanded(child: _buildSidebarMenu()),
            _buildSidebarFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarLogo() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: KarhabtiTokens.border)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [KarhabtiTokens.gold, Color(0xFFB8860B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: KarhabtiTokens.gold.withOpacity(0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.speed_rounded, color: Color(0xFF1A1200), size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CARHABTI',
                style: TextStyle(
                  color: KarhabtiTokens.textPri,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
              Text(
                _cfg.consoleSubtitle,
                style: TextStyle(
                  color: KarhabtiTokens.gold.withOpacity(0.8),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
      child: TextField(
        style: const TextStyle(color: KarhabtiTokens.textPri, fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Navigation rapide…',
          hintStyle: const TextStyle(color: KarhabtiTokens.textMuted, fontSize: 12),
          prefixIcon: const Icon(Icons.search_rounded, color: KarhabtiTokens.textMuted, size: 17),
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

  Widget _buildSidebarMenu() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 6, bottom: 12),
      child: Column(
        children: _cfg.sections.asMap().entries.map((e) {
          final i = e.key;
          final section = e.value;
          return SidebarSection(
            section: section,
            isOpen: _sectionOpen[i],
            selectedIndex: _selectedIndex,
            onToggle: () => setState(() => _sectionOpen[i] = !_sectionOpen[i]),
            onSelectItem: goToPage,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSidebarFooter() {
    final authService = Provider.of<AuthService>(context, listen: false);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: KarhabtiTokens.border)),
        color: KarhabtiTokens.surfaceAlt,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [KarhabtiTokens.gold, Color(0xFFB8860B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_cfg.footerIcon, color: const Color(0xFF1A1200), size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _cfg.footerRoleTitle,
                  style: const TextStyle(
                    color: KarhabtiTokens.textPri,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _cfg.footerRoleSubtitle,
                  style: const TextStyle(color: KarhabtiTokens.textMuted, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Tooltip(
            message: 'Déconnexion',
            child: InkWell(
              onTap: () async {
                try {
                  await authService.signOut();
                  if (mounted) {
                    Navigator.of(context).pushReplacementNamed('/login');
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur : $e')),
                    );
                  }
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: KarhabtiTokens.danger.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: KarhabtiTokens.danger.withOpacity(0.2)),
                ),
                child: const Icon(Icons.logout_rounded, size: 16, color: KarhabtiTokens.danger),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: KarhabtiTokens.surface,
        border: Border(bottom: BorderSide(color: KarhabtiTokens.border)),
      ),
      child: Row(
        children: [
          Row(
            children: [
              const Icon(Icons.speed_rounded, size: 14, color: KarhabtiTokens.textMuted),
              const SizedBox(width: 6),
              const Text(
                'CARHABTI',
                style: TextStyle(color: KarhabtiTokens.textMuted, fontSize: 12, letterSpacing: 0.5),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.chevron_right_rounded, size: 14, color: KarhabtiTokens.textMuted),
              ),
              Text(
                _cfg.titles[_selectedIndex],
                style: const TextStyle(
                  color: KarhabtiTokens.textPri,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Spacer(),
          const TopBarSearch(),
          const SizedBox(width: 12),
          Container(width: 1, height: 24, color: KarhabtiTokens.border),
          const SizedBox(width: 12),
          NotificationButton(
            count: 4,
            isActive: _showNotifications,
            onTap: () => setState(() => _showNotifications = !_showNotifications),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => goToPage(_cfg.profilePageIndex),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: KarhabtiTokens.gold.withOpacity(0.5), width: 2),
              ),
              child: CircleAvatar(
                radius: 14,
                backgroundColor: KarhabtiTokens.gold.withOpacity(0.15),
                child: const Icon(Icons.person_rounded, size: 16, color: KarhabtiTokens.gold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Stack(
      children: [
        SlideTransition(
          position: _pageSlide,
          child: FadeTransition(
            opacity: _pageFade,
            child: _cfg.pages[_selectedIndex],
          ),
        ),
        if (_showNotifications)
          Positioned(
            top: 0,
            right: 0,
            child: NotificationsPanel(
              onClose: () => setState(() => _showNotifications = false),
            ),
          ),
      ],
    );
  }
}
