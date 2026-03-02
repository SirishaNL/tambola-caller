import 'package:flutter/material.dart';

/// Placeholder on non-web; on web, use cast_button_web.dart which embeds the real Cast launcher.
class CastButtonWeb extends StatelessWidget {
  const CastButtonWeb({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox(width: 48, height: 48);
}
