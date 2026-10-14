import 'dart:ui' show Rect;

import 'tray_menu.dart';

sealed class TrayEvent {
  const TrayEvent();
}

final class TrayIconActivated extends TrayEvent {
  const TrayIconActivated({this.anchor});

  /// The icon's screen frame, top-left origin on the primary screen, where the
  /// platform reports one (macOS).
  final Rect? anchor;
}

final class TrayMenuRequested extends TrayEvent {
  const TrayMenuRequested();
}

final class TrayMenuItemSelected extends TrayEvent {
  const TrayMenuItemSelected(this.item);

  final TrayMenuItem item;
}
