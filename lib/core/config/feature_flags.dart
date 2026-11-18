import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Features whose backend does not exist yet and run on made-up data (AI
/// chat and analysis, the document vault, the scripted lawyer replies in
/// chat). They are visible in debug/profile builds so development goes on,
/// and hidden in release builds so users never see invented results.
///
/// A release build can opt in for internal demos with
/// `--dart-define=SHOW_PREVIEW_FEATURES=true`. Remove each guarded entry
/// point as its real backend ships (docs/plans/roadmap.md 4.2, 5.1, 6.2).
class FeatureFlags {
  const FeatureFlags._();

  static const previewFeatures = !kReleaseMode || bool.fromEnvironment('SHOW_PREVIEW_FEATURES');
}

/// Overridable in tests to exercise the release (hidden) layout.
final previewFeaturesProvider = Provider<bool>((ref) => FeatureFlags.previewFeatures);
