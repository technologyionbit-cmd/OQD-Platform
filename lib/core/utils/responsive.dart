import 'package:flutter/widgets.dart';

/// Screen-width breakpoints. The screenshots are a visual reference, not a
/// device spec — layouts must be built with these, `LayoutBuilder`,
/// `Flexible`/`Expanded` and constraints, never a hardcoded width/height.
enum ScreenSize { small, standard, large }

class ResponsiveBreakpoints {
  const ResponsiveBreakpoints._();

  /// e.g. iPhone SE / small Android phones.
  static const smallMax = 360.0;

  /// e.g. iPhone 14/15/16, mid-size Android phones.
  static const standardMax = 430.0;

  // Above standardMax is treated as a large phone / phablet.
}

extension ResponsiveContextX on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);

  ScreenSize get responsiveSize {
    final width = screenSize.width;
    if (width <= ResponsiveBreakpoints.smallMax) return ScreenSize.small;
    if (width <= ResponsiveBreakpoints.standardMax) return ScreenSize.standard;
    return ScreenSize.large;
  }

  bool get isSmallPhone => responsiveSize == ScreenSize.small;
  bool get isLargePhone => responsiveSize == ScreenSize.large;

  EdgeInsets get safeAreaPadding => MediaQuery.paddingOf(this);
}

/// Picks a value based on the current [ScreenSize], falling back to
/// [standard] when a size-specific value isn't provided. Prefer this over
/// scattering `MediaQuery` breakpoint checks across every screen.
T responsiveValue<T>(BuildContext context, {required T standard, T? small, T? large}) {
  switch (context.responsiveSize) {
    case ScreenSize.small:
      return small ?? standard;
    case ScreenSize.large:
      return large ?? standard;
    case ScreenSize.standard:
      return standard;
  }
}
