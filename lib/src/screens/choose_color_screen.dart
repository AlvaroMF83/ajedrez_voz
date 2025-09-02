import 'package:flutter/material.dart';
import 'package:ajedrez_voz/src/settings/settings_models.dart'; // PlayerColor aquí

class ChooseColorScreen extends StatefulWidget {
  const ChooseColorScreen({Key? key}) : super(key: key);

  @override
  State<ChooseColorScreen> createState() => _ChooseColorScreenState();
}

class _ChooseColorScreenState extends State<ChooseColorScreen> {
  PlayerColor _choice = PlayerColor.random;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Elige color')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<PlayerColor>(
              title: const Text('Blancas'),
              value: PlayerColor.white,
              groupValue: _choice,
              onChanged: (v) => setState(() => _choice = v!),
            ),
            RadioListTile<PlayerColor>(
              title: const Text('Negras'),
              value: PlayerColor.black,
              groupValue: _choice,
              onChanged: (v) => setState(() => _choice = v!),
            ),
            RadioListTile<PlayerColor>(
              title: const Text('Aleatorio'),
              value: PlayerColor.random,
              groupValue: _choice,
              onChanged: (v) => setState(() => _choice = v!),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  '/game',
                  arguments: {'playerColor': _choice},
                );
              },
              child: const Text('Continuar'),
            ),
          ],
        ),
      ),
    );
  }
}
