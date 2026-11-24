import 'package:flutter/material.dart';

/// A titled card of label/value rows, used on detail screens.
class InfoCard extends StatelessWidget {
  const InfoCard({required this.title, required this.children, super.key});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// One `label ........ value` row. [value] can be text or any widget.
class InfoRow extends StatelessWidget {
  const InfoRow({required this.label, super.key, this.text, this.child});

  final String label;
  final String? text;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
          Expanded(child: child ?? SelectableText(text ?? '-')),
        ],
      ),
    );
  }
}
