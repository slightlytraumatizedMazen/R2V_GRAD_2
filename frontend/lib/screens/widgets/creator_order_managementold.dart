import 'package:flutter/material.dart';

class CreatorOrderManagementDashboard extends StatefulWidget {
  const CreatorOrderManagementDashboard({super.key});

  @override
  State<CreatorOrderManagementDashboard> createState() => _CreatorOrderManagementDashboardState();
}

class _CreatorOrderManagementDashboardState extends State<CreatorOrderManagementDashboard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _metricsFade;
  late Animation<Offset> _metricsSlide;
  late Animation<double> _ordersFade;
  late Animation<Offset> _ordersSlide;
  late Animation<double> _timelineFade;
  late Animation<Offset> _timelineSlide;

  // Mock Orders Data
  final List<Map<String, dynamic>> _orders = [
    {
      "title": "Cyberpunk Accessory Pack",
      "client": "NeonArcade VR",
      "tags": ".OBJ • .FBX",
      "progress": 0.60,
      "progressText": "60%",
      "phase": "High Poly Modeling",
      "deadline": "2 days left",
      "isOverdue": true,
      "isArchived": false,
      "icon": Icons.precision_manufacturing_rounded, 
    },
    {
      "title": "Modular Laboratory Kit",
      "client": "Stellar Labs Inc.",
      "tags": ".BLEND • .GLTF",
      "progress": 0.85,
      "progressText": "85%",
      "phase": "Texturing & PBR",
      "deadline": "Aug 24, 2026",
      "isOverdue": false,
      "isArchived": false,
      "icon": Icons.science_rounded,
    },
    {
      "title": "Conceptual NFT Avatar",
      "client": "Metaspace Collective",
      "tags": "ARCHIVED",
      "progress": 1.0,
      "progressText": "100%",
      "phase": "Completed",
      "deadline": "",
      "completedDate": "July 12, 2026",
      "isOverdue": false,
      "isArchived": true,
      "icon": Icons.face_retouching_natural_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));

    _headerFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)));
    _headerSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)));

    _metricsFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.6, curve: Curves.easeOut)));
    _metricsSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.6, curve: Curves.easeOut)));

    _ordersFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.9, curve: Curves.easeOut)));
    _ordersSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.9, curve: Curves.easeOut)));

    _timelineFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.6, 1.0, curve: Curves.easeOut)));
    _timelineSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.6, 1.0, curve: Curves.easeOut)));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
          // 1. Header Row
          FadeTransition(
            opacity: _headerFade,
            child: SlideTransition(
              position: _headerSlide,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Order Management",
                    style: TextStyle(fontFamily: 'Inter', color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: isWeb ? 32 : 26, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Manage your ongoing high-fidelity 3D productions",
                    style: TextStyle(fontFamily: 'Inter', color: isDark ? Colors.white70 : Colors.black54, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: isWeb ? 48 : 24),

          // 2. Top Metrics Row
          FadeTransition(
            opacity: _metricsFade,
            child: SlideTransition(
              position: _metricsSlide,
              child: isWeb 
                  ? Row(
                      children: [
                        _buildMetricCard(title: "TOTAL ORDERS", value: "42", icon: Icons.shopping_cart_outlined, iconColor: const Color(0xFFBC70FF), isDark: isDark),
                        const SizedBox(width: 20),
                        _buildMetricCard(title: "ACTIVE PROJECTS", value: "07", icon: Icons.rocket_launch_rounded, iconColor: const Color(0xFF4CC9F0), isDark: isDark),
                        const SizedBox(width: 20),
                        _buildMetricCard(title: "COMPLETED MILESTONES", value: "128", icon: Icons.check_circle_outline_rounded, iconColor: const Color(0xFFF72585), isDark: isDark),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildMetricCard(title: "TOTAL ORDERS", value: "42", icon: Icons.shopping_cart_outlined, iconColor: const Color(0xFFBC70FF), isDark: isDark),
                        const SizedBox(height: 12),
                        _buildMetricCard(title: "ACTIVE PROJECTS", value: "07", icon: Icons.rocket_launch_rounded, iconColor: const Color(0xFF4CC9F0), isDark: isDark),
                        const SizedBox(height: 12),
                        _buildMetricCard(title: "COMPLETED MILESTONES", value: "128", icon: Icons.check_circle_outline_rounded, iconColor: const Color(0xFFF72585), isDark: isDark),
                      ],
                    ),
            ),
          ),
          SizedBox(height: isWeb ? 48 : 32),

          // 3. Main Layout Grid
          isWeb 
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 60, child: _buildActiveOrdersSection(isDark, isWeb)),
                  const SizedBox(width: 32),
                  Expanded(flex: 40, child: _buildTimelineSection(isDark, isWeb)),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildActiveOrdersSection(isDark, isWeb),
                  const SizedBox(height: 32),
                  _buildTimelineSection(isDark, isWeb),
                ],
              ),
        ],
      ),
    );
  }

  // --- COMPONENTS ---

  Widget _buildMetricCard({required String title, required String value, required IconData icon, required Color iconColor, required bool isDark}) {
    return Expanded(
      flex: 1, // Will only matter inside a Row
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: _glassDecoration(isDark),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: iconColor.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontFamily: 'Inter', color: isDark ? Colors.white60 : Colors.black45, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(value, style: TextStyle(fontFamily: 'Inter', color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 28, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveOrdersSection(bool isDark, bool isWeb) {
    return FadeTransition(
      opacity: _ordersFade,
      child: SlideTransition(
        position: _ordersSlide,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isWeb)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Active Orders", style: TextStyle(fontFamily: 'Inter', color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 20, fontWeight: FontWeight.w800)),
                  Row(
                    children: [
                      _buildFilterChip("All Status", true, isDark),
                      const SizedBox(width: 8),
                      _buildFilterChip("Recent First", false, isDark),
                    ],
                  ),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Active Orders", style: TextStyle(fontFamily: 'Inter', color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildFilterChip("All Status", true, isDark)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildFilterChip("Recent", false, isDark)),
                    ],
                  ),
                ],
              ),
            const SizedBox(height: 24),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _orders.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final order = _orders[index];
                final bool isArchived = order['isArchived'];

                return Opacity(
                  opacity: isArchived ? 0.5 : 1.0,
                  child: Container(
                    padding: EdgeInsets.all(isWeb ? 24 : 16),
                    decoration: _glassDecoration(isDark),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: isWeb ? 64 : 48, height: isWeb ? 64 : 48,
                          decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.04), shape: BoxShape.circle, border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.transparent)),
                          child: Icon(order['icon'] as IconData, color: isArchived ? Colors.grey : const Color(0xFFBC70FF), size: isWeb ? 28 : 20),
                        ),
                        SizedBox(width: isWeb ? 20 : 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      order['title'] as String,
                                      style: TextStyle(fontFamily: 'Inter', color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: isWeb ? 16 : 14, fontWeight: FontWeight.w800),
                                      maxLines: 1, overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isArchived ? Colors.transparent : const Color(0xFFBC70FF).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      order['tags'] as String,
                                      style: TextStyle(fontFamily: 'Inter', color: isArchived ? Colors.grey : const Color(0xFFBC70FF), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.0),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text("Client: ${order['client']}", style: TextStyle(fontFamily: 'Inter', color: isArchived ? Colors.grey : const Color(0xFF4CC9F0), fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 20),
                              
                              if (!isArchived) ...[
                                Row(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: LinearProgressIndicator(
                                          value: order['progress'] as double, minHeight: 6,
                                          backgroundColor: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFBC70FF)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(order['progressText'] as String, style: TextStyle(fontFamily: 'Inter', color: isDark ? Colors.white : Colors.black87, fontSize: 12, fontWeight: FontWeight.w700)),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                if (isWeb)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildPhaseInfo(order['phase'], isDark),
                                      _buildDeadlineInfo(order['deadline'], order['isOverdue'], isDark),
                                    ],
                                  )
                                else
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildPhaseInfo(order['phase'], isDark),
                                      const SizedBox(height: 8),
                                      _buildDeadlineInfo(order['deadline'], order['isOverdue'], isDark),
                                    ],
                                  )
                              ] else ...[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child: Text("Completed on ${order['completedDate']}", style: const TextStyle(fontFamily: 'Inter', color: Colors.grey, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                    const Text("View Delivery", style: TextStyle(fontFamily: 'Inter', color: Color(0xFFBC70FF), fontSize: 12, fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseInfo(String phase, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.account_tree_outlined, color: isDark ? Colors.white54 : Colors.black45, size: 14),
        const SizedBox(width: 6),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(text: "Phase: ", style: TextStyle(fontFamily: 'Inter', color: isDark ? Colors.white54 : Colors.black54, fontSize: 12)),
              TextSpan(text: phase, style: TextStyle(fontFamily: 'Inter', color: isDark ? Colors.white : Colors.black87, fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
          maxLines: 1, overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildDeadlineInfo(String deadline, bool isOverdue, bool isDark) {
    final alertColor = const Color(0xFFF72585);
    final normalColor = isDark ? Colors.white54 : Colors.black54;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.schedule_rounded, color: isOverdue ? alertColor : normalColor, size: 14),
        const SizedBox(width: 6),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(text: "Deadline: ", style: TextStyle(fontFamily: 'Inter', color: isOverdue ? alertColor : normalColor, fontSize: 12)),
              TextSpan(text: deadline, style: TextStyle(fontFamily: 'Inter', color: isOverdue ? alertColor : (isDark ? Colors.white : Colors.black87), fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineSection(bool isDark, bool isWeb) {
    return FadeTransition(
      opacity: _timelineFade,
      child: SlideTransition(
        position: _timelineSlide,
        child: Container(
          padding: EdgeInsets.all(isWeb ? 32 : 20),
          decoration: _glassDecoration(isDark),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Milestone Timeline", style: TextStyle(fontFamily: 'Inter', color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 24),
              _buildTimelineStep(title: "Concept Approval", description: "Moodboards and references verified.", metaInfo: "Completed Aug 12", state: _TimelineState.completed, isFirst: true, isDark: isDark),
              _buildTimelineStep(title: "Block-out & Scaling", description: "Basic geometry and proportions.", metaInfo: "Completed Aug 15", state: _TimelineState.completed, isDark: isDark),
              _buildTimelineStep(title: "High Poly Details", description: "Adding microscopic detail and surfacing.", state: _TimelineState.active, hasActions: true, isDark: isDark),
              _buildTimelineStep(title: "Retopology & UVs", description: "Optimization for real-time performance.", state: _TimelineState.future, isLast: true, isDark: isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String text, bool isActive, bool isDark) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: isActive ? null : Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1)),
      ),
      child: Text(
        text,
        style: TextStyle(fontFamily: 'Inter', color: isActive ? (isDark ? Colors.white : Colors.black87) : (isDark ? Colors.white60 : Colors.black54), fontSize: 12, fontWeight: isActive ? FontWeight.w700 : FontWeight.w500),
      ),
    );
  }

  Widget _buildTimelineStep({required String title, required String description, String? metaInfo, required _TimelineState state, bool isFirst = false, bool isLast = false, bool hasActions = false, required bool isDark}) {
    final Color activeColor = const Color(0xFFBC70FF);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Path Column
          SizedBox(
            width: 32,
            child: Column(
              children: [
                if (!isFirst) Container(width: 2, height: 16, color: state == _TimelineState.completed || state == _TimelineState.active ? activeColor.withOpacity(0.4) : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05))),
                if (isFirst) const SizedBox(height: 16),
                Container(
                  width: 14, height: 14,
                  decoration: BoxDecoration(
                    color: state == _TimelineState.completed ? const Color(0xFF4CC9F0) : (state == _TimelineState.active ? activeColor : (isDark ? Colors.white24 : Colors.black12)),
                    shape: BoxShape.circle,
                    boxShadow: state == _TimelineState.active ? [BoxShadow(color: activeColor.withOpacity(0.5), blurRadius: 8, spreadRadius: 2)] : null,
                  ),
                ),
                if (!isLast) Expanded(child: Container(width: 2, color: state == _TimelineState.completed ? activeColor.withOpacity(0.4) : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)))),
                if (isLast) const SizedBox(height: 32),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Content Column
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 13.0, bottom: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(title, style: TextStyle(fontFamily: 'Inter', color: state == _TimelineState.future ? (isDark ? Colors.white54 : Colors.black45) : (isDark ? Colors.white : Colors.black87), fontSize: 14, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      if (state == _TimelineState.completed) const Icon(Icons.check_circle_rounded, color: Color(0xFF4CC9F0), size: 16),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(description, style: TextStyle(fontFamily: 'Inter', color: state == _TimelineState.future ? (isDark ? Colors.white38 : Colors.black38) : (isDark ? Colors.white70 : Colors.black54), fontSize: 12.5)),
                  if (metaInfo != null && metaInfo.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(metaInfo, style: const TextStyle(fontFamily: 'Inter', color: Colors.grey, fontSize: 11)),
                  ],
                  if (hasActions) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isDark ? Colors.white : Colors.black87,
                            side: BorderSide(color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Upload File", style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: activeColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: const Text("Approve", style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
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

enum _TimelineState { completed, active, future }