import 'package:flutter/material.dart';

class BubbleDecorationWidget extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Bubble besar kanan — sedikit keluar canvas biar keliatan natural
    paint.color = const Color(0xFF8B5FBA).withValues(alpha: 0.12);
    canvas.drawCircle(
      Offset(size.width * 0.80, size.height * 0.30),
      size.width * 0.32,
      paint,
    );

    // Stroke bubble kanan
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFF7B4DB8).withValues(alpha: 0.35);
    canvas.drawCircle(
      Offset(size.width * 0.80, size.height * 0.30),
      size.width * 0.32,
      paint,
    );

    // Bubble besar kiri — overlap dengan yang kanan
    paint
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF6B3FA8).withValues(alpha: 0.10);
    canvas.drawCircle(
      Offset(size.width * 0.58, size.height * 0.75),
      size.width * 0.32,
      paint,
    );

    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFF7B4DB8).withValues(alpha: 0.25);
    canvas.drawCircle(
      Offset(size.width * 0.58, size.height * 0.75),
      size.width * 0.32,
      paint,
    );

    // Bubble kecil aksen kanan bawah
    paint
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF5A2E9A).withValues(alpha: 0.15);
    canvas.drawCircle(
      Offset(size.width * 0.95, size.height * 0.90),
      size.width * 0.16,
      paint,
    );

    // Bubble kecil aksen kiri atas
    paint.color = const Color(0xFF4A1E8A).withValues(alpha: 0.20);
    canvas.drawCircle(
      Offset(size.width * 0.10, size.height * 0.18),
      size.width * 0.13,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
