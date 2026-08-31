import 'package:flutter/material.dart';

import 'package:aqd_ionbit/core/theme/app_colors.dart';

/// The numbered-circle progress bar used by the contract-creation wizard.
/// Steps are laid out in logical order (1..N) — under RTL this mirrors
/// automatically (step 1 lands on the right, matching the reference
/// screenshots) without any manual direction handling here.
class StepIndicator extends StatelessWidget {
  const StepIndicator({super.key, required this.stepCount, required this.currentStep});

  /// 1-based index of the active step.
  final int stepCount;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(stepCount, (index) {
        final stepNumber = index + 1;
        final isDone = stepNumber < currentStep;
        final isActive = stepNumber == currentStep;
        final isLast = stepNumber == stepCount;

        return Expanded(
          child: Row(
            children: [
              _StepCircle(number: stepNumber, isDone: isDone, isActive: isActive),
              if (!isLast) Expanded(child: Container(height: 2, color: isDone ? AppColors.primary : AppColors.border)),
            ],
          ),
        );
      }),
    );
  }
}

class _StepCircle extends StatelessWidget {
  const _StepCircle({required this.number, required this.isDone, required this.isActive});

  final int number;
  final bool isDone;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final filled = isDone || isActive;
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? AppColors.primary : AppColors.surfaceVariant,
      ),
      child: isDone
          ? const Icon(Icons.check, size: 16, color: AppColors.onPrimary)
          : Text(
              '$number',
              style: TextStyle(
                color: isActive ? AppColors.onPrimary : AppColors.textSecondary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
    );
  }
}
