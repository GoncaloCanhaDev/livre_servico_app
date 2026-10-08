import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/info_contacts.dart';
import '../../theme.dart';

/// [text] with every Portuguese phone number in it (see `splitPhones`)
/// underlined and tappable to call.
class PhoneLinkedText extends StatefulWidget {
  const PhoneLinkedText(this.text, {super.key, this.style});

  final String text;
  final TextStyle? style;

  @override
  State<PhoneLinkedText> createState() => _PhoneLinkedTextState();
}

class _PhoneLinkedTextState extends State<PhoneLinkedText> {
  final _recognizers = <TapGestureRecognizer>[];

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _disposeRecognizers() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
  }

  /// A recognizer that calls [phone], disposed with this widget.
  TapGestureRecognizer _callOnTap(String phone) {
    final r = TapGestureRecognizer()
      ..onTap = () => launchUrl(Uri(scheme: 'tel', path: phone));
    _recognizers.add(r);
    return r;
  }

  @override
  Widget build(BuildContext context) {
    _disposeRecognizers();
    return Text.rich(
      TextSpan(
        style: widget.style,
        children: [
          for (final part in splitPhones(widget.text))
            if (part.phone)
              TextSpan(
                text: part.text,
                style: TextStyle(
                  color: context.colors.secondary,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
                recognizer: _callOnTap(part.text),
              )
            else
              TextSpan(text: part.text),
        ],
      ),
    );
  }
}
