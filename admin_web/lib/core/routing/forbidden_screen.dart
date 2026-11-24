import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_admin/features/auth/presentation/providers/auth_controller.dart';
import 'package:aqd_admin/features/auth/presentation/widgets/access_denied_card.dart';

/// The 403 page: signed in, but not an admin (or the role was withdrawn).
class ForbiddenScreen extends ConsumerWidget {
  const ForbiddenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: AccessDeniedCard(onBack: () => ref.read(authControllerProvider.notifier).logout()),
          ),
        ),
      ),
    );
  }
}
