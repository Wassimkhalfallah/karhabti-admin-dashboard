import 'package:flutter/material.dart';
import '../garages_pro/garage_form_screen.dart';

class ResponsableGarageSetupScreen extends StatelessWidget {
  const ResponsableGarageSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuration du garage')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Première connexion: créez votre garage pour continuer.'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                await showDialog(context: context, builder: (_) => const GarageFormScreen());
              },
              child: const Text('Créer mon garage'),
            ),
          ],
        ),
      ),
    );
  }
}
