// ignore: avoid_web_libraries_in_flutter
import 'dart:js_util' as js_util;

/// On web: opens the Cast device picker so the user can select a device and connect.
void tryOpenCastPicker() {
  try {
    js_util.callMethod(js_util.globalThis, 'openCastPicker', []);
  } catch (_) {}
}
