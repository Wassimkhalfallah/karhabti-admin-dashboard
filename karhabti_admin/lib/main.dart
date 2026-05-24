// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/supabase_config.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/pieces/pieces_screen.dart';
import 'screens/vehicles/vehicles_screen.dart';
import 'screens/clients/clients_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/affectation_pieces/affectation_pieces_screen.dart';
import 'services/auth_service.dart';
import 'screens/feedback/feedback_screen.dart';
import 'screens/analytics/analytics_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/garages_pro/garages_pro_dashboard.dart';
import 'screens/garages_pro/garages_list_screen.dart';
import 'screens/garages_pro/appointments_screen.dart';
import 'screens/garages_pro/reviews_screen.dart';
import 'screens/garages_pro/prestations_screen.dart';
import 'screens/garages_pro/notifications_screen.dart';

// ═══════════════════════════════════════════════════════════════
//  DESIGN TOKENS — palette cohérente avec les autres écrans
// ═══════════════════════════════════════════════════════════════
class _T {
  // Couleurs de fond
  static const bg         = Color(0xFF0F1117);
  static const surface    = Color(0xFF181C27);
  static const surfaceAlt = Color(0xFF1E2333);
  static const border     = Color(0xFF2A2F45);

  // Accents
  static const gold       = Color(0xFFD4A843);
  static const success    = Color(0xFF34D399);
  static const danger     = Color(0xFFF87171);
  static const warning    = Color(0xFFFBBF24);
  static const info       = Color(0xFF60A5FA);

  // Texte
  static const textPri    = Color(0xFFF0F2F8);
  static const textSec    = Color(0xFF8B93A8);
  static const textMuted  = Color(0xFF4A5168);

  // Sidebar
  static const sidebarW   = 264.0;
}

// ═══════════════════════════════════════════════════════════════
//  ENTRY POINT
// ═══════════════════════════════════════════════════════════════
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  runApp(
    Provider<AuthService>(
      create: (_) => AuthService(),
      child: const KarhabtiAdminApp(),
    ),
  );
}

class KarhabtiAdminApp extends StatelessWidget {
  const KarhabtiAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return MaterialApp(
      title: 'CARHABTI Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: _T.bg,
        colorScheme: const ColorScheme.dark(
          primary: _T.gold,
          surface: _T.surface,
        ),
      ),
      initialRoute: authService.isAuthenticated ? '/dashboard' : '/login',
      routes: {
        '/login':     (_) => const LoginScreen(),
        '/dashboard': (_) => const AdminDashboard(),
        '/profile':   (_) => const ProfileScreen(),
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  MODÈLE — Section de navigation
// ═══════════════════════════════════════════════════════════════
class _NavSection {
  final String label;
  final IconData sectionIcon;
  final Color   accentColor;
  final List<_NavItem> items;
  const _NavSection({
    required this.label,
    required this.sectionIcon,
    required this.accentColor,
    required this.items,
  });
}

class _NavItem {
  final String   label;
  final IconData icon;
  final int      index;
  final String?  badge;
  final Color?   badgeColor;
  const _NavItem({
    required this.label,
    required this.icon,
    required this.index,
    this.badge,
    this.badgeColor,
  });
}

// ═══════════════════════════════════════════════════════════════
//  ADMIN DASHBOARD — Shell principal
// ═══════════════════════════════════════════════════════════════
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with TickerProviderStateMixin {

  // ── Navigation ──
  int _selectedIndex = 0;

  static const List<String> _titles = [
    'Tableau de bord',
    'Gestion des pièces',
    'Affectation Pièces',
    'Véhicules',
    'Clients',
    'Feedbacks',
    'Analytiques',
    'Paramètres',
    'Profil',
    'Garages PRO — Dashboard',
    'Garages PRO — Liste',
    'Rendez-vous',
    'Avis',
    'Prestations',
    'Notifications',
  ];

  static const List<Widget> _pages = [
    DashboardScreen(),
    PiecesScreen(),
    AffectationPiecesScreen(),
    VehiclesScreen(),
    ClientsScreen(),
    FeedbackScreen(),
    AnalyticsScreen(),
    SettingsScreen(),
    ProfileScreen(),
    GaragesProDashboard(),
    GaragesListScreen(),
    AppointmentsScreen(),
    ReviewsScreen(),
    PrestationsScreen(),
    NotificationsJournalScreen(),
  ];

  // ── Structure de navigation par sections ──
  static final List<_NavSection> _sections = [
    _NavSection(
      label: 'Gestion générale',
      sectionIcon: Icons.grid_view_rounded,
      accentColor: _T.info,
      items: [
        _NavItem(label: 'Tableau de bord',   icon: Icons.dashboard_rounded,            index: 0),
        _NavItem(label: 'Pièces',             icon: Icons.settings_rounded,             index: 1, badge: '3', badgeColor: _T.info),
        _NavItem(label: 'Affectation Pièces', icon: Icons.assignment_turned_in_rounded, index: 2),
        _NavItem(label: 'Véhicules',          icon: Icons.directions_car_rounded,       index: 3, badge: 'Nouveau', badgeColor: _T.success),
        _NavItem(label: 'Clients',            icon: Icons.people_rounded,               index: 4),
      ],
    ),
    _NavSection(
      label: 'Garages PRO',
      sectionIcon: Icons.store_rounded,
      accentColor: _T.gold,
      items: [
        _NavItem(label: 'Dashboard PRO', icon: Icons.dashboard_rounded,        index: 9),
        _NavItem(label: 'Garages',       icon: Icons.store_rounded,            index: 10, badge: 'PRO', badgeColor: _T.gold),
        _NavItem(label: 'Rendez-vous',   icon: Icons.calendar_month_outlined,  index: 11),
        _NavItem(label: 'Avis',          icon: Icons.star_outline_rounded,     index: 12),
        _NavItem(label: 'Prestations',   icon: Icons.build_circle_outlined,    index: 13),
        _NavItem(label: 'Notifications', icon: Icons.notifications_outlined,   index: 14),
      ],
    ),
    _NavSection(
      label: 'Analyses & Suivi',
      sectionIcon: Icons.analytics_rounded,
      accentColor: _T.warning,
      items: [
        _NavItem(label: 'Feedbacks',   icon: Icons.feedback_rounded,  index: 5, badge: '4', badgeColor: _T.danger),
        _NavItem(label: 'Analytiques', icon: Icons.analytics_rounded, index: 6),
      ],
    ),
    _NavSection(
      label: 'Paramètres',
      sectionIcon: Icons.tune_rounded,
      accentColor: _T.textSec,
      items: [
        _NavItem(label: 'Paramètres', icon: Icons.settings_outlined,      index: 7),
        _NavItem(label: 'Profil',     icon: Icons.person_outline_rounded,  index: 8),
      ],
    ),
  ];

  // ── États des sections (ouvert/fermé) ──
  final List<bool> _sectionOpen = [true, true, true, false];

  // ── Notifications ──
  bool _showNotifications = false;

  // ── Animations ──
  late AnimationController _shellCtrl;
  late Animation<double>   _shellFade;
  late AnimationController _pageCtrl;
  late Animation<Offset>   _pageSlide;
  late Animation<double>   _pageFade;

  @override
  void initState() {
    super.initState();

    // Apparition initiale du shell
    _shellCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _shellFade = CurvedAnimation(parent: _shellCtrl, curve: Curves.easeOut);
    _shellCtrl.forward();

    // Transition de page
    _pageCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 280));
    _pageSlide = Tween<Offset>(begin: const Offset(0.04, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _pageCtrl, curve: Curves.easeOutCubic));
    _pageFade  = CurvedAnimation(parent: _pageCtrl, curve: Curves.easeOut);
    _pageCtrl.forward();
  }

  @override
  void dispose() {
    _shellCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  void _navigateTo(int index) {
    if (_selectedIndex == index) return;
    _pageCtrl.reverse().then((_) {
      setState(() => _selectedIndex = index);
      _pageCtrl.forward();
    });
    if (_showNotifications) setState(() => _showNotifications = false);
  }

  // ════════════════════════ BUILD ════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _T.bg,
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

  // ══════════════════════════════════════════════════════
  //  SIDEBAR
  // ══════════════════════════════════════════════════════
  Widget _buildSidebar() {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero)
          .animate(CurvedAnimation(parent: _shellCtrl, curve: Curves.easeOutQuart)),
      child: Container(
        width: _T.sidebarW,
        decoration: const BoxDecoration(
          color: _T.surface,
          border: Border(right: BorderSide(color: _T.border)),
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

  // ── Logo ──
  Widget _buildSidebarLogo() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _T.border)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_T.gold, Color(0xFFB8860B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: _T.gold.withOpacity(0.35),
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
              const Text('CARHABTI',
                  style: TextStyle(
                    color: _T.textPri,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  )),
              Text('Admin Console',
                  style: TextStyle(
                    color: _T.gold.withOpacity(0.8),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  )),
            ],
          ),
        ],
      ),
    );
  }

  // ── Recherche rapide dans la sidebar ──
  Widget _buildSidebarSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
      child: TextField(
        style: const TextStyle(color: _T.textPri, fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Navigation rapide…',
          hintStyle: const TextStyle(color: _T.textMuted, fontSize: 12),
          prefixIcon: const Icon(Icons.search_rounded, color: _T.textMuted, size: 17),
          filled: true,
          fillColor: _T.surfaceAlt,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _T.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _T.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _T.gold, width: 1.5),
          ),
          isDense: true,
        ),
      ),
    );
  }

  // ── Menu avec sections collapsables ──
  Widget _buildSidebarMenu() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 6, bottom: 12),
      child: Column(
        children: _sections.asMap().entries.map((e) {
          final i       = e.key;
          final section = e.value;
          return _SidebarSection(
            section:    section,
            isOpen:     _sectionOpen[i],
            selectedIndex: _selectedIndex,
            onToggle:   () => setState(() => _sectionOpen[i] = !_sectionOpen[i]),
            onSelectItem: _navigateTo,
          );
        }).toList(),
      ),
    );
  }

  // ── Footer admin ──
  Widget _buildSidebarFooter() {
    final authService = Provider.of<AuthService>(context, listen: false);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _T.border)),
        color: _T.surfaceAlt,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_T.gold, Color(0xFFB8860B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.admin_panel_settings_rounded,
                color: Color(0xFF1A1200), size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Administrateur',
                    style: TextStyle(color: _T.textPri, fontWeight: FontWeight.w700, fontSize: 13)),
                const Text('Super Admin',
                    style: TextStyle(color: _T.textMuted, fontSize: 11)),
              ],
            ),
          ),
          // Déconnexion
          Tooltip(
            message: 'Déconnexion',
            child: InkWell(
              onTap: () async {
                try {
                  await authService.signOut();
                  if (mounted) Navigator.of(context).pushReplacementNamed('/login');
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur : ${e.toString()}')));
                  }
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: _T.danger.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _T.danger.withOpacity(0.2)),
                ),
                child: const Icon(Icons.logout_rounded, size: 16, color: _T.danger),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  //  TOP BAR
  // ══════════════════════════════════════════════════════
  Widget _buildTopBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: _T.surface,
        border: Border(bottom: BorderSide(color: _T.border)),
      ),
      child: Row(
        children: [
          // Breadcrumb / titre
          Row(
            children: [
              const Icon(Icons.speed_rounded, size: 14, color: _T.textMuted),
              const SizedBox(width: 6),
              const Text('CARHABTI',
                  style: TextStyle(color: _T.textMuted, fontSize: 12, letterSpacing: 0.5)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.chevron_right_rounded, size: 14, color: _T.textMuted),
              ),
              Text(_titles[_selectedIndex],
                  style: const TextStyle(
                    color: _T.textPri,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  )),
            ],
          ),

          const Spacer(),

          // Recherche globale
          _TopBarSearch(),
          const SizedBox(width: 12),

          // Divider vertical
          Container(width: 1, height: 24, color: _T.border),
          const SizedBox(width: 12),

          // Bouton notifications
          _NotificationButton(
            count: 4,
            isActive: _showNotifications,
            onTap: () => setState(() => _showNotifications = !_showNotifications),
          ),
          const SizedBox(width: 8),

          // Profil rapide
          GestureDetector(
            onTap: () => _navigateTo(8),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _T.gold.withOpacity(0.5), width: 2),
              ),
              child: CircleAvatar(
                radius: 14,
                backgroundColor: _T.gold.withOpacity(0.15),
                child: const Icon(Icons.person_rounded, size: 16, color: _T.gold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  //  CONTENU PRINCIPAL (page + panneau notifs)
  // ══════════════════════════════════════════════════════
  Widget _buildMainContent() {
    return Stack(
      children: [
        // Page animée
        SlideTransition(
          position: _pageSlide,
          child: FadeTransition(
            opacity: _pageFade,
            child: _pages[_selectedIndex],
          ),
        ),
        // Panneau de notifications en overlay
        if (_showNotifications)
          Positioned(
            top: 0,
            right: 0,
            child: _NotificationsPanel(
              onClose: () => setState(() => _showNotifications = false),
            ),
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  SIDEBAR SECTION — Collapsable animée
// ═══════════════════════════════════════════════════════════════
class _SidebarSection extends StatefulWidget {
  final _NavSection section;
  final bool        isOpen;
  final int         selectedIndex;
  final VoidCallback           onToggle;
  final void Function(int)     onSelectItem;

  const _SidebarSection({
    required this.section,
    required this.isOpen,
    required this.selectedIndex,
    required this.onToggle,
    required this.onSelectItem,
  });

  @override
  State<_SidebarSection> createState() => _SidebarSectionState();
}

class _SidebarSectionState extends State<_SidebarSection>
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
  void didUpdateWidget(_SidebarSection old) {
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
        // En-tête de section cliquable
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
                      size: 16, color: _T.textMuted),
                ),
              ],
            ),
          ),
        ),
        // Items animés
        SizeTransition(
          sizeFactor: _expand,
          child: FadeTransition(
            opacity: _expand,
            child: Column(
              children: sec.items.map((item) {
                final isSelected = widget.selectedIndex == item.index;
                return _SidebarItemTile(
                  item:       item,
                  isSelected: isSelected,
                  accent:     sec.accentColor,
                  onTap:      () => widget.onSelectItem(item.index),
                );
              }).toList(),
            ),
          ),
        ),
        // Séparateur bas de section
        Container(
          margin: const EdgeInsets.fromLTRB(18, 8, 18, 0),
          height: 1,
          color: _T.border.withOpacity(0.5),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  SIDEBAR ITEM — Tile animé
// ═══════════════════════════════════════════════════════════════
class _SidebarItemTile extends StatefulWidget {
  final _NavItem    item;
  final bool        isSelected;
  final Color       accent;
  final VoidCallback onTap;

  const _SidebarItemTile({
    required this.item,
    required this.isSelected,
    required this.accent,
    required this.onTap,
  });

  @override
  State<_SidebarItemTile> createState() => _SidebarItemTileState();
}

class _SidebarItemTileState extends State<_SidebarItemTile>
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
  void didUpdateWidget(_SidebarItemTile old) {
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
                          ? _T.surfaceAlt
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: widget.isSelected
                      ? Border.all(color: accent.withOpacity(0.25))
                      : Border.all(color: Colors.transparent),
                ),
                child: Row(
                  children: [
                    // Indicateur latéral
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
                    // Icône
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
                        color: widget.isSelected ? accent : _T.textSec,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Label
                    Expanded(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 180),
                        style: TextStyle(
                          color: widget.isSelected ? accent : _T.textSec,
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
                          color: (widget.item.badgeColor ?? _T.gold)
                              .withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: (widget.item.badgeColor ?? _T.gold)
                                .withOpacity(0.35),
                          ),
                        ),
                        child: Text(
                          widget.item.badge!,
                          style: TextStyle(
                            color: widget.item.badgeColor ?? _T.gold,
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

// ═══════════════════════════════════════════════════════════════
//  TOP BAR — Recherche globale
// ═══════════════════════════════════════════════════════════════
class _TopBarSearch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 36,
      child: TextField(
        style: const TextStyle(color: _T.textPri, fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Recherche globale…',
          hintStyle: const TextStyle(color: _T.textMuted, fontSize: 12),
          prefixIcon: const Icon(Icons.search_rounded, color: _T.textMuted, size: 17),
          suffixIcon: Container(
            margin: const EdgeInsets.all(6),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: _T.surfaceAlt,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _T.border),
            ),
            child: const Text('⌘K',
                style: TextStyle(color: _T.textMuted, fontSize: 10,
                    fontWeight: FontWeight.w600)),
          ),
          filled: true,
          fillColor: _T.surfaceAlt,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _T.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _T.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _T.gold, width: 1.5),
          ),
          isDense: true,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  TOP BAR — Bouton notifications
// ═══════════════════════════════════════════════════════════════
class _NotificationButton extends StatefulWidget {
  final int  count;
  final bool isActive;
  final VoidCallback onTap;

  const _NotificationButton({
    required this.count,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NotificationButton> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<_NotificationButton>
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
                ? _T.gold.withOpacity(0.12)
                : _T.surfaceAlt,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.isActive
                  ? _T.gold.withOpacity(0.35)
                  : _T.border,
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
                color: widget.isActive ? _T.gold : _T.textSec,
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
                          color: _T.danger,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: _T.danger.withOpacity(0.5),
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

// ═══════════════════════════════════════════════════════════════
//  PANNEAU DE NOTIFICATIONS
// ═══════════════════════════════════════════════════════════════
class _NotificationsPanel extends StatefulWidget {
  final VoidCallback onClose;
  const _NotificationsPanel({required this.onClose});

  @override
  State<_NotificationsPanel> createState() => _NotificationsPanelState();
}

class _NotificationsPanelState extends State<_NotificationsPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset>   _slide;
  late Animation<double>   _fade;

  static const _notifs = [
    (
      icon: Icons.shopping_cart_rounded,
      color: _T.success,
      title: 'Nouvelle commande pièces',
      desc:  'Ref. CMD-2041 vient d\'être validée',
      time:  'Il y a 5 min',
      isNew: true,
    ),
    (
      icon: Icons.warning_amber_rounded,
      color: _T.warning,
      title: 'Stock bas détecté',
      desc:  'Filtre à huile — 3 unités restantes',
      time:  'Il y a 2 h',
      isNew: true,
    ),
    (
      icon: Icons.person_add_rounded,
      color: _T.info,
      title: 'Nouveau client inscrit',
      desc:  'Ahmed B. vient de créer un compte',
      time:  'Hier',
      isNew: false,
    ),
    (
      icon: Icons.error_outline_rounded,
      color: _T.danger,
      title: 'Erreur de synchronisation',
      desc:  'Supabase — tentative échouée à 03:12',
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
            color: _T.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _T.border),
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
              const Divider(height: 1, color: _T.border),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _notifs.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: _T.border, indent: 16, endIndent: 16),
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
              color: _T.gold.withOpacity(0.12),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: _T.gold.withOpacity(0.25)),
            ),
            child: const Icon(Icons.notifications_rounded, color: _T.gold, size: 16),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Notifications',
                  style: TextStyle(
                    color: _T.textPri,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  )),
              Text('${_notifs.where((n) => n.isNew).length} nouvelles',
                  style: const TextStyle(color: _T.textMuted, fontSize: 11)),
            ],
          ),
          const Spacer(),
          Tooltip(
            message: 'Tout marquer comme lu',
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.done_all_rounded, size: 16, color: _T.textSec),
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
              child: Icon(Icons.close_rounded, size: 16, color: _T.textSec),
            ),
          ),
        ],
      ),
    );
  }

  Widget _notifTile(dynamic n, int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      color: n.isNew ? _T.gold.withOpacity(0.03) : Colors.transparent,
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
                              color: _T.textPri,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            )),
                      ),
                      if (n.isNew as bool)
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: _T.gold,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: _T.gold.withOpacity(0.6),
                                  blurRadius: 4)
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(n.desc as String,
                      style: const TextStyle(color: _T.textSec, fontSize: 12, height: 1.4)),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          size: 11, color: _T.textMuted),
                      const SizedBox(width: 4),
                      Text(n.time as String,
                          style: const TextStyle(color: _T.textMuted, fontSize: 11)),
                      if (n.isNew as bool) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: _T.gold.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _T.gold.withOpacity(0.3)),
                          ),
                          child: const Text('NOUVEAU',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: _T.gold,
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
              color: _T.surfaceAlt,
              icon: const Icon(Icons.more_vert_rounded,
                  size: 15, color: _T.textMuted),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: _T.border),
              ),
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'read',
                    child: Text('Marquer comme lu',
                        style: TextStyle(color: _T.textPri, fontSize: 13))),
                const PopupMenuItem(value: 'delete',
                    child: Text('Supprimer',
                        style: TextStyle(color: _T.danger, fontSize: 13))),
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
        border: Border(top: BorderSide(color: _T.border)),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        color: _T.surfaceAlt,
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
                  color: _T.gold,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                )),
            SizedBox(width: 6),
            Icon(Icons.arrow_forward_rounded, size: 14, color: _T.gold),
          ],
        ),
      ),
    );
  }
}