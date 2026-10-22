import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app/theme.dart';

/// Rounded surface tile used across screens.
class Tile extends StatelessWidget {
  const Tile({
    super.key,
    required this.child,
    this.color = AppColors.surface,
    this.padding = const EdgeInsets.all(16),
    this.border,
    this.onTap,
  });

  final Widget child;
  final Color color;
  final EdgeInsets padding;
  final Color? border;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final box = Ink(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        border: border == null ? null : Border.all(color: border!),
      ),
      child: Padding(padding: padding, child: child),
    );
    return Material(
      color: Colors.transparent,
      child: onTap == null
          ? box
          : InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: onTap,
              child: box,
            ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10, top: 6),
        child: Row(children: [
          Expanded(
            child: Text(text,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ),
          ?trailing,
        ]),
      );
}

class Caption extends StatelessWidget {
  const Caption(this.text, {super.key, this.color = AppColors.textSecondary});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: TextStyle(fontSize: 12, color: color, height: 1.4));
}

/// Coloured status pill: "Verify · 7 mo old", "Cap full", …
class Pill extends StatelessWidget {
  const Pill(this.text, {super.key, required this.fg, required this.bg});
  final String text;
  final Color fg;
  final Color bg;

  factory Pill.attention(String t) =>
      Pill(t, fg: AppColors.attention, bg: AppColors.attentionContainer);
  factory Pill.earned(String t) =>
      Pill(t, fg: AppColors.earned, bg: AppColors.earnedContainer);
  factory Pill.danger(String t) =>
      Pill(t, fg: AppColors.dangerText, bg: AppColors.dangerContainer);
  factory Pill.accent(String t) => Pill(t,
      fg: AppColors.onPrimaryContainer, bg: AppColors.primaryContainer);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(8)),
        child: Text(text,
            style: TextStyle(
                color: fg, fontSize: 11, fontWeight: FontWeight.w800)),
      );
}

/// Horizontal progress bar with a track.
class Bar extends StatelessWidget {
  const Bar({super.key, required this.value, this.color = AppColors.primary});
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: value.clamp(0, 1),
          minHeight: 8,
          backgroundColor: AppColors.track,
          color: color,
        ),
      );
}

/// Circular progress ring with a centred label (fee waiver, milestones).
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.value,
    this.size = 56,
    this.stroke = 6,
    this.color = AppColors.attention,
  });

  final double value;
  final double size;
  final double stroke;
  final Color color;

  @override
  Widget build(BuildContext context) => Semantics(
        label: '${(value * 100).round()} percent',
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _RingPainter(value.clamp(0, 1), stroke, color),
            child: Center(
              child: Text('${(value * 100).round()}%',
                  style: TextStyle(
                      fontSize: size * 0.22, fontWeight: FontWeight.w800)),
            ),
          ),
        ),
      );
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.value, this.stroke, this.color);
  final double value;
  final double stroke;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final r = rect.deflate(stroke / 2);
    final track = Paint()
      ..color = AppColors.track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    final arc = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke;
    canvas
      ..drawArc(r, 0, math.pi * 2, false, track)
      ..drawArc(r, -math.pi / 2, math.pi * 2 * value, false, arc);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.color != color;
}

/// The Card Master mark: two fanned cards and a gold spark (Brand board).
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 72, this.cutout = AppColors.background});
  final double size;
  final Color cutout;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _MarkPainter(cutout)),
      );
}

class _MarkPainter extends CustomPainter {
  _MarkPainter(this.cutout);
  final Color cutout;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 120);
    void card(double x, double y, double deg, double cx, double cy, Color c,
        {bool stroke = false}) {
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(deg * math.pi / 180);
      canvas.translate(-cx, -cy);
      final rr = RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, 66, 44), const Radius.circular(9));
      canvas.drawRRect(rr, Paint()..color = c);
      if (stroke) {
        canvas.drawRRect(
            rr,
            Paint()
              ..color = cutout
              ..style = PaintingStyle.stroke
              ..strokeWidth = 4);
      }
      canvas.restore();
    }

    card(16, 30, -16, 49, 52, const Color(0xFF1C8C7A));
    card(34, 44, 6, 67, 66, const Color(0xFF7C6CF2), stroke: true);
    canvas.save();
    canvas.translate(67, 66);
    canvas.rotate(6 * math.pi / 180);
    canvas.translate(-67, -66);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(44, 56, 13, 10), const Radius.circular(2.5)),
        Paint()..color = AppColors.chipGold);
    canvas.restore();
    final spark = Path()
      ..moveTo(94, 8)
      ..lineTo(98.5, 22.5)
      ..lineTo(113, 27)
      ..lineTo(98.5, 31.5)
      ..lineTo(94, 46)
      ..lineTo(89.5, 31.5)
      ..lineTo(75, 27)
      ..lineTo(89.5, 22.5)
      ..close();
    canvas.drawPath(spark, Paint()..color = AppColors.spark);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Wordmark C (primary): "card ✦ master".
class Wordmark extends StatelessWidget {
  const Wordmark({super.key, this.fontSize = 14, this.color});
  final double fontSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontFamily: 'Unbounded',
      fontWeight: FontWeight.w700,
      fontSize: fontSize,
      letterSpacing: -0.3,
      color: color ?? AppColors.textSecondary,
    );
    return Semantics(
      label: 'Card Master',
      excludeSemantics: true,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text('card', style: style),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: fontSize * 0.35),
          child: Icon(Icons.auto_awesome,
              size: fontSize * 0.8, color: AppColors.spark),
        ),
        Text('master', style: style),
      ]),
    );
  }
}

/// Wordmark B (splash lockup): CARD over MASTER.
class StackedWordmark extends StatelessWidget {
  const StackedWordmark({super.key, this.scale = 1});
  final double scale;

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Card Master',
        excludeSemantics: true,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('CARD',
              style: TextStyle(
                  fontFamily: 'Unbounded',
                  fontWeight: FontWeight.w500,
                  fontSize: 14 * scale,
                  letterSpacing: 12 * scale,
                  color: AppColors.textSecondary)),
          SizedBox(height: 6 * scale),
          Text.rich(TextSpan(children: [
            TextSpan(
                text: 'MASTER',
                style: TextStyle(
                    fontFamily: 'Unbounded',
                    fontWeight: FontWeight.w800,
                    fontSize: 38 * scale,
                    letterSpacing: -1)),
            TextSpan(
                text: '.',
                style: TextStyle(
                    fontFamily: 'Unbounded',
                    fontWeight: FontWeight.w800,
                    fontSize: 38 * scale,
                    color: AppColors.spark)),
          ])),
        ]),
      );
}
