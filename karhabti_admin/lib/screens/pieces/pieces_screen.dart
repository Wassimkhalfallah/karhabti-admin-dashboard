import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../theme/app_theme.dart';
import '../../models/piece_model.dart';

class PiecesScreen extends StatefulWidget {
  const PiecesScreen({Key? key}) : super(key: key);

  @override
  State<PiecesScreen> createState() => _PiecesScreenState();
}

class _PiecesScreenState extends State<PiecesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  List<String> pieceTypes = [
    'Pneus',
    'Vidange',
    'Amortisseurs',
    'Batterie',
    'Embrayage',
    'Freins',
    'Courroie',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: pieceTypes.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildHeader(),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildSearchAndActions(),
          ),
          const SizedBox(height: 16),
          TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: AppTheme.greyColor,
            indicatorColor: AppTheme.primaryColor,
            isScrollable: true,
            tabs: pieceTypes.map((type) => Tab(text: type)).toList(),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: pieceTypes.map((type) => _buildPieceDataTable(type)).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditPieceDialog(context),
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
          'Gestion des Pièces',
          style: AppTheme.headingLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Gérez les différentes pièces et composants pour l\'application KARHABTI',
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyColor),
        ),
      ],
    );
  }

  Widget _buildSearchAndActions() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Rechercher une pièce...',
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
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.filter_list),
          label: const Text('Filtrer'),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.sort),
          label: const Text('Trier'),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.download),
          label: const Text('Exporter'),
        ),
      ],
    );
  }

  Widget _buildPieceDataTable(String pieceType) {
    // Adapter les colonnes en fonction du type de pièce
    List<DataColumn2> columns = _getColumnsForPieceType(pieceType);
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: DataTable2(
            columnSpacing: 12,
            horizontalMargin: 12,
            minWidth: 900,
            columns: columns,
            rows: _getDummyRowsForPieceType(pieceType),
          ),
        ),
      ),
    );
  }

  List<DataColumn2> _getColumnsForPieceType(String pieceType) {
    List<DataColumn2> baseColumns = [
      const DataColumn2(
        label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold)),
        size: ColumnSize.S,
      ),
      const DataColumn2(
        label: Text('Nom', style: TextStyle(fontWeight: FontWeight.bold)),
        size: ColumnSize.M,
      ),
      const DataColumn2(
        label: Text('Marque', style: TextStyle(fontWeight: FontWeight.bold)),
        size: ColumnSize.M,
      ),
      const DataColumn2(
        label: Text('Prix', style: TextStyle(fontWeight: FontWeight.bold)),
        size: ColumnSize.S,
        numeric: true,
      ),
    ];

    // Ajouter des colonnes spécifiques en fonction du type de pièce
    switch (pieceType.toLowerCase()) {
      case 'pneus':
        baseColumns.add(const DataColumn2(
          label: Text('Dimension', style: TextStyle(fontWeight: FontWeight.bold)),
          size: ColumnSize.M,
        ));
        baseColumns.add(const DataColumn2(
          label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
          size: ColumnSize.M,
        ));
        break;
      case 'vidange':
        baseColumns.add(const DataColumn2(
          label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
          size: ColumnSize.M,
        ));
        baseColumns.add(const DataColumn2(
          label: Text('Viscosité', style: TextStyle(fontWeight: FontWeight.bold)),
          size: ColumnSize.M,
        ));
        break;
      case 'amortisseurs':
        baseColumns.add(const DataColumn2(
          label: Text('Position', style: TextStyle(fontWeight: FontWeight.bold)),
          size: ColumnSize.M,
        ));
        baseColumns.add(const DataColumn2(
          label: Text('Compatibilité', style: TextStyle(fontWeight: FontWeight.bold)),
          size: ColumnSize.L,
        ));
        break;
      case 'batterie':
        baseColumns.add(const DataColumn2(
          label: Text('Capacité', style: TextStyle(fontWeight: FontWeight.bold)),
          size: ColumnSize.M,
        ));
        baseColumns.add(const DataColumn2(
          label: Text('Démarrage', style: TextStyle(fontWeight: FontWeight.bold)),
          size: ColumnSize.M,
        ));
        break;
      case 'embrayage':
        baseColumns.add(const DataColumn2(
          label: Text('Type Véhicule', style: TextStyle(fontWeight: FontWeight.bold)),
          size: ColumnSize.M,
        ));
        baseColumns.add(const DataColumn2(
          label: Text('Diamètre', style: TextStyle(fontWeight: FontWeight.bold)),
          size: ColumnSize.M,
        ));
        break;
      case 'freins':
        baseColumns.add(const DataColumn2(
          label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
          size: ColumnSize.M,
        ));
        baseColumns.add(const DataColumn2(
          label: Text('Position', style: TextStyle(fontWeight: FontWeight.bold)),
          size: ColumnSize.M,
        ));
        break;
      case 'courroie':
        baseColumns.add(const DataColumn2(
          label: Text('Nb Dents', style: TextStyle(fontWeight: FontWeight.bold)),
          size: ColumnSize.M,
        ));
        baseColumns.add(const DataColumn2(
          label: Text('Avec Pompe', style: TextStyle(fontWeight: FontWeight.bold)),
          size: ColumnSize.M,
        ));
        break;
    }

    // Colonne d'actions (toujours la dernière)
    baseColumns.add(const DataColumn2(
      label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold)),
      size: ColumnSize.L,
    ));

    return baseColumns;
  }

  List<DataRow> _getDummyRowsForPieceType(String pieceType) {
    // Générer des données fictives en fonction du type de pièce
    List<DataRow> rows = [];
    
    for (int i = 1; i <= 10; i++) {
      List<DataCell> cells = [
        DataCell(Text('P$i')),
        DataCell(Text('${pieceType.substring(0, pieceType.length - 1)} Premium $i')),
        DataCell(Text('Marque ${i % 5 + 1}')),
        DataCell(Text('${(i * 50 + 100).toStringAsFixed(2)} DT')),
      ];

      // Ajouter des cellules spécifiques en fonction du type de pièce
      switch (pieceType.toLowerCase()) {
        case 'pneus':
          cells.add(DataCell(Text('205/55R${14 + (i % 4)}'))); // Dimension
          cells.add(DataCell(Text(i % 3 == 0 ? 'Été' : i % 3 == 1 ? 'Hiver' : '4 Saisons'))); // Type
          break;
        case 'vidange':
          cells.add(DataCell(Text(i % 3 == 0 ? 'Synthétique' : i % 3 == 1 ? 'Semi-synthétique' : 'Minérale'))); // Type
          cells.add(DataCell(Text('${5 + (i % 4) * 5}W${30 + (i % 3) * 10}'))); // Viscosité
          break;
        case 'amortisseurs':
          cells.add(DataCell(Text(i % 2 == 0 ? 'Avant' : 'Arrière'))); // Position
          cells.add(DataCell(Text('Compatible ${['Renault', 'Peugeot', 'Volkswagen', 'Toyota'][i % 4]}'))); // Compatibilité
          break;
        case 'batterie':
          cells.add(DataCell(Text('${45 + i * 5} Ah'))); // Capacité
          cells.add(DataCell(Text('${360 + i * 20} A'))); // Démarrage
          break;
        case 'embrayage':
          cells.add(DataCell(Text(i % 2 == 0 ? 'Diesel' : 'Essence'))); // Type Véhicule
          cells.add(DataCell(Text('${200 + i * 10} mm'))); // Diamètre
          break;
        case 'freins':
          cells.add(DataCell(Text(i % 3 == 0 ? 'Disque' : i % 3 == 1 ? 'Plaquette' : 'Tambour'))); // Type
          cells.add(DataCell(Text(i % 2 == 0 ? 'Avant' : 'Arrière'))); // Position
          break;
        case 'courroie':
          cells.add(DataCell(Text('${100 + i * 5}'))); // Nb Dents
          cells.add(DataCell(Text(i % 2 == 0 ? 'Oui' : 'Non'))); // Avec Pompe
          break;
      }

      // Cellule d'actions (toujours la dernière)
      cells.add(
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.visibility, color: AppTheme.primaryColor, size: 20),
                onPressed: () {},
                tooltip: 'Voir les détails',
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: AppTheme.secondaryColor, size: 20),
                onPressed: () => _showAddEditPieceDialog(context, isEdit: true),
                tooltip: 'Modifier',
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: AppTheme.dangerColor, size: 20),
                onPressed: () => _showDeleteConfirmationDialog(context),
                tooltip: 'Supprimer',
              ),
            ],
          ),
        ),
      );

      rows.add(DataRow(cells: cells));
    }

    return rows;
  }

  void _showAddEditPieceDialog(BuildContext context, {bool isEdit = false}) {
    final pieceType = pieceTypes[_tabController.index].toLowerCase();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${isEdit ? 'Modifier' : 'Ajouter'} un ${pieceType.substring(0, pieceType.length - 1)}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCommonPieceFields(),
                const SizedBox(height: 16),
                _buildSpecificPieceFields(pieceType),
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
                // Sauvegarder la pièce
                Navigator.pop(context);
              },
              child: Text(isEdit ? 'Mettre à jour' : 'Ajouter'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCommonPieceFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: const InputDecoration(
            labelText: 'Nom',
            hintText: 'Nom de la pièce',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Marque',
            hintText: 'Marque de la pièce',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Prix (DT)',
            hintText: 'Prix de la pièce',
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Description',
            hintText: 'Description de la pièce',
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildSpecificPieceFields(String pieceType) {
    switch (pieceType) {
      case 'pneus':
        return Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Dimension',
                hintText: 'Ex: 205/55R16',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Type'),
              items: ['Été', 'Hiver', '4 Saisons']
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
                labelText: 'Indice de charge',
                hintText: 'Ex: 91',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Indice de vitesse',
                hintText: 'Ex: H',
              ),
            ),
          ],
        );
      case 'vidange':
        return Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Type'),
              items: ['Synthétique', 'Semi-synthétique', 'Minérale']
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
                labelText: 'Viscosité W',
                hintText: 'Ex: 5',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Viscosité N',
                hintText: 'Ex: 30',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Capacité (Litres)',
                hintText: 'Ex: 5',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        );
      case 'amortisseurs':
        return Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Type'),
              items: ['Avant', 'Arrière', 'Kit complet']
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
                labelText: 'Compatibilité',
                hintText: 'Modèles de voiture compatibles',
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Amortisseur à gaz'),
              value: false,
              onChanged: (value) {},
            ),
          ],
        );
      case 'batterie':
        return Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Capacité (Ah)',
                hintText: 'Ex: 60',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Courant de démarrage (A)',
                hintText: 'Ex: 540',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Tension'),
              items: ['12V', '24V']
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) {},
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Technologie'),
              items: ['Plomb', 'AGM', 'EFB', 'Lithium']
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) {},
            ),
          ],
        );
      // Implémenter les champs spécifiques pour les autres types de pièces...
      default:
        return const SizedBox.shrink();
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: const Text('Êtes-vous sûr de vouloir supprimer cette pièce ? Cette action est irréversible.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                // Supprimer la pièce
                Navigator.pop(context);
                _showSnackBar('Pièce supprimée avec succès');
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
