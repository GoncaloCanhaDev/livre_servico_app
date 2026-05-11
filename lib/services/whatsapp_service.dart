import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppService {
  WhatsAppService._();

  /// Launches WhatsApp with the given [message] pre-filled.
  /// The user picks the destination (contact or group) themselves.
  static Future<bool> send(String message) async {
    final encoded = Uri.encodeComponent(message);

    // Try the intent-style URL first (works best on Android)
    final intentUri = Uri.parse(
        'intent://send?text=$encoded#Intent;package=com.whatsapp;scheme=whatsapp;end');
    try {
      final ok = await launchUrl(intentUri);
      if (ok) return true;
    } catch (_) {}

    // Fallback: HTTPS URL
    final httpsUri =
        Uri.parse('https://api.whatsapp.com/send?text=$encoded');
    try {
      final ok = await launchUrl(httpsUri,
          mode: LaunchMode.externalApplication);
      if (ok) return true;
    } catch (_) {}

    // Fallback: whatsapp:// scheme
    final waUri = Uri.parse('whatsapp://send?text=$encoded');
    try {
      final ok = await launchUrl(waUri,
          mode: LaunchMode.externalApplication);
      if (ok) return true;
    } catch (_) {}

    debugPrint('WhatsApp: all launch methods failed');
    return false;
  }

  /// Shows a confirmation dialog, then sends via WhatsApp if confirmed.
  static Future<void> sendWithConfirm(
    BuildContext context,
    String message,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Enviar por WhatsApp?'),
        content: Text(
          message,
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final sent = await send(message);
    if (!sent && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Não foi possível abrir o WhatsApp.')),
      );
    }
  }
}

