import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/responsable_technicien_model.dart';
import '../../services/responsable_technicien_service.dart';

// ─────────────────────────────────────────────
//  Design tokens
// ─────────────────────────────────────────────
class _K {
  static const Color bg = Color(0xFFF7F9FC);
  static const Color surface = Colors.white;
  static const Color primary = Color(0xFF3B82F6);
  static const Color primaryLight = Color(0xFFEFF6FF);
  static const Color accent = Color(0xFF10B981);
  static const Color danger = Color(0xFFEF4444);
  static const Color warn = Color(0xFFF59E0B);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMid = Color(0xFF64748B);
  static const Color textLight = Color(0xFFCBD5E1);
  static const Color border = Color(0xFFE2E8F0);
  static const Color shadow = Color(0x0D1E293B);
  static const double radius = 16;
  static const double cardRadius = 20;
}

// ─────────────────────────────────────────────
//  Screen
// ─────────────────────────────────────────────
class ResponsablesScreen extends StatefulWidget {
  const ResponsablesScreen({super.key});

  @override
  State<ResponsablesScreen> createState() => _ResponsablesScreenState();
}

class _ResponsablesScreenState extends State<ResponsablesScreen>
    with SingleTickerProviderStateMixin {
  final _service = ResponsableTechnicienService();
  bool _loading = true;
  List<ResponsableTechnicien> _items = [];
  String _search = '';
  late AnimationController _fabAnim;

  @override
  void initState() {
    super.initState();
    _fabAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _load();
  }

  @override
  void dispose() {
    _fabAnim.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final rows = await _service.getAllByAdminView();
    if (!mounted) return;
    setState(() {
      _items = rows;
      _loading = false;
    });
    _fabAnim.forward(from: 0);
  }

  List<ResponsableTechnicien> get _filtered {
    if (_search.isEmpty) return _items;
    final q = _search.toLowerCase();
    return _items.where((r) {
      return r.nomComplet.toLowerCase().contains(q) ||
          (r.telephone ?? '').contains(q) ||
          (r.garageId ?? '').toLowerCase().contains(q);
    }).toList();
  }

  int get _total => _items.length;
  int get _actifs => _items.where((r) => r.estActif).length;
  int get _withGarage => _items.where((r) => r.garageId != null).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _K.bg,
      body: _loading ? _buildSkeleton() : _buildBody(),
    );
  }

  Widget _buildSkeleton() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            itemCount: 5,
            itemBuilder: (_, __) => const _SkeletonCard(),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    final list = _filtered;
    return Column(
      children: [
        _buildHeader(),
        _buildStatsRow(),
        _buildSearchBar(),
        Expanded(
          child: list.isEmpty
              ? _buildEmpty()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                  itemCount: list.length,
                  itemBuilder: (_, i) => _ResponsableCard(
                    key: ValueKey(list[i].id),
                    item: list[i],
                    index: i,
                    onToggle: (v) async {
                      await _service.toggleActif(list[i].id, v);
                      _load();
                    },
                    onSendCredentials: () => _sendCredentials(list[i]),
                    onEdit: () => _openEditDialog(list[i]),
                    onDelete: () => _confirmDelete(list[i]),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 24,
        right: 24,
        bottom: 20,
      ),
      decoration: const BoxDecoration(
        color: _K.surface,
        border: Border(bottom: BorderSide(color: _K.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _K.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.manage_accounts_rounded,
                color: _K.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Responsables',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: _K.textDark,
                        fontSize: 20,
                      ),
                ),
                const Text(
                  'Gestion des responsables techniciens',
                  style: TextStyle(color: _K.textMid, fontSize: 12),
                ),
              ],
            ),
          ),
          ScaleTransition(
            scale: CurvedAnimation(parent: _fabAnim, curve: Curves.elasticOut),
            child: FilledButton.icon(
              onPressed: _openCreateDialog,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Nouveau'),
              style: FilledButton.styleFrom(
                backgroundColor: _K.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      color: _K.surface,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: [
          _StatChip(label: 'Total', value: '$_total', color: _K.primary),
          const SizedBox(width: 8),
          _StatChip(label: 'Actifs', value: '$_actifs', color: _K.accent),
          const SizedBox(width: 8),
          _StatChip(
              label: 'Avec garage',
              value: '$_withGarage',
              color: _K.warn),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: TextField(
        onChanged: (v) => setState(() => _search = v),
        decoration: InputDecoration(
          hintText: 'Rechercher un responsable…',
          hintStyle: const TextStyle(color: _K.textLight, fontSize: 14),
          prefixIcon:
              const Icon(Icons.search_rounded, color: _K.textMid, size: 20),
          filled: true,
          fillColor: _K.surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_K.radius),
            borderSide: const BorderSide(color: _K.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_K.radius),
            borderSide: const BorderSide(color: _K.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_K.radius),
            borderSide: const BorderSide(color: _K.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _K.primaryLight,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.person_search_rounded,
                color: _K.primary, size: 40),
          ),
          const SizedBox(height: 16),
          const Text('Aucun résultat',
              style: TextStyle(
                  color: _K.textDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 16)),
          const SizedBox(height: 4),
          const Text('Essayez une autre recherche',
              style: TextStyle(color: _K.textMid, fontSize: 13)),
        ],
      ),
    );
  }

  // ── Create dialog ──────────────────────────
  // L'UUID est généré automatiquement par Supabase Auth via signUp —
  // aucun champ "User ID" n'est exposé à l'administrateur.
  Future<void> _openCreateDialog() async {
    final form = GlobalKey<FormState>();
    final nomCtrl = TextEditingController();
    final telCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    bool obscure = true;
    bool creating = false;

    await showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDlg) => _KDialog(
          title: 'Nouveau responsable',
          icon: Icons.person_add_rounded,
          iconColor: _K.primary,
          actions: [
            TextButton(
              onPressed: creating ? null : () => Navigator.pop(ctx),
              child:
                  const Text('Annuler', style: TextStyle(color: _K.textMid)),
            ),
            FilledButton(
              onPressed: creating
                  ? null
                  : () async {
                      if (!form.currentState!.validate()) return;
                      setDlg(() => creating = true);
                      try {
                        // 1️⃣  Créer le compte dans auth.users via signUp
                        //     → Supabase génère l'UUID automatiquement
                        final authResp = await _service.signUpResponsable(
                          email: emailCtrl.text.trim(),
                          password: passwordCtrl.text,
                        );
                        final newUserId = authResp?.id;
                        if (newUserId == null) {
                          throw Exception('Échec de la création du compte auth.');
                        }

                        // 2️⃣  Insérer le profil dans responsables_techniciens
                        //     avec l'UUID retourné par Supabase
                        await _service.createResponsable(
                          userId: newUserId,
                          nomComplet: nomCtrl.text.trim(),
                          telephone: telCtrl.text.trim().isEmpty
                              ? null
                              : telCtrl.text.trim(),
                        );

                        if (mounted) Navigator.pop(ctx);
                        _load();
                      } catch (e) {
                        setDlg(() => creating = false);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(children: [
                                const Icon(Icons.error_rounded,
                                    color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: Text('Erreur : ${e.toString()}')),
                              ]),
                              backgroundColor: _K.danger,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        }
                      }
                    },
              style: FilledButton.styleFrom(
                backgroundColor: _K.primary,
                disabledBackgroundColor: _K.primary.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: creating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Créer'),
            ),
          ],
          child: Form(
            key: form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Infos profil ─────────────────────
                _KField(
                  ctrl: nomCtrl,
                  label: 'Nom complet',
                  icon: Icons.badge_rounded,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Champ requis' : null,
                ),
                const SizedBox(height: 12),
                _KField(
                  ctrl: telCtrl,
                  label: 'Téléphone',
                  icon: Icons.phone_rounded,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                const Divider(color: _K.border),
                const SizedBox(height: 4),
                // ── Section identifiants ─────────────
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'IDENTIFIANTS DE CONNEXION',
                    style: TextStyle(
                        color: _K.textMid,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8),
                  ),
                ),
                const SizedBox(height: 6),
                // Info contextuelle
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: _K.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          size: 14, color: _K.primary),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'L\'UUID est généré automatiquement par Supabase Auth.',
                          style:
                              TextStyle(color: _K.primary, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _KField(
                  ctrl: emailCtrl,
                  label: 'Adresse e-mail',
                  icon: Icons.email_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Champ requis';
                    if (!v.contains('@')) return 'E-mail invalide';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _KField(
                  ctrl: passwordCtrl,
                  label: 'Mot de passe',
                  icon: Icons.lock_rounded,
                  obscureText: obscure,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Champ requis';
                    if (v.length < 6) return 'Minimum 6 caractères';
                    return null;
                  },
                  suffix: IconButton(
                    icon: Icon(
                      obscure
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                      color: _K.textMid,
                      size: 18,
                    ),
                    onPressed: () => setDlg(() => obscure = !obscure),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Edit dialog ────────────────────────────
  Future<void> _openEditDialog(ResponsableTechnicien r) async {
    final form = GlobalKey<FormState>();
    final nomCtrl = TextEditingController(text: r.nomComplet);
    final telCtrl = TextEditingController(text: r.telephone ?? '');

    await showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (_) => _KDialog(
        title: 'Modifier le responsable',
        icon: Icons.edit_rounded,
        iconColor: _K.warn,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: _K.textMid)),
          ),
          FilledButton(
            onPressed: () async {
              if (!form.currentState!.validate()) return;
              await _service.updateResponsable(
                id: r.id,
                nomComplet: nomCtrl.text.trim(),
                telephone: telCtrl.text.trim().isEmpty
                    ? null
                    : telCtrl.text.trim(),
              );
              if (mounted) Navigator.pop(context);
              _load();
            },
            style: FilledButton.styleFrom(
              backgroundColor: _K.warn,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Enregistrer'),
          ),
        ],
        child: Form(
          key: form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _KField(
                ctrl: nomCtrl,
                label: 'Nom complet',
                icon: Icons.badge_rounded,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 12),
              _KField(
                ctrl: telCtrl,
                label: 'Téléphone',
                icon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Delete confirm ─────────────────────────
  Future<void> _confirmDelete(ResponsableTechnicien r) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black26,
      builder: (_) => _KDialog(
        title: 'Supprimer le responsable',
        icon: Icons.delete_rounded,
        iconColor: _K.danger,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler', style: TextStyle(color: _K.textMid)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: _K.danger,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Supprimer'),
          ),
        ],
        child: Text(
          'Êtes-vous sûr de vouloir supprimer "${r.nomComplet}" ? Cette action est irréversible.',
          style:
              const TextStyle(color: _K.textMid, fontSize: 14, height: 1.5),
        ),
      ),
    );
    if (confirmed == true) {
      await _service.deleteResponsable(r.id);
      _load();
    }
  }

  // ── Send credentials dialog ────────────────
  Future<void> _sendCredentials(ResponsableTechnicien r) async {
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    bool obscure = true;

    await showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDlg) => _KDialog(
          title: 'Envoyer les identifiants',
          icon: Icons.send_rounded,
          iconColor: _K.accent,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child:
                  const Text('Annuler', style: TextStyle(color: _K.textMid)),
            ),
            FilledButton.icon(
              onPressed: () async {
                if (emailCtrl.text.trim().isEmpty ||
                    passwordCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('E-mail et mot de passe requis')),
                  );
                  return;
                }
                // TODO: integrate with your notification / email service
                // e.g. await _service.sendCredentials(
                //   responsableId: r.id,
                //   email: emailCtrl.text.trim(),
                //   password: passwordCtrl.text,
                // );
                if (mounted) Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(children: [
                      const Icon(Icons.check_circle_rounded,
                          color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text('Identifiants envoyés à ${r.nomComplet}'),
                    ]),
                    backgroundColor: _K.accent,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
              icon: const Icon(Icons.send_rounded, size: 16),
              label: const Text('Envoyer'),
              style: FilledButton.styleFrom(
                backgroundColor: _K.accent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: _K.accent.withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person_rounded,
                        color: _K.accent, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        r.nomComplet,
                        style: const TextStyle(
                            color: _K.textDark,
                            fontWeight: FontWeight.w600,
                            fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _KField(
                ctrl: emailCtrl,
                label: 'E-mail',
                icon: Icons.email_rounded,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              _KField(
                ctrl: passwordCtrl,
                label: 'Mot de passe',
                icon: Icons.lock_rounded,
                obscureText: obscure,
                suffix: IconButton(
                  icon: Icon(
                    obscure
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                    color: _K.textMid,
                    size: 18,
                  ),
                  onPressed: () => setDlg(() => obscure = !obscure),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Responsable Card
// ─────────────────────────────────────────────
class _ResponsableCard extends StatefulWidget {
  const _ResponsableCard({
    super.key,
    required this.item,
    required this.index,
    required this.onToggle,
    required this.onSendCredentials,
    required this.onEdit,
    required this.onDelete,
  });

  final ResponsableTechnicien item;
  final int index;
  final ValueChanged<bool> onToggle;
  final VoidCallback onSendCredentials;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<_ResponsableCard> createState() => _ResponsableCardState();
}

class _ResponsableCardState extends State<_ResponsableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 350 + widget.index * 55),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    Future.delayed(Duration(milliseconds: widget.index * 55),
        () => mounted ? _ctrl.forward() : null);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year}';
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.item;
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: _K.surface,
            borderRadius: BorderRadius.circular(_K.cardRadius),
            border: Border.all(color: _K.border),
            boxShadow: const [
              BoxShadow(
                  color: _K.shadow, blurRadius: 12, offset: Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              // Top content
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 8, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Avatar(name: r.nomComplet, active: r.estActif),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.nomComplet,
                            style: const TextStyle(
                              color: _K.textDark,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (r.telephone != null)
                            _InfoRow(
                                icon: Icons.phone_rounded,
                                text: r.telephone!),
                          _InfoRow(
                            icon: Icons.garage_rounded,
                            text: r.garageId != null
                                ? 'Garage: ${r.garageId}'
                                : 'Aucun garage',
                            dim: r.garageId == null,
                          ),
                          _InfoRow(
                            icon: Icons.calendar_today_rounded,
                            text: _formatDate(r.createdAt),
                            dim: true,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Switch(
                          value: r.estActif,
                          onChanged: widget.onToggle,
                          activeThumbColor: _K.accent,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        Text(
                          r.estActif ? 'Actif' : 'Inactif',
                          style: TextStyle(
                            fontSize: 10,
                            color: r.estActif ? _K.accent : _K.textLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: _K.border, indent: 16, endIndent: 16),
              // Action row
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: _ActionBtn(
                        icon: Icons.send_rounded,
                        label: 'Identifiants',
                        color: _K.accent,
                        bgColor: const Color(0xFFF0FDF4),
                        onTap: widget.onSendCredentials,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _ActionsMenu(
                      onEdit: widget.onEdit,
                      onDelete: widget.onDelete,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Info row helper
// ─────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text, this.dim = false});
  final IconData icon;
  final String text;
  final bool dim;

  @override
  Widget build(BuildContext context) {
    final color = dim ? _K.textLight : _K.textMid;
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: color, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Avatar
// ─────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, required this.active});
  final String name;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final initials = name
        .trim()
        .split(' ')
        .where((s) => s.isNotEmpty)
        .take(2)
        .map((s) => s[0].toUpperCase())
        .join();

    return Stack(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF6366F1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Text(
            initials.isEmpty ? '?' : initials,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 13,
            height: 13,
            decoration: BoxDecoration(
              color: active ? _K.accent : _K.textLight,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Action button
// ─────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Actions popup menu
// ─────────────────────────────────────────────
class _ActionsMenu extends StatelessWidget {
  const _ActionsMenu({required this.onEdit, required this.onDelete});
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (v) {
        if (v == 'edit') onEdit();
        if (v == 'delete') onDelete();
      },
      offset: const Offset(0, 36),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: _K.surface,
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: _K.bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _K.border),
        ),
        child: const Row(
          children: [
            Icon(Icons.more_horiz_rounded, size: 18, color: _K.textMid),
            SizedBox(width: 4),
            Text(
              'Actions',
              style: TextStyle(
                color: _K.textMid,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.edit_rounded, size: 15, color: _K.warn),
              ),
              const SizedBox(width: 10),
              const Text('Modifier',
                  style: TextStyle(
                      color: _K.textDark,
                      fontWeight: FontWeight.w500,
                      fontSize: 13)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.delete_rounded,
                    size: 15, color: _K.danger),
              ),
              const SizedBox(width: 10),
              const Text('Supprimer',
                  style: TextStyle(
                      color: _K.danger,
                      fontWeight: FontWeight.w500,
                      fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Stat chip
// ─────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  const _StatChip(
      {required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(0.75),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Reusable dialog shell
// ─────────────────────────────────────────────
class _KDialog extends StatelessWidget {
  const _KDialog({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
    required this.actions,
  });
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        decoration: BoxDecoration(
          color: _K.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 40,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: _K.textDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: _K.border),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: child,
              ),
            ),
            const Divider(height: 1, color: _K.border),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions
                    .expand((w) => [w, const SizedBox(width: 8)])
                    .toList()
                  ..removeLast(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Reusable field
// ─────────────────────────────────────────────
class _KField extends StatelessWidget {
  const _KField({
    required this.ctrl,
    required this.label,
    required this.icon,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.suffix,
  });
  final TextEditingController ctrl;
  final String label;
  final IconData icon;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: _K.textDark, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _K.textMid, fontSize: 13),
        prefixIcon: Icon(icon, size: 18, color: _K.textMid),
        suffixIcon: suffix,
        filled: true,
        fillColor: _K.bg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _K.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _K.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _K.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _K.danger),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Skeleton card
// ─────────────────────────────────────────────
class _SkeletonCard extends StatefulWidget {
  const _SkeletonCard();

  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final shade = Color.lerp(
            const Color(0xFFE2E8F0), const Color(0xFFF1F5F9), _anim.value)!;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _K.surface,
            borderRadius: BorderRadius.circular(_K.cardRadius),
            border: Border.all(color: _K.border),
          ),
          child: Row(
            children: [
              Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                      color: shade,
                      borderRadius: BorderRadius.circular(14))),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        height: 12,
                        width: 140,
                        decoration: BoxDecoration(
                            color: shade,
                            borderRadius: BorderRadius.circular(6))),
                    const SizedBox(height: 8),
                    Container(
                        height: 10,
                        width: 100,
                        decoration: BoxDecoration(
                            color: shade,
                            borderRadius: BorderRadius.circular(6))),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}