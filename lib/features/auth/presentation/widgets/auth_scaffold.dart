import 'package:flutter/material.dart';

import 'package:aqd_ionbit/core/theme/app_gradients.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/features/auth/presentation/widgets/auth_header.dart';

/// Shared chrome for every auth screen: a navy gradient hero ([AuthHeader])
/// whose bottom edge is a rounded "sheet" lip, with the form continuing
/// below on the normal page background. Everything scrolls together, so a
/// long form or a large font never overflows. Screens only supply the
/// header content and their form body.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    this.icon,
    this.showLogo = false,
    required this.title,
    required this.subtitle,
    required this.child,
    this.showBackButton = true,
    this.headerTrailing,
  });

  final IconData? icon;
  final bool showLogo;
  final String title;
  final String subtitle;
  final Widget child;
  final bool showBackButton;
  final Widget? headerTrailing;

  static const _lipHeight = 28.0;

  @override
  Widget build(BuildContext context) {
    final pageColor = Theme.of(context).scaffoldBackgroundColor;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(
                gradient: AppGradients.navyHeader,
              ),
              child: Column(
                children: [
                  AuthHeader(
                    icon: icon,
                    showLogo: showLogo,
                    title: title,
                    subtitle: subtitle,
                    showBackButton: showBackButton,
                    trailing: headerTrailing,
                  ),
                  // The page colour rises into the gradient with rounded
                  // top corners, which reads as a sheet sliding over it.
                  Container(
                    height: _lipHeight,
                    decoration: BoxDecoration(
                      color: pageColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(_lipHeight),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.xs,
                    AppSpacing.xl,
                    AppSpacing.xl,
                  ),
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
