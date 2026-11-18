import 'package:flutter/material.dart';

/// The Aqd wordmark (calligraphic "عقد"). [onDark] picks the light version
/// for navy surfaces; otherwise it follows the theme brightness.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.width = 160, this.onDark});

  final double width;
  final bool? onDark;

  @override
  Widget build(BuildContext context) {
    final light = onDark ?? Theme.of(context).brightness == Brightness.dark;
    return Image.asset(
      light ? 'assets/images/logo_light.png' : 'assets/images/logo_dark.png',
      width: width,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      // The name is announced by the surrounding screen title, not the image.
      excludeFromSemantics: true,
    );
  }
}
