import 'package:flutter/material.dart';

import 'package:aqd_ionbit/core/theme/app_colors.dart';

/// A minimal freehand drawing surface — controlled by the parent (owns
/// [strokes], receives updates via [onStrokesChanged]) rather than holding
/// its own state, so the parent screen can clear/reuse the same stroke data
/// (e.g. render a read-only preview elsewhere) without reaching into this
/// widget's internals.
class SignaturePad extends StatelessWidget {
  const SignaturePad({super.key, required this.strokes, required this.onStrokesChanged, this.readOnly = false});

  final List<List<Offset>> strokes;
  final ValueChanged<List<List<Offset>>> onStrokesChanged;
  final bool readOnly;

  void _startStroke(DragStartDetails details) {
    onStrokesChanged([...strokes, [details.localPosition]]);
  }

  void _extendStroke(DragUpdateDetails details) {
    if (strokes.isEmpty) return;
    final updated = [...strokes];
    updated[updated.length - 1] = [...updated.last, details.localPosition];
    onStrokesChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final canvas = CustomPaint(painter: _SignaturePainter(strokes), child: const SizedBox.expand());
    if (readOnly) return canvas;
    return GestureDetector(onPanStart: _startStroke, onPanUpdate: _extendStroke, child: canvas);
  }
}

class _SignaturePainter extends CustomPainter {
  _SignaturePainter(this.strokes);

  final List<List<Offset>> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textPrimary
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final stroke in strokes) {
      for (var i = 0; i < stroke.length - 1; i++) {
        canvas.drawLine(stroke[i], stroke[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => oldDelegate.strokes != strokes;
}
