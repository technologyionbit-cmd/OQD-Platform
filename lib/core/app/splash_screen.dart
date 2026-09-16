import 'package:flutter/material.dart';

import 'package:aqd_ionbit/core/widgets/loading_view.dart';

/// Shown while [AuthController] resolves the stored session on cold start.
/// The router's redirect moves on from here automatically once that
/// resolves — this screen never navigates itself.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: LoadingView());
  }
}
