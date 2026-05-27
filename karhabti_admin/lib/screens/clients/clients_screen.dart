// ignore_for_file: use_build_context_synchronously, duplicate_ignore, deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../theme/app_theme.dart';
import '../../models/client_model.dart';
import '../../services/client_service.dart';
import '../../config/supabase_config.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen>
    with SingleTickerProviderStateMixin {
  final ClientService _clientService = ClientService();
  late AnimationController _animationController;
  // ignore: unused_field
  late Animation<double> _fadeAnimation;

  // États de l'écran
  String _searchQuery = '';
  String _selectedFilter = 'Tous';
  bool _isLoading = true;
  bool _isError = false;
  String? _errorMessage;

  // Données
  List<Client> _allClients = [];
  List<Client> _filteredClients = [];

  // Statistiques
  int _totalClients = 0;
  int _activeClients = 0; // Clients considérés actifs (au moins 1 véhicule)
  int _notifiedClients = 0;
  int _recentClients = 0;
  int _clientsWithVehicles = 0;

  // Contrôleurs
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Options de filtre
  // ignore: unused_field
  final List<String> _clientFilters = [
    'Tous',
    'Actifs',
    'Avec Notification',
    'Récents',
    'Plus de Véhicules',
  ];

  // Pour formater les dates dans le tableau
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();

    // Configuration de l'animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);

    // Listener pour la recherche
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
        _applyFilters();
      });
    });

    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Charge les données des clients
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _isError = false;
      _errorMessage = null;
    });

    try {
      if (kDebugMode) {
        print('🔄 Chargement des données clients depuis la page clients...');
      }
      if (kDebugMode) {
        print('📱 Vérification de la connexion réseau...');
      }

      // Récupération des clients avec leurs données connexes
      if (kDebugMode) {
        print('🔍 Appel à ClientService.getAllClients()...');
      }
      final clients = await _clientService.getAllClients();
      if (kDebugMode) {
        print('📋 Clients récupérés par la page: ${clients.length}');
      }

      if (clients.isEmpty) {
        if (kDebugMode) {
          print('⚠️ Aucun client n\'a été récupéré. Affichage de l\'état vide.');
        }
        setState(() {
          _allClients = [];
          _filteredClients = [];
          _totalClients = 0;
          _activeClients = 0;
          _notifiedClients = 0;
          _recentClients = 0;
          _clientsWithVehicles = 0;
          _isLoading = false;
        });
        return;
      }

      if (clients.isNotEmpty) {
        if (kDebugMode) {
          print('👤 Premier client reçu: ${clients.first}');
        }
      }

      // Calcul des statistiques
      final now = DateTime.now();
      final oneWeekAgo = now.subtract(const Duration(days: 7));

      if (kDebugMode) {
        print('📊 Calcul des statistiques...');
      }
      final totalClients = clients.length;
      final activeClients =
          clients.where((client) => client.vehicleCount > 0).length;
      final notifiedClients =
          clients.where((client) => client.notificationsEnabled).length;
      final recentClients =
          clients
              .where((client) => client.createdAt.isAfter(oneWeekAgo))
              .length;
      final clientsWithVehicles =
          clients.where((client) => client.vehicleCount > 0).length;

      if (kDebugMode) {
        print(
        '📊 Statistiques calculées: Total=$totalClients, Actifs=$activeClients, Notifiés=$notifiedClients',
      );
      }

      // Mise à jour de l'état
      setState(() {
        _allClients = clients;
        _filteredClients = clients;
        _totalClients = totalClients;
        _activeClients = activeClients;
        _notifiedClients = notifiedClients;
        _recentClients = recentClients;
        _clientsWithVehicles = clientsWithVehicles;
        _isLoading = false;
      });

      if (kDebugMode) {
        print('✅ Données chargées avec succès');
      }

      // Démarrage de l'animation
      _animationController.forward();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors du chargement des clients dans la page: $e');
      }
      if (kDebugMode) {
        print(StackTrace.current);
      }

      setState(() {
        _allClients = [];
        _filteredClients = [];
        _isLoading = false;
        _isError = true;
        _errorMessage = 'Erreur lors du chargement des clients: $e';
      });

      // Afficher un message d'erreur à l'utilisateur
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de chargement: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Réessayer',
              onPressed: _loadData,
              textColor: Colors.white,
            ),
          ),
        );
      }
    }
  }

  // Applique les filtres à la liste des clients
  void _applyFilters() {
    setState(() {
      _filteredClients =
          _allClients.where((client) {
            // Filtre de recherche
            final matchesSearch =
                _searchQuery.isEmpty ||
                client.nomClient.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                (client.email?.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ??
                    false);

            // Filtre de catégorie
            bool matchesFilter;
            switch (_selectedFilter) {
              case 'Actifs':
                matchesFilter =
                    client.vehicleCount >
                    0; // Un client actif a au moins un véhicule
                break;
              case 'Avec Notification':
                matchesFilter = client.notificationsEnabled;
                break;
              case 'Récents':
                final oneWeekAgo = DateTime.now().subtract(
                  const Duration(days: 7),
                );
                matchesFilter = client.createdAt.isAfter(oneWeekAgo);
                break;
              case 'Plus de Véhicules':
                matchesFilter = client.vehicleCount > 0;
                break;
              default: // 'Tous'
                matchesFilter = true;
            }

            return matchesSearch && matchesFilter;
          }).toList();
    });
  }

  // Définit le filtre et applique les changements
  void _setFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      _applyFilters();
    });
  }

  // Export de la liste des clients au format CSV
  Future<void> _exportClientsList() async {
    // En-tête CSV
    String csvContent =
        'ID,Nom,Email,Date de création,Notifications,Nombre de véhicules\n';

    // Données
    for (final client in _filteredClients) {
      csvContent +=
          '${client.id},${client.nomClient},${client.email ?? ''},${_dateFormat.format(client.createdAt)},${client.notificationsEnabled ? 'Oui' : 'Non'},${client.vehicleCount}\n';
    }

    // Copie dans le presse-papier
    await Clipboard.setData(ClipboardData(text: csvContent));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Liste des clients copiée dans le presse-papier'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  // Affiche le dialogue d'ajout/modification d'un client
  void _showAddEditClientDialog(BuildContext context, [Client? client]) {
    final TextEditingController nomController = TextEditingController(
      text: client?.nomClient ?? '',
    );
    final TextEditingController telephoneController = TextEditingController(
      text: client?.telephone ?? '',
    );

    String selectedType = client?.typeClient ?? 'Particulier';
    bool notificationsEnabled = client?.notificationsEnabled ?? true;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              client == null ? 'Ajouter un client' : 'Modifier le client',
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nomController,
                    decoration: const InputDecoration(
                      labelText: 'Nom du client',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: telephoneController,
                    decoration: const InputDecoration(
                      labelText: 'Téléphone',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Type de client',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Particulier',
                        child: Text('Particulier'),
                      ),
                      DropdownMenuItem(
                        value: 'Professionnel',
                        child: Text('Professionnel'),
                      ),
                    ],
                    onChanged: (value) {
                      selectedType = value!;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: notificationsEnabled,
                        onChanged: (value) {
                          setState(() {
                            notificationsEnabled = value!;
                          });
                        },
                      ),
                      const Text('Activer les notifications'),
                    ],
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
                onPressed: () async {
                  // Vérifier si un ID utilisateur valide est disponible pour la création
                  final currentUser = SupabaseConfig.client.auth.currentUser;
                  if (client == null && currentUser == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Erreur: Vous devez être connecté pour créer un client',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Création d'un objet client
                  final newClient = Client(
                    id: client?.id ?? currentUser!.id,
                    nomClient: nomController.text,
                    createdAt: client?.createdAt ?? DateTime.now(),
                    notificationsEnabled: notificationsEnabled,
                    typeClient: selectedType,
                    telephone: telephoneController.text,
                  );

                  // Sauvegarde en base de données
                  try {
                    if (kDebugMode) {
                      print(
                      '💾 Tentative de sauvegarde du client: ${newClient.id}',
                    );
                    }
                    if (client == null) {
                      // Création d'un nouveau client
                      await _clientService.createClient(newClient);
                      if (mounted) {
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Client créé avec succès'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } else {
                      // Mise à jour d'un client existant
                      await _clientService.updateClient(newClient);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Client mis à jour avec succès'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }

                    // Fermeture du dialogue et rechargement des données
                    if (mounted) {
                      Navigator.pop(context);
                      _loadData();
                    }
                  } catch (e) {
                    if (kDebugMode) {
                      print('❌ Erreur lors de la sauvegarde du client: $e');
                    }
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erreur: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Enregistrer'),
              ),
            ],
          ),
    );
  }

  // Crée un client de test pour vérifier l'interface
  Future<void> _createTestClient() async {
    try {
      if (kDebugMode) {
        print('🧪 Création d\'un client de test...');
      }

      // Utilisez l'ID d'un utilisateur valide de Supabase Auth pour le test
      // Étant donné que l'ID client est lié à auth.users.id et qu'il doit être un UUID valide
      final currentUser = SupabaseConfig.client.auth.currentUser;
      if (currentUser == null) {
        if (kDebugMode) {
          print('❌ Aucun utilisateur connecté pour créer un client de test');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Erreur: Vous devez être connecté pour créer un client',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Utiliser l'ID de l'utilisateur authentifié comme ID client
      // puisque c'est une relation de clé étrangère vers auth.users.id
      final userId = currentUser.id;
      if (kDebugMode) {
        print('🔑 Utilisation de l\'ID utilisateur connecté: $userId');
      }

      // Créer un client fictif pour les tests
      final testClient = Client(
        id: userId, // UUID valide de l'utilisateur actuellement connecté
        nomClient: 'Client Test ${DateTime.now().day}/${DateTime.now().month}',
        createdAt: DateTime.now(),
        notificationsEnabled: true,
        typeClient: 'Particulier',
        telephone: '+216 123 456 789',
      );

      if (kDebugMode) {
        print('🔍 Tentative de création du client avec ID: ${testClient.id}');
      }

      // Sauvegarder dans la base de données
      final savedClient = await _clientService.createClient(testClient);

      if (savedClient != null) {
        if (kDebugMode) {
          print('✅ Client de test créé avec succès: ${savedClient.id}');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Client de test créé avec succès'),
            backgroundColor: Colors.green,
          ),
        );

        // Recharger les données
        await _loadData();
      } else {
        if (kDebugMode) {
          print('❌ Erreur lors de la création du client de test');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la création du client de test'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Exception lors de la création du client de test: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print(
      '🏗️ Build ClientsScreen: isLoading=$_isLoading, filteredClients=${_filteredClients.length}',
    );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Gestion des Clients',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.download),
                      label: const Text('Exporter'),
                      onPressed: _exportClientsList,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Colors.blue),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _loadData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Actualiser'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildStatCards(),
            const SizedBox(height: 24),
            _buildFilterButtons(),
            const SizedBox(height: 16),
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _filteredClients.isEmpty
                      ? _buildEmptyState()
                      : _buildClientList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditClientDialog(context),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatCards() {
    return Row(
      children: [
        _buildStatCard(
          icon: Icons.people,
          title: 'Total Clients',
          value: _totalClients.toString(),
          color: Colors.blue[100]!,
          iconColor: Colors.blue,
        ),
        const SizedBox(width: 16),
        _buildStatCard(
          icon: Icons.check_circle_outline,
          title: 'Clients Actifs',
          value: _activeClients.toString(),
          color: Colors.green[100]!,
          iconColor: Colors.green,
        ),
        const SizedBox(width: 16),
        _buildStatCard(
          icon: Icons.notifications_active,
          title: 'Avec Notifications',
          value: _notifiedClients.toString(),
          color: Colors.purple[100]!,
          iconColor: Colors.purple,
        ),
        const SizedBox(width: 16),
        _buildStatCard(
          icon: Icons.access_time,
          title: 'Clients Récents',
          value: _recentClients.toString(),
          color: Colors.orange[100]!,
          iconColor: Colors.orange,
        ),
        const SizedBox(width: 16),
        _buildStatCard(
          icon: Icons.directions_car,
          title: 'Avec Véhicules',
          value: _clientsWithVehicles.toString(),
          color: Colors.teal[100]!,
          iconColor: Colors.teal,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required Color iconColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButtons() {
    return Row(
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.people),
          label: const Text('Tous'),
          onPressed: () => _setFilter('Tous'),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                _selectedFilter == 'Tous' ? Colors.blue : Colors.white,
            foregroundColor:
                _selectedFilter == 'Tous' ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          icon: const Icon(Icons.check_circle),
          label: const Text('Actifs'),
          onPressed: () => _setFilter('Actifs'),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                _selectedFilter == 'Actifs' ? Colors.blue : Colors.white,
            foregroundColor:
                _selectedFilter == 'Actifs' ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          icon: const Icon(Icons.notifications),
          label: const Text('Avec Notification'),
          onPressed: () => _setFilter('Avec Notification'),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                _selectedFilter == 'Avec Notification'
                    ? Colors.blue
                    : Colors.white,
            foregroundColor:
                _selectedFilter == 'Avec Notification'
                    ? Colors.white
                    : Colors.black,
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          icon: const Icon(Icons.access_time),
          label: const Text('Récents'),
          onPressed: () => _setFilter('Récents'),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                _selectedFilter == 'Récents' ? Colors.blue : Colors.white,
            foregroundColor:
                _selectedFilter == 'Récents' ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          icon: const Icon(Icons.directions_car),
          label: const Text('Plus de Véhicules'),
          onPressed: () => _setFilter('Plus de Véhicules'),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                _selectedFilter == 'Plus de Véhicules'
                    ? Colors.blue
                    : Colors.white,
            foregroundColor:
                _selectedFilter == 'Plus de Véhicules'
                    ? Colors.white
                    : Colors.black,
          ),
        ),
        const Spacer(),
        SizedBox(
          width: 300,
          height: 40,
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              hintText: 'Rechercher un client...',
              hintStyle: TextStyle(color: Colors.grey[900]),
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Aucun client trouvé',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoutez des clients en cliquant sur le bouton +',
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          // Bouton pour créer un client de test (pour le débogage)
          if (_isError || _allClients.isEmpty)
            ElevatedButton.icon(
              onPressed: _createTestClient,
              icon: const Icon(Icons.science),
              label: const Text('Créer un client de test'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
            ),
          if (_isError)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                'Erreur: ${_errorMessage ?? "Inconnu"}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildClientList() {
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DataTable2(
              columnSpacing: 12,
              horizontalMargin: 12,
              minWidth: 900,
              headingRowHeight: 50,
              dataRowHeight: 60,
              columns: const [
                DataColumn2(label: Text('Client', style: TextStyle(color: Colors.black87)), size: ColumnSize.L,),
                DataColumn2(label: Text('Contact', style: TextStyle(color: Colors.black87)), size: ColumnSize.L),
                DataColumn2(label: Text('Type', style: TextStyle(color: Colors.black87)), size: ColumnSize.S),
                DataColumn2(label: Text('Véhicules', style: TextStyle(color: Colors.black87)), size: ColumnSize.S),
                DataColumn2(label: Text('Inscription', style: TextStyle(color: Colors.black87)), size: ColumnSize.M),
                DataColumn2(label: Text('Actions', style: TextStyle(color: Colors.black87)), size: ColumnSize.S),
              ],
              rows:
                  _filteredClients.map((client) {
                    // Générer les initiales du client pour l'avatar
                    final initials =
                        client.nomClient.isNotEmpty
                            ? client.nomClient
                                .substring(
                                  0,
                                  client.nomClient.isNotEmpty ? 1 : 0,
                                )
                                .toUpperCase()
                            : '?';

                    return DataRow2(
                      cells: [
                        // Cellule Client
                        DataCell(
                          Row(
                            children: [
                              // Avatar avec initiales
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _getAvatarColor(client.id),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Center(
                                  child: Text(
                                    initials,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Nom et ID
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    client.nomClient,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    'ID: #${client.id.split('-').first}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Cellule Contact
                        DataCell(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (client.email != null &&
                                  client.email!.isNotEmpty)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.email,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(client.email!, style: const TextStyle(color: Colors.black87)),
                                  ],
                                ),
                              if (client.telephone != null &&
                                  client.telephone!.isNotEmpty)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.phone,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(client.telephone!, style: const TextStyle(color: Colors.black87)),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        // Cellule Type
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  client.typeClient?.toLowerCase() ==
                                          'professionnel'
                                      ? Colors.purple[50]
                                      : Colors.blue[50],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              client.typeClient ?? 'Particulier',
                              style: TextStyle(
                                color:
                                    client.typeClient?.toLowerCase() ==
                                            'professionnel'
                                        ? Colors.purple[700]
                                        : Colors.blue[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        // Cellule Véhicules
                        DataCell(
                          Row(
                            children: [
                              const Icon(
                                Icons.directions_car,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(client.vehicleCount.toString(), style: const TextStyle(color: Colors.black87)),
                            ],
                          ),
                        ),
                        // Cellule Date d'inscription
                        DataCell(
                          Text(
                            DateFormat('dd/MM/yyyy').format(client.createdAt),
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        // Cellule Actions
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.visibility, size: 20),
                                color: Colors.blue,
                                onPressed: () {},
                                tooltip: 'Voir',
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                color: Colors.blue,
                                onPressed: () {},
                                tooltip: 'Modifier',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20),
                                color: Colors.red,
                                onPressed: () {},
                                tooltip: 'Supprimer',
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
          child: Row(
            children: [
              Text(
                'Affichage de ${_filteredClients.length} sur ${_allClients.length} clients',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const Spacer(),
              // Pagination
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {},
                    tooltip: 'Précédent',
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Center(
                      child: Text('1', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {},
                    tooltip: 'Suivant',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Générer une couleur basée sur l'ID du client
  Color _getAvatarColor(String id) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
    ];

    // Utiliser la somme des codes ASCII comme une graine pour la sélection
    int sum = 0;
    for (int i = 0; i < id.length; i++) {
      sum += id.codeUnitAt(i);
    }

    return colors[sum % colors.length];
  }
}
