import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Your custom dashboards
import 'widgets/creator_analytics_dashboard.dart';
import 'widgets/creator_wallet_dashboard.dart';
import 'widgets/creator_order_management.dart';

enum FreelanceHubView {
  discovery,
  analytics,
  wallet,
  orders,
}

class FreelanceHubScreen extends StatefulWidget {
  const FreelanceHubScreen({super.key});

  @override
  State<FreelanceHubScreen> createState() => _FreelanceHubScreenState();
}

class _FreelanceHubScreenState extends State<FreelanceHubScreen> {
  FreelanceHubView _activeView = FreelanceHubView.discovery;

  int _webActiveNavIndex = 3;
  int? _webHoverNavIndex;

  final List<SpecialistModel> trendingSpecialists = const [
    SpecialistModel(
      heroImage:
          'https://images.unsplash.com/photo-1620641788421-7a1c342ea42e?q=80&w=600&auto=format&fit=crop',
      avatar:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=150&auto=format&fit=crop',
      name: 'Elias Thorne',
      role: 'Character Sculptor & Rigger',
      rating: 4.9,
      reviews: 124,
      startingPrice: '\$1,200',
    ),
    SpecialistModel(
      heroImage:
          'https://images.unsplash.com/photo-1550745165-9bc0b252726f?q=80&w=600&auto=format&fit=crop',
      avatar:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=150&auto=format&fit=crop',
      name: 'Mina Volkov',
      role: 'Environment Architect',
      rating: 5.0,
      reviews: 89,
      startingPrice: '\$3,500',
    ),
    SpecialistModel(
      heroImage:
          'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=600&auto=format&fit=crop',
      avatar:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=150&auto=format&fit=crop',
      name: 'Arlo Chen',
      role: 'VFX & Motion Graphics',
      rating: 4.8,
      reviews: 215,
      startingPrice: '\$900',
    ),
  ];

  final List<ArtistModel> discoverArtists = const [
    ArtistModel(
      image:
          'https://images.unsplash.com/photo-1614850523459-c2f4c699c52e?q=80&w=400&auto=format&fit=crop',
      avatar:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=150&auto=format&fit=crop',
      name: 'Tech Prophet',
      role: 'Hard Surface Modeler',
      hourlyRate: '\$85/hr',
      rating: 4.7,
    ),
    ArtistModel(
      image:
          'https://images.unsplash.com/photo-1550751827-4bd374c3f58b?q=80&w=400&auto=format&fit=crop',
      avatar:
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=150&auto=format&fit=crop',
      name: 'Lumina Studio',
      role: 'Lighting Specialist',
      hourlyRate: '\$120/hr',
      rating: 5.0,
    ),
    ArtistModel(
      image:
          'https://images.unsplash.com/photo-1574169208507-84376144848b?q=80&w=400&auto=format&fit=crop',
      avatar:
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=150&auto=format&fit=crop',
      name: 'Rune Carver',
      role: 'Texture Artist',
      hourlyRate: '\$95/hr',
      rating: 4.9,
    ),
    ArtistModel(
      image:
          'https://images.unsplash.com/photo-1518770660439-4636190af475?q=80&w=400&auto=format&fit=crop',
      avatar:
          'https://images.unsplash.com/photo-1552058544-f2b08422138a?q=80&w=150&auto=format&fit=crop',
      name: 'Orbit Design',
      role: 'Archviz Specialist',
      hourlyRate: '\$150/hr',
      rating: 4.8,
    ),
  ];

  void _setActiveView(FreelanceHubView view) {
    if (_activeView == view) return;
    setState(() => _activeView = view);
  }

  void _safePushNamed(String routeName) {
    if (!mounted) return;
    Navigator.pushNamed(context, routeName);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isWeb = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0C0414) : const Color(0xFFF8FAFC),
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(child: MeshyParticleBackground(isDark: isDark)),
          Positioned.fill(child: _ReactHeroBackground(isDark: isDark)),
          SafeArea(
            child: isWeb ? _buildWebLayout(isDark) : _buildMobileLayout(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildWebLayout(bool isDark) {
    final width = MediaQuery.sizeOf(context).width;
    final contentWidth = width > 1180 ? 1180.0 : width;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: contentWidth),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildHomeStyleTopBar(isDark),
            const SizedBox(height: 24),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSidebar(isDark),
                  const SizedBox(width: 24),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      child: _buildMainContent(isDark, isWeb: true),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(bool isDark) {
    return Column(
      children: [
        AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Freelance Hub',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          iconTheme: IconThemeData(
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
        _buildMobileNavChips(isDark),
        const SizedBox(height: 12),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _buildMainContent(isDark, isWeb: false),
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent(bool isDark, {required bool isWeb}) {
    switch (_activeView) {
      case FreelanceHubView.analytics:
        return const CreatorAnalyticsDashboard(key: ValueKey('analytics'));
      case FreelanceHubView.wallet:
        return const CreatorWalletDashboard(key: ValueKey('wallet'));
      case FreelanceHubView.orders:
        return const CreatorOrderManagementDashboard(key: ValueKey('orders'));
      case FreelanceHubView.discovery:
        return _buildDiscoveryView(isDark, isWeb: isWeb);
    }
  }

  Widget _buildDiscoveryView(bool isDark, {required bool isWeb}) {
    return SingleChildScrollView(
      key: const PageStorageKey<String>('discovery'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isWeb ? 0 : 16),
            child: _buildProfessionalHero(isDark, isWeb: isWeb),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Trending Specialists',
                    style: TextStyle(
                      color:
                          isDark ? Colors.white : const Color(0xFF1E293B),
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 330,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: trendingSpecialists.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                return _buildGlassSpecialistCard(
                  trendingSpecialists[index],
                  isDark,
                );
              },
            ),
          ),
          const SizedBox(height: 48),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Discover Artists',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final available = constraints.maxWidth;
                    final crossAxisCount =
                        available > 800 ? 3 : (available > 500 ? 2 : 1);

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: discoverArtists.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.85,
                      ),
                      itemBuilder: (context, index) {
                        return _buildGlassArtistCard(
                          discoverArtists[index],
                          isDark,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalHero(bool isDark, {required bool isWeb}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(isWeb ? 32 : 20),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withValues(alpha: 0.20)
                : Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.white,
            ),
            boxShadow: isDark
                ? const []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CC9F0).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: const Color(0xFF4CC9F0).withValues(alpha: 0.3),
                  ),
                ),
                child: const Text(
                  'R2V FREELANCE NETWORK',
                  style: TextStyle(
                    color: Color(0xFF4CC9F0),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Hire Top-Tier 3D Talent',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  fontSize: isWeb ? 36 : 28,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Connect with elite environmental architects, sculptors, and animators. Get your assets built professionally and automatically managed in your workspace.',
                style: TextStyle(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.70)
                      : Colors.black54,
                  fontSize: 14.5,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isWeb ? 18 : 10,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.15)
                        : Colors.black.withValues(alpha: 0.05),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      color: isDark ? Colors.white54 : Colors.black45,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: "Search 'Character Rigger'...",
                          hintStyle: TextStyle(
                            color: isDark ? Colors.white38 : Colors.black38,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          isCollapsed: true,
                        ),
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) {},
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF8A4FFF),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Search',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassSpecialistCard(SpecialistModel data, bool isDark) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.25)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.white,
        ),
        boxShadow: isDark
            ? const []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(22),
                    topRight: Radius.circular(22),
                  ),
                  child: _AppNetworkImage(
                    url: data.heroImage,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    borderRadius: 0,
                  ),
                ),
                Positioned(
                  bottom: -20,
                  left: 16,
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF1A1B20)
                            : Colors.white,
                        width: 3,
                      ),
                    ),
                    child: ClipOval(
                      child: _AppNetworkImage(
                        url: data.avatar,
                        fit: BoxFit.cover,
                        borderRadius: 999,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 26, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.name,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  data.role,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${data.rating} (${data.reviews})',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black87,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'From ${data.startingPrice}',
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassArtistCard(ArtistModel data, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.25)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.white,
        ),
        boxShadow: isDark
            ? const []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: _AppNetworkImage(
                url: data.image,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                borderRadius: 0,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: ClipOval(
                        child: _AppNetworkImage(
                          url: data.avatar,
                          fit: BoxFit.cover,
                          borderRadius: 999,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        data.name,
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  data.role,
                  style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.black54,
                    fontSize: 11.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        data.hourlyRate,
                        style: const TextStyle(
                          color: Color(0xFF8A4FFF),
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${data.rating}',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black87,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: 250,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withValues(alpha: 0.20)
                : Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.white,
            ),
            boxShadow: isDark
                ? const []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Freelance Menu',
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black45,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildSidebarItem(
                icon: Icons.search_rounded,
                title: 'Find Talent',
                isActive: _activeView == FreelanceHubView.discovery,
                isDark: isDark,
                onTap: () => _setActiveView(FreelanceHubView.discovery),
              ),
              const SizedBox(height: 4),
              _buildSidebarItem(
                icon: Icons.bar_chart_rounded,
                title: 'Analytics',
                isActive: _activeView == FreelanceHubView.analytics,
                isDark: isDark,
                onTap: () => _setActiveView(FreelanceHubView.analytics),
              ),
              const SizedBox(height: 4),
              _buildSidebarItem(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Wallet',
                isActive: _activeView == FreelanceHubView.wallet,
                isDark: isDark,
                onTap: () => _setActiveView(FreelanceHubView.wallet),
              ),
              const SizedBox(height: 4),
              _buildSidebarItem(
                icon: Icons.receipt_long_outlined,
                title: 'Manage Orders',
                isActive: _activeView == FreelanceHubView.orders,
                isDark: isDark,
                onTap: () => _setActiveView(FreelanceHubView.orders),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileNavChips(bool isDark) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        children: [
          _mobileChip('Find Talent', FreelanceHubView.discovery, isDark),
          _mobileChip('Analytics', FreelanceHubView.analytics, isDark),
          _mobileChip('Wallet', FreelanceHubView.wallet, isDark),
          _mobileChip('Manage Orders', FreelanceHubView.orders, isDark),
        ],
      ),
    );
  }

  Widget _mobileChip(String label, FreelanceHubView view, bool isDark) {
    final active = _activeView == view;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => _setActiveView(view),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: active
                ? const Color(0xFF8A4FFF)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05)),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: active
                  ? Colors.transparent
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.transparent),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active
                  ? Colors.white
                  : (isDark ? Colors.white70 : Colors.black87),
              fontSize: 13,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String title,
    required bool isActive,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 16, left: 8),
      decoration: BoxDecoration(
        color: isActive
            ? (isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.04))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                icon,
                color: isActive
                    ? const Color(0xFFBC70FF)
                    : (isDark ? Colors.white54 : Colors.black54),
                size: 20,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isActive
                        ? (isDark ? Colors.white : const Color(0xFF1E293B))
                        : (isDark ? Colors.white70 : Colors.black87),
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeStyleTopBar(bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.9),
            ),
            boxShadow: isDark
                ? const []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
          ),
          child: Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                size: 26,
                color: Color(0xFFBC70FF),
              ),
              const SizedBox(width: 8),
              Text(
                'R2V FREELANCE',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              SizedBox(width: 520, child: _buildHomeStyleNavTabs(isDark)),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => _safePushNamed('/profile'),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.15)
                        : Colors.black.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeStyleNavTabs(bool isDark) {
    const labels = ['Home', 'AI Studio', 'Marketplace', 'Freelance', 'Settings'];
    const routes = ['/home', '/aichat', '/explore', null, '/settings'];
    final navCount = labels.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final segmentWidth = constraints.maxWidth / navCount;
        const indicatorWidth = 48.0;
        final underlineIndex =
            (_webHoverNavIndex ?? _webActiveNavIndex).clamp(0, navCount - 1);
        final underlineLeft =
            underlineIndex * segmentWidth + (segmentWidth - indicatorWidth) / 2;

        return SizedBox(
          height: 34,
          child: Stack(
            children: [
              Row(
                children: List.generate(navCount, (index) {
                  final isActive = _webActiveNavIndex == index;
                  final isHover = _webHoverNavIndex == index;
                  final effectiveActive = isActive || isHover;

                  return MouseRegion(
                    onEnter: (_) {
                      if (_webHoverNavIndex != index) {
                        setState(() => _webHoverNavIndex = index);
                      }
                    },
                    onExit: (_) {
                      if (_webHoverNavIndex != null) {
                        setState(() => _webHoverNavIndex = null);
                      }
                    },
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        if (_webActiveNavIndex != index) {
                          setState(() => _webActiveNavIndex = index);
                        }
                        final route = routes[index];
                        if (route != null) _safePushNamed(route);
                      },
                      child: SizedBox(
                        width: segmentWidth,
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 120),
                            style: TextStyle(
                              color: effectiveActive
                                  ? (isDark
                                      ? Colors.white
                                      : const Color(0xFF1E293B))
                                  : (isDark
                                      ? Colors.white.withValues(alpha: 0.7)
                                      : Colors.black54),
                              fontWeight: effectiveActive
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              fontSize: 13.5,
                            ),
                            child: Text(labels[index]),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                left: underlineLeft,
                bottom: 0,
                child: Container(
                  width: indicatorWidth,
                  height: 2,
                  decoration: BoxDecoration(
                    color: const Color(0xFFBC70FF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SpecialistModel {
  final String heroImage;
  final String avatar;
  final String name;
  final String role;
  final double rating;
  final int reviews;
  final String startingPrice;

  const SpecialistModel({
    required this.heroImage,
    required this.avatar,
    required this.name,
    required this.role,
    required this.rating,
    required this.reviews,
    required this.startingPrice,
  });
}

class ArtistModel {
  final String image;
  final String avatar;
  final String name;
  final String role;
  final String hourlyRate;
  final double rating;

  const ArtistModel({
    required this.image,
    required this.avatar,
    required this.name,
    required this.role,
    required this.hourlyRate,
    required this.rating,
  });
}

class _AppNetworkImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final double borderRadius;

  const _AppNetworkImage({
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Colors.transparent,
      child: Image.network(
        url,
        fit: fit,
        width: width,
        height: height,
        filterQuality: FilterQuality.medium,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              gradient: const LinearGradient(
                colors: [Color(0xFF1F2937), Color(0xFF374151)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.broken_image_outlined,
              color: Colors.white70,
              size: 28,
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              color: Colors.white.withValues(alpha: 0.04),
            ),
            child: const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
      ),
    );
  }
}

class _ReactHeroBackground extends StatelessWidget {
  final bool isDark;

  const _ReactHeroBackground({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
        child: Stack(
          children: [
            Positioned(
              top: -150,
              right: -50,
              child: Transform.rotate(
                angle: -0.35,
                child: Row(
                  children: [
                    _GradientBlob(isDark: isDark),
                    const SizedBox(width: 50),
                    _GradientBlob(isDark: isDark),
                    const SizedBox(width: 50),
                    _GradientBlob(isDark: isDark),
                  ],
                ),
              ),
            ),
            Positioned(
              top: -50,
              right: -150,
              child: Transform.rotate(
                angle: -0.35,
                child: Row(
                  children: [
                    _GradientBlob(isDark: isDark),
                    const SizedBox(width: 50),
                    _GradientBlob(isDark: isDark),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientBlob extends StatelessWidget {
  final bool isDark;

  const _GradientBlob({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.skewY(-0.7),
      child: Container(
        width: 140,
        height: 400,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    Colors.white.withValues(alpha: 0.15),
                    Colors.blue.shade300.withValues(alpha: 0.35),
                  ]
                : [
                    const Color(0xFFBC70FF).withValues(alpha: 0.25),
                    const Color(0xFF4895EF).withValues(alpha: 0.25),
                  ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
      ),
    );
  }
}

class MeshyParticleBackground extends StatelessWidget {
  final bool isDark;

  const MeshyParticleBackground({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: _MeshyBgCore(isDark: isDark),
    );
  }
}

class _MeshyBgCore extends StatefulWidget {
  final bool isDark;

  const _MeshyBgCore({required this.isDark});

  @override
  State<_MeshyBgCore> createState() => _MeshyBgCoreState();
}

class _MeshyBgCoreState extends State<_MeshyBgCore>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  late final ValueNotifier<int> _repaint;
  final math.Random _rng = math.Random(42);

  Size _size = Size.zero;
  Offset _mouse = Offset.zero;
  bool _hasMouse = false;

  late List<_Particle> _particles;
  double _time = 0;

  @override
  void initState() {
    super.initState();
    _particles = <_Particle>[];
    _repaint = ValueNotifier<int>(0);

    _ticker = createTicker((elapsed) {
      if (_size == Size.zero) return;

      _time = elapsed.inMilliseconds / 1000.0;
      const dt = 1 / 60;

      for (final p in _particles) {
        p.pos = p.pos + p.vel * dt;

        if (p.pos.dx < 0 || p.pos.dx > _size.width) {
          p.vel = Offset(-p.vel.dx, p.vel.dy);
        }
        if (p.pos.dy < 0 || p.pos.dy > _size.height) {
          p.vel = Offset(p.vel.dx, -p.vel.dy);
        }

        p.pos = Offset(
          p.pos.dx.clamp(0.0, _size.width),
          p.pos.dy.clamp(0.0, _size.height),
        );
      }

      _repaint.value++;
    });

    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _repaint.dispose();
    super.dispose();
  }

  void _ensureParticles(Size size) {
    if (size == Size.zero) return;

    final area = size.width * size.height;
    int target = (area / 18000).round();
    target = target.clamp(35, 95);

    if (_particles.length == target) return;

    _particles = List.generate(target, (_) {
      final pos = Offset(
        _rng.nextDouble() * size.width,
        _rng.nextDouble() * size.height,
      );
      final speed = 8 + _rng.nextDouble() * 18;
      final angle = _rng.nextDouble() * math.pi * 2;
      final vel = Offset(math.cos(angle), math.sin(angle)) * speed;
      final radius = 1.2 + _rng.nextDouble() * 1.9;

      return _Particle(pos: pos, vel: vel, radius: radius);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final newSize = Size(constraints.maxWidth, constraints.maxHeight);
        if (_size != newSize) {
          _size = newSize;
          _ensureParticles(newSize);
        }

        return MouseRegion(
          onHover: (event) {
            _mouse = event.localPosition;
            _hasMouse = true;
            _repaint.value++;
          },
          onExit: (_) {
            _hasMouse = false;
            _repaint.value++;
          },
          child: CustomPaint(
            painter: _MeshPainter(
              particles: _particles,
              time: _time,
              size: _size,
              mouse: _mouse,
              hasMouse: _hasMouse,
              isDark: widget.isDark,
              repaint: _repaint,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }
}

class _Particle {
  Offset pos;
  Offset vel;
  final double radius;

  _Particle({
    required this.pos,
    required this.vel,
    required this.radius,
  });
}

class _MeshPainter extends CustomPainter {
  final List<_Particle> particles;
  final double time;
  final Size size;
  final Offset mouse;
  final bool hasMouse;
  final bool isDark;

  _MeshPainter({
    required this.particles,
    required this.time,
    required this.size,
    required this.mouse,
    required this.hasMouse,
    required this.isDark,
    required Listenable repaint,
  }) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size _) {
    final rect = Offset.zero & size;

    final bgColors = isDark
        ? const [
            Color(0xFF0F1118),
            Color(0xFF141625),
            Color(0xFF0B0D14),
          ]
        : const [
            Color(0xFFF8FAFC),
            Color(0xFFF1F5F9),
            Color(0xFFE2E8F0),
          ];

    final bg = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: bgColors,
        stops: [0.0, 0.55, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, bg);

    void glowBlob(Offset center, double radius, Color color, double opacity) {
      final paint = Paint()
        ..color = color.withValues(alpha: opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 90);
      canvas.drawCircle(center, radius, paint);
    }

    final center = Offset(size.width * 0.55, size.height * 0.35);
    final wobble = Offset(
      math.sin(time * 0.5) * 40,
      math.cos(time * 0.45) * 30,
    );

    glowBlob(
      center + wobble,
      280,
      isDark ? const Color(0xFF8A4FFF) : const Color(0xFFA855F7),
      isDark ? 0.18 : 0.12,
    );

    glowBlob(
      Offset(size.width * 0.25, size.height * 0.70) +
          Offset(
            math.cos(time * 0.35) * 35,
            math.sin(time * 0.32) * 28,
          ),
      240,
      isDark ? const Color(0xFF4895EF) : const Color(0xFF38BDF8),
      isDark ? 0.14 : 0.10,
    );

    Offset parallax = Offset.zero;
    if (hasMouse) {
      final dx = (mouse.dx / math.max(1.0, size.width) - 0.5) * 18;
      final dy = (mouse.dy / math.max(1.0, size.height) - 0.5) * 18;
      parallax = Offset(dx, dy);
    }

    final connectDist = math.min(size.width, size.height) * 0.15;
    final connectDist2 = connectDist * connectDist;

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < particles.length; i++) {
      final a = particles[i];
      final ap = a.pos + parallax * 0.25;

      for (int j = i + 1; j < particles.length; j++) {
        final b = particles[j];
        final bp = b.pos + parallax * 0.25;

        final dx = ap.dx - bp.dx;
        final dy = ap.dy - bp.dy;
        final d2 = dx * dx + dy * dy;

        if (d2 < connectDist2) {
          final t = 1.0 - (math.sqrt(d2) / connectDist);
          linePaint.color = isDark
              ? Colors.white.withValues(alpha: 0.06 * t)
              : const Color(0xFF8A4FFF).withValues(alpha: 0.15 * t);
          canvas.drawLine(ap, bp, linePaint);
        }
      }
    }

    final dotPaint = Paint()..style = PaintingStyle.fill;
    for (final particle in particles) {
      final pos = particle.pos + parallax * 0.6;
      dotPaint.color = isDark
          ? Colors.white.withValues(alpha: 0.12)
          : const Color(0xFF8A4FFF).withValues(alpha: 0.25);
      canvas.drawCircle(pos, particle.radius, dotPaint);
    }

    final vignetteColors = isDark
        ? [Colors.transparent, Colors.black.withValues(alpha: 0.55)]
        : [Colors.transparent, Colors.white.withValues(alpha: 0.4)];

    final vignette = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.15,
        colors: vignetteColors,
        stops: const [0.55, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, vignette);
  }

  @override
  bool shouldRepaint(covariant _MeshPainter oldDelegate) {
    return oldDelegate.isDark != isDark ||
        oldDelegate.size != size ||
        oldDelegate.hasMouse != hasMouse ||
        oldDelegate.mouse != mouse ||
        oldDelegate.time != time ||
        oldDelegate.particles.length != particles.length;
  }
}