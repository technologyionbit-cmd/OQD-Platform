import 'package:flutter/material.dart';

import 'package:aqd_ionbit/core/theme/app_colors.dart';
import 'package:aqd_ionbit/core/theme/app_radii.dart';
import 'package:aqd_ionbit/core/theme/app_spacing.dart';

/// The one modal-bottom-sheet chrome the app uses — rounded top corners +
/// drag handle + safe-area padding — so filter sheets, action sheets, and
/// pickers never each reinvent this shell.
Future<T?> showAppBottomSheet<T>(BuildContext context, {required WidgetBuilder builder, bool isScrollControlled = true}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadiusDirectional.vertical(top: Radius.circular(AppRadii.lg))),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(color: AppColors.border, borderRadius: AppRadii.smRadius),
                ),
              ),
              Builder(builder: builder),
            ],
          ),
        ),
      );
    },
  );
}
