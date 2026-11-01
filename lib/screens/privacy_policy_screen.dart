import 'package:flutter/material.dart';

import '../models/privacy_policy.dart';
import '../theme.dart';
import 'widgets/wide_layout.dart';

/// The Política de Privacidade. With [accept] (creating an account), "Li e
/// aceito" at the end of the text pops with true; leaving pops with nothing.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key, this.accept = false});

  final bool accept;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Política de Privacidade')),
    body: ReadableWidth(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Versão de $privacyPolicyVersion',
              style: TextStyle(color: context.muted),
            ),
            for (final s in privacyPolicy) ...[
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 6),
                child: Text(
                  s.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              for (final p in s.paragraphs)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(p, style: const TextStyle(height: 1.4)),
                ),
            ],
            if (accept) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Li e aceito'),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
