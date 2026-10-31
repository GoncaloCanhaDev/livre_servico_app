import 'package:flutter/material.dart';

import '../services/account_service.dart';
import '../services/demo_mode.dart';
import '../theme.dart';
import 'account_screen.dart';
import 'privacy_policy_screen.dart';

/// The website's first page for a visitor who isn't signed in: what the app
/// does, the demo, and the way in (Criar conta / Entrar open Conta, closed
/// again once signed in, when the first page changes underneath).
class PresentationScreen extends StatefulWidget {
  const PresentationScreen({super.key});

  @override
  State<PresentationScreen> createState() => _PresentationScreenState();
}

class _PresentationScreenState extends State<PresentationScreen> {
  final _auth = AccountService.instance;

  @override
  void initState() {
    super.initState();
    _auth.addListener(_signedIn);
  }

  @override
  void dispose() {
    _auth.removeListener(_signedIn);
    super.dispose();
  }

  void _signedIn() {
    if (_auth.isSignedIn && mounted) {
      Navigator.of(context).popUntil((r) => r.isFirst);
    }
  }

  static const _features = [
    (
      Icons.checklist,
      'Tarefas diárias e semanais',
      'Quem fez o quê e quando, dia a dia, sem papéis perdidos.',
    ),
    (
      Icons.playlist_add_check,
      'Listas de Abertura e Automáticas',
      'Congelados, OPLS e Não Perecíveis enviados por secção.',
    ),
    (
      Icons.local_shipping,
      'Receção de camiões e vasilhame',
      'Paletes por departamento, expositores e o vasilhame a enviar.',
    ),
    (
      Icons.inventory_2,
      'Inventários e pedidos',
      'O valor de cada inventário e os pedidos por chegar.',
    ),
    (
      Icons.groups,
      'Pessoas e equipas',
      'Quem trabalha hoje, folgas, ausências e aniversários.',
    ),
    (
      Icons.campaign_outlined,
      'Avisos à equipa',
      'Uma mensagem para a equipa ou para uma pessoa, com "Visto".',
    ),
    (
      Icons.cloud_sync,
      'No telemóvel e no computador',
      'Funciona sem rede no telemóvel e sincroniza com a equipa.',
    ),
  ];

  static const _steps = [
    'Crie a sua conta com o seu email.',
    'Peça o código da loja à chefia e diga quem é na lista.',
    'Quando for aprovado, a loja abre sozinha.',
  ];

  void _account(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const AccountScreen()),
  );

  Widget _buttons(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      FilledButton.icon(
        icon: const Icon(Icons.play_arrow),
        label: const Text('Experimentar a demo'),
        onPressed: DemoMode.enter,
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _account(context),
              child: const Text('Criar conta'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              onPressed: () => _account(context),
              child: const Text('Entrar'),
            ),
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
              children: [
                Icon(Icons.storefront, size: 48, color: colors.primary),
                const SizedBox(height: 12),
                const Text(
                  'Livre Serviço Companion',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  'O dia a dia das equipas da loja num só sítio: listas, '
                  'tarefas, receções e pessoas.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: context.muted),
                ),
                const SizedBox(height: 24),
                _buttons(context),
                const SizedBox(height: 8),
                Text(
                  'A demonstração usa uma loja de exemplo e não guarda nada.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: context.muted),
                ),
                const SizedBox(height: 28),
                for (final (icon, title, text) in _features)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: colors.primaryContainer,
                      foregroundColor: colors.onPrimaryContainer,
                      child: Icon(icon),
                    ),
                    title: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(text),
                  ),
                const SizedBox(height: 24),
                const Text(
                  'Como começar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                for (final (i, step) in _steps.indexed)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(radius: 14, child: Text('${i + 1}')),
                    title: Text(step),
                  ),
                const SizedBox(height: 24),
                _buttons(context),
                const SizedBox(height: 32),
                Text(
                  'Aplicação independente, não oficial do Pingo Doce nem da '
                  'Jerónimo Martins.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: context.muted),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PrivacyPolicyScreen(),
                    ),
                  ),
                  child: const Text('Política de Privacidade'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
