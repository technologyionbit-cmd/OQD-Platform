import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/core/localization/generated/app_localizations.dart';
import 'package:aqd_ionbit/core/providers/core_providers.dart';
import 'package:aqd_ionbit/core/routing/route_paths.dart';
import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_radii.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';
import 'package:aqd_ionbit/core/utils/validators.dart';
import 'package:aqd_ionbit/core/widgets/app_button.dart';
import 'package:aqd_ionbit/core/widgets/app_text_field.dart';
import 'package:aqd_ionbit/core/widgets/icon_badge.dart';
import 'package:aqd_ionbit/features/auth/presentation/providers/auth_controller.dart';

/// Demo accounts mirrored from AuthMockDataSource — kept here only for the
/// dev-only quick-fill card below, never referenced by production logic.
const _devPassword = 'Password123';
const _devAccounts = [('client@aqd.test', 'عميل'), ('lawyer@aqd.test', 'محامٍ'), ('company@aqd.test', 'شركة')];

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;
  String? _formError;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _fillDemoAccount(String email) {
    _emailController.text = email;
    _passwordController.text = _devPassword;
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;

    final emailError = !Validators.isRequired(_emailController.text)
        ? l10n.validationRequired
        : !Validators.isValidEmail(_emailController.text)
        ? l10n.validationInvalidEmail
        : null;
    final passwordError = !Validators.isRequired(_passwordController.text) ? l10n.validationRequired : null;

    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
      _formError = null;
    });
    if (emailError != null || passwordError != null) return;

    setState(() => _isSubmitting = true);
    final result = await ref
        .read(authControllerProvider.notifier)
        .login(email: _emailController.text.trim(), password: _passwordController.text);
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.fold((failure) => setState(() => _formError = _messageFor(failure, l10n)), (_) {
      // Navigation is driven by the router's redirect reacting to
      // authControllerProvider — this screen doesn't navigate itself.
    });
  }

  String _messageFor(Failure failure, AppLocalizations l10n) {
    return switch (failure) {
      UnauthorizedFailure() => l10n.errorInvalidCredentials,
      NetworkFailure() => l10n.errorNetwork,
      TimeoutFailure() => l10n.errorTimeout,
      ServerFailure() => l10n.errorServer,
      _ => l10n.errorGeneric,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isProduction = ref.watch(envConfigProvider).isProduction;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: IconBadge(icon: Icons.gavel_rounded, backgroundColor: AppColors.navy, iconColor: Colors.white)),
                  const SizedBox(height: AppSpacing.lg),
                  Text(l10n.authLoginTitle, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    l10n.authLoginSubtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (!isProduction) ...[_DevCredentialsCard(l10n: l10n, onSelect: _fillDemoAccount), const SizedBox(height: AppSpacing.lg)],
                  AppTextField(
                    controller: _emailController,
                    label: l10n.authEmailOrPhoneLabel,
                    errorText: _emailError,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: _passwordController,
                    label: l10n.authPasswordLabel,
                    errorText: _passwordError,
                    obscureText: true,
                    autofillHints: const [AutofillHints.password],
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(
                      onPressed: () => context.push(RoutePaths.forgotPassword),
                      child: Text(l10n.authForgotPassword),
                    ),
                  ),
                  if (_formError != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(_formError!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  AppButton(label: l10n.authLoginSubmit, isLoading: _isSubmitting, onPressed: _submit),
                  const SizedBox(height: AppSpacing.lg),
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        Text(l10n.authNoAccount, style: Theme.of(context).textTheme.bodyMedium),
                        TextButton(
                          onPressed: () => context.push(RoutePaths.register),
                          child: Text(l10n.authCreateAccount),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DevCredentialsCard extends StatelessWidget {
  const _DevCredentialsCard({required this.l10n, required this.onSelect});

  final AppLocalizations l10n;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: AppRadii.mdRadius,
        // BorderDirectional, not Border: the accent stripe belongs on the
        // leading edge (right in RTL, left in LTR), not a hardcoded side.
        border: const BorderDirectional(start: BorderSide(color: AppColors.secondary, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.devCredentialsTitle, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
          const SizedBox(height: AppSpacing.xxs),
          Text(l10n.devCredentialsPassword(_devPassword), style: const TextStyle(fontSize: 12)),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: _devAccounts
                .map(
                  (account) => ActionChip(
                    label: Text('${account.$2} — ${account.$1}', style: const TextStyle(fontSize: 11)),
                    onPressed: () => onSelect(account.$1),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
