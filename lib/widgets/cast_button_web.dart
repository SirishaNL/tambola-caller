// Only imported on web (see conditional import in screens).
import 'dart:html' as html;
import 'package:flutter/material.dart';

/// Embeds the real Google Cast launcher in the app bar so a user click opens the Cast device picker.
class CastButtonWeb extends StatelessWidget {
  const CastButtonWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: HtmlElementView.fromTagName(
        tagName: 'google-cast-launcher',
        onElementCreated: (Object element) {
          final el = element as html.Element;
          el.style.width = '48px';
          el.style.height = '48px';
        },
      ),
    );
  }
}
