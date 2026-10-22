import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../data/catalog/catalog.dart';
import '../domain/models.dart';

/// Styled card face: physical-card details without any bank artwork
/// (docs/02-DESIGN.md §7). ISO ID-1 ratio 1.586.
class CardFace extends StatelessWidget {
  const CardFace({
    super.key,
    required this.card,
    required this.style,
    this.width,
    this.compact = false,
    this.photo,
  });

  /// Photo face (number already blurred). Shown instead of the styled face.

  final UserCard card;
  final CardFaceStyle style;
  final double? width;
  final bool compact;
  final Uint8List? photo;

  @override
  Widget build(BuildContext context) {
    if (photo != null) {
      return LayoutBuilder(builder: (context, c) {
        final w = width ?? c.maxWidth;
        return SizedBox(
          width: w,
          height: w / 1.586,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18 * w / 340),
              boxShadow: compact
                  ? null
                  : const [
                      BoxShadow(
                          color: Color(0x66000000),
                          blurRadius: 28,
                          offset: Offset(0, 12)),
                    ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18 * w / 340),
              child: Image.memory(photo!, fit: BoxFit.cover,
                  semanticLabel: '${card.displayName} card photo'),
            ),
          ),
        );
      });
    }
    final ink = Color(style.ink);
    final base = Color(card.faceColor);
    return LayoutBuilder(builder: (context, constraints) {
      final w = width ?? constraints.maxWidth;
      final scale = w / 340;
      return SizedBox(
        width: w,
        height: w / 1.586,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18 * scale),
            color: base,
            gradient: _finishGradient(base),
            boxShadow: compact
                ? null
                : const [
                    BoxShadow(
                        color: Color(0x66000000),
                        blurRadius: 28,
                        offset: Offset(0, 12)),
                  ],
          ),
          child: Stack(children: [
            if (style.finish == 'pattern') ..._pattern(w),
            Padding(
              padding: EdgeInsets.all(20 * scale),
              child: DefaultTextStyle(
                style: TextStyle(color: ink, fontFamily: 'Manrope'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            card.bankName.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 13 * scale,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            card.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                fontSize: 12 * scale,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    Row(children: [
                      _Chip(scale: scale, silver: style.chip == 'silver'),
                      SizedBox(width: 14 * scale),
                      Icon(Icons.contactless_outlined,
                          color: ink, size: 26 * scale),
                    ]),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            style.numberless || card.last4 == null
                                ? (compact ? '' : 'NUMBERLESS FRONT')
                                : '•••• ${card.last4}',
                            style: TextStyle(
                              fontSize:
                                  (style.numberless ? 11 : 16) * scale,
                              letterSpacing: style.numberless ? 1 : 2.5,
                              fontWeight: FontWeight.w600,
                              shadows: const [
                                Shadow(
                                    color: Color(0x59000000),
                                    offset: Offset(0, 1)),
                              ],
                            ),
                          ),
                        ),
                        Text(
                          card.network.label,
                          style: TextStyle(
                            fontSize: 13 * scale,
                            fontWeight: FontWeight.w800,
                            fontStyle: card.network == CardNetwork.visa
                                ? FontStyle.italic
                                : FontStyle.normal,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ),
      );
    });
  }

  Gradient? _finishGradient(Color base) {
    switch (style.finish) {
      case 'metal':
        final light = Color.lerp(base, Colors.white, 0.25)!;
        return LinearGradient(
          colors: [base, light, base, light, base],
          stops: const [0, 0.25, 0.5, 0.75, 1],
          tileMode: TileMode.repeated,
          begin: Alignment.centerLeft,
          end: const Alignment(-0.97, 0),
        );
      case 'gloss':
        return LinearGradient(
          begin: const Alignment(-1, -1),
          end: const Alignment(1, 1),
          colors: [
            base,
            Color.lerp(base, Colors.white, 0.18)!,
            base,
          ],
          stops: const [0.4, 0.5, 0.6],
        );
      default:
        return null;
    }
  }

  List<Widget> _pattern(double w) => [
        Positioned(
          right: -w * 0.08,
          top: -w * 0.1,
          child: _circle(w * 0.4, 0.14),
        ),
        Positioned(
          right: w * 0.05,
          bottom: -w * 0.35,
          child: _circle(w * 0.7, 0.10),
        ),
      ];

  Widget _circle(double size, double opacity) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: opacity),
        ),
      );
}

class _Chip extends StatelessWidget {
  const _Chip({required this.scale, required this.silver});
  final double scale;
  final bool silver;

  @override
  Widget build(BuildContext context) => Container(
        width: 44 * scale,
        height: 34 * scale,
        decoration: BoxDecoration(
          color: silver ? AppColors.chipSilver : AppColors.chipGold,
          borderRadius: BorderRadius.circular(6 * scale),
        ),
        child: CustomPaint(painter: _ChipLines()),
      );
}

class _ChipLines extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = const Color(0x55000000)
      ..strokeWidth = 1;
    final x1 = s.width * 0.3, x2 = s.width * 0.7;
    canvas
      ..drawLine(Offset(0, s.height / 3), Offset(x1, s.height / 3), p)
      ..drawLine(Offset(0, s.height * 2 / 3), Offset(x1, s.height * 2 / 3), p)
      ..drawLine(Offset(x2, s.height / 3), Offset(s.width, s.height / 3), p)
      ..drawLine(
          Offset(x2, s.height * 2 / 3), Offset(s.width, s.height * 2 / 3), p)
      ..drawLine(Offset(x1, 0), Offset(x1, s.height), p)
      ..drawLine(Offset(x2, 0), Offset(x2, s.height), p)
      ..drawLine(Offset(x1, s.height / 2), Offset(x2, s.height / 2), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
