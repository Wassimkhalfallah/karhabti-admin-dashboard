import 'package:flutter/material.dart';
import '../../models/nav_models.dart';
import '../../services/responsable_technicien_service.dart';
import '../../theme/karhabti_tokens.dart';
import '../../widgets/karhabti_dashboard_shell.dart';
import '../affectation_pieces/affectation_pieces_screen.dart';
import '../garages_pro/appointments_screen.dart';
import '../garages_pro/notifications_screen.dart';
import '../garages_pro/prestations_screen.dart';
import '../garages_pro/reviews_screen.dart';
import '../pieces/pieces_screen.dart';
import '../profile/profile_screen.dart';
import 'mon_garage_screen.dart';
import 'responsable_home_tab.dart';
import 'vehicules_screen.dart';

class ResponsableShell extends StatefulWidget {
  const ResponsableShell({super.key});

  @override
  State<ResponsableShell> createState() => _ResponsableShellState();
}

class _ResponsableShellState extends State<ResponsableShell> {
  final _responsableService = ResponsableTechnicienService();
  final _shellKey = GlobalKey<KarhabtiDashboardShellState>();

  bool _loading = true;
  String? _garageId;
  String _nomComplet = 'Responsable';

  static const List<String> _titles = [
    'Tableau de bord',
    'Gestion des pièces',
    'Affectation Pièces',
    'Rendez-vous',
    'Véhicules',
    'Mon garage',
    'Avis clients',
    'Prestations',
    'Notifications',
    'Profil',
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await _responsableService.getMyProfile();
    if (!mounted) return;
    if (profile?.garageId == null) {
      Navigator.of(context).pushReplacementNamed('/garage-setup');
      return;
    }
    setState(() {
      _garageId = profile!.garageId;
      _nomComplet = profile.nomComplet;
      _loading = false;
    });
  }

  List<NavSection> get _sections => [
        NavSection(
          label: 'Gestion garage',
          sectionIcon: Icons.grid_view_rounded,
          accentColor: KarhabtiTokens.info,
          items: [
            NavItem(label: 'Tableau de bord', icon: Icons.dashboard_rounded, index: 0),
            NavItem(label: 'Pièces', icon: Icons.settings_rounded, index: 1),
            NavItem(label: 'Affectation Pièces', icon: Icons.assignment_turned_in_rounded, index: 2),
            NavItem(label: 'Rendez-vous', icon: Icons.calendar_month_rounded, index: 3),
            NavItem(label: 'Véhicules', icon: Icons.directions_car_rounded, index: 4),
            NavItem(label: 'Mon garage', icon: Icons.store_rounded, index: 5),
          ],
        ),
        NavSection(
          label: 'Garages PRO',
          sectionIcon: Icons.store_rounded,
          accentColor: KarhabtiTokens.gold,
          items: [
            NavItem(label: 'Avis clients', icon: Icons.star_rounded, index: 6, badge: 'PRO', badgeColor: KarhabtiTokens.gold),
            NavItem(label: 'Prestations', icon: Icons.build_rounded, index: 7),
            NavItem(label: 'Notifications', icon: Icons.notifications_rounded, index: 8),
          ],
        ),
        NavSection(
          label: 'Compte',
          sectionIcon: Icons.person_rounded,
          accentColor: KarhabtiTokens.textSec,
          items: [
            NavItem(label: 'Profil', icon: Icons.person_outline_rounded, index: 9),
          ],
        ),
      ];

  List<Widget> _buildPages(String garageId) => [
        ResponsableHomeTab(
          garageId: garageId,
          onNavigate: (i) => _shellKey.currentState?.goToPage(i),
        ),
        const PiecesScreen(),
        const AffectationPiecesScreen(),
        AppointmentsScreen(garageId: garageId),
        ResponsableVehiculesScreen(garageId: garageId),
        MonGarageScreen(garageId: garageId),
        ReviewsScreen(garageId: garageId),
        const PrestationsScreen(),
        const NotificationsJournalScreen(),
        const ProfileScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    if (_loading || _garageId == null) {
      return const Scaffold(
        backgroundColor: KarhabtiTokens.bg,
        body: Center(child: CircularProgressIndicator(color: KarhabtiTokens.gold)),
      );
    }

    final gid = _garageId!;

    return KarhabtiDashboardShell(
      key: _shellKey,
      config: KarhabtiShellConfig(
        consoleSubtitle: 'Responsable Technicien',
        footerRoleTitle: _nomComplet,
        footerRoleSubtitle: 'Responsable garage',
        footerIcon: Icons.engineering_rounded,
        titles: _titles,
        pages: _buildPages(gid),
        sections: _sections,
        initialSectionOpen: const [true, true, false],
        profilePageIndex: 9,
      ),
    );
  }
}
