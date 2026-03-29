import 'dart:ui';
import 'package:flutter/material.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 800;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0D14) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text("Analytics Dashboard", style: TextStyle(fontWeight: FontWeight.w800, color: isDark ? Colors.white : const Color(0xFF1E293B))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : const Color(0xFF1E293B)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Performance Overview",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 24),
            if (isWide)
              Row(
                children: [
                  Expanded(child: _buildStatCard("Total Generations", "1,245", "+12% this week", const Color(0xFF8A4FFF), isDark, Icons.auto_awesome_rounded)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard("Models Downloaded", "842", "+5% this week", const Color(0xFF4CC9F0), isDark, Icons.download_rounded)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard("API Usage", "84%", "Approaching limit", const Color(0xFFF72585), isDark, Icons.data_usage_rounded)),
                ],
              )
            else
              Column(
                children: [
                  _buildStatCard("Total Generations", "1,245", "+12% this week", const Color(0xFF8A4FFF), isDark, Icons.auto_awesome_rounded),
                  const SizedBox(height: 16),
                  _buildStatCard("Models Downloaded", "842", "+5% this week", const Color(0xFF4CC9F0), isDark, Icons.download_rounded),
                  const SizedBox(height: 16),
                  _buildStatCard("API Usage", "84%", "Approaching limit", const Color(0xFFF72585), isDark, Icons.data_usage_rounded),
                ],
              ),
            const SizedBox(height: 32),
            Text(
              "Generation Activity",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),
            _buildChartSection(isDark),
            const SizedBox(height: 32),
            Text(
              "Recent Models",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),
            _buildRecentModelsList(isDark),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, Color accent, bool isDark, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark 
            ? [Colors.white.withOpacity(0.06), Colors.white.withOpacity(0.02)]
            : [Colors.white, Colors.white.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05)),
        boxShadow: isDark ? [] : [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accent, size: 24),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(subtitle, style: TextStyle(color: accent, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(value, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 32, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontSize: 15, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildChartSection(bool isDark) {
    return Container(
      height: 280,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05)),
        boxShadow: isDark ? [] : [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Last 7 Days", style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontSize: 14)),
          const SizedBox(height: 24),
          Expanded(
            child: CustomPaint(
              size: const Size(double.infinity, double.infinity),
              painter: _MockChartPainter(isDark: isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentModelsList(bool isDark) {
    final items = [
      {"name": "Sci-Fi Drone", "date": "2 hours ago", "status": "Completed", "color": const Color(0xFF4CC9F0)},
      {"name": "Cyberpunk Car", "date": "5 hours ago", "status": "Processing", "color": const Color(0xFFF72585)},
      {"name": "Medieval Knight", "date": "1 day ago", "status": "Completed", "color": const Color(0xFF4CC9F0)},
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05)),
        boxShadow: isDark ? [] : [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (context, index) => Divider(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05), height: 1),
        itemBuilder: (context, index) {
          final item = items[index];
          final c = item["color"] as Color;
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            leading: Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: c.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.view_in_ar_rounded, color: c),
            ),
            title: Text(item["name"] as String, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.w600)),
            subtitle: Text(item["date"] as String, style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 13)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(item["status"] as String, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          );
        },
      ),
    );
  }
}

class _MockChartPainter extends CustomPainter {
  final bool isDark;
  _MockChartPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8A4FFF)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.cubicTo(size.width * 0.2, size.height * 0.8, size.width * 0.3, size.height * 0.3, size.width * 0.5, size.height * 0.5);
    path.cubicTo(size.width * 0.7, size.height * 0.7, size.width * 0.8, size.height * 0.2, size.width, size.height * 0.1);

    canvas.drawPath(path, paint);

    final gradientPath = Path.from(path);
    gradientPath.lineTo(size.width, size.height);
    gradientPath.lineTo(0, size.height);
    gradientPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF8A4FFF).withOpacity(0.3),
          const Color(0xFF8A4FFF).withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(gradientPath, fillPaint);

    final pointsPaint = Paint()
      ..color = isDark ? const Color(0xFF1A1D2D) : Colors.white
      ..style = PaintingStyle.fill;
    
    final strokePaint = Paint()
      ..color = const Color(0xFF8A4FFF)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final points = [
      Offset(0, size.height * 0.8),
      Offset(size.width * 0.5, size.height * 0.5),
      Offset(size.width, size.height * 0.1),
    ];

    for (var p in points) {
      canvas.drawCircle(p, 5, pointsPaint);
      canvas.drawCircle(p, 5, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}