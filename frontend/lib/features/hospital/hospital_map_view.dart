import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

// Hospital Model
class HospitalInfo {
  final String name;
  final String type; // PHC, General, Clinic, Ambulance
  final double distance; // in km
  final int time; // in minutes
  final String contact;
  final Offset mapCoordinates; // Custom coordinate on our 400x400 map canvas

  HospitalInfo({
    required this.name,
    required this.type,
    required this.distance,
    required this.time,
    required this.contact,
    required this.mapCoordinates,
  });
}

class HospitalMapView extends StatefulWidget {
  final HospitalInfo? selectedHospital;

  const HospitalMapView({
    super.key,
    required this.selectedHospital,
  });

  @override
  State<HospitalMapView> createState() => _HospitalMapViewState();
}

class _HospitalMapViewState extends State<HospitalMapView> with SingleTickerProviderStateMixin {
  late AnimationController _navigationController;

  @override
  void initState() {
    super.initState();
    _navigationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant HospitalMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedHospital != oldWidget.selectedHospital) {
      _navigationController.reset();
      _navigationController.forward();
    }
  }

  @override
  void dispose() {
    _navigationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0), // Map Canvas Background Color
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            // Panning and Zooming Support
            InteractiveViewer(
              maxScale: 3.0,
              minScale: 0.8,
              child: AnimatedBuilder(
                animation: _navigationController,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(400, 300),
                    painter: MapPainter(
                      selectedHospital: widget.selectedHospital,
                      navigationProgress: _navigationController.value,
                    ),
                  );
                },
              ),
            ),
            // Map Control Overlays
            Positioned(
              right: 12,
              bottom: 12,
              child: Column(
                children: [
                  _buildMapControl(Icons.gps_fixed, () {
                    // Reset zoom
                  }),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Offline GPS Active',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.successGreen),
                    ),
                  ),
                ],
              ),
            ),
            // Compass
            Positioned(
              left: 12,
              top: 12,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Text('🧭', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapControl(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: AppTheme.accentBlue),
        onPressed: onPressed,
      ),
    );
  }
}

// Custom Painter to draw the offline rural map
class MapPainter extends CustomPainter {
  final HospitalInfo? selectedHospital;
  final double navigationProgress;

  MapPainter({
    required this.selectedHospital,
    required this.navigationProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = true;

    // 1. Draw Field Background (Grassland)
    paint.color = const Color(0xFFF1F5F9); // Light Gray-Green
    canvas.drawRect(Offset.zero & size, paint);

    // Draw some green forest/shrub zones
    paint.color = const Color(0xFFDCFCE7); // Soft Green
    canvas.drawCircle(const Offset(80, 70), 50, paint);
    canvas.drawCircle(const Offset(300, 240), 65, paint);
    canvas.drawCircle(const Offset(60, 220), 40, paint);

    // 2. Draw Blue River running horizontally
    paint.color = const Color(0xFFBFDBFE); // River blue
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 14;
    final riverPath = Path()
      ..moveTo(0, 150)
      ..cubicTo(100, 130, 200, 180, 300, 140)
      ..lineTo(400, 160);
    canvas.drawPath(riverPath, paint);

    // 3. Draw Gray Roads System
    paint.color = const Color(0xFFCBD5E1); // Slate Road Color
    paint.strokeWidth = 12;
    paint.strokeCap = StrokeCap.round;
    paint.style = PaintingStyle.stroke;

    // Main Road (horizontal)
    canvas.drawLine(const Offset(0, 100), const Offset(400, 100), paint);
    // Vertical Road linking to River bridge
    canvas.drawLine(const Offset(200, 20), const Offset(200, 280), paint);
    // Loop road
    canvas.drawLine(const Offset(100, 100), const Offset(100, 250), paint);
    canvas.drawLine(const Offset(100, 250), const Offset(300, 250), paint);
    canvas.drawLine(const Offset(300, 250), const Offset(300, 100), paint);

    // Draw yellow dotted center lane lines on roads
    paint.color = Colors.white;
    paint.strokeWidth = 1.5;
    paint.style = PaintingStyle.stroke;
    // Main horizontal road dotted line
    _drawDashedLine(canvas, const Offset(0, 100), const Offset(400, 100), paint);
    _drawDashedLine(canvas, const Offset(200, 20), const Offset(200, 280), paint);
    _drawDashedLine(canvas, const Offset(100, 100), const Offset(100, 250), paint);
    _drawDashedLine(canvas, const Offset(100, 250), const Offset(300, 250), paint);
    _drawDashedLine(canvas, const Offset(300, 250), const Offset(300, 100), paint);

    // 4. Draw Bridges
    paint.color = const Color(0xFF94A3B8);
    paint.style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromCenter(center: const Offset(200, 150), width: 22, height: 18), paint);

    // 5. Draw Landmark Icons (Houses, Trees)
    paint.style = PaintingStyle.fill;
    
    // User Location: "Self Home"
    const Offset homeLoc = Offset(200, 100);
    _drawMarker(canvas, homeLoc, '🏠', 'Self Home', Colors.blue);

    // Draw Other Hospital Locations
    _drawMarker(canvas, const Offset(100, 100), '🏥', 'Rampur PHC', Colors.green);
    _drawMarker(canvas, const Offset(300, 100), '🏥', 'Govt Hospital', Colors.green);
    _drawMarker(canvas, const Offset(300, 250), '🩺', 'Arogya Clinic', Colors.amber);
    _drawMarker(canvas, const Offset(100, 250), '🚑', 'Ambulance Hub', Colors.red);

    // 6. Draw Navigation Route if a Hospital is Selected
    if (selectedHospital != null) {
      final destLoc = selectedHospital!.mapCoordinates;
      
      // Draw highlighted route line (Orange glowing line)
      paint.color = Colors.orange;
      paint.strokeWidth = 5;
      paint.style = PaintingStyle.stroke;
      paint.strokeCap = StrokeCap.round;

      final routePath = Path();
      routePath.moveTo(homeLoc.dx, homeLoc.dy);

      // Simple routing based on coordinate grid
      if (destLoc.dy == 100) {
        routePath.lineTo(destLoc.dx, destLoc.dy);
      } else {
        // Go along loop
        routePath.lineTo(destLoc.dx, 100);
        routePath.lineTo(destLoc.dx, destLoc.dy);
      }
      canvas.drawPath(routePath, paint);

      // Calculate coordinates of animated navigation pin
      Offset animPos;
      if (destLoc.dy == 100) {
        animPos = Offset(
          homeLoc.dx + (destLoc.dx - homeLoc.dx) * navigationProgress,
          100,
        );
      } else {
        // Multi-point route segment interpolation
        if (navigationProgress < 0.5) {
          final p = navigationProgress / 0.5;
          animPos = Offset(
            homeLoc.dx + (destLoc.dx - homeLoc.dx) * p,
            100,
          );
        } else {
          final p = (navigationProgress - 0.5) / 0.5;
          animPos = Offset(
            destLoc.dx,
            100 + (destLoc.dy - 100) * p,
          );
        }
      }

      // Draw glowing pulse ring
      paint.color = Colors.blue.withOpacity(0.3 * (1 - (navigationProgress % 0.5) * 2));
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(animPos, 16, paint);

      // Draw navigation pin
      paint.color = Colors.blue;
      canvas.drawCircle(animPos, 6, paint);
      paint.color = Colors.white;
      canvas.drawCircle(animPos, 2.5, paint);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashWidth = 4;
    const dashSpace = 4;
    double distance = sqrt((p2.dx - p1.dx) * (p2.dx - p1.dx) + (p2.dy - p1.dy) * (p2.dy - p1.dy));
    double dx = (p2.dx - p1.dx) / distance;
    double dy = (p2.dy - p1.dy) / distance;
    double startX = p1.dx;
    double startY = p1.dy;

    while (distance > 0) {
      canvas.drawLine(Offset(startX, startY), Offset(startX + dx * dashWidth, startY + dy * dashWidth), paint);
      startX += dx * (dashWidth + dashSpace);
      startY += dy * (dashWidth + dashSpace);
      distance -= (dashWidth + dashSpace);
    }
  }

  void _drawMarker(Canvas canvas, Offset offset, String emoji, String label, Color accentColor) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Draw Emoji Icon
    textPainter.text = TextSpan(
      text: emoji,
      style: const TextStyle(fontSize: 16),
    );
    textPainter.layout();
    textPainter.paint(canvas, offset - Offset(textPainter.width / 2, textPainter.height / 2 + 2));

    // Draw Label Text
    textPainter.text = TextSpan(
      text: label,
      style: TextStyle(
        fontSize: 7.5,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryBlue,
        backgroundColor: Colors.white.withOpacity(0.85),
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, offset + Offset(-textPainter.width / 2, 8));
  }

  @override
  bool shouldRepaint(covariant MapPainter oldDelegate) {
    return oldDelegate.selectedHospital != selectedHospital ||
        oldDelegate.navigationProgress != navigationProgress;
  }
}
