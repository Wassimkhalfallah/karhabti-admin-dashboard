// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../models/review_pro_model.dart';
import '../../services/garage_pro_service.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final GarageProService _service = GarageProService();
  bool _loading = true;
  List<ReviewPro> _reviews = [];
  bool? _visibleFilter;
  bool? _reponduFilter;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final reviews = await _service.getReviews(estVisible: _visibleFilter);
    if (mounted) {
      setState(() {
        _reviews = _reponduFilter == null
            ? reviews
            : reviews.where((r) => r.aReponse == _reponduFilter).toList();
        _loading = false;
      });
    }
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
            FilterChip(
              label: const Text('Visibles'),
              selected: _visibleFilter == true,
              onSelected: (v) { _visibleFilter = v ? true : null; _loadData(); },
              selectedColor: AppTheme.successColor.withOpacity(0.15),
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('Masqués'),
              selected: _visibleFilter == false,
              onSelected: (v) { _visibleFilter = v ? false : null; _loadData(); },
              selectedColor: AppTheme.dangerColor.withOpacity(0.15),
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('Non répondus'),
              selected: _reponduFilter == false,
              onSelected: (v) { _reponduFilter = v ? false : null; _loadData(); },
              selectedColor: AppTheme.warningColor.withOpacity(0.15),
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
    if (_reviews.isEmpty) return const Center(child: Text('Aucun avis'));
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _reviews.length,
      itemBuilder: (_, i) {
        final r = _reviews[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(r.stars, style: const TextStyle(fontSize: 18, color: Colors.amber)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(r.clientNom ?? 'Client', style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(r.garageNom ?? 'Garage', style: TextStyle(color: AppTheme.greyColor, fontSize: 12)),
                    ]),
                  ),
                  _visibilityBadge(r.estVisible),
                  const SizedBox(width: 8),
                  _reponseBadge(r.aReponse),
                ]),
                if (r.commentaire != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(r.commentaire!, style: AppTheme.bodyMedium),
                  ),
                ],
                if (r.aReponse) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Icon(Icons.reply, size: 16, color: AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      Expanded(child: Text(r.reponseGarage!, style: const TextStyle(fontSize: 13))),
                    ]),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat('dd/MM/yyyy').format(r.createdAt),
                        style: TextStyle(color: AppTheme.greyColor, fontSize: 12)),
                    Row(children: [
                      TextButton.icon(
                        onPressed: () => _toggleVisibility(r),
                        icon: Icon(r.estVisible ? Icons.visibility_off : Icons.visibility, size: 16),
                        label: Text(r.estVisible ? 'Masquer' : 'Afficher'),
                      ),
                      const SizedBox(width: 4),
                      TextButton.icon(
                        onPressed: () => _replyToReview(r),
                        icon: const Icon(Icons.reply, size: 16),
                        label: const Text('Répondre'),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.dangerColor),
                        onPressed: () => _deleteReview(r),
                        tooltip: 'Supprimer',
                      ),
                    ]),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _visibilityBadge(bool visible) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: visible ? AppTheme.successColor.withOpacity(0.1) : AppTheme.dangerColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(visible ? 'Visible' : 'Masqué',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
              color: visible ? AppTheme.successColor : AppTheme.dangerColor)),
    );
  }

  Widget _reponseBadge(bool repondu) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: repondu ? AppTheme.primaryColor.withOpacity(0.1) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(repondu ? 'Répondu' : 'Non répondu',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
              color: repondu ? AppTheme.primaryColor : Colors.grey)),
    );
  }

  Future<void> _toggleVisibility(ReviewPro r) async {
    await _service.toggleReviewVisibility(r.id, !r.estVisible);
    _loadData();
  }

  Future<void> _replyToReview(ReviewPro r) async {
    final ctrl = TextEditingController(text: r.reponseGarage ?? '');
    final reponse = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Répondre à l\'avis'),
        content: TextField(controller: ctrl, maxLines: 3, decoration: const InputDecoration(hintText: 'Votre réponse...')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(onPressed: () => Navigator.pop(context, ctrl.text), child: const Text('Envoyer')),
        ],
      ),
    );
    if (reponse != null && reponse.isNotEmpty) {
      await _service.replyToReview(r.id, reponse);
      _loadData();
    }
  }

  Future<void> _deleteReview(ReviewPro r) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer cet avis ?'),
        content: const Text('L\'avis sera masqué (est_visible = false).'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerColor),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _service.deleteReview(r.id);
      _loadData();
    }
  }
}
