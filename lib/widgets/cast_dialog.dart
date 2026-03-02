import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'cast_platform_stub.dart' if (dart.library.io) 'cast_platform_io.dart' as cast_platform;

const _castChannel = MethodChannel('com.tambolacaller.tambola_caller/cast');

/// When user taps the cast button: on web shows instructions (Chrome menu → Cast), on Android opens cast settings, else shows instructions.
Future<void> performCastAction(BuildContext context) async {
  if (kIsWeb) {
    await showCastDialog(context);
    return;
  }
  if (cast_platform.isAndroid) {
    await openCastSettings();
    return;
  }
  await showCastDialog(context);
}

/// Opens the system cast/screen mirror settings so the user can detect devices and connect.
/// On Android: opens Cast or Wireless settings. On iOS/Web: returns false.
Future<bool> openCastSettings() async {
  if (!cast_platform.isAndroid) return false;
  try {
    final ok = await _castChannel.invokeMethod<bool>('openCastSettings');
    return ok == true;
  } on PlatformException {
    return false;
  }
}

/// Shows a dialog to cast/mirror the app to a TV. On Android, offers a button to open cast settings.
/// Returns a Future that completes when the dialog is closed.
Future<void> showCastDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (ctx) {
      final isAndroid = cast_platform.isAndroid;
      return AlertDialog(
        icon: Icon(Icons.cast_connected, size: 48, color: Theme.of(ctx).colorScheme.primary),
        title: const Text('Cast to TV'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isAndroid)
                const Text(
                  'Open cast settings to detect nearby devices (Chromecast, Smart TV, etc.) and connect to mirror this screen.',
                  style: TextStyle(fontWeight: FontWeight.w500),
                )
              else
                const Text(
                  'To cast or mirror this app to your TV, use your device\'s built-in casting:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              if (!isAndroid) ...[
                const SizedBox(height: 12),
                const Text('• Chrome (this browser): Use the Cast icon in the browser toolbar (⋮ → Cast).'),
                const SizedBox(height: 6),
                const Text('• iPhone / iPad: Swipe down → Screen Mirroring → choose your TV'),
                const SizedBox(height: 4),
                const Text('• Windows: Settings → System → Projecting to this PC'),
              ],
              const SizedBox(height: 16),
              const Text(
                'This screen is designed with large numbers and a clean layout so it looks great on the big screen!',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          if (isAndroid)
            TextButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                await openCastSettings();
              },
              child: const Text('Open cast settings'),
            ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(isAndroid ? 'Cancel' : 'Got it'),
          ),
        ],
      );
    },
  );
}
