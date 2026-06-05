import 'package:flutter/material.dart';
import '../../services/vehicle_service.dart';
import 'vehicule_detail_screen.dart';

// ── Design tokens ─────────────────────────────────────────────────────────
const _kPrimary  = Color(0xFF5B6EF5);
const _kTeal     = Color(0xFF06C8B4);
const _kOrange   = Color(0xFFFF8C42);
const _kBg       = Color(0xFFF8FAFF);
const _kTextPri  = Color(0xFF1A1D2E);
const _kTextSec  = Color(0xFF64748B);

class ResponsableVehiculesScreen extends StatefulWidget {
  final String garageId;
  const ResponsableVehiculesScreen({super.key, required this.garageId});

  @override
  State<ResponsableVehiculesScreen> createState() =>
      _ResponsableVehiculesScreenState();
}

class _ResponsableVehiculesScreenState
    extends State<ResponsableVehiculesScreen>
    with SingleTickerProviderStateMixin {
  final _service = VehicleService();
  bool _loading  = true;
  List<Map<String, dynamic>> _data = [];

  late AnimationController _listCtrl;

  @override
  void initState() {
    super.initState();
    _listCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _load();
  }

  @override
  void dispose() {
    _listCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _listCtrl.reset();
    final data = await _service.getVehiculesDuGarage(widget.garageId);
    if (mounted) {
      setState(() {
        _data    = data;
        _loading = false;
      });
      _listCtrl.forward();
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  bool _hasCritical(Map<String, dynamic> v) {
    final p = v['prediction'] as Map<String, dynamic>?;
    if (p == null) return false;
    return [
      p['tire_wear'], p['battery_health'], p['brake_wear'],
      p['oil_change'], p['belt_risk'], p['clutch_wear'],
      p['ShockAbsorber_Wear'],
    ].any((e) => (e as num?) != null && e! >= 70);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: _buildAppBar(),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(_kPrimary),
              ),
            )
          : _data.isEmpty
              ? _buildEmptyState()
              : _buildList(),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      foregroundColor: _kTextPri,
      leadingWidth: 56,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: BoxDecoration(
              color: _kPrimary.withOpacity(0.07),
              borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: _kPrimary, size: 18)),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Véhicules du Garage',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800,
                  color: _kTextPri, height: 1.1)),
          Text('${_data.length} véhicule${_data.length > 1 ? 's' : ''}',
              style: const TextStyle(
                  fontSize: 12, color: _kTextSec,
                  fontWeight: FontWeight.w400)),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 14),
          decoration: BoxDecoration(
            color: _kPrimary.withOpacity(0.07),
            borderRadius: BorderRadius.circular(10)),
          child: IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded, color: _kPrimary, size: 20),
            tooltip: 'Actualiser',
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: const Color(0xFFF0F2FF)),
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 84, height: 84,
          decoration: BoxDecoration(
            color: _kTeal.withOpacity(0.07),
            borderRadius: BorderRadius.circular(24)),
          child: const Icon(Icons.directions_car_outlined,
              size: 42, color: _kTeal)),
        const SizedBox(height: 18),
        const Text('Aucun véhicule',
            style: TextStyle(fontSize: 18,
                fontWeight: FontWeight.w700, color: _kTextPri)),
        const SizedBox(height: 6),
        const Text('Aucun véhicule enregistré dans ce garage',
            style: TextStyle(fontSize: 14, color: _kTextSec)),
      ]),
    );
  }

  // ── Vehicle list ──────────────────────────────────────────────────────────

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: _data.length,
      itemBuilder: (context, index) {
        final v      = _data[index];
        final client = v['client'] as Map<String, dynamic>?;
        final isCrit = _hasCritical(v);

        return AnimatedBuilder(
          animation: _listCtrl,
          builder: (ctx, child) {
            final delay    = (index * 0.08).clamp(0.0, 0.65);
            final progress =
                ((_listCtrl.value - delay) / 0.35).clamp(0.0, 1.0);
            return Opacity(
              opacity: Curves.easeOut.transform(progress),
              child: Transform.translate(
                offset: Offset(0,
                    24 * (1 - Curves.easeOutCubic.transform(progress))),
                child: child,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildVehicleCard(v, client, isCrit),
          ),
        );
      },
    );
  }

  // ── Vehicle card ──────────────────────────────────────────────────────────

  Widget _buildVehicleCard(
    Map<String, dynamic> v,
    Map<String, dynamic>? client,
    bool isCritical,
  ) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, a, __) => VehiculeDetailScreen(vehiculeData: v),
          transitionsBuilder: (_, a, __, child) => SlideTransition(
            position: Tween<Offset>(
                    begin: const Offset(1, 0), end: Offset.zero)
                .animate(CurvedAnimation(
                    parent: a, curve: Curves.easeOutCubic)),
            child: child,
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14, offset: const Offset(0, 5))],
          border: isCritical
              ? Border.all(color: _kOrange.withOpacity(0.35), width: 1.5)
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(children: [
            // Critical stripe
            if (isCritical)
              Container(height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_kOrange, _kOrange.withOpacity(0.4)]))),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                // ── Vehicle icon ───────────────────────────────
                Container(
                  width: 66, height: 66,
                  decoration: BoxDecoration(
                    color: _kTeal.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(18)),
                  child: Stack(alignment: Alignment.center, children: [
                    const Icon(Icons.directions_car_rounded,
                        size: 34, color: _kTeal),
                    if (isCritical)
                      Positioned(
                        top: 6, right: 6,
                        child: Container(
                          width: 14, height: 14,
                          decoration: BoxDecoration(
                            color: _kOrange,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white, width: 1.5)),
                        ),
                      ),
                  ]),
                ),
                const SizedBox(width: 14),

                // ── Info ───────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                          child: Text(
                            v['immatriculation'] ?? '—',
                            style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w800,
                              color: _kTextPri),
                          ),
                        ),
                        if (isCritical)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _kOrange.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(10)),
                            child: const Text('Critique',
                                style: TextStyle(
                                    color: _kOrange, fontSize: 10,
                                    fontWeight: FontWeight.w700)),
                          ),
                      ]),
                      const SizedBox(height: 4),
                      Text(
                        '${v['marque'] ?? ''} ${v['modele'] ?? ''}'.trim(),
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500,
                            color: _kTextSec),
                      ),
                      const SizedBox(height: 8),
                      // Client
                      Row(children: [
                        const Icon(Icons.person_outline_rounded,
                            size: 14, color: _kTextSec),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            client?['nom_client'] ?? 'Client inconnu',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 13, color: _kTextSec)),
                        ),
                      ]),
                      if (client?['telephone'] != null) ...[
                        const SizedBox(height: 4),
                        Row(children: [
                          const Icon(Icons.phone_outlined,
                              size: 14, color: _kTextSec),
                          const SizedBox(width: 5),
                          Text(client!['telephone'],
                              style: const TextStyle(
                                  fontSize: 13, color: _kTextSec)),
                        ]),
                      ],
                    ],
                  ),
                ),

                // ── Arrow ──────────────────────────────────────
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _kPrimary.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.arrow_forward_ios_rounded,
                      color: _kPrimary, size: 14)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}