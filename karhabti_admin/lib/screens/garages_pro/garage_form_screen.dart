// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/garage_pro_model.dart';
import '../../services/garage_pro_service.dart';

// ─── Palette de couleurs du formulaire ────────────────────────────────────

class _FormColors {
  static const sage = Color(0xFF4A7C6F);
  static const sageLight = Color(0xFFEBF4F1);
  static const sageMid = Color(0xFF7FADA3);
  static const warmWhite = Color(0xFFFAFAF8);
  static const slateLight = Color(0xFFEDF2F7);
  static const accent = Color(0xFFC17D3C);
  static const accentLight = Color(0xFFFDF4EB);
  static const border = Color(0xFFE2E8E6);
  static const textMuted = Color(0xFF718096);
  static const textBody = Color(0xFF4A5568);
  static const danger = Color(0xFFE05252);
}

// ─── Entrée point : GarageFormScreen ──────────────────────────────────────

class GarageFormScreen extends StatefulWidget {
  final GaragePro? garage;
  const GarageFormScreen({super.key, this.garage});

  @override
  State<GarageFormScreen> createState() => _GarageFormScreenState();
}

class _GarageFormScreenState extends State<GarageFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = GarageProService();
  bool _saving = false;
  int _page = 0; // 0=Infos, 1=Localisation, 2=Horaires, 3=Paramètres

  // Controllers
  late final TextEditingController _nom;
  late final TextEditingController _adresse;
  late final TextEditingController _ville;
  late final TextEditingController _codePostal;
  late final TextEditingController _telephone;
  late final TextEditingController _telephone2;
  late final TextEditingController _email;
  late final TextEditingController _siteWeb;
  late final TextEditingController _description;
  late final TextEditingController _photo;
  late final TextEditingController _searchCtrl;

  // GPS state
  LatLng? _pickedLocation;
  String? _resolvedAddress;
  bool _geocoding = false;
  GoogleMapController? _mapCtrl;
  Set<Marker> _markers = {};

  // Saisie manuelle de coordonnées (fallback carte)
  late final TextEditingController _latCtrl;
  late final TextEditingController _lngCtrl;
  bool _showManualInput = false;
  String? _manualError;

  // Paramètres
  bool _estVerifie = false;
  bool _estActif = true;
  bool _accepteRdv = true;
  int _delai = 24;
  List<String> _specialites = [];

  // Horaires
  late Map<String, Map<String, dynamic>> _horaires;

  final List<String> _jours = [
    'lundi',
    'mardi',
    'mercredi',
    'jeudi',
    'vendredi',
    'samedi',
    'dimanche',
  ];
  final List<String> _defaultSpecs = [
    'Vidange',
    'Freins',
    'Électronique',
    'Carrosserie',
    'Climatisation',
    'Pneus',
    'Batterie',
    'Courroie',
    'Diagnostic',
    'Révision',
    'Embrayage',
    'Dépannage',
  ];

  // Position par défaut : Tunis
  static const LatLng _defaultPosition = LatLng(36.8065, 10.1815);

  @override
  void initState() {
    super.initState();
    final g = widget.garage;
    _nom = TextEditingController(text: g?.nom ?? '');
    _adresse = TextEditingController(text: g?.adresse ?? '');
    _ville = TextEditingController(text: g?.ville ?? '');
    _codePostal = TextEditingController(text: g?.codePostal ?? '');
    _telephone = TextEditingController(text: g?.telephone ?? '');
    _telephone2 = TextEditingController(text: g?.telephoneSecondaire ?? '');
    _email = TextEditingController(text: g?.email ?? '');
    _siteWeb = TextEditingController(text: g?.siteWeb ?? '');
    _description = TextEditingController(text: g?.description ?? '');
    _photo = TextEditingController(text: g?.photoCouverture ?? '');
    _searchCtrl = TextEditingController();
    _latCtrl = TextEditingController(
      text: g != null ? g.latitude.toStringAsFixed(6) : '',
    );
    _lngCtrl = TextEditingController(
      text: g != null ? g.longitude.toStringAsFixed(6) : '',
    );
    _estVerifie = g?.estVerifie ?? false;
    _estActif = g?.estActif ?? true;
    _accepteRdv = g?.accepteRdvEnLigne ?? true;
    _delai = g?.delaiConfirmation ?? 24;
    _specialites = List.from(g?.specialites ?? []);

    if (g != null) {
      _pickedLocation = LatLng(g.latitude, g.longitude);
      _markers = {
        Marker(
          markerId: const MarkerId('garage'),
          position: _pickedLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      };
    }

    _horaires = {};
    for (final j in _jours) {
      final existing = g?.horaires[j] as Map<String, dynamic>?;
      _horaires[j] = {
        'ouvert': existing?['ouvert'] ?? (j != 'dimanche'),
        'debut': existing?['debut'] ?? '08:00',
        'fin': existing?['fin'] ?? (j == 'samedi' ? '12:00' : '18:00'),
      };
    }
  }

  @override
  void dispose() {
    for (final c in [
      _nom,
      _adresse,
      _ville,
      _codePostal,
      _telephone,
      _telephone2,
      _email,
      _siteWeb,
      _description,
      _photo,
      _searchCtrl,
      _latCtrl,
      _lngCtrl,
    ]) {
      c.dispose();
    }
    _mapCtrl?.dispose();
    super.dispose();
  }

  // ── Google Maps interactions ─────────────────────────────────────────────

  void _onMapCreated(GoogleMapController c) {
    _mapCtrl = c;
    // Style carte sobre (optionnel — JSON style string)
    String? mapStyle;
    c.setMapStyle(mapStyle);
  }

  Future<void> _onMapTap(LatLng pos) async {
    setState(() {
      _pickedLocation = pos;
      _updateMarker(pos);
      _geocoding = true;
      // Synchroniser les champs manuels
      _latCtrl.text = pos.latitude.toStringAsFixed(6);
      _lngCtrl.text = pos.longitude.toStringAsFixed(6);
      _manualError = null;
    });
    try {
      final placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );
      if (placemarks.isNotEmpty && mounted) {
        final p = placemarks.first;
        final addr = [
          p.street,
          p.subLocality,
          p.locality,
        ].where((s) => s != null && s.isNotEmpty).join(', ');
        setState(() {
          _resolvedAddress = addr;
          if (_ville.text.isEmpty && p.locality != null) {
            _ville.text = p.locality!;
          }
          if (_adresse.text.isEmpty && p.street != null) {
            _adresse.text = p.street!;
          }
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _geocoding = false);
    }
  }

  void _updateMarker(LatLng pos) {
    _markers = {
      Marker(
        markerId: const MarkerId('garage'),
        position: pos,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        draggable: true,
        onDragEnd: _onMarkerDragEnd,
      ),
    };
  }

  Future<void> _onMarkerDragEnd(LatLng pos) async {
    await _onMapTap(pos);
  }

  Future<void> _searchAddress() async {
    final query = _searchCtrl.text.trim();
    if (query.isEmpty) return;
    setState(() => _geocoding = true);
    try {
      final locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        final pos = LatLng(loc.latitude, loc.longitude);
        await _onMapTap(pos);
        _mapCtrl?.animateCamera(CameraUpdate.newLatLngZoom(pos, 16));
      } else {
        _showSnack('Adresse introuvable', isError: true);
      }
    } catch (e) {
      _showSnack('Erreur de géocodage : $e', isError: true);
    } finally {
      if (mounted) setState(() => _geocoding = false);
    }
  }

  Future<void> _useMyLocation() async {
    final perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
    try {
      final pos = await Geolocator.getCurrentPosition();
      final latLng = LatLng(pos.latitude, pos.longitude);
      await _onMapTap(latLng);
      _mapCtrl?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 16));
    } catch (e) {
      _showSnack('Impossible d\'obtenir la position', isError: true);
    }
  }

  // ── Saisie manuelle de coordonnées ───────────────────────────────────────

  void _applyManualCoords() {
    final latStr = _latCtrl.text.trim();
    final lngStr = _lngCtrl.text.trim();
    final lat = double.tryParse(latStr.replaceAll(',', '.'));
    final lng = double.tryParse(lngStr.replaceAll(',', '.'));

    if (lat == null || lng == null) {
      setState(() => _manualError = 'Format invalide. Ex : 36.806500 / 10.181500');
      return;
    }
    if (lat < -90 || lat > 90) {
      setState(() => _manualError = 'Latitude invalide (doit être entre -90 et 90)');
      return;
    }
    if (lng < -180 || lng > 180) {
      setState(() => _manualError = 'Longitude invalide (doit être entre -180 et 180)');
      return;
    }

    final pos = LatLng(lat, lng);
    setState(() {
      _pickedLocation = pos;
      _updateMarker(pos);
      _manualError = null;
      _resolvedAddress = null;
    });
    // Déplacer la caméra sur la carte
    _mapCtrl?.animateCamera(CameraUpdate.newLatLngZoom(pos, 15));
    // Lancer le géocodage inverse en tâche de fond
    _onMapTap(pos);
  }

  // ── Sauvegarde ────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _page = 0);
      return;
    }
    if (_pickedLocation == null) {
      setState(() => _page = 1);
      _showSnack('Veuillez positionner le garage sur la carte.', isError: true);
      return;
    }
    setState(() => _saving = true);
    final nom = _nom.text.trim();
    final slug =
        '${nom
            .toLowerCase()
            .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
            .replaceAll(RegExp(r'\s+'), '-')}-${_ville.text.trim().toLowerCase().replaceAll(' ', '-')}';

    final data = {
      'nom': nom,
      'slug': slug,
      'adresse': _adresse.text.trim(),
      'ville': _ville.text.trim(),
      'code_postal':
          _codePostal.text.trim().isEmpty ? null : _codePostal.text.trim(),
      'telephone':
          _telephone.text.trim().isEmpty ? null : _telephone.text.trim(),
      'telephone_secondaire':
          _telephone2.text.trim().isEmpty ? null : _telephone2.text.trim(),
      'email': _email.text.trim().isEmpty ? null : _email.text.trim(),
      'site_web': _siteWeb.text.trim().isEmpty ? null : _siteWeb.text.trim(),
      'description':
          _description.text.trim().isEmpty ? null : _description.text.trim(),
      'latitude': _pickedLocation!.latitude,
      'longitude': _pickedLocation!.longitude,
      'photo_couverture':
          _photo.text.trim().isEmpty ? null : _photo.text.trim(),
      'specialites': _specialites,
      'horaires': _horaires,
      'est_verifie': _estVerifie,
      'est_actif': _estActif,
      'accepte_en_ligne': _accepteRdv,
      'delai_confirmation': _delai,
    };

    try {
      if (widget.garage != null) {
        await _service.updateGarage(widget.garage!.id, data);
      } else {
        await _service.createGarage(data);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _showSnack('Erreur lors de l\'enregistrement : $e', isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? _FormColors.danger : _FormColors.sage,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.garage != null;
    return Dialog(
      backgroundColor: _FormColors.warmWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 780,
        height: MediaQuery.of(context).size.height * 0.9,
        child: Column(
          children: [
            _buildHeader(isEdit),
            _buildStepper(),
            Expanded(
              child: Form(
                key: _formKey,
                child: IndexedStack(
                  index: _page,
                  children: [
                    _pageInfos(),
                    _pageLocalisation(),
                    _pageHoraires(),
                    _pageParametres(),
                  ],
                ),
              ),
            ),
            _buildFooter(isEdit),
          ],
        ),
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader(bool isEdit) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: const BoxDecoration(
        color: _FormColors.sage,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isEdit ? Icons.edit_outlined : Icons.add_business_outlined,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEdit ? 'Modifier le garage' : 'Ajouter un garage partenaire',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .3,
                ),
              ),
              Text(
                'Toutes les modifications sont persistées dans Supabase',
                style: TextStyle(
                  color: Colors.white.withOpacity(.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
            splashRadius: 22,
          ),
        ],
      ),
    );
  }

  // ── Stepper ──────────────────────────────────────────────────────────────

  Widget _buildStepper() {
    final steps = ['Informations', 'Localisation', 'Horaires', 'Paramètres'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            return Expanded(
              child: Container(
                height: 1,
                color: i ~/ 2 < _page ? _FormColors.sage : _FormColors.border,
              ),
            );
          }
          final idx = i ~/ 2;
          final done = idx < _page;
          final active = idx == _page;
          return GestureDetector(
            onTap: () => setState(() => _page = idx),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        done || active
                            ? _FormColors.sage
                            : _FormColors.slateLight,
                    border:
                        active
                            ? Border.all(color: _FormColors.sage, width: 2)
                            : null,
                  ),
                  child: Center(
                    child:
                        done
                            ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 14,
                            )
                            : Text(
                              '${idx + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color:
                                    active
                                        ? Colors.white
                                        : _FormColors.textMuted,
                              ),
                            ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  steps[idx],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: active ? _FormColors.sage : _FormColors.textMuted,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ── Footer ────────────────────────────────────────────────────────────────

  Widget _buildFooter(bool isEdit) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _FormColors.border)),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        children: [
          if (_page > 0)
            OutlinedButton.icon(
              onPressed: () => setState(() => _page--),
              icon: const Icon(Icons.arrow_back, size: 16),
              label: const Text('Précédent'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _FormColors.textBody,
                side: const BorderSide(color: _FormColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
              ),
            ),
          const Spacer(),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Annuler',
              style: TextStyle(color: _FormColors.textMuted),
            ),
          ),
          const SizedBox(width: 10),
          if (_page < 3)
            FilledButton.icon(
              onPressed: () => setState(() => _page++),
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('Suivant'),
              style: FilledButton.styleFrom(
                backgroundColor: _FormColors.sage,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
            )
          else
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon:
                  _saving
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Icon(Icons.check, size: 16),
              label: Text(isEdit ? 'Enregistrer' : 'Créer le garage'),
              style: FilledButton.styleFrom(
                backgroundColor: _FormColors.sage,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // PAGE 0 — Informations générales
  // ═══════════════════════════════════════════════════════════════════════

  Widget _pageInfos() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionCard('Identité du garage', [
            _row2(
              _field(_nom, 'Nom du garage', required: true),
              _field(_adresse, 'Adresse', required: true),
            ),
            const SizedBox(height: 12),
            _row3(
              _field(_ville, 'Ville', required: true),
              _field(_codePostal, 'Code postal'),
              _field(
                TextEditingController(),
                'Slug',
                hint: 'Auto-généré',
                enabled: false,
                mono: true,
              ),
            ),
          ]),
          const SizedBox(height: 16),
          _sectionCard('Contacts', [
            _row3(
              _field(
                _telephone,
                'Téléphone principal',
                icon: Icons.phone_outlined,
              ),
              _field(
                _telephone2,
                'Téléphone secondaire',
                icon: Icons.phone_outlined,
              ),
              _field(
                _email,
                'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            const SizedBox(height: 12),
            _row2(
              _field(
                _siteWeb,
                'Site web',
                icon: Icons.language_outlined,
                hint: 'https://',
              ),
              _field(
                TextEditingController(),
                'Google Place ID',
                hint: 'ChIJ...',
                mono: true,
              ),
            ),
          ]),
          const SizedBox(height: 16),
          _sectionCard('Description & Photo', [
            _fieldMulti(
              _description,
              'Description',
              4,
              hint: 'Décrivez le garage, ses équipements, son expertise...',
            ),
            const SizedBox(height: 12),
            _field(
              _photo,
              'URL photo de couverture',
              icon: Icons.image_outlined,
              hint: 'https://...',
            ),
          ]),
          const SizedBox(height: 16),
          _sectionCard('Spécialités proposées', [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _defaultSpecs.map((s) {
                    final sel = _specialites.contains(s);
                    return FilterChip(
                      label: Text(s, style: const TextStyle(fontSize: 12)),
                      selected: sel,
                      onSelected:
                          (v) => setState(
                            () =>
                                v
                                    ? _specialites.add(s)
                                    : _specialites.remove(s),
                          ),
                      selectedColor: _FormColors.sageLight,
                      checkmarkColor: _FormColors.sage,
                      side: BorderSide(
                        color: sel ? _FormColors.sage : _FormColors.border,
                      ),
                      backgroundColor: _FormColors.slateLight,
                      labelStyle: TextStyle(
                        color: sel ? _FormColors.sage : _FormColors.textBody,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    );
                  }).toList(),
            ),
          ]),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // PAGE 1 — Localisation Google Maps
  // ═══════════════════════════════════════════════════════════════════════

  Widget _pageLocalisation() {
    final hasCoords = _pickedLocation != null;

    return Column(
      children: [
        // ── Barre de recherche ──────────────────────────────────────────────
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'Rechercher une adresse…',
                    prefixIcon: const Icon(
                      Icons.search,
                      size: 18,
                      color: _FormColors.sageMid,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _FormColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _FormColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: _FormColors.sage,
                        width: 1.5,
                      ),
                    ),
                    filled: true,
                    fillColor: _FormColors.slateLight,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _searchAddress(),
                ),
              ),
              const SizedBox(width: 8),
              _mapButton('Rechercher', _FormColors.sage,
                  onTap: _searchAddress, icon: Icons.search),
              const SizedBox(width: 8),
              _mapButton('Ma position', _FormColors.accent,
                  onTap: _useMyLocation, icon: Icons.my_location),
              const SizedBox(width: 8),
              // ── Bouton bascule saisie manuelle ──────────────────────────
              Tooltip(
                message: _showManualInput
                    ? 'Masquer la saisie manuelle'
                    : 'Saisir les coordonnées manuellement',
                child: GestureDetector(
                  onTap: () => setState(() {
                    _showManualInput = !_showManualInput;
                    _manualError = null;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      color: _showManualInput
                          ? _FormColors.accent.withOpacity(0.12)
                          : _FormColors.slateLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _showManualInput
                            ? _FormColors.accent.withOpacity(0.5)
                            : _FormColors.border,
                        width: _showManualInput ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit_location_alt_outlined,
                          size: 15,
                          color: _showManualInput
                              ? _FormColors.accent
                              : _FormColors.textMuted,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'GPS manuel',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _showManualInput
                                ? _FormColors.accent
                                : _FormColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Panneau saisie manuelle (collapsible) ───────────────────────────
        AnimatedSize(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          child: _showManualInput
              ? _buildManualCoordsPanel()
              : const SizedBox.shrink(),
        ),

        // ── Carte Google Maps ───────────────────────────────────────────────
        Expanded(
          child: Stack(
            children: [
              GoogleMap(
                onMapCreated: _onMapCreated,
                onTap: _onMapTap,
                initialCameraPosition: CameraPosition(
                  target: _pickedLocation ?? _defaultPosition,
                  zoom: _pickedLocation != null ? 15 : 10,
                ),
                markers: _markers,
                mapType: MapType.normal,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: true,
                compassEnabled: true,
              ),
              // Indicateur de géocodage
              if (_geocoding)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _FormColors.sage,
                      ),
                    ),
                  ),
                ),
              // Tip initial
              if (!hasCoords)
                Positioned(
                  bottom: 12,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 11),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: const Border.fromBorderSide(
                          BorderSide(color: _FormColors.border)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(children: [
                      const Icon(Icons.touch_app_outlined,
                          color: _FormColors.sage, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                                fontSize: 12,
                                color: _FormColors.textBody),
                            children: const [
                              TextSpan(
                                  text:
                                      'Appuyez sur la carte pour positionner le marqueur  '),
                              TextSpan(
                                text: '·  ou utilisez "GPS manuel" si la carte ne se charge pas',
                                style: TextStyle(
                                    color: _FormColors.accent,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
            ],
          ),
        ),

        // ── Bandeau coordonnées ──────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: hasCoords
                ? _FormColors.sageLight
                : const Color(0xFFFFF8F0),
            border: Border(
              top: BorderSide(
                color: hasCoords
                    ? _FormColors.border
                    : _FormColors.accent.withOpacity(0.3),
              ),
            ),
          ),
          child: Row(children: [
            // Indicateur état
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: hasCoords ? _FormColors.sage : _FormColors.accent,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              hasCoords ? 'Coordonnées enregistrées' : 'Aucune position sélectionnée',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: hasCoords ? _FormColors.sage : _FormColors.accent,
              ),
            ),
            const SizedBox(width: 16),
            // Lat chip
            _coordChip('Lat', _pickedLocation?.latitude.toStringAsFixed(6)),
            const SizedBox(width: 10),
            // Lng chip
            _coordChip('Lng', _pickedLocation?.longitude.toStringAsFixed(6)),
            if (_resolvedAddress != null) ...[
              const SizedBox(width: 10),
              Expanded(
                child: _coordChip(
                  'Adresse',
                  _resolvedAddress,
                  icon: Icons.location_on_outlined,
                ),
              ),
            ],
          ]),
        ),
      ],
    );
  }

  // ── Panneau saisie manuelle ───────────────────────────────────────────────

  Widget _buildManualCoordsPanel() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: BoxDecoration(
        color: _FormColors.accentLight,
        border: Border(
          bottom: BorderSide(color: _FormColors.accent.withOpacity(0.25)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre
          Row(children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _FormColors.accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.edit_location_alt_outlined,
                  size: 15, color: _FormColors.accent),
            ),
            const SizedBox(width: 10),
            const Text(
              'Saisie manuelle des coordonnées GPS',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _FormColors.accent,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _FormColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Fallback si la carte ne charge pas',
                style: TextStyle(
                    fontSize: 10,
                    color: _FormColors.accent,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ]),

          const SizedBox(height: 12),

          // Champs + bouton
          Row(children: [
            // Latitude
            Expanded(child: _coordInputField(
              controller: _latCtrl,
              label: 'Latitude',
              hint: 'Ex : 36.806500',
              icon: Icons.swap_vert_rounded,
            )),
            const SizedBox(width: 10),
            // Longitude
            Expanded(child: _coordInputField(
              controller: _lngCtrl,
              label: 'Longitude',
              hint: 'Ex : 10.181500',
              icon: Icons.swap_horiz_rounded,
            )),
            const SizedBox(width: 10),
            // Bouton valider
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('  ', style: TextStyle(fontSize: 11)),
                const SizedBox(height: 2),
                ElevatedButton.icon(
                  onPressed: _applyManualCoords,
                  icon: const Icon(Icons.check_rounded, size: 15),
                  label: const Text('Valider et centrer',
                      style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _FormColors.accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 11),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ]),

          // Message erreur
          if (_manualError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(children: [
                const Icon(Icons.error_outline_rounded,
                    size: 14, color: _FormColors.danger),
                const SizedBox(width: 6),
                Text(
                  _manualError!,
                  style: const TextStyle(
                      fontSize: 12,
                      color: _FormColors.danger,
                      fontWeight: FontWeight.w500),
                ),
              ]),
            ),

          // Info aide
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: _FormColors.accent.withOpacity(0.2)),
            ),
            child: Row(children: [
              const Icon(Icons.info_outline_rounded,
                  size: 13, color: _FormColors.textMuted),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                        fontSize: 11.5, color: _FormColors.textMuted),
                    children: const [
                      TextSpan(
                          text:
                              'Obtenez les coordonnées depuis '),
                      TextSpan(
                          text: 'Google Maps',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: _FormColors.accent)),
                      TextSpan(
                          text:
                              ' → clic droit sur le lieu → "Qu\'y a-t-il ici ?" — '
                              'Copiez les valeurs décimales (ex : 36.8065, 10.1815).'),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _coordInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _FormColors.textMuted),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(
              decimal: true, signed: true),
          style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              fontFamily: 'monospace'),
          onChanged: (_) => setState(() => _manualError = null),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
                color: _FormColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.normal),
            prefixIcon: Icon(icon, size: 15, color: _FormColors.sageMid),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 10),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _FormColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _FormColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                  color: _FormColors.accent, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: _FormColors.danger),
            ),
          ),
        ),
      ],
    );
  }

  Widget _mapButton(
    String label,
    Color color, {
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 15),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _coordChip(String label, String? value, {IconData? icon}) {
    final hasVal = value != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: hasVal ? _FormColors.border : _FormColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: _FormColors.sage),
            const SizedBox(width: 4),
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                    fontSize: 9,
                    color: _FormColors.sage,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .1),
              ),
              Text(
                value ?? '—',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: hasVal
                      ? const Color(0xFF2D3748)
                      : _FormColors.textMuted,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // PAGE 2 — Horaires
  // ═══════════════════════════════════════════════════════════════════════

  Widget _pageHoraires() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: _sectionCard('Horaires d\'ouverture', [
        ...List.generate(_jours.length, (i) {
          final j = _jours[i];
          final h = _horaires[j]!;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    j[0].toUpperCase() + j.substring(1),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _FormColors.textBody,
                    ),
                  ),
                ),
                Switch(
                  value: h['ouvert'] as bool,
                  onChanged: (v) => setState(() => h['ouvert'] = v),
                  activeThumbColor: _FormColors.sage,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AnimatedOpacity(
                    opacity: h['ouvert'] == true ? 1 : .35,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _FormColors.slateLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child:
                          h['ouvert'] == true
                              ? Row(
                                children: [
                                  _timeField(h, 'debut'),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Text(
                                      'à',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  _timeField(h, 'fin'),
                                ],
                              )
                              : const Text(
                                'Fermé',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _FormColors.textMuted,
                                ),
                              ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ]),
    );
  }

  Widget _timeField(Map<String, dynamic> h, String key) {
    return SizedBox(
      width: 70,
      child: TextFormField(
        initialValue: h[key] as String? ?? '',
        onChanged: (v) => h[key] = v,
        style: const TextStyle(fontSize: 13,color: Colors.black87, fontWeight: FontWeight.w600, fontFamily: 'monospace'),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 6,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: _FormColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: _FormColors.sage, width: 1.5),
          ),
          hintText: key == 'debut' ? '08:00' : '18:00',
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // PAGE 3 — Paramètres
  // ═══════════════════════════════════════════════════════════════════════

  Widget _pageParametres() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionCard('Configuration', [
            _toggleTile(
              'Garage vérifié',
              'Badge visible sur l\'annuaire client',
              _estVerifie,
              Icons.verified_outlined,
              (v) => setState(() => _estVerifie = v),
            ),
            const SizedBox(height: 8),
            _toggleTile(
              'Garage actif (visible dans l\'annuaire)',
              'Si désactivé, le garage est masqué mais conservé',
              _estActif,
              Icons.visibility_outlined,
              (v) => setState(() => _estActif = v),
            ),
            const SizedBox(height: 8),
            _toggleTile(
              'Accepte les rendez-vous en ligne',
              'Permet aux clients de réserver via l\'app',
              _accepteRdv,
              Icons.calendar_today_outlined,
              (v) => setState(() => _accepteRdv = v),
            ),
          ]),
          const SizedBox(height: 16),
          _sectionCard('Délai de confirmation', [
            Text(
              'Délai maximum avant confirmation du rendez-vous : $_delai heure(s)',
              style: const TextStyle(fontSize: 13, color: _FormColors.textBody),
            ),
            const SizedBox(height: 10),
            Slider(
              value: _delai.toDouble(),
              min: 1,
              max: 72,
              divisions: 71,
              activeColor: _FormColors.sage,
              inactiveColor: _FormColors.sageLight,
              label: '$_delai h',
              onChanged: (v) => setState(() => _delai = v.round()),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  '1h',
                  style: TextStyle(fontSize: 11, color: _FormColors.textMuted),
                ),
                Text(
                  '72h',
                  style: TextStyle(fontSize: 11, color: _FormColors.textMuted),
                ),
              ],
            ),
          ]),
        ],
      ),
    );
  }

  Widget _toggleTile(
    String title,
    String subtitle,
    bool value,
    IconData icon,
    ValueChanged<bool> onChanged,
  ) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _FormColors.slateLight,
          borderRadius: BorderRadius.circular(10),
          border:
              value
                  ? const Border.fromBorderSide(
                    BorderSide(color: _FormColors.sageLight, width: 1.5),
                  )
                  : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: value ? _FormColors.sage : _FormColors.textMuted,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: _FormColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: _FormColors.sage,
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // WIDGETS UTILITAIRES
  // ═══════════════════════════════════════════════════════════════════════

  Widget _sectionCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: const Border.fromBorderSide(
          BorderSide(color: _FormColors.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: .08,
                  color: _FormColors.sage,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(height: 1, color: _FormColors.sageLight),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label, {
    bool required = false,
    String? hint,
    bool enabled = true,
    bool mono = false,
    IconData? icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      enabled: enabled,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 14, color: Colors.black87, fontFamily: mono ? 'monospace' : null),
      validator:
          validator ??
          (required
              ? (v) => (v == null || v.trim().isEmpty) ? 'Champ requis' : null
              : null),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(fontSize: 12, color: _FormColors.textMuted),
        prefixIcon:
            icon != null
                ? Icon(icon, size: 16, color: _FormColors.sageMid)
                : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _FormColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _FormColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _FormColors.sage, width: 1.5),
        ),
        filled: true,
        fillColor: enabled ? _FormColors.slateLight : Colors.grey.shade100,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
    );
  }

  Widget _fieldMulti(
    TextEditingController ctrl,
    String label,
    int lines, {
    String? hint,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: lines,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        alignLabelWithHint: true,
        labelStyle: const TextStyle(fontSize: 12, color: _FormColors.textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _FormColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _FormColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _FormColors.sage, width: 1.5),
        ),
        filled: true,
        fillColor: _FormColors.slateLight,
        isDense: true,
        contentPadding: const EdgeInsets.all(12),
      ),
    );
  }

  Widget _row2(Widget a, Widget b) => Row(
    children: [
      Expanded(child: a),
      const SizedBox(width: 12),
      Expanded(child: b),
    ],
  );

  Widget _row3(Widget a, Widget b, Widget c) => Row(
    children: [
      Expanded(child: a),
      const SizedBox(width: 10),
      Expanded(child: b),
      const SizedBox(width: 10),
      Expanded(child: c),
    ],
  );
}