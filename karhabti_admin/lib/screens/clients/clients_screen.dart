import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../theme/app_theme.dart';
import '../../models/client_model.dart';
import '../../widgets/stat_card.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({Key? key}) : super(key: key);

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'Tous';
  
  final List<String> _clientFilters = ['Tous', 'Actifs', 'Inactifs', 'Récents'];
  
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
            _buildStatCards(),
            const SizedBox(height: 24),
            _buildFiltersAndSearch(),
            const SizedBox(height: 16),
            _buildClientsTable(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditClientDialog(context),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gestion des Clients',
          style: AppTheme.headingLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Visualisez et gérez les clients inscrits dans le système KARHABTI',
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyColor),
        ),
      ],
    );
  }

  Widget _buildStatCards() {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Total des clients',
            value: '423',
            icon: Icons.people,
            iconColor: AppTheme.primaryColor,
            subtitle: '+32 ce mois-ci',
            onTap: () {
              setState(() {
                _selectedFilter = 'Tous';
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: 'Clients actifs',
            value: '368',
            icon: Icons.check_circle,
            iconColor: AppTheme.successColor,
            subtitle: '87% du total',
            onTap: () {
              setState(() {
                _selectedFilter = 'Actifs';
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: 'Nouveaux clients',
            value: '42',
            icon: Icons.person_add,
            iconColor: AppTheme.accentColor,
            subtitle: 'Derniers 30 jours',
            onTap: () {
              setState(() {
                _selectedFilter = 'Récents';
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: 'Activité récente',
            value: '87',
            icon: Icons.access_time,
            iconColor: AppTheme.secondaryColor,
            subtitle: 'Connexions (7 derniers jours)',
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildFiltersAndSearch() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Rechercher un client...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.lightGreyColor),
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedFilter,
              hint: const Text('Filtre'),
              items: _clientFilters.map((filter) => DropdownMenuItem(
                value: filter,
                child: Text(filter),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                });
              },
            ),
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.filter_list),
          label: const Text('Plus de filtres'),
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.download),
          label: const Text('Exporter'),
        ),
      ],
    );
  }

  Widget _buildClientsTable() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Liste des clients ${_selectedFilter != "Tous" ? _selectedFilter.toLowerCase() : ""}',
                  style: AppTheme.headingSmall,
                ),
                Text(
                  '10 de 423 clients', 
                  style: AppTheme.caption,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 500,
              child: DataTable2(
                columnSpacing: 12,
                horizontalMargin: 12,
                minWidth: 600,
                columns: const [
                  DataColumn2(
                    label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold)),
                    size: ColumnSize.S,
                  ),
                  DataColumn2(
                    label: Text('Nom complet', style: TextStyle(fontWeight: FontWeight.bold)),
                    size: ColumnSize.L,
                  ),
                  DataColumn2(
                    label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
                    size: ColumnSize.L,
                  ),
                  DataColumn2(
                    label: Text('Téléphone', style: TextStyle(fontWeight: FontWeight.bold)),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text('Véhicules', style: TextStyle(fontWeight: FontWeight.bold)),
                    size: ColumnSize.S,
                    numeric: true,
                  ),
                  DataColumn2(
                    label: Text('Date d\'inscription', style: TextStyle(fontWeight: FontWeight.bold)),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text('Statut', style: TextStyle(fontWeight: FontWeight.bold)),
                    size: ColumnSize.S,
                  ),
                  DataColumn2(
                    label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold)),
                    size: ColumnSize.L,
                  ),
                ],
                rows: _generateDummyClientRows(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.chevron_left),
                  label: const Text('Précédent'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.chevron_right),
                  label: const Text('Suivant'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<DataRow> _generateDummyClientRows() {
    final firstNames = ['Mohamed', 'Sarah', 'Ahmed', 'Amina', 'Karim', 'Leila', 'Youssef', 'Yasmine', 'Ali', 'Nour'];
    final lastNames = ['Abidi', 'Ben Salem', 'Chahed', 'Dallel', 'El Ghoul', 'Fares', 'Ghanmi', 'Hammami', 'Ibrahim', 'Jerbi'];
    
    List<DataRow> rows = [];
    
    for (int i = 1; i <= 10; i++) {
      final name = '${firstNames[i-1]} ${lastNames[i-1]}';
      final email = '${firstNames[i-1].toLowerCase()}.${lastNames[i-1].toLowerCase().replaceAll(' ', '')}@email.com';
      final phone = '+216 ${20 + i}${100000 + i * 1111}';
      final vehicles = i % 3 + 1; // 1 à 3 véhicules
      final date = DateTime.now().subtract(Duration(days: i * 30));
      final formattedDate = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      final isActive = i != 4 && i != 9; // Quelques clients inactifs
      
      // Filtrer selon le critère sélectionné
      if (_selectedFilter == 'Actifs' && !isActive) continue;
      if (_selectedFilter == 'Inactifs' && isActive) continue;
      if (_selectedFilter == 'Récents' && date.isBefore(DateTime.now().subtract(const Duration(days: 60)))) continue;
      
      // Filtrer selon la recherche
      if (_searchQuery.isNotEmpty) {
        if (!name.toLowerCase().contains(_searchQuery.toLowerCase()) && 
            !email.toLowerCase().contains(_searchQuery.toLowerCase())) {
          continue;
        }
      }
      
      rows.add(DataRow(
        cells: [
          DataCell(Text('C$i')),
          DataCell(Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                child: Text(
                  name.substring(0, 1),
                  style: TextStyle(color: AppTheme.primaryColor, fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              Text(name),
            ],
          )),
          DataCell(Text(email)),
          DataCell(Text(phone)),
          DataCell(Container(
            alignment: Alignment.center,
            child: Text(vehicles.toString()),
          )),
          DataCell(Text(formattedDate)),
          DataCell(Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isActive ? AppTheme.successColor.withOpacity(0.1) : AppTheme.dangerColor.withOpacity(0.1),
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
          )),
          DataCell(
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility, color: AppTheme.primaryColor, size: 20),
                  onPressed: () => _showClientDetailsDialog(context, name, email, phone, vehicles, formattedDate, isActive),
                  tooltip: 'Voir les détails',
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: AppTheme.secondaryColor, size: 20),
                  onPressed: () => _showAddEditClientDialog(context, isEdit: true, clientName: name),
                  tooltip: 'Modifier',
                ),
                IconButton(
                  icon: const Icon(Icons.directions_car, color: AppTheme.accentColor, size: 20),
                  onPressed: () => _showClientVehiclesDialog(context, name),
                  tooltip: 'Véhicules',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: AppTheme.dangerColor, size: 20),
                  onPressed: () => _showDeleteConfirmationDialog(context, name),
                  tooltip: 'Supprimer',
                ),
              ],
            ),
          ),
        ],
      ));
    }
    
    return rows;
  }

  void _showClientDetailsDialog(BuildContext context, String name, String email, String phone, int vehicles, String date, bool isActive) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Détails de $name'),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('Email'),
                  subtitle: Text(email),
                ),
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: const Text('Téléphone'),
                  subtitle: Text(phone),
                ),
                ListTile(
                  leading: const Icon(Icons.directions_car),
                  title: const Text('Véhicules'),
                  subtitle: Text('$vehicles véhicule${vehicles > 1 ? 's' : ''}'),
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Date d\'inscription'),
                  subtitle: Text(date),
                ),
                ListTile(
                  leading: Icon(isActive ? Icons.check_circle : Icons.cancel, color: isActive ? AppTheme.successColor : AppTheme.dangerColor),
                  title: const Text('Statut'),
                  subtitle: Text(isActive ? 'Compte actif' : 'Compte inactif'),
                ),
                const Divider(),
                const ListTile(
                  leading: Icon(Icons.history),
                  title: Text('Activité récente'),
                  subtitle: Text('Dernière connexion: Hier à 15:30'),
                ),
              ],
            ),
          ),
          actions: [
            OutlinedButton.icon(
              onPressed: () => _showClientVehiclesDialog(context, name),
              icon: const Icon(Icons.directions_car),
              label: const Text('Voir les véhicules'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  void _showAddEditClientDialog(BuildContext context, {bool isEdit = false, String? clientName}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${isEdit ? 'Modifier' : 'Ajouter'} un client'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Prénom',
                          hintText: 'Ex: Mohamed',
                        ),
                        controller: TextEditingController(text: isEdit ? clientName?.split(' ')[0] : null),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Nom',
                          hintText: 'Ex: Abidi',
                        ),
                        controller: TextEditingController(text: isEdit && clientName != null ? clientName.split(' ').length > 1 ? clientName.split(' ')[1] : '' : null),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Ex: mohamed.abidi@email.com',
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Téléphone',
                    hintText: 'Ex: +216 55 123 456',
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Adresse',
                    hintText: 'Ex: 10 Rue de Carthage, Tunis',
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Compte actif'),
                  value: true,
                  onChanged: (value) {},
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
                // Sauvegarder le client
                Navigator.pop(context);
                _showSnackBar('${isEdit ? 'Client modifié' : 'Client ajouté'} avec succès');
              },
              child: Text(isEdit ? 'Mettre à jour' : 'Ajouter'),
            ),
          ],
        );
      },
    );
  }

  void _showClientVehiclesDialog(BuildContext context, String clientName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Véhicules de $clientName'),
          content: SizedBox(
            width: 600,
            height: 300,
            child: ListView.separated(
              itemCount: 3,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final carBrands = ['Renault', 'Peugeot', 'Volkswagen'];
                final carModels = ['Clio', '208', 'Golf'];
                final year = 2018 + index;
                
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    child: Icon(Icons.directions_car, color: AppTheme.primaryColor),
                  ),
                  title: Text('${carBrands[index]} ${carModels[index]} ($year)'),
                  subtitle: Text('Immatriculation: ${100 + index} TU ${1000 + index * 111}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.history, size: 16),
                        label: const Text('Historique'),
                      ),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Modifier'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un véhicule'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String clientName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: Text('Êtes-vous sûr de vouloir supprimer le client $clientName ? Cette action est irréversible.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                // Supprimer le client
                Navigator.pop(context);
                _showSnackBar('Client supprimé avec succès');
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerColor),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
