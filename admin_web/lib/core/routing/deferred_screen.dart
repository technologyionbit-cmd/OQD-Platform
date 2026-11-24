import 'package:flutter/material.dart';

import 'package:aqd_admin/core/widgets/state_views.dart';

/// Loads a `deferred as` library the first time its route is opened, so the
/// initial download holds only the shell and sign-in, not every module.
class DeferredScreen extends StatefulWidget {
  const DeferredScreen({required this.loadLibrary, required this.builder, super.key});

  final Future<void> Function() loadLibrary;
  final WidgetBuilder builder;

  @override
  State<DeferredScreen> createState() => _DeferredScreenState();
}

class _DeferredScreenState extends State<DeferredScreen> {
  late Future<void> _loading = widget.loadLibrary();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loading,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ErrorView(
            error: snapshot.error!,
            onRetry: () => setState(() => _loading = widget.loadLibrary()),
          );
        }
        if (snapshot.connectionState != ConnectionState.done) return const LoadingView();
        return widget.builder(context);
      },
    );
  }
}
