// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/supabase_config.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/vehicles/vehicles_screen.dart';
import 'screens/clients/clients_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'services/auth_service.dart';
import 'screens/feedback/feedback_screen.dart';
import 'screens/analytics/analytics_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/responsable/garage_setup_screen.dart';
import 'screens/responsable/responsable_shell.dart';
import 'services/responsable_technicien_service.dart';
import 'screens/admin/responsables_screen.dart';
import 'theme/karhabti_tokens.dart';
import 'models/nav_models.dart';
import 'widgets/karhabti_dashboard_shell.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  await initializeDateFormatting('fr_FR', null);
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
    return MaterialApp(
      title: 'CARHABTI Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: KarhabtiTokens.bg,
        colorScheme: const ColorScheme.dark(
          primary: KarhabtiTokens.gold,
          surface: KarhabtiTokens.surface,
        ),
      ),
      initialRoute: '/home',
      routes: {
        '/home': (_) => const RoleRouterScreen(),
        '/login': (_) => const LoginScreen(),
        '/dashboard': (_) => const AdminDashboard(),
        '/profile': (_) => const ProfileScreen(),
        '/responsable': (_) => const ResponsableShell(),
        '/garage-setup': (_) => const ResponsableGarageSetupScreen(),
      },
    );
  }
}

class RoleRouterScreen extends StatefulWidget {
  const RoleRouterScreen({super.key});

  @override
  State<RoleRouterScreen> createState() => _RoleRouterScreenState();
}

class _RoleRouterScreenState extends State<RoleRouterScreen> {
  final _auth = AuthService();
  final _responsableService = ResponsableTechnicienService();
  String? _error;
  bool _working = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _redirect());
  }

  void _goTo(String route) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(route);
    });
  }

  Future<void> _redirect() async {
    if (!mounted) return;
    setState(() {
      _working = true;
      _error = null;
    });

    try {
      if (!_auth.isAuthenticated) {
        _goTo('/login');
        return;
      }

      final isAdmin = await _auth.isAdmin(_auth.currentUser!.id).timeout(const Duration(seconds: 12));

      if (!mounted) return;

      if (isAdmin) {
        _goTo('/dashboard');
        return;
      }
      
      switch (UserRole.responsableTechnicien) {
        case UserRole.admin:
          _goTo('/dashboard');
          return;
        case UserRole.responsableTechnicien:
          final user = _auth.currentUser!;
          final hasGarage = await _responsableService
              .hasGarage(user.id)
              .timeout(const Duration(seconds: 12));
          if (!mounted) return;
          _goTo(hasGarage ? '/responsable' : '/garage-setup');
          return;
        case UserRole.client:
          if (mounted) {
            setState(() {
              _working = false;
              _error =
                  'Ce compte est un compte client. Utilisez l\'application client, '
                  'ou demandez à un admin de vous ajouter dans admins / responsables_techniciens.';
            });
          }
          return;
        case UserRole.unknown:
          if (mounted) {
            setState(() {
              _working = false;
              _error =
                  'Compte connecté, mais aucun rôle admin ou responsable technicien détecté.\n\n'
                  'Ajoutez votre UUID dans Supabase :\n'
                  '• public.admins (id = votre user_id)\n'
                  '• ou public.admin_users (user_id)\n'
                  '• ou public.responsables_techniciens (id, nom_complet, est_actif=true)';
            });
          }
          return;
      }
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _working = false;
        _error =
            'Délai dépassé lors de la vérification du rôle (Supabase). '
            'Vérifiez votre connexion internet et réessayez.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _working = false;
        _error =
            'Impossible de déterminer votre rôle. '
            'Vérifiez que le script SQL responsable_technicien a été exécuté '
            'et que votre compte existe dans admins ou responsables_techniciens.\n\n'
            'Détail: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: _error == null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 12),
                      Text(
                        _working ? 'Chargement…' : 'Préparation…',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.error_outline, size: 40),
                      const SizedBox(height: 12),
                      Text(_error!, textAlign: TextAlign.left),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _working ? null : _redirect,
                        child: const Text('Réessayer'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: _working
                            ? null
                            : () async {
                                await _auth.signOut();
                                _goTo('/login');
                              },
                        child: const Text('Se déconnecter'),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _shellKey = GlobalKey<KarhabtiDashboardShellState>();

  static const List<String> _titles = [
    'Tableau de bord',
    'Véhicules',
    'Clients',
    'Responsables techniciens',
    'Feedbacks',
    'Analytiques',
    'Paramètres',
    'Profil',
  ];

  late final List<Widget> _pages;

  static final List<NavSection> _sections = [
    NavSection(
      label: 'Gestion générale',
      sectionIcon: Icons.grid_view_rounded,
      accentColor: KarhabtiTokens.info,
      items: [
        NavItem(label: 'Tableau de bord', icon: Icons.dashboard_rounded, index: 0),
        NavItem(
          label: 'Véhicules',
          icon: Icons.directions_car_rounded,
          index: 1,
          badge: 'Nouveau',
          badgeColor: KarhabtiTokens.success,
        ),
        NavItem(label: 'Clients', icon: Icons.people_rounded, index: 2),
        NavItem(label: 'Responsables', icon: Icons.engineering_rounded, index: 3),
      ],
    ),
    NavSection(
      label: 'Analyses & Suivi',
      sectionIcon: Icons.analytics_rounded,
      accentColor: KarhabtiTokens.warning,
      items: [
        NavItem(
          label: 'Feedbacks',
          icon: Icons.feedback_rounded,
          index: 4,
          badge: '4',
          badgeColor: KarhabtiTokens.danger,
        ),
        NavItem(label: 'Analytiques', icon: Icons.analytics_rounded, index: 5),
      ],
    ),
    NavSection(
      label: 'Paramètres',
      sectionIcon: Icons.tune_rounded,
      accentColor: KarhabtiTokens.textSec,
      items: [
        NavItem(label: 'Paramètres', icon: Icons.settings_outlined, index: 6),
        NavItem(label: 'Profil', icon: Icons.person_outline_rounded, index: 7),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pages = [
      DashboardScreen(onNavigate: (i) => _shellKey.currentState?.goToPage(i)),
      const VehiclesScreen(),
      const ClientsScreen(),
      const ResponsablesScreen(),
      const FeedbackScreen(),
      const AnalyticsScreen(),
      const SettingsScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return KarhabtiDashboardShell(
      key: _shellKey,
      config: KarhabtiShellConfig(
        consoleSubtitle: 'Admin Console',
        footerRoleTitle: 'Administrateur',
        footerRoleSubtitle: 'Super Admin',
        titles: _titles,
        pages: _pages,
        sections: _sections,
        initialSectionOpen: const [true, true, false],
        profilePageIndex: 7,
      ),
    );
  }
}
