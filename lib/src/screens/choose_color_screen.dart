import 'package:flutter/material.dart';
import '../routes.dart';

enum PlayerColor { white, black, random }

class ChooseColorScreen extends StatefulWidget {
  const ChooseColorScreen({super.key});

  @override
  State<ChooseColorScreen> createState() => _ChooseColorScreenState();
}

class _ChooseColorScreenState extends State<ChooseColorScreen> {
  PlayerColor _choice = PlayerColor.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Elige color')),
      body: ListView(
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: () {
                final color = _choice == PlayerColor.random
                    ? (DateTime.now().millisecond.isEven ? PlayerColor.white : PlayerColor.black)
                    : _choice;
                Navigator.pushNamed(
                  context,
                  AppRoutes.game,
                  arguments: {'playerColor': color},
                );
              },
              child: const Text('Comenzar'),
            ),
          ),
        ],
      ),
    );
  }
}