import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aqd_admin/features/auth/presentation/providers/auth_controller.dart';

/// May the signed-in admin change things in [module] (not just view)?
/// Screens use it to hide buttons the server would refuse anyway.
bool canManage(WidgetRef ref, String module) => ref.watch(authControllerProvider).value?.can(module, manage: true) ?? false;
