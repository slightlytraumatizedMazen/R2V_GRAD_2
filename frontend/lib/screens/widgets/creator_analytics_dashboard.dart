import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CreatorAnalyticsDashboard extends StatefulWidget {
  const CreatorAnalyticsDashboard({super.key});

  @override
  State<CreatorAnalyticsDashboard> createState() => _CreatorAnalyticsDashboardState();
}

class _CreatorAnalyticsDashboardState extends State<CreatorAnalyticsDashboard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _metricsFade;
  late Animation<Offset> _metricsSlide;
  late Animation<double> _chartsFade;
  late Animation<Offset> _chartsSlide;
  late Animation<double> _listsFade;
  late Animation<Offset> _listsSlide;

  int _touchedPieIndex = -1;

  final List<Map<String, String>> _mockGigs = [
    {
      "image": "https://images.unsplash.com/photo-1550745165-9bc0b252726f?q=80&w=200&auto=format&fit=crop",
      "title": "Custom Cyberpunk Avatars",
      "views": "4.2K VIEWS",
      "sales": "22 SALES",
      "price": "\$249",
    },
    {
      "image": "https://images.unsplash.com/photo-1544256718-3baf237f3942?q=80&w=200&auto=format&fit=crop",
      "title": "Hover-Bike Concept Rig",
      "views": "3.1K VIEWS",
      "sales": "14 SALES",
      "price": "\$580",
    },
    {
      "image": "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=200&auto=format&fit=crop",
      "title": "Modular Sci-Fi Street Kit",
      "views": "2.8K VIEWS",
      "sales": "38 SALES",
      "price": "\$120",
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));

    _metricsFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)));
    _metricsSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)));

    _chartsFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.6, curve: Curves.easeOut)));
    _chartsSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.6, curve: Curves.easeOut)));

    _listsFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.9, curve: Curves.easeOut)));
    _listsSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.9, curve: Curves.easeOut)));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _shuffleGigs() {
    setState(() {
      _mockGigs.shuffle();
    });
  }

  void _showClientDirectorySnackbar(bool isDark) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Routing to Full Client Directory...", style: TextStyle(fontFamily: 'Inter', color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600)),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: const Color(0xFFBC70FF).withOpacity(0.5))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isWeb = MediaQuery.of(context).size.width >= 900;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isWeb ? 40 : 16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            "Analytics Overview",
            style: TextStyle(fontFamily: 'Inter', color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: isWeb ? 32 : 26, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            "Track your creative impact and financial growth across the R2V Studio ecosystem.",
            style: TextStyle(fontFamily: 'Inter', color: isDark ? Colors.white70 : Colors.black54, fontSize: 14),
          ),
          SizedBox(height: isWeb ? 48 : 24),

          // Top Metrics Row
          FadeTransition(
            opacity: _metricsFade,
            child: SlideTransition(
              position: _metricsSlide,
              child: isWeb 
                  ? Row(
                      children: [
                        Expanded(child: _buildMetricCard(icon: Icons.payments_rounded, iconColor: const Color(0xFFBC70FF), title: "TOTAL EARNINGS", value: "\$4,850.00", trend: "+12.5%", isPositive: true, isDark: isDark)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildMetricCard(icon: Icons.assignment_rounded, iconColor: const Color(0xFF4CC9F0), title: "ACTIVE ORDERS", value: "14", trend: "Steady", isPositive: null, isDark: isDark)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildMetricCard(icon: Icons.check_circle_rounded, iconColor: const Color(0xFFBC70FF), title: "COMPLETED", value: "186", trend: "+4", isPositive: true, isDark: isDark)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildMetricCard(icon: Icons.visibility_rounded, iconColor: const Color(0xFFBC70FF), title: "PROFILE VIEWS", value: "12.4K", trend: "-2.1%", isPositive: false, isDark: isDark)),
                      ],
                    )
                  : Wrap(
                      spacing: 16, runSpacing: 16,
                      children: [
                        SizedBox(width: (MediaQuery.of(context).size.width - 48) / 2, child: _buildMetricCard(icon: Icons.payments_rounded, iconColor: const Color(0xFFBC70FF), title: "EARNINGS", value: "\$4,850", trend: "+12.5%", isPositive: true, isDark: isDark)),
                        SizedBox(width: (MediaQuery.of(context).size.width - 48) / 2, child: _buildMetricCard(icon: Icons.assignment_rounded, iconColor: const Color(0xFF4CC9F0), title: "ORDERS", value: "14", trend: "Steady", isPositive: null, isDark: isDark)),
                        SizedBox(width: (MediaQuery.of(context).size.width - 48) / 2, child: _buildMetricCard(icon: Icons.check_circle_rounded, iconColor: const Color(0xFFBC70FF), title: "COMPLETED", value: "186", trend: "+4", isPositive: true, isDark: isDark)),
                        SizedBox(width: (MediaQuery.of(context).size.width - 48) / 2, child: _buildMetricCard(icon: Icons.visibility_rounded, iconColor: const Color(0xFFBC70FF), title: "VIEWS", value: "12.4K", trend: "-2.1%", isPositive: false, isDark: isDark)),
                      ],
                    ),
            ),
          ),
          SizedBox(height: isWeb ? 24 : 16),

          // Dashboard Charts Row
          FadeTransition(
            opacity: _chartsFade,
            child: SlideTransition(
              position: _chartsSlide,
              child: isWeb 
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 15, child: _buildLineChartCard(isDark, isWeb)),
                        const SizedBox(width: 24),
                        Expanded(flex: 9, child: _buildPieChartCard(isDark)),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildLineChartCard(isDark, isWeb),
                        const SizedBox(height: 16),
                        _buildPieChartCard(isDark),
                      ],
                    ),
            ),
          ),
          SizedBox(height: isWeb ? 24 : 16),

          // Detailed Lists Row
          FadeTransition(
            opacity: _listsFade,
            child: SlideTransition(
              position: _listsSlide,
              child: isWeb 
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildClientsList(isDark, isWeb)),
                        const SizedBox(width: 24),
                        Expanded(child: _buildGigsList(isDark, isWeb)),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildClientsList(isDark, isWeb),
                        const SizedBox(height: 16),
                        _buildGigsList(isDark, isWeb),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // --- COMPONENTS ---

  Widget _buildMetricCard({required IconData icon, required Color iconColor, required String title, required String value, required String trend, required bool? isPositive, required bool isDark}) {
    Color trendColor = isDark ? Colors.white54 : Colors.black45;
    if (isPositive == true) trendColor = const Color(0xFF22C55E); // Green
    if (isPositive == false) trendColor = const Color(0xFFF72585); // Red/Pink

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _glassDecoration(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: iconColor.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              Row(
                children: [
                  if (trend != "Steady") Icon(isPositive == true ? Icons.trending_up : Icons.trending_down, color: trendColor, size: 16),
                  if (trend != "Steady") const SizedBox(width: 4),
                  Text(trend, style: TextStyle(fontFamily: 'Inter', color: trendColor, fontSize: 12, fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(title, style: TextStyle(fontFamily: 'Inter', color: isDark ? Colors.white60 : Colors.black54, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.0), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontFamily: 'Inter', color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 24, fontWeight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildLineChartCard(bool isDark, bool isWeb) {
    return Container(
      height: 380,
      padding: EdgeInsets.all(isWeb ? 32 : 20),
      decoration: _glassDecoration(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Revenue Over Time", style: TextStyle(fontFamily: 'Inter', color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 18, fontWeight: FontWeight.w800)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05), borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    Text("6 Months", style: TextStyle(fontFamily: 'Inter', color: isDark ? Colors.white70 : Colors.black87, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down, color: isDark ? Colors.white70 : Colors.black87, size: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          Expanded(child: _buildLineChart(isDark)),
        ],
      ),
    );
  }

  Widget _buildPieChartCard(bool isDark) {
    return Container(
      height: 380,
      padding: const EdgeInsets.all(24),
      decoration: _glassDecoration(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Earnings by Category", style: TextStyle(fontFamily: 'Inter', color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 24),
          Expanded(child: _buildPieChart(isDark)),
          const SizedBox(height: 24),
          _buildLegendItem(color: const Color(0xFFBC70FF), label: "Avatars", value: "45%", isDark: isDark),
          const SizedBox(height: 12),
          _buildLegendItem(color: const Color(0xFF4CC9F0), label: "Vehicles", value: "32%", isDark: isDark),
          const SizedBox(height: 12),
          _buildLegendItem(color: const Color(0xFFF72585), label: "Environments", value: "23%", isDark: isDark),
        ],
      ),
    );
  }

  Widget _buildClientsList(bool isDark, bool isWeb) {
    return Container(
      padding: EdgeInsets.all(isWeb ? 32 : 20),
      decoration: _glassDecoration(isDark),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Top Clients", style: TextStyle(fontFamily: 'Inter', color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 18, fontWeight: FontWeight.w800)),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => _showClientDirectorySnackbar(isDark),
                  child: const Text("VIEW ALL", style: TextStyle(fontFamily: 'Inter', color: Color(0xFFBC70FF), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildClientTile(avatar: "https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=150&auto=format&fit=crop", name: "Nebula Systems", role: "Enterprise Partner", earnings: "\$12,400", projects: "8 PROJECTS", isDark: isDark),
          const SizedBox(height: 24),
          _buildClientTile(avatar: "https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?q=80&w=150&auto=format&fit=crop", name: "Elena Vance", role: "Creative Director", earnings: "\$8,920", projects: "3 PROJECTS", isDark: isDark),
          const SizedBox(height: 24),
          _buildClientTile(avatar: "https://images.unsplash.com/photo-1622253692010-333f2da6031d?q=80&w=150&auto=format&fit=crop", name: "Aura Labs", role: "Recurring Client", earnings: "\$5,150", projects: "5 PROJECTS", isDark: isDark),
        ],
      ),
    );
  }

  Widget _buildGigsList(bool isDark, bool isWeb) {
    return Container(
      padding: EdgeInsets.all(isWeb ? 32 : 20),
      decoration: _glassDecoration(isDark),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Most Viewed Gigs", style: TextStyle(fontFamily: 'Inter', color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 18, fontWeight: FontWeight.w800)),
              Row(
                children: [
                  GestureDetector(
                    onTap: _shuffleGigs,
                    child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05), shape: BoxShape.circle), child: Icon(Icons.chevron_left, color: isDark ? Colors.white70 : Colors.black54, size: 16)),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _shuffleGigs,
                    child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05), shape: BoxShape.circle), child: Icon(Icons.chevron_right, color: isDark ? Colors.white70 : Colors.black54, size: 16)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildGigTile(image: _mockGigs[0]["image"]!, title: _mockGigs[0]["title"]!, views: _mockGigs[0]["views"]!, sales: _mockGigs[0]["sales"]!, price: _mockGigs[0]["price"]!, isDark: isDark),
          const SizedBox(height: 24),
          _buildGigTile(image: _mockGigs[1]["image"]!, title: _mockGigs[1]["title"]!, views: _mockGigs[1]["views"]!, sales: _mockGigs[1]["sales"]!, price: _mockGigs[1]["price"]!, isDark: isDark),
          const SizedBox(height: 24),
          _buildGigTile(image: _mockGigs[2]["image"]!, title: _mockGigs[2]["title"]!, views: _mockGigs[2]["views"]!, sales: _mockGigs[2]["sales"]!, price: _mockGigs[2]["price"]!, isDark: isDark),
        ],
      ),
    );
  }

  // --- CHART HELPERS ---

  Widget _buildLineChart(bool isDark) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) => touchedSpots.map((spot) => LineTooltipItem("\$${(spot.y * 1000).toStringAsFixed(0)}", const TextStyle(color: Colors.white, fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 12))).toList(),
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final style = TextStyle(color: isDark ? Colors.white54 : Colors.black45, fontSize: 10, fontFamily: 'Inter', fontWeight: FontWeight.w700);
                Widget text;
                switch (value.toInt()) {
                  case 0: text = Text('JAN', style: style); break;
                  case 1: text = Text('FEB', style: style); break;
                  case 2: text = Text('MAR', style: style); break;
                  case 3: text = Text('APR', style: style); break;
                  case 4: text = Text('MAY', style: style); break;
                  case 5: text = Text('JUN', style: style); break;
                  default: text = const Text(''); break;
                }
                return Padding(padding: const EdgeInsets.only(top: 10.0), child: text);
              },
              interval: 1,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: const [FlSpot(0, 3), FlSpot(1, 3.2), FlSpot(2, 4.5), FlSpot(3, 4.1), FlSpot(4, 5.8), FlSpot(5, 5.0)],
            isCurved: true,
            color: const Color(0xFFBC70FF),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true, getDotPainter: (s, p, b, i) => FlDotCirclePainter(radius: 4, color: isDark ? Colors.black : Colors.white, strokeWidth: 2, strokeColor: const Color(0xFFBC70FF))),
            belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [const Color(0xFFBC70FF).withOpacity(0.3), Colors.transparent], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildPieChart(bool isDark) {
    return Stack(
      children: [
        PieChart(
          PieChartData(
            pieTouchData: PieTouchData(touchCallback: (event, res) => setState(() => _touchedPieIndex = (!event.isInterestedForInteractions || res == null || res.touchedSection == null) ? -1 : res.touchedSection!.touchedSectionIndex)),
            sectionsSpace: 4,
            centerSpaceRadius: 50,
            sections: [
              PieChartSectionData(color: const Color(0xFFBC70FF), value: 45, title: '', radius: _touchedPieIndex == 0 ? 18 : 12),
              PieChartSectionData(color: const Color(0xFF4CC9F0), value: 32, title: '', radius: _touchedPieIndex == 1 ? 18 : 12),
              PieChartSectionData(color: const Color(0xFFF72585), value: 23, title: '', radius: _touchedPieIndex == 2 ? 18 : 12),
            ],
          ),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("\$42.8k", style: TextStyle(fontFamily: 'Inter', color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text("TOTAL", style: TextStyle(fontFamily: 'Inter', color: isDark ? Colors.white54 : Colors.black45, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem({required Color color, required String label, required String value, required bool isDark}) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(fontFamily: 'Inter', color: isDark ? Colors.white70 : Colors.black87, fontSize: 13)),
        const Spacer(),
        Text(value, style: TextStyle(fontFamily: 'Inter', color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 13, fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _buildClientTile({required String avatar, required String name, required String role, required String earnings, required String projects, required bool isDark}) {
    return Row(
      children: [
        CircleAvatar(radius: 18, backgroundImage: NetworkImage(avatar)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: TextStyle(fontFamily: 'Inter', color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 14, fontWeight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(role, style: TextStyle(fontFamily: 'Inter', color: isDark ? Colors.white60 : Colors.black54, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(earnings, style: const TextStyle(fontFamily: 'Inter', color: Color(0xFFBC70FF), fontSize: 14, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(projects, style: TextStyle(fontFamily: 'Inter', color: isDark ? Colors.white60 : Colors.black54, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
          ],
        ),
      ],
    );
  }

  Widget _buildGigTile({required String image, required String title, required String views, required String sales, required String price, required bool isDark}) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            image, width: 50, height: 40, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(width: 50, height: 40, color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05), child: Icon(Icons.image_not_supported, color: isDark ? Colors.white54 : Colors.black38, size: 16)),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontFamily: 'Inter', color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 14, fontWeight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.visibility_outlined, color: isDark ? Colors.white54 : Colors.black54, size: 12),
                  const SizedBox(width: 4),
                  Text(views, style: TextStyle(fontFamily: 'Inter', color: isDark ? Colors.white54 : Colors.black54, fontSize: 10, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 10),
                  Icon(Icons.shopping_cart_outlined, color: isDark ? Colors.white54 : Colors.black54, size: 12),
                  const SizedBox(width: 4),
                  Text(sales, style: TextStyle(fontFamily: 'Inter', color: isDark ? Colors.white54 : Colors.black54, fontSize: 10, fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
        ),
        Text(price, style: const TextStyle(fontFamily: 'Inter', color: Color(0xFFBC70FF), fontSize: 15, fontWeight: FontWeight.w800)),
      ],
    );
  }

  BoxDecoration _glassDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark ? Colors.black.withOpacity(0.25) : Colors.white.withOpacity(0.85),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.white),
      boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
    );
  }
}