import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import 'config/supabase_config.dart';
import 'theme/app_theme.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/pieces/pieces_screen.dart';
import 'screens/vehicles/vehicles_screen.dart';
import 'screens/clients/clients_screen.dart';
import 'screens/feedback/feedback_screen.dart';
import 'screens/analytics/analytics_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/notifications/notifications_panel.dart';
import 'services/auth_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser Supabase
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
      title: 'KARHABTI Admin Dashboard',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: authService.isAuthenticated ? '/dashboard' : '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const AdminDashboard(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  final List<String> _titles = [
    'Tableau de bord',
    'Gestion des pièces',
    'Véhicules',
    'Clients',
    'Feedbacks',
    'Analytiques',
    'Paramètres',
    'Profil'
  ];

  // État pour le panneau de notifications
  bool _showNotifications = false;
  final GlobalKey _notificationButtonKey = GlobalKey();
  
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return AdminScaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: AppTheme.whiteColor,
        actions: [
          Stack(
            children: [
              IconButton(
                key: _notificationButtonKey,
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  setState(() {
                    _showNotifications = !_showNotifications;
                  });
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: AppTheme.dangerColor,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: const Center(
                    child: Text(
                      '4',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              setState(() {
                _selectedIndex = 7; // Index pour le profil
              });
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await authService.signOut();
                if (mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur de déconnexion: ${e.toString()}')),
                );
              }
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      sideBar: SideBar(
        backgroundColor: AppTheme.whiteColor,
        activeBackgroundColor: AppTheme.primaryColor.withOpacity(0.1),
        activeIconColor: AppTheme.primaryColor,
        activeTextStyle: const TextStyle(color: AppTheme.primaryColor, fontSize: 14),
        textStyle: const TextStyle(color: AppTheme.greyColor, fontSize: 14),
        items: [
          AdminMenuItem(
            title: 'Tableau de bord',
            icon: Icons.dashboard,
          ),
          AdminMenuItem(
            title: 'Gestion des pièces',
            icon: Icons.settings,
          ),
          AdminMenuItem(
            title: 'Véhicules',
            icon: Icons.directions_car,
          ),
          AdminMenuItem(
            title: 'Clients',
            icon: Icons.people,
          ),
          AdminMenuItem(
            title: 'Feedbacks',
            icon: Icons.feedback,
          ),
          AdminMenuItem(
            title: 'Analytiques',
            icon: Icons.analytics,
          ),
          AdminMenuItem(
            title: 'Paramètres',
            icon: Icons.settings_outlined,
          ),
          AdminMenuItem(
            title: 'Profil',
            icon: Icons.person_outline,
          ),
        ],
        selectedRoute: _selectedIndex.toString(),
        onSelected: (item) {
          setState(() {
            _selectedIndex = _titles.indexOf(item.title);
          });
        },
      ),
      body: Stack(
        children: [
          _getBody(),
          if (_showNotifications)
            Positioned(
              top: 0,
              right: 16,
              child: NotificationsPanel(
                onClose: () {
                  setState(() {
                    _showNotifications = false;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _getBody() {
    switch (_selectedIndex) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const PiecesScreen();
      case 2:
        return const VehiclesScreen();
      case 3:
        return const ClientsScreen();
      case 4:
        return const FeedbackScreen();
      case 5:
        return const AnalyticsScreen();
      case 6:
        return const SettingsScreen();
      case 7:
        return const ProfileScreen();
      default:
        return const DashboardScreen();
    }
  }
}

class NotificationsPanel extends StatelessWidget {
  final VoidCallback onClose;

  const NotificationsPanel({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 400,
      decoration: BoxDecoration(
        color: AppTheme.whiteColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppTheme.greyColor.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Notifications',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: onClose,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Notification ${index + 1}'),
                  subtitle: Text('Description de la notification ${index + 1}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
