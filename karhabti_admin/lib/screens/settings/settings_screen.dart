// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Paramu00e8tres de l'application
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _language = 'Franu00e7ais';
  String _dateFormat = 'DD/MM/YYYY';
  bool _autoBackupEnabled = true;
  String _backupFrequency = 'Quotidienne';

  // Paramu00e8tres de la base de donnu00e9es Supabase
  final TextEditingController _supabaseUrlController = TextEditingController(
    text: 'https://example.supabase.co',
  );
  final TextEditingController _supabaseKeyController = TextEditingController(
    text: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
  );

  // Paramu00e8tres des seuils d'alerte
  final TextEditingController _lowStockThresholdController =
      TextEditingController(text: '10');
  final TextEditingController _maintenanceReminderDaysController =
      TextEditingController(text: '30');
  final TextEditingController _predictionConfidenceController =
      TextEditingController(text: '75');

  @override
  void dispose() {
    _supabaseUrlController.dispose();
    _supabaseKeyController.dispose();
    _lowStockThresholdController.dispose();
    _maintenanceReminderDaysController.dispose();
    _predictionConfidenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildSettingsTabs(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Paramu00e8tres', style: AppTheme.headingLarge),
        const SizedBox(height: 8),
        Text(
          'Configurez les paramu00e8tres de votre tableau de bord d\'administration CARHABTI pour une gestion optimale de votre garage.',
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyColor),
        ),
      ],
    );
  }

  Widget _buildSettingsTabs() {
    return DefaultTabController(
      length: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppTheme.whiteColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppTheme.borderRadius),
                topRight: Radius.circular(AppTheme.borderRadius),
              ),
            ),
            child: TabBar(
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: AppTheme.greyColor,
              indicatorColor: AppTheme.primaryColor,
              tabs: const [
                Tab(text: 'général'),
                Tab(text: 'Base de donnees'),
                Tab(text: 'Seuils d\'alerte'),
                Tab(text: 'Utilisateurs'),
              ],
            ),
          ),
          Container(
            height: 600,
            decoration: BoxDecoration(
              color: AppTheme.whiteColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(AppTheme.borderRadius),
                bottomRight: Radius.circular(AppTheme.borderRadius),
              ),
            ),
            child: TabBarView(
              children: [
                _buildGeneralSettings(),
                _buildDatabaseSettings(),
                _buildAlertThresholdSettings(),
                _buildUserSettings(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralSettings() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'performance de l\'interface',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildSettingSwitch(
            'Activer les notifications',
            'Recevoir des alertes pour les mouvements importants',
            _notificationsEnabled,
            (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          const Divider(),
          _buildSettingSwitch(
            'Mode sombre',
            'Utiliser une interface sombre pour réduire la fatigue oculaire',
            _darkModeEnabled,
            (value) {
              setState(() {
                _darkModeEnabled = value;
              });
            },
          ),
          const Divider(),
          _buildSettingDropdown(
            'Langue',
            'Sélectionnez la langue de l\'interface',
            _language,
            ['Français', 'English', 'Arabic'],
            (value) {
              setState(() {
                _language = value!;
              });
            },
          ),
          const Divider(),
          _buildSettingDropdown(
            'Format de date',
            'Sélectionnez le format de date préférencé pour l\'affichage',
            _dateFormat,
            ['DD/MM/YYYY', 'MM/DD/YYYY', 'YYYY-MM-DD'],
            (value) {
              setState(() {
                _dateFormat = value!;
              });
            },
          ),
          const SizedBox(height: 32),
          const Text(
            'Sauvegarde des donnees',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildSettingSwitch(
            'Sauvegarde automatique',
            'Activer la sauvegarde automatique des donnees pour éviter toute perte d\'information',
            _autoBackupEnabled,
            (value) {
              setState(() {
                _autoBackupEnabled = value;
              });
            },
          ),
          const Divider(),
          _buildSettingDropdown(
            'Fréquence de sauvegarde',
            'Sélectionnez la fréquence de sauvegarde automatique',
            _backupFrequency,
            ['Quotidienne', 'Hebdomadaire', 'Mensuelle'],
            (value) {
              setState(() {
                _backupFrequency = value!;
              });
            },
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () {
                  // Ru00e9initialiser les paramu00e8tres
                  _showSnackBar('Paramu00e8tres ru00e9initialisu00e9s');
                },
                child: const Text('Ru00e9initialiser'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  // Sauvegarder les paramu00e8tres
                  _showSnackBar(
                    'paramètres enregistrés avec succès',
                  );
                },
                child: const Text('Enregistrer'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDatabaseSettings() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configuration Supabase',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildSettingTextField(
            'URL Supabase',
            'URL de votre instance Supabase',
            _supabaseUrlController,
          ),
          const SizedBox(height: 16),
          _buildSettingTextField(
            'Clé API anonyme',
            'Clé API Supabase pour les requêtes anonymes',
            _supabaseKeyController,
            isSecret: true,
          ),
          const SizedBox(height: 32),
          const Text(
            'Tests de connexion',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              // Tester la connexion u00e0 la base de donnu00e9es
              _showSnackBar('Test de connexion ruessie');
            },
            icon: const Icon(Icons.check_circle),
            label: const Text('Tester la connexion'),
          ),
          const SizedBox(height: 16),
          const Text(
            'Actions de base de donnu00e9es',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  // Demander confirmation avant de synchroniser
                  _showConfirmationDialog(
                    'Synchroniser la base de donnees',
                    'Voulez-vous vraiment forcer la synchronisation de la base de donnees? Cette operation peut prendre du temps.',
                    () {
                      _showSnackBar('Synchronisation en cours...');
                    },
                  );
                },
                icon: const Icon(Icons.sync),
                label: const Text('Synchroniser'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () {
                  // Demander confirmation avant d'exporter
                  _showConfirmationDialog(
                    'Exporter la base de donnu00e9es',
                    'Voulez-vous exporter la base de donnu00e9es vers un fichier?',
                    () {
                      _showSnackBar('Exportation en cours...');
                    },
                  );
                },
                icon: const Icon(Icons.download),
                label: const Text('Exporter'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () {
                  // Ru00e9initialiser les paramu00e8tres
                  _showSnackBar('Paramu00e8tres ru00e9initialisu00e9s');
                },
                child: const Text('Ru00e9initialiser'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  // Sauvegarder les paramu00e8tres
                  _showSnackBar(
                    'Paramu00e8tres enregistru00e9s avec succu00e8s',
                  );
                },
                child: const Text('Enregistrer'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlertThresholdSettings() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Seuils d\'alerte pour les stocks',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildSettingTextField(
            'Seuil de stock bas',
            'Alerte lorsque le stock est infu00e9rieur u00e0 cette valeur',
            _lowStockThresholdController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 32),
          const Text(
            'Seuils d\'alerte pour la maintenance',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildSettingTextField(
            'Rappel de maintenance (jours)',
            'Nombre de jours avant d\'envoyer un rappel de maintenance',
            _maintenanceReminderDaysController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 32),
          const Text(
            'Seuils pour les pru00e9dictions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildSettingTextField(
            'Seuil de confiance des pru00e9dictions (%)',
            'Niveau de confiance minimum pour afficher une pru00e9diction',
            _predictionConfidenceController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () {
                  // Ru00e9initialiser les paramu00e8tres
                  _lowStockThresholdController.text = '10';
                  _maintenanceReminderDaysController.text = '30';
                  _predictionConfidenceController.text = '75';
                  _showSnackBar('Paramu00e8tres ru00e9initialisu00e9s');
                },
                child: const Text('Ru00e9initialiser'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  // Sauvegarder les paramu00e8tres
                  _showSnackBar(
                    'Paramu00e8tres enregistru00e9s avec succu00e8s',
                  );
                },
                child: const Text('Enregistrer'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserSettings() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Gestion des utilisateurs',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // Ajouter un nouvel utilisateur
                  _showAddUserDialog();
                },
                icon: const Icon(Icons.add),
                label: const Text('Ajouter un utilisateur'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              side: BorderSide(color: AppTheme.lightGreyColor),
            ),
            child: ListView(
              shrinkWrap: true,
              children: [
                _buildUserListItem(
                  'admin@carhabti.com',
                  'Administrateur',
                  'Administrateur',
                  isActive: true,
                ),
                const Divider(height: 1),
                _buildUserListItem(
                  'manager@carhabti.com',
                  'Gestionnaire',
                  'Gestionnaire',
                  isActive: true,
                ),
                const Divider(height: 1),
                _buildUserListItem(
                  'support@carhabti.com',
                  'Support',
                  'Support client',
                  isActive: true,
                ),
                const Divider(height: 1),
                _buildUserListItem(
                  'analyst@carhabti.com',
                  'Analyste',
                  'Analyste de donnu00e9es',
                  isActive: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Ru00f4les et permissions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              side: BorderSide(color: AppTheme.lightGreyColor),
            ),
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  title: const Text('Administrateur'),
                  subtitle: const Text(
                    'Accu00e8s complet u00e0 toutes les fonctionnalitu00e9s',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {},
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Gestionnaire'),
                  subtitle: const Text(
                    'Gestion des piu00e8ces, vu00e9hicules et clients',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {},
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Support client'),
                  subtitle: const Text(
                    'Accu00e8s aux messages et ru00e9ponses aux clients',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {},
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Analyste de donnu00e9es'),
                  subtitle: const Text(
                    'Accu00e8s en lecture aux statistiques et analyses',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingSwitch(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildSettingDropdown(
    String title,
    String subtitle,
    String value,
    List<String> options,
    Function(String?) onChanged,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: DropdownButton<String>(
        value: value,
        onChanged: onChanged,
        items:
            options
                .map(
                  (option) =>
                      DropdownMenuItem(value: option, child: Text(option)),
                )
                .toList(),
      ),
    );
  }

  Widget _buildSettingTextField(
    String label,
    String hint,
    TextEditingController controller, {
    bool isSecret = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isSecret,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        ),
      ),
    );
  }

  Widget _buildUserListItem(
    String email,
    String name,
    String role, {
    required bool isActive,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
        child: Text(
          name.substring(0, 1),
          style: TextStyle(color: AppTheme.primaryColor),
        ),
      ),
      title: Text(name),
      subtitle: Text('$email - $role'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color:
                  isActive
                      ? AppTheme.successColor.withOpacity(0.1)
                      : AppTheme.dangerColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isActive ? 'Actif' : 'Inactif',
              style: TextStyle(
                color: isActive ? AppTheme.successColor : AppTheme.dangerColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () {}),
          IconButton(
            icon: const Icon(
              Icons.delete,
              color: AppTheme.dangerColor,
              size: 20,
            ),
            onPressed: () {
              _showConfirmationDialog(
                'Supprimer un utilisateur',
                'u00cates-vous su00fbr de vouloir supprimer cet utilisateur ? Cette action est irru00e9versible.',
                () {
                  _showSnackBar('Utilisateur supprimu00e9 avec succu00e8s');
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    String selectedRole = 'Support client';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ajouter un utilisateur'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom complet',
                    hintText: 'Ex: John Doe',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Ex: john.doe@example.com',
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Ru00f4le'),
                  initialValue: selectedRole,
                  items:
                      [
                            'Administrateur',
                            'Gestionnaire',
                            'Support client',
                            'Analyste de donnu00e9es',
                          ]
                          .map(
                            (role) => DropdownMenuItem(
                              value: role,
                              child: Text(role),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    selectedRole = value!;
                  },
                ),
                const SizedBox(height: 16),
                const SwitchListTile(
                  title: Text('Compte actif'),
                  value: true,
                  onChanged: null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showSnackBar('Utilisateur ajoutu00e9 avec succu00e8s');
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  void _showConfirmationDialog(
    String title,
    String content,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
