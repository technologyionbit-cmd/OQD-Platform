import 'package:flutter/material.dart';

import 'package:aqd_ionbit/core/theme/app_gradients.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/widgets/icon_badge.dart';

/// The navy greeting hero atop each role's home/dashboard tab — visually
/// shared chrome (same treatment as [AuthHeader]'s gradient), content
/// differs per role via [greeting]/[icon]. Deliberately just a greeting: a
/// notification bell or search bar here would be a fake control until
/// those features exist.
class HomeGreetingHeader extends StatelessWidget {
  const HomeGreetingHeader({super.key, required this.greeting, required this.icon});

  final String greeting;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: AppGradients.navyHeader),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  greeting,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              IconBadge(icon: icon, backgroundColor: Colors.white.withValues(alpha: 0.12), iconColor: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
