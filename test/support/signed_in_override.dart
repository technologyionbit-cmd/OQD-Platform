import 'package:aqd_ionbit/features/auth/presentation/providers/current_user_id_provider.dart';

/// For tests that pump a screen or controller on its own, without the
/// auth flow: account data providers load only for a signed-in account
/// (see [currentUserIdProvider]), and this stands in for one — without
/// building the real auth controller and its session restore.
final signedInOverride = currentUserIdProvider.overrideWithValue('u_test');
