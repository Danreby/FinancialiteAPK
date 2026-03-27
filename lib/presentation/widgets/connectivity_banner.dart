import 'package:flutter/material.dart';

class ConnectivityBanner extends StatelessWidget {
  final bool isOnline;
  const ConnectivityBanner({super.key, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    if (isOnline) return const SizedBox.shrink();
    return MaterialBanner(
      content: const Row(
        children: [
          Icon(Icons.wifi_off, size: 18),
          SizedBox(width: 8),
          Text('Sem conexão. Dados podem estar desatualizados.'),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.errorContainer,
      actions: const [SizedBox.shrink()],
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}
