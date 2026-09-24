import 'package:flutter/material.dart';
import 'consulta_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('InverTexto'), centerTitle: true),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Ferramentas para o seu dia',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Escolha uma função para começar. As consultas precisam de internet.',
            ),
            const SizedBox(height: 24),
            for (final feature in Feature.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    leading: Icon(
                      feature.icon,
                      color: Theme.of(context).colorScheme.primary,
                      size: 30,
                    ),
                    title: Text(
                      feature.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(feature.description),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => ConsultaPage(feature: feature),
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            const Text(
              'Consultas via API Invertexto',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}
