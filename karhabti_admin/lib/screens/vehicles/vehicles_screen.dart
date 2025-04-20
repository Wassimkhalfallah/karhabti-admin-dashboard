import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../theme/app_theme.dart';
import '../../models/vehicle_model.dart';
import '../../widgets/stat_card.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({Key? key}) : super(key: key);

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  String _searchQuery = '';
  String _selectedType = 'Tous';
  
  final List<String> _vehicleTypes = ['Tous', 'Particulier', 'Professionnel'];
  
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
            _buildVehiclesTable(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditVehicleDialog(context),
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
          'Gestion des Vu00e9hicules',
          style: AppTheme.headingLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Visualisez et gu00e9rez les vu00e9hicules enregistru00e9s dans le systu00e8me KARHABTI',
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
            title: 'Total des vu00e9hicules',
            value: '157',
            icon: Icons.directions_car,
            iconColor: AppTheme.primaryColor,
            subtitle: '+12% ce mois-ci',
            onTap: () {},
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: 'Vu00e9hicules particuliers',
            value: '102',
            icon: Icons.person,
            iconColor: AppTheme.secondaryColor,
            subtitle: '65% du total',
            onTap: () {
              setState(() {
                _selectedType = 'Particulier';
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: 'Vu00e9hicules professionnels',
            value: '55',
            icon: Icons.business,
            iconColor: AppTheme.accentColor,
            subtitle: '35% du total',
            onTap: () {
              setState(() {
                _selectedType = 'Professionnel';
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: 'u00c2ge moyen des vu00e9hicules',
            value: '6.2 ans',
            icon: Icons.timelapse,
            iconColor: AppTheme.greyColor,
            subtitle: '10+ ans: 23%',
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
              hintText: 'Rechercher un vu00e9hicule...',
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
              value: _selectedType,
              hint: const Text('Type'),
              items: _vehicleTypes.map((type) => DropdownMenuItem(
                value: type,
                child: Text(type),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
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

  Widget _buildVehiclesTable() {
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
                  'Liste des vu00e9hicules ${_selectedType == "Tous" ? "" : _selectedType.toLowerCase() + "s"}',
                  style: AppTheme.headingSmall,
                ),
                Text(
                  '10 de 157 vu00e9hicules', 
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
                    label: Text('Immatriculation', style: TextStyle(fontWeight: FontWeight.bold)),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text('Marque / Modu00e8le', style: TextStyle(fontWeight: FontWeight.bold)),
                    size: ColumnSize.L,
                  ),
                  DataColumn2(
                    label: Text('Annu00e9e', style: TextStyle(fontWeight: FontWeight.bold)),
                    size: ColumnSize.S,
                    numeric: true,
                  ),
                  DataColumn2(
                    label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text('Carburant', style: TextStyle(fontWeight: FontWeight.bold)),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text('Kilomu00e9trage', style: TextStyle(fontWeight: FontWeight.bold)),
                    size: ColumnSize.M,
                    numeric: true,
                  ),
                  DataColumn2(
                    label: Text('Client', style: TextStyle(fontWeight: FontWeight.bold)),
                    size: ColumnSize.L,
                  ),
                  DataColumn2(
                    label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold)),
                    size: ColumnSize.L,
                  ),
                ],
                rows: _generateDummyVehicleRows(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.chevron_left),
                  label: const Text('Pru00e9cu00e9dent'),
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

  List<DataRow> _generateDummyVehicleRows() {
    final carBrands = ['Renault', 'Peugeot', 'Volkswagen', 'Toyota', 'Ford', 'Citrou00ebn', 'Mercedes', 'BMW', 'Audi', 'Fiat'];
    final carModels = ['Clio', '208', 'Golf', 'Corolla', 'Focus', 'C3', 'Classe C', 'Su00e9rie 3', 'A3', '500'];
    final fuelTypes = ['Essence', 'Diesel', 'Hybride', 'Electrique'];
    final clientNames = ['Mohamed A.', 'Sarah B.', 'Ahmed C.', 'Amina D.', 'Karim E.', 'Leila F.', 'Youssef G.', 'Yasmine H.', 'Ali I.', 'Nour J.'];
    
    List<DataRow> rows = [];
    
    for (int i = 1; i <= 10; i++) {
      final carIndex = i % carBrands.length;
      final fuelIndex = i % fuelTypes.length;
      final year = 2010 + (i % 14);
      final isParticulier = i % 3 != 0;
      final type = isParticulier ? 'Particulier' : 'Professionnel';
      
      // Skip if filtered by type
      if (_selectedType != 'Tous' && _selectedType != type) {
        continue;
      }
      
      final registrationNumber = '${100 + i} TU ${1000 + i}';
      
      rows.add(DataRow(
        cells: [
          DataCell(Text('V$i')),
          DataCell(Text(registrationNumber)),
          DataCell(Text('${carBrands[carIndex]} ${carModels[carIndex]}')),
          DataCell(Text('$year')),
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isParticulier ? AppTheme.primaryColor.withOpacity(0.1) : AppTheme.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                type,
                style: TextStyle(
                  color: isParticulier ? AppTheme.primaryColor : AppTheme.accentColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          DataCell(Text(fuelTypes[fuelIndex])),
          DataCell(Text('${(50000 + i * 15000).toString()} km')),
          DataCell(Text(clientNames[i % clientNames.length])),
          DataCell(
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility, color: AppTheme.primaryColor, size: 20),
                  onPressed: () {},
                  tooltip: 'Voir les du00e9tails',
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: AppTheme.secondaryColor, size: 20),
                  onPressed: () => _showAddEditVehicleDialog(context, isEdit: true),
                  tooltip: 'Modifier',
                ),
                IconButton(
                  icon: const Icon(Icons.history, color: AppTheme.greyColor, size: 20),
                  onPressed: () => _showMaintenanceHistoryDialog(context),
                  tooltip: 'Historique de maintenance',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: AppTheme.dangerColor, size: 20),
                  onPressed: () => _showDeleteConfirmationDialog(context),
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

  void _showAddEditVehicleDialog(BuildContext context, {bool isEdit = false}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${isEdit ? 'Modifier' : 'Ajouter'} un vu00e9hicule'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Marque',
                    hintText: 'Ex: Renault',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Modu00e8le',
                    hintText: 'Ex: Clio',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Annu00e9e',
                    hintText: 'Ex: 2020',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Immatriculation',
                    hintText: 'Ex: 123 TU 4567',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Couleur',
                    hintText: 'Ex: Bleu',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Type de carburant'),
                  items: ['Essence', 'Diesel', 'Hybride', 'Electrique']
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {},
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Kilomu00e9trage',
                    hintText: 'Ex: 75000',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Type de vu00e9hicule'),
                  items: ['Particulier', 'Professionnel']
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {},
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Client'),
                  items: ['Mohamed A.', 'Sarah B.', 'Ahmed C.', 'Amina D.', 'Karim E.']
                      .map((client) => DropdownMenuItem(
                            value: client,
                            child: Text(client),
                          ))
                      .toList(),
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
                // Sauvegarder le vu00e9hicule
                Navigator.pop(context);
                _showSnackBar('${isEdit ? 'Vu00e9hicule modifiu00e9' : 'Vu00e9hicule ajoutu00e9'} avec succu00e8s');
              },
              child: Text(isEdit ? 'Mettre u00e0 jour' : 'Ajouter'),
            ),
          ],
        );
      },
    );
  }

  void _showMaintenanceHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Historique de maintenance'),
          content: SizedBox(
            width: 600,
            height: 400,
            child: ListView.separated(
              itemCount: 5,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final date = DateTime.now().subtract(Duration(days: 30 * (index + 1)));
                final formattedDate = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
                final maintenanceTypes = [
                  'Vidange moteur',
                  'Remplacement des plaquettes de frein',
                  'Changement des pneus',
                  'Entretien batterie',
                  'Remplacement courroie de distribution'
                ];
                
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppTheme.primaryColor,
                    child: Icon(Icons.build, color: Colors.white),
                  ),
                  title: Text(maintenanceTypes[index % maintenanceTypes.length]),
                  subtitle: Text('Ru00e9alisu00e9 le $formattedDate'),
                  trailing: Text(
                    '${(150 * (index + 1)).toString()} DT',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ),
          actions: [
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Ajouter une maintenance'),
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

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: const Text('u00cates-vous su00fbr de vouloir supprimer ce vu00e9hicule ? Cette action est irru00e9versible.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                // Supprimer le vu00e9hicule
                Navigator.pop(context);
                _showSnackBar('Vu00e9hicule supprimu00e9 avec succu00e8s');
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
