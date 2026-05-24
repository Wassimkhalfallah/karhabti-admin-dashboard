import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../services/garage_pro_service.dart';

class NotificationsJournalScreen extends StatefulWidget {
  const NotificationsJournalScreen({super.key});

  @override
  State<NotificationsJournalScreen> createState() => _NotificationsJournalScreenState();
}

class _NotificationsJournalScreenState extends State<NotificationsJournalScreen> {
  final GarageProService _service = GarageProService();
  bool _loading = true;
  List<Map<String, dynamic>> _notifications = [];
  String? _typeFilter;
  String? _canalFilter;
  String? _statutFilter;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final data = await _service.getNotifications(
      type: _typeFilter,
      canal: _canalFilter,
      statut: _statutFilter,
    );
    if (mounted) setState(() { _notifications = data; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildToolbar(),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _buildList(),
        ),
      ],
    );
  }

  Widget _buildToolbar() {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            DropdownButton<String?>(
              value: _typeFilter,
              hint: const Text('Type'),
              items: [
                const DropdownMenuItem(value: null, child: Text('Tous')),
                const DropdownMenuItem(value: 'confirmation', child: Text('Confirmation')),
                const DropdownMenuItem(value: 'rappel_24h', child: Text('Rappel 24h')),
                const DropdownMenuItem(value: 'annulation', child: Text('Annulation')),
              ],
              onChanged: (v) { _typeFilter = v; _loadData(); },
            ),
            const SizedBox(width: 12),
            DropdownButton<String?>(
              value: _canalFilter,
              hint: const Text('Canal'),
              items: [
                const DropdownMenuItem(value: null, child: Text('Tous')),
                const DropdownMenuItem(value: 'push', child: Text('Push')),
                const DropdownMenuItem(value: 'email', child: Text('Email')),
                const DropdownMenuItem(value: 'sms', child: Text('SMS')),
              ],
              onChanged: (v) { _canalFilter = v; _loadData(); },
            ),
            const SizedBox(width: 12),
            DropdownButton<String?>(
              value: _statutFilter,
              hint: const Text('Statut'),
              items: [
                const DropdownMenuItem(value: null, child: Text('Tous')),
                const DropdownMenuItem(value: 'envoyee', child: Text('Envoyée ✅')),
                const DropdownMenuItem(value: 'lu', child: Text('Lu 👁️')),
                const DropdownMenuItem(value: 'echouee', child: Text('Échouée ❌')),
              ],
              onChanged: (v) { _statutFilter = v; _loadData(); },
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Actualiser'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    if (_notifications.isEmpty) return const Center(child: Text('Aucune notification'));
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _notifications.length,
      itemBuilder: (_, i) {
        final n = _notifications[i];
        final statut = n['statut'] as String? ?? '';
        final envoyeLe = n['envoye_le'] as String? ?? '';
        final canal = n['canal'] as String? ?? '';
        final type = n['type'] as String? ?? '';
        final erreur = n['erreur'] as String?;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: _statutIcon(statut),
            title: Text(_typeLabel(type), style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Canal: ${_canalLabel(canal)}'),
                if (envoyeLe.isNotEmpty)
                  Text(DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(envoyeLe)),
                      style: TextStyle(color: AppTheme.greyColor, fontSize: 12)),
                if (erreur != null && erreur.isNotEmpty)
                  Text('Erreur: $erreur', style: const TextStyle(color: AppTheme.dangerColor, fontSize: 12)),
              ],
            ),
            trailing: _statutBadge(statut),
          ),
        );
      },
    );
  }

  Icon _statutIcon(String statut) {
    switch (statut) {
      case 'envoyee': return const Icon(Icons.check_circle, color: AppTheme.successColor);
      case 'lu': return const Icon(Icons.visibility, color: AppTheme.primaryColor);
      case 'echouee': return const Icon(Icons.error, color: AppTheme.dangerColor);
      default: return const Icon(Icons.help, color: AppTheme.greyColor);
    }
  }

  Widget _statutBadge(String statut) {
    Color color;
    String label;
    switch (statut) {
      case 'envoyee': color = AppTheme.successColor; label = 'Envoyée ✅'; break;
      case 'lu': color = AppTheme.primaryColor; label = 'Lu 👁️'; break;
      case 'echouee': color = AppTheme.dangerColor; label = 'Échouée ❌'; break;
      default: color = AppTheme.greyColor; label = statut;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      // ignore: deprecated_member_use
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'confirmation': return 'Confirmation de RDV';
      case 'rappel_24h': return 'Rappel 24h';
      case 'annulation': return 'Annulation de RDV';
      default: return type;
    }
  }

  String _canalLabel(String canal) {
    switch (canal) {
      case 'push': return 'Push';
      case 'email': return 'Email';
      case 'sms': return 'SMS';
      default: return canal;
    }
  }
}
