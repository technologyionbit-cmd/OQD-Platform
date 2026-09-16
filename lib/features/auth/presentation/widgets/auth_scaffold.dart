import 'package:flutter/material.dart';

import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/features/auth/presentation/widgets/auth_header.dart';

/// Shared chrome for the secondary auth screens (register, forgot
/// password, OTP, reset): the navy [AuthHeader] hero followed by a
/// scrollable, width-capped content column. Screens only supply the header
/// text/icon and their form body.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
    this.showBackButton = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthHeader(icon: icon, title: title, subtitle: subtitle, showBackButton: showBackButton),
            Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
