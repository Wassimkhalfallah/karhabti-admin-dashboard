import 'package:flutter/material.dart';
import '../../models/garage_pro_model.dart';
import '../../services/auth_service.dart';
import '../../services/responsable_technicien_service.dart';
import '../../theme/karhabti_tokens.dart';
import '../garages_pro/garage_form_screen.dart';

class ResponsableGarageSetupScreen extends StatelessWidget {
  const ResponsableGarageSetupScreen({super.key});

  Future<void> _createGarage(BuildContext context) async {
    final result = await showDialog<Object?>(
      context: context,
      builder: (_) => const GarageFormScreen(),
    );
    if (result is! GaragePro || !context.mounted) return;

    final userId = AuthService().currentUser?.id;
    if (userId == null) return;

    try {
      await ResponsableTechnicienService().assignerGarage(userId, result.id);
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/responsable');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Garage créé mais liaison impossible : $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KarhabtiTokens.bg,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [KarhabtiTokens.gold, Color(0xFFB8860B)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.store_rounded, size: 48, color: Color(0xFF1A1200)),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Configuration du garage',
                  style: TextStyle(
                    color: KarhabtiTokens.textPri,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Première connexion : créez votre garage pour accéder au tableau de bord responsable.',
                  style: TextStyle(color: KarhabtiTokens.textSec, fontSize: 14, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                ElevatedButton.icon(
                  onPressed: () => _createGarage(context),
                  icon: const Icon(Icons.add_business_rounded),
                  label: const Text('Créer mon garage'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KarhabtiTokens.gold,
                    foregroundColor: const Color(0xFF1A1200),
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
