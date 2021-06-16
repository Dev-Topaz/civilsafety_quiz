import 'package:flutter/material.dart';

class CurvePainter extends CustomPainter {
  double height;
  double width;
  CurvePainter(this.height, this.width);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = Colors.white;
    paint.style = PaintingStyle.fill;

    var path = Path();

    path.moveTo(0, height * 0.8);
    path.quadraticBezierTo(
        width * 0.25, height * 0.75, width * 0.38, height * 0.8);
    path.quadraticBezierTo(
        width * 0.4, height * 0.8, width * 0.5, height * 0.85);
    path.quadraticBezierTo(width * 0.7, height * 0.91, width, height * 0.85);
    path.lineTo(width, height);
    path.lineTo(0, height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CurvePainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(CurvePainter oldDelegate) => false;
}
