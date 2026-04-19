// home_screen.dart
import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../api/r2v_api.dart';
import '../api/api_exception.dart';
import '../main.dart'; // Needed for themeNotifier

class MarketModel {
  final String name;
  final String author;
  final String description;
  final List<String> tags;
  final String likes;
  final String tagLabel;
  final String glbAssetPath;
  final String posterAssetPath;

  const MarketModel({
    required this.name,
    required this.author,
    required this.description,
    required this.tags,
    required this.likes,
    required this.tagLabel,
    required this.glbAssetPath,
    required this.posterAssetPath,
  });
}

class HeroModel {
  final String src;
  final String prompt;

  const HeroModel({
    required this.src,
    required this.prompt,
  });
}

class HomeScreen extends StatefulWidget {
  final String username;

  const HomeScreen({super.key, this.username = 'User'});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;
  int _webActiveNavIndex = 0;
  int? _webHoverNavIndex;

  late final ScrollController _scrollController;
  bool _collapsed = false;

  int _selectedUseCase = 0;
  late final ScrollController _useCaseScrollController;
  Timer? _useCaseAutoTimer;
  bool _pauseUseCaseAutoScroll = false;
  bool _isUserDraggingUseCases = false;

  bool _lastIsWeb = false;

  MarketModel? _activeMarketModel;

  bool _loadingSummary = false;
  String _displayName = '';

  final List<HeroModel> _heroModels = const [
    HeroModel(
      src: "assets/models/Ankit.glb",
      prompt: "A futuristic humanoid character with clean proportions and a premium showcase look.",
    ),
    HeroModel(
      src: "assets/models/StarBucks.glb",
      prompt: "Starbucks cup with logo, soft studio lighting.",
    ),
    HeroModel(
      src: "assets/models/GOLD KART.glb",
      prompt: "A detailed vintage car with polished brass, cinematic studio lighting.",
    ),
    HeroModel(
      src: "assets/models/apple-vision-pro.glb",
      prompt: "A sleek mixed-reality headset with glossy visor, minimal studio lighting.",
    ),
  ];

  late HeroModel _currentHeroModel;

  Map<String, dynamic> _continueAI = {
    "title": "Neon sci-fi car in rainy alley",
    "subtitle": "Last prompt • 2 hours ago",
    "route": "/aichat",
    "accent": const Color(0xFF8A4FFF),
    "icon": Icons.bolt_rounded,
  };

  Map<String, dynamic> _continueScan = {
    "title": "Vintage Chair Scan",
    "subtitle": "Draft scan • 10 minutes ago",
    "route": "/photo_scan",
    "accent": const Color(0xFFF72585),
    "icon": Icons.photo_camera_rounded,
  };

  Map<String, dynamic> _continueMarket = {
    "title": "Porsche 911 Asset",
    "subtitle": "Last viewed • yesterday",
    "route": "/explore",
    "accent": const Color(0xFF4895EF),
    "icon": Icons.storefront_rounded,
  };

  Map<String, int> _stats = {
    "Models": 12,
    "Scans": 5,
    "Downloads": 9,
  };

  final List<Map<String, String>> _useCases = const [
    {"id": "film", "title": "Film Production", "asset": "assets/usecases/film.png"},
    {"id": "product", "title": "Product Design", "asset": "assets/usecases/product.png"},
    {"id": "edu", "title": "Education", "asset": "assets/usecases/education.png"},
    {"id": "game", "title": "Game\nDevelopment", "asset": "assets/usecases/game.png"},
    {"id": "print", "title": "3D Printing", "asset": "assets/usecases/printing.png"},
    {"id": "vr", "title": "VR/AR", "asset": "assets/usecases/vr.png"},
    {"id": "interior", "title": "Interior Design", "asset": "assets/usecases/interior.png"},
  ];

  final List<Map<String, dynamic>> _useCaseDetails = const [
    {
      "id": "film",
      "title": "Film Production",
      "subtitle": "Cut costs and accelerate VFX and previs workflows with R2V AI",
      "bullets": ["Fast Previs & Look Dev", "Streamlined VFX Workflow", "Industry-Standard Quality"],
      "cta": "Explore More",
      "ctaRoute": "/explore",
      "preview": "assets/usecase_previews/film.png",
      "accent": Color(0xFF9CA3AF),
    },
    {
      "id": "product",
      "title": "Product Design",
      "subtitle": "Prototype faster with AI-assisted 3D concepts and ready assets.",
      "bullets": ["Rapid Ideation", "Accurate Scale Mockups", "Export-Ready Models"],
      "cta": "Explore More",
      "ctaRoute": "/explore",
      "preview": "assets/usecase_previews/product.png",
      "accent": Color(0xFF38BDF8),
    },
    {
      "id": "edu",
      "title": "Education",
      "subtitle": "Teach 3D concepts interactively with instant models and scans.",
      "bullets": ["Interactive Lessons", "Visual Learning", "Student Projects"],
      "cta": "Explore More",
      "ctaRoute": "/explore",
      "preview": "assets/usecase_previews/education.png",
      "accent": Color(0xFFFDE68A),
    },
    {
      "id": "game",
      "title": "Game Development",
      "subtitle": "Generate and iterate on assets faster for your next game world.",
      "bullets": ["Concept to Asset", "Style Variations", "Faster Iteration"],
      "cta": "Explore More",
      "ctaRoute": "/explore",
      "preview": "assets/usecase_previews/game.png",
      "accent": Color(0xFF22D3EE),
    },
    {
      "id": "print",
      "title": "3D Printing",
      "subtitle": "Scan real objects and convert ideas into printable 3D models.",
      "bullets": ["Scan to STL", "Repair & Optimize", "Print-Ready Output"],
      "cta": "Start Scan",
      "ctaRoute": "/photo_scan",
      "preview": "assets/usecase_previews/printing.png",
      "accent": Color(0xFFA3E635),
    },
    {
      "id": "vr",
      "title": "VR/AR",
      "subtitle": "Build immersive experiences with quick, clean 3D content.",
      "bullets": ["Lightweight Assets", "Realistic Textures", "GLB/FBX Export"],
      "cta": "Explore More",
      "ctaRoute": "/explore",
      "preview": "assets/usecase_previews/vr.png",
      "accent": Color(0xFFC084FC),
    },
    {
      "id": "interior",
      "title": "Interior Design",
      "subtitle": "Create and visualize spaces with furniture and room assets.",
      "bullets": ["Room Mockups", "Asset Library", "Client Presentations"],
      "cta": "Explore More",
      "ctaRoute": "/explore",
      "preview": "assets/usecase_previews/interior.png",
      "accent": Color(0xFFFCA5A5),
    },
  ];

  final List<MarketModel> _models = const [
    MarketModel(
      name: "Porsche 911",
      author: "McLaughlin Rh",
      description: "911 sports car, clean geometry, studio lighting.",
      tags: ["car", "game-ready", "complex", "edges", "symmetric"],
      likes: "1.2k",
      tagLabel: "Saved",
      glbAssetPath: "assets/models/911.glb",
      posterAssetPath: "assets/posters/911.png",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentHeroModel = _heroModels[Random().nextInt(_heroModels.length)];
    _scrollController = ScrollController()..addListener(_onScroll);
    _useCaseScrollController = ScrollController();
    _displayName = widget.username;
    _startUseCaseAutoSwitch();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    setState(() => _loadingSummary = true);
    try {
      final profile = await r2vProfile.me();
      final dashboard = await r2vDashboard.me();
      final aiJobs = await r2vAiJobs.listJobs(limit: 1);
      final scanJobs = await r2vScanJobs.listJobs(limit: 1);
      final assets = await r2vMarketplace.listAssets(limit: 1);

      if (!mounted) return;

      setState(() {
        _displayName = profile.username.isNotEmpty ? profile.username : _displayName;
        _stats = {
          "Models": dashboard.assets,
          "Scans": dashboard.scanJobs,
          "Downloads": dashboard.downloads,
        };

        if (aiJobs.isNotEmpty) {
          final job = aiJobs.first;
          _continueAI = {
            "title": job.prompt?.isNotEmpty == true ? job.prompt! : "AI job ${job.id}",
            "subtitle": "Status: ${job.status}",
            "route": "/aichat",
            "accent": const Color(0xFF8A4FFF),
            "icon": Icons.bolt_rounded,
          };
        }

        if (scanJobs.isNotEmpty) {
          final job = scanJobs.first;
          _continueScan = {
            "title": "Scan job ${job.id}",
            "subtitle": "Status: ${job.status}",
            "route": "/photo_scan",
            "accent": const Color(0xFFF72585),
            "icon": Icons.photo_camera_rounded,
          };
        }

        if (assets.isNotEmpty) {
          final asset = assets.first;
          _continueMarket = {
            "title": asset.title,
            "subtitle": asset.category,
            "route": "/explore",
            "accent": const Color(0xFF4895EF),
            "icon": Icons.storefront_rounded,
          };
        }
      });
    } catch (_) {
      // Graceful degradation, continue showing defaults if fetch fails
    } finally {
      if (mounted) setState(() => _loadingSummary = false);
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final dir = _scrollController.position.userScrollDirection;
    if (dir == ScrollDirection.reverse && !_collapsed) {
      setState(() => _collapsed = true);
    } else if (dir == ScrollDirection.forward && _collapsed) {
      setState(() => _collapsed = false);
    }
  }

  void _startUseCaseAutoSwitch() {
    _useCaseAutoTimer?.cancel();
    _useCaseAutoTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      if (_pauseUseCaseAutoScroll) return;
      if (_isUserDraggingUseCases) return;

      if (_lastIsWeb) {
        if (_webActiveNavIndex != 0) return;
      } else {
        if (_selectedTab != 0) return;
      }

      setState(() => _selectedUseCase = (_selectedUseCase + 1) % _useCases.length);
    });
  }

  void _onUseCaseTap(int idx) {
    setState(() => _selectedUseCase = idx);
    setState(() => _pauseUseCaseAutoScroll = true);
    Future.delayed(const Duration(seconds: 6), () {
      if (!mounted) return;
      setState(() => _pauseUseCaseAutoScroll = false);
    });
  }

  @override
  void dispose() {
    _useCaseAutoTimer?.cancel();
    _scrollController.dispose();
    _useCaseScrollController.dispose();
    super.dispose();
  }

  Widget _heroModelViewer({double borderRadius = 20}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: ModelViewer(
        key: ValueKey(_currentHeroModel.src),
        src: _currentHeroModel.src,
        backgroundColor: Colors.transparent,
        autoRotate: true,
        autoRotateDelay: 0,
        rotationPerSecond: "25deg",
        cameraControls: false,
        disableZoom: true,
        environmentImage: "neutral",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isWeb = MediaQuery.of(context).size.width >= 900;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    _lastIsWeb = isWeb;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0414) : const Color(0xFFF8FAFC),
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(child: MeshyParticleBackground(isDark: isDark)),
          Positioned.fill(child: _ReactHeroBackground(isDark: isDark)),
          Positioned.fill(child: isWeb ? _buildWebHome(context, isDark) : _buildMobileHome(context, isDark)),
          if (_activeMarketModel != null)
            Positioned.fill(
              child: _HomeMarketModelPanel(
                model: _activeMarketModel!,
                onClose: () => setState(() => _activeMarketModel = null),
                isDark: isDark,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWebHome(BuildContext context, bool isDark) {
    final double w = MediaQuery.of(context).size.width;
    final double contentWidth = w > 1180 ? 1180 : w;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: contentWidth),
          child: Column(
            children: [
              const SizedBox(height: 24),
              _buildWebTopBar(context, isDark),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWebHeroSection(context, isDark),
                      const SizedBox(height: 18),
                      _SectionHeader(title: "Your stats", subtitle: "Quick overview", isDark: isDark),
                      const SizedBox(height: 12),
                      _StatsRow(stats: _stats, isDark: isDark),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => Navigator.pushNamed(context, '/analysis'),
                          icon: const Icon(Icons.analytics_outlined, color: Color(0xFF4CC9F0)),
                          label: const Text(
                            "View Full Analysis",
                            style: TextStyle(color: Color(0xFF4CC9F0), fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      _SectionHeader(title: "Continue", subtitle: "Jump back in", isDark: isDark),
                      const SizedBox(height: 12),
                      _ContinueRow(
                        items: [_continueAI, _continueScan, _continueMarket],
                        onTap: (item) => Navigator.pushNamed(context, item["route"] as String),
                        isDark: isDark,
                      ),
                      const SizedBox(height: 28),
                      _SectionHeader(title: "Use R2V for", subtitle: "Pick a category", isDark: isDark),
                      const SizedBox(height: 12),
                      MouseRegion(
                        onEnter: (_) => setState(() => _pauseUseCaseAutoScroll = true),
                        onExit: (_) => setState(() => _pauseUseCaseAutoScroll = false),
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (n) {
                            if (n is ScrollStartNotification) _isUserDraggingUseCases = true;
                            if (n is ScrollEndNotification) _isUserDraggingUseCases = false;
                            return false;
                          },
                          child: UseCasesRow(
                            items: _useCases,
                            selectedIndex: _selectedUseCase,
                            controller: _useCaseScrollController,
                            onTap: _onUseCaseTap,
                            isDark: isDark,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 320),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, anim) {
                          return SlideTransition(
                            position: Tween<Offset>(begin: const Offset(-0.06, 0), end: Offset.zero).animate(anim),
                            child: FadeTransition(opacity: anim, child: child),
                          );
                        },
                        child: UseCaseDetailsSection(
                          key: ValueKey(_useCaseDetails[_selectedUseCase]["id"]),
                          data: _useCaseDetails[_selectedUseCase],
                          onCta: () => Navigator.pushNamed(
                            context,
                            _useCaseDetails[_selectedUseCase]["ctaRoute"],
                          ),
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(height: 26),
                      if (_loadingSummary)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            "Updating…",
                            style: TextStyle(
                              color: isDark ? Colors.white.withOpacity(0.6) : Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebTopBar(BuildContext context, bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.75),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.9)),
            boxShadow: isDark
                ? []
                : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
          ),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, size: 26, color: Color(0xFFBC70FF)),
              const SizedBox(width: 8),
              Text(
                "R2V",
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              SizedBox(width: 520, child: _buildWebNavTabs(context, isDark)),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/profile'),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person, color: isDark ? Colors.white : const Color(0xFF1E293B), size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebNavTabs(BuildContext context, bool isDark) {
    final labels = ["Home", "AI Studio", "Marketplace", "Freelance", "Settings"];
    final navCount = labels.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final segmentWidth = totalWidth / navCount;
        const indicatorWidth = 48.0;
        final underlineIndex = (_webHoverNavIndex ?? _webActiveNavIndex).clamp(0, navCount - 1);
        final underlineLeft = underlineIndex * segmentWidth + (segmentWidth - indicatorWidth) / 2;

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
                    onEnter: (_) => setState(() => _webHoverNavIndex = index),
                    onExit: (_) => setState(() => _webHoverNavIndex = null),
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _webActiveNavIndex = index);
                        switch (index) {
                          case 0:
                            break;
                          case 1:
                            Navigator.pushNamed(context, '/aichat');
                            break;
                          case 2:
                            Navigator.pushNamed(context, '/explore');
                            break;
                          case 3:
                            Navigator.pushNamed(context, '/freelance_hub');
                            break;
                          case 4:
                            Navigator.pushNamed(context, '/settings');
                            break;
                        }
                      },
                      child: SizedBox(
                        width: segmentWidth,
                        child: Center(
                          child: _NavTextButton(label: labels[index], isActive: effectiveActive, isDark: isDark),
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

  Widget _buildWebHeroSection(BuildContext context, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.8)),
                  boxShadow: isDark
                      ? []
                      : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome back, @$_displayName",
                      style: TextStyle(color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54, fontSize: 15),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Turn your ideas\ninto 3D in seconds.",
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                        fontSize: 38,
                        height: 1.1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Use AI prompts, scan objects, or browse ready-made 3D assets.",
                      style: TextStyle(color: isDark ? Colors.white.withOpacity(0.8) : Colors.black87, fontSize: 15, height: 1.4),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pushNamed(context, '/aichat'),
                          icon: const Icon(Icons.bolt_rounded),
                          label: const Text("AI Studio"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8A4FFF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            elevation: isDark ? 0 : 4,
                          ),
                        ),
                        const SizedBox(width: 14),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pushNamed(context, '/photo_scan'),
                          icon: const Icon(Icons.photo_camera_rounded),
                          label: const Text("Scan"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF72585),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            elevation: isDark ? 0 : 4,
                          ),
                        ),
                        const SizedBox(width: 14),
                        OutlinedButton.icon(
                          onPressed: () => Navigator.pushNamed(context, '/explore'),
                          icon: const Icon(Icons.storefront_rounded),
                          label: const Text("Marketplace"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isDark ? Colors.white : const Color(0xFF1E293B),
                            side: BorderSide(color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1)),
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 32),
        Expanded(
          flex: 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                height: 320,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.5),
                  border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.white),
                  boxShadow: isDark
                      ? []
                      : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "“${_currentHeroModel.prompt}”",
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black87,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Create 3D models from prompts — in minutes",
                      style: TextStyle(
                        color: isDark ? Colors.white.withOpacity(0.65) : Colors.black54,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: RadialGradient(
                            center: Alignment.center,
                            radius: 0.9,
                            colors: [
                              const Color(0xFF8A4FFF).withOpacity(0.20),
                              const Color(0xFF4895EF).withOpacity(0.10),
                              Colors.transparent,
                            ],
                          ),
                          border: Border.all(
                            color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
                          ),
                        ),
                        child: _heroModelViewer(borderRadius: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileHome(BuildContext context, bool isDark) {
    final double w = MediaQuery.of(context).size.width;
    final double contentWidth = w > 520 ? 520.0 : w;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(_collapsed ? 56 : 70),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.only(left: 14, right: 14, top: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: _buildMobileTopPill(context, isDark),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _GlassBottomNavBar(
        currentIndex: _selectedTab,
        onTap: (i) => setState(() => _selectedTab = i),
        isDark: isDark,
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(16, (_collapsed ? 86 : 104), 16, 96),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: contentWidth),
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_selectedTab == 0) _buildHomeTabMobile(context, isDark),
                  if (_selectedTab == 1) _buildAiTabMobile(context, isDark),
                  if (_selectedTab == 2) _buildScanTabMobile(context, isDark),
                  if (_selectedTab == 3) _buildMarketTabMobile(context, isDark),
                  if (_selectedTab == 4) _buildProfileTabMobile(context, isDark),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileTopPill(BuildContext context, bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: _collapsed ? 9 : 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.10) : Colors.white),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome_rounded, color: Color(0xFFBC70FF), size: 18),
          const SizedBox(width: 8),
          Text(
            "R2V",
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1E293B),
              fontSize: _collapsed ? 15 : 16,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
            ),
          ),
          if (_loadingSummary) ...[
            const SizedBox(width: 10),
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: isDark ? Colors.white.withOpacity(0.8) : const Color(0xFFBC70FF),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHomeTabMobile(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMobileHeroStack(context, isDark),
        const SizedBox(height: 16),
        _SectionHeader(title: "Your stats", subtitle: "Quick overview", isDark: isDark),
        const SizedBox(height: 12),
        _StatsRow(stats: _stats, isDark: isDark),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/analysis'),
            icon: const Icon(Icons.analytics_outlined, color: Color(0xFF4CC9F0)),
            label: const Text(
              "View Full Analysis",
              style: TextStyle(color: Color(0xFF4CC9F0), fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 18),
        _SectionHeader(title: "Continue", subtitle: "Jump back in", isDark: isDark),
        const SizedBox(height: 12),
        _ContinueRow(
          items: [_continueAI, _continueScan, _continueMarket],
          onTap: (item) => Navigator.pushNamed(context, item["route"] as String),
          forceVerticalOnMobile: true,
          isDark: isDark,
        ),
        const SizedBox(height: 22),
        _SectionHeader(title: "Use R2V for", subtitle: "Pick a category", isDark: isDark),
        const SizedBox(height: 12),
        NotificationListener<ScrollNotification>(
          onNotification: (n) {
            if (n is ScrollStartNotification) _isUserDraggingUseCases = true;
            if (n is ScrollEndNotification) _isUserDraggingUseCases = false;
            return false;
          },
          child: UseCasesRow(
            items: _useCases,
            selectedIndex: _selectedUseCase,
            controller: _useCaseScrollController,
            onTap: _onUseCaseTap,
            isDark: isDark,
          ),
        ),
        const SizedBox(height: 14),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, anim) {
            return SlideTransition(
              position: Tween<Offset>(begin: const Offset(-0.06, 0), end: Offset.zero).animate(anim),
              child: FadeTransition(opacity: anim, child: child),
            );
          },
          child: UseCaseDetailsSectionMobile(
            key: ValueKey(_useCaseDetails[_selectedUseCase]["id"]),
            data: _useCaseDetails[_selectedUseCase],
            onCta: () => Navigator.pushNamed(context, _useCaseDetails[_selectedUseCase]["ctaRoute"]),
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileHeroStack(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.white),
                boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome back, @$_displayName",
                    style: TextStyle(color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Turn your ideas\ninto 3D in seconds.",
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                      fontSize: 26,
                      height: 1.08,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Use AI prompts, scan objects, or browse ready-made 3D assets.",
                    style: TextStyle(color: isDark ? Colors.white.withOpacity(0.82) : Colors.black87, fontSize: 13.5, height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pushNamed(context, '/aichat'),
                          icon: const Icon(Icons.bolt_rounded, size: 18),
                          label: const Text("AI Studio"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8A4FFF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pushNamed(context, '/photo_scan'),
                          icon: const Icon(Icons.photo_camera_rounded, size: 18),
                          label: const Text("Scan"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF72585),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/explore'),
                      icon: const Icon(Icons.storefront_rounded, size: 18),
                      label: const Text("Marketplace"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark ? Colors.white : const Color(0xFF1E293B),
                        side: BorderSide(color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.5),
                border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.white),
                boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "“${_currentHeroModel.prompt}”",
                    style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Create 3D models from prompts — in minutes",
                    style: TextStyle(
                      color: isDark ? Colors.white.withOpacity(0.65) : Colors.black54,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 220,
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: RadialGradient(
                          center: Alignment.center,
                          radius: 0.9,
                          colors: [
                            const Color(0xFF8A4FFF).withOpacity(0.20),
                            const Color(0xFF4895EF).withOpacity(0.10),
                            Colors.transparent,
                          ],
                        ),
                        border: Border.all(
                          color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
                        ),
                      ),
                      child: _heroModelViewer(borderRadius: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAiTabMobile(BuildContext context, bool isDark) {
    return _HomeActionCard(
      title: "AI Studio",
      subtitle: "Text → 3D concepts & variations",
      icon: Icons.bolt_rounded,
      accent: const Color(0xFF8A4FFF),
      onTap: () => Navigator.pushNamed(context, '/aichat'),
      primaryLabel: "Open AI Studio",
      secondaryLabel: "Templates",
      onSecondaryTap: () => _toast(context, "Templates coming soon"),
      bullets: const ["Prompt", "Variants", "Export"],
      isDark: isDark,
    );
  }

  Widget _buildScanTabMobile(BuildContext context, bool isDark) {
    return _HomeActionCard(
      title: "Scan",
      subtitle: "Photo → 3D model (photogrammetry)",
      icon: Icons.photo_camera_rounded,
      accent: const Color(0xFFF72585),
      onTap: () => Navigator.pushNamed(context, '/photo_scan'),
      primaryLabel: "Start Scan",
      secondaryLabel: "Tips",
      onSecondaryTap: () => _openTips(context, isDark),
      bullets: const ["Capture", "Rebuild", "STL/GLB"],
      isDark: isDark,
    );
  }

  Widget _buildMarketTabMobile(BuildContext context, bool isDark) {
    return _HomeActionCard(
      title: "Marketplace",
      subtitle: "Browse assets & packs",
      icon: Icons.storefront_rounded,
      accent: const Color(0xFF4895EF),
      onTap: () => Navigator.pushNamed(context, '/explore'),
      primaryLabel: "Open Marketplace",
      secondaryLabel: "Saved",
      onSecondaryTap: () => setState(() => _activeMarketModel = _models.first),
      bullets: const ["Preview", "Free/Paid", "Creators"],
      isDark: isDark,
    );
  }

  Widget _buildProfileTabMobile(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: "Profile", subtitle: "Account shortcuts", isDark: isDark),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _GlassSmallAction(
                icon: Icons.person_rounded,
                title: "View Profile",
                subtitle: "Your info & activity",
                onTap: () => Navigator.pushNamed(context, '/profile'),
                accent: const Color(0xFFBC70FF),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _GlassSmallAction(
                icon: Icons.settings_rounded,
                title: "Settings",
                subtitle: "Preferences",
                onTap: () => Navigator.pushNamed(context, '/settings'),
                accent: const Color(0xFF4895EF),
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _SectionHeader(title: "Tip", subtitle: "Quick scan tips", isDark: isDark),
        const SizedBox(height: 10),
        _GlassSmallAction(
          icon: Icons.lightbulb_rounded,
          title: "Open Scan Tips",
          subtitle: "Lighting, angles, consistency",
          onTap: () => _openTips(context, isDark),
          accent: const Color(0xFFF72585),
          isDark: isDark,
        ),
      ],
    );
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  void _openTips(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(12),
        child: _TipsSheet(isDark: isDark),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isDark;

  const _SectionHeader({required this.title, required this.subtitle, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 19, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(color: isDark ? Colors.white.withOpacity(0.65) : Colors.black54, fontSize: 13)),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  final Map<String, int> stats;
  final bool isDark;

  const _StatsRow({required this.stats, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final isWeb = c.maxWidth >= 900;
      final items = stats.entries.toList();

      return Row(
        children: items.map((e) {
          final idx = items.indexOf(e);
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: idx == items.length - 1 ? 0 : (isWeb ? 14 : 10)),
              child: _MiniStatCard(label: e.key, value: e.value, isDark: isDark),
            ),
          );
        }).toList(),
      );
    });
  }
}

class _MiniStatCard extends StatelessWidget {
  final String label;
  final int value;
  final bool isDark;

  const _MiniStatCard({required this.label, required this.value, required this.isDark});

  Color _accentFor(String label) {
    switch (label.toLowerCase()) {
      case "models":
        return const Color(0xFF8A4FFF);
      case "scans":
        return const Color(0xFFF72585);
      case "downloads":
        return const Color(0xFF4895EF);
      default:
        return const Color(0xFFBC70FF);
    }
  }

  IconData _iconFor(String label) {
    switch (label.toLowerCase()) {
      case "models":
        return Icons.view_in_ar_rounded;
      case "scans":
        return Icons.photo_camera_rounded;
      case "downloads":
        return Icons.download_rounded;
      default:
        return Icons.insights_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentFor(label);
    final icon = _iconFor(label);

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.12) : Colors.white),
            boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.18),
                  shape: BoxShape.circle,
                  border: Border.all(color: accent.withOpacity(0.55)),
                ),
                child: Icon(icon, color: isDark ? Colors.white.withOpacity(0.95) : accent, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        label,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: isDark ? Colors.white.withOpacity(0.70) : Colors.black54, fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "$value",
                      style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.w900, fontSize: 18),
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
}

class _ContinueRow extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final void Function(Map<String, dynamic> item) onTap;
  final bool forceVerticalOnMobile;
  final bool isDark;

  const _ContinueRow({
    required this.items,
    required this.onTap,
    this.forceVerticalOnMobile = false,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isNarrow = w < 520;

    if (forceVerticalOnMobile && isNarrow) {
      return Column(
        children: items
            .map((it) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ContinueCard(item: it, onTap: () => onTap(it), isDark: isDark),
                ))
            .toList(),
      );
    }

    return LayoutBuilder(builder: (context, c) {
      final isWeb = c.maxWidth >= 900;

      if (isWeb) {
        return Row(
          children: items.map((it) {
            final idx = items.indexOf(it);
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: idx == items.length - 1 ? 0 : 14),
                child: _ContinueCard(item: it, onTap: () => onTap(it), isDark: isDark),
              ),
            );
          }).toList(),
        );
      }

      return SizedBox(
        height: 100,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, i) {
            return SizedBox(
              width: 290,
              child: _ContinueCard(item: items[i], onTap: () => onTap(items[i]), isDark: isDark),
            );
          },
        ),
      );
    });
  }
}

class _ContinueCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;
  final bool isDark;

  const _ContinueCard({required this.item, required this.onTap, required this.isDark});

  @override
  State<_ContinueCard> createState() => _ContinueCardState();
}

class _ContinueCardState extends State<_ContinueCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width >= 900;
    final Color accent = widget.item["accent"] as Color;
    final IconData icon = widget.item["icon"] as IconData;
    final String title = widget.item["title"] as String;
    final String subtitle = widget.item["subtitle"] as String;
    final isDark = widget.isDark;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              transform: Matrix4.identity()..translate(0.0, (_hover && isWeb) ? -5.0 : 0.0),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _hover
                      ? (isDark ? Colors.white.withOpacity(0.20) : Colors.black.withOpacity(0.1))
                      : (isDark ? Colors.white.withOpacity(0.12) : Colors.white),
                ),
                boxShadow: [
                  if (isDark)
                    BoxShadow(
                      blurRadius: _hover ? 24 : 18,
                      color: Colors.black.withOpacity(_hover ? 0.45 : 0.30),
                      offset: const Offset(0, 12),
                    )
                  else
                    BoxShadow(
                      blurRadius: _hover ? 16 : 8,
                      color: Colors.black.withOpacity(0.04),
                      offset: const Offset(0, 4),
                    )
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.18),
                      shape: BoxShape.circle,
                      border: Border.all(color: accent.withOpacity(0.55)),
                    ),
                    child: Icon(icon, color: isDark ? Colors.white : accent, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.w900, fontSize: 14),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: isDark ? Colors.white.withOpacity(0.70) : Colors.black54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_rounded, color: isDark ? Colors.white70 : Colors.black38),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class UseCasesRow extends StatelessWidget {
  final List<Map<String, String>> items;
  final int selectedIndex;
  final ScrollController controller;
  final void Function(int index) onTap;
  final bool isDark;

  const UseCasesRow({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.controller,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final isWide = c.maxWidth >= 900;
        final cardWidth = isWide ? 190.0 : 170.0;
        final spacing = isWide ? 16.0 : 12.0;
        final side = isWide ? 30.0 : 10.0;

        return SizedBox(
          height: isWide ? 178 : 165,
          child: ListView.separated(
            controller: controller,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: side),
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => SizedBox(width: spacing),
            itemBuilder: (context, i) {
              final m = items[i];
              final title = m["title"] ?? "";
              final asset = m["asset"];
              final active = i == selectedIndex;

              return _UseCaseTile(
                title: title,
                asset: asset,
                isActive: active,
                width: cardWidth,
                onTap: () => onTap(i),
                isDark: isDark,
              );
            },
          ),
        );
      },
    );
  }
}

class _UseCaseTile extends StatefulWidget {
  final String title;
  final String? asset;
  final bool isActive;
  final double width;
  final VoidCallback onTap;
  final bool isDark;

  const _UseCaseTile({
    required this.title,
    required this.asset,
    required this.isActive,
    required this.width,
    required this.onTap,
    required this.isDark,
  });

  @override
  State<_UseCaseTile> createState() => _UseCaseTileState();
}

class _UseCaseTileState extends State<_UseCaseTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final baseColors = _gradientFor(widget.title, widget.isDark);
    final isDark = widget.isDark;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: widget.width,
          padding: const EdgeInsets.only(top: 8),
          transform: Matrix4.identity()..translate(0.0, (_hover || widget.isActive) ? -5.0 : 0.0),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      height: 105,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: baseColors),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: widget.isActive
                              ? (isDark ? Colors.white.withOpacity(0.28) : Colors.black.withOpacity(0.1))
                              : (isDark ? Colors.white.withOpacity(0.12) : Colors.white),
                          width: widget.isActive ? 1.4 : 1,
                        ),
                        boxShadow: [
                          if (widget.isActive && isDark)
                            BoxShadow(blurRadius: 28, color: Colors.white.withOpacity(0.10), offset: const Offset(0, 10)),
                          if (!isDark)
                            BoxShadow(blurRadius: 15, color: Colors.black.withOpacity(0.04), offset: const Offset(0, 5)),
                          if (isDark)
                            BoxShadow(
                              blurRadius: 18,
                              color: Colors.black.withOpacity((_hover || widget.isActive) ? 0.40 : 0.25),
                              offset: const Offset(0, 10),
                            ),
                        ],
                      ),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Text(
                            widget.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: widget.isActive ? (isDark ? Colors.white : const Color(0xFF1E293B)) : (isDark ? Colors.white.withOpacity(0.92) : Colors.black54),
                              fontWeight: FontWeight.w800,
                              fontSize: 16.5,
                              height: 1.1,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 72,
                child: SizedBox(
                  height: 92,
                  child: (widget.asset == null)
                      ? Icon(Icons.category, color: isDark ? Colors.white70 : Colors.black26, size: 54)
                      : Image.asset(
                          widget.asset!,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Icon(Icons.category, color: isDark ? Colors.white70 : Colors.black26, size: 54),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _gradientFor(String title, bool isDark) {
    final t = title.replaceAll('\n', ' ').toLowerCase();

    if (isDark) {
      switch (t) {
        case 'film production':
          return [const Color(0xFF9CA3AF).withOpacity(.4), const Color(0xFF111827).withOpacity(.15)];
        case 'product design':
          return [const Color(0xFF38BDF8).withOpacity(.4), const Color(0xFF2563EB).withOpacity(.15)];
        case 'education':
          return [const Color(0xFFFDE68A).withOpacity(.4), const Color(0xFFB45309).withOpacity(.15)];
        case 'game development':
          return [const Color(0xFF22D3EE).withOpacity(.4), const Color(0xFF0EA5E9).withOpacity(.15)];
        case '3d printing':
          return [const Color(0xFFA3E635).withOpacity(.4), const Color(0xFF16A34A).withOpacity(.15)];
        case 'vr/ar':
          return [const Color(0xFFC084FC).withOpacity(.4), const Color(0xFFFB7185).withOpacity(.15)];
        case 'interior design':
          return [const Color(0xFFFCA5A5).withOpacity(.4), const Color(0xFFF59E0B).withOpacity(.15)];
        default:
          return [Colors.white.withOpacity(.18), Colors.white.withOpacity(.06)];
      }
    } else {
      return [Colors.white.withOpacity(0.85), Colors.white.withOpacity(0.6)];
    }
  }
}

class UseCaseDetailsSection extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onCta;
  final bool isDark;

  const UseCaseDetailsSection({
    super.key,
    required this.data,
    required this.onCta,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final Color accent = (data["accent"] as Color?) ?? const Color(0xFFBC70FF);
    final bullets = (data["bullets"] as List?)?.cast<String>() ?? const <String>[];

    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.12) : Colors.white),
            boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data["title"] ?? "",
                      style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 44, height: 1.05, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      data["subtitle"] ?? "",
                      style: TextStyle(color: isDark ? Colors.white.withOpacity(0.78) : Colors.black87, fontSize: 15, height: 1.45),
                    ),
                    const SizedBox(height: 22),
                    for (final b in bullets)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: accent.withOpacity(0.20),
                                shape: BoxShape.circle,
                                border: Border.all(color: accent.withOpacity(0.60), width: 1),
                              ),
                              child: Icon(Icons.check, size: 14, color: isDark ? Colors.white : accent),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                b,
                                style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 18),
                    ElevatedButton.icon(
                      onPressed: onCta,
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: Text(data["cta"] ?? "Explore More"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? accent.withOpacity(0.18) : accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        side: isDark ? BorderSide(color: accent.withOpacity(0.55), width: 1) : BorderSide.none,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 22),
              Expanded(
                flex: 5,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    height: 360,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
                      border: Border.all(color: isDark ? Colors.white.withOpacity(0.10) : Colors.transparent),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            data["preview"] ?? "",
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Center(child: Icon(Icons.image_outlined, color: isDark ? Colors.white.withOpacity(0.5) : Colors.black26, size: 48)),
                          ),
                        ),
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomLeft,
                                end: Alignment.topRight,
                                colors: [
                                  isDark ? Colors.black.withOpacity(0.30) : Colors.white.withOpacity(0.5),
                                  Colors.transparent
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UseCaseDetailsSectionMobile extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onCta;
  final bool isDark;

  const UseCaseDetailsSectionMobile({
    super.key,
    required this.data,
    required this.onCta,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final Color accent = (data["accent"] as Color?) ?? const Color(0xFFBC70FF);
    final bullets = (data["bullets"] as List?)?.cast<String>() ?? const <String>[];

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.10) : Colors.white),
            boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data["title"] ?? "",
                style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 26, height: 1.1, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Text(
                data["subtitle"] ?? "",
                style: TextStyle(color: isDark ? Colors.white.withOpacity(0.78) : Colors.black87, fontSize: 13.5, height: 1.4),
              ),
              const SizedBox(height: 12),
              for (final b in bullets.take(3))
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.18),
                          shape: BoxShape.circle,
                          border: Border.all(color: accent.withOpacity(0.55), width: 1),
                        ),
                        child: Icon(Icons.check, size: 12, color: isDark ? Colors.white : accent),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          b,
                          style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 13.5, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          data["preview"] ?? "",
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Center(child: Icon(Icons.image_outlined, color: isDark ? Colors.white.withOpacity(0.5) : Colors.black26, size: 42)),
                        ),
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight,
                              colors: [isDark ? Colors.black.withOpacity(0.28) : Colors.white.withOpacity(0.3), Colors.transparent],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: onCta,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: Text(data["cta"] ?? "Explore More"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? accent.withOpacity(0.18) : accent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  side: isDark ? BorderSide(color: accent.withOpacity(0.55), width: 1) : BorderSide.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavTextButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isDark;

  const _NavTextButton({required this.label, this.isActive = false, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 120),
      style: TextStyle(
        color: isActive ? (isDark ? Colors.white : const Color(0xFF1E293B)) : (isDark ? Colors.white.withOpacity(0.7) : Colors.black54),
        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
        fontSize: 13.5,
      ),
      child: Text(label),
    );
  }
}

class _HomeActionCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;
  final String primaryLabel;
  final String secondaryLabel;
  final VoidCallback? onSecondaryTap;
  final List<String> bullets;
  final bool isDark;

  const _HomeActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.onSecondaryTap,
    required this.bullets,
    required this.isDark,
  });

  @override
  State<_HomeActionCard> createState() => _HomeActionCardState();
}

class _HomeActionCardState extends State<_HomeActionCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width >= 900;
    final isDark = widget.isDark;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              transform: Matrix4.identity()..translate(0.0, (_hover && isWeb) ? -6.0 : 0.0),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _hover
                      ? (isDark ? Colors.white.withOpacity(0.22) : Colors.black.withOpacity(0.1))
                      : (isDark ? Colors.white.withOpacity(0.12) : Colors.white),
                  width: _hover ? 1.3 : 1,
                ),
                boxShadow: [
                  if (isDark)
                    BoxShadow(
                      blurRadius: _hover ? 28 : 18,
                      color: Colors.black.withOpacity(_hover ? 0.45 : 0.30),
                      offset: const Offset(0, 12),
                    )
                  else
                    BoxShadow(
                      blurRadius: _hover ? 15 : 10,
                      color: Colors.black.withOpacity(0.05),
                      offset: const Offset(0, 5),
                    )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: widget.accent.withOpacity(0.18),
                          shape: BoxShape.circle,
                          border: Border.all(color: widget.accent.withOpacity(0.55), width: 1),
                        ),
                        child: Icon(widget.icon, color: isDark ? Colors.white : widget.accent, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.w900, fontSize: 16),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: isDark ? Colors.white.withOpacity(0.72) : Colors.black54, height: 1.25),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.bullets
                        .map((b) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: isDark ? Colors.white.withOpacity(0.10) : Colors.transparent),
                              ),
                              child: Text(
                                b,
                                style: TextStyle(
                                  color: isDark ? Colors.white.withOpacity(0.88) : Colors.black87,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: widget.onTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? widget.accent.withOpacity(0.22) : widget.accent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: isDark ? BorderSide(color: widget.accent.withOpacity(0.55), width: 1) : BorderSide.none,
                          ),
                          child: Text(widget.primaryLabel, style: const TextStyle(fontWeight: FontWeight.w900)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: widget.onSecondaryTap,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isDark ? Colors.white : const Color(0xFF1E293B),
                            side: BorderSide(color: isDark ? Colors.white.withOpacity(0.18) : Colors.black.withOpacity(0.1)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(widget.secondaryLabel, style: const TextStyle(fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassSmallAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color accent;
  final bool isDark;

  const _GlassSmallAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.accent,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: isDark ? Colors.white.withOpacity(0.12) : Colors.white),
              boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.18),
                    shape: BoxShape.circle,
                    border: Border.all(color: accent.withOpacity(0.55)),
                  ),
                  child: Icon(icon, color: isDark ? Colors.white : accent, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: isDark ? Colors.white.withOpacity(0.70) : Colors.black54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_rounded, color: isDark ? Colors.white70 : Colors.black38, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TipsSheet extends StatelessWidget {
  final bool isDark;
  const _TipsSheet({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.black.withOpacity(0.35) : Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.14) : Colors.white),
            boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 5))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Scan Tips", style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.w900, fontSize: 16)),
              const SizedBox(height: 10),
              _tip("Use bright, even lighting (no harsh shadows).", isDark),
              _tip("Capture 20–40 photos from all angles.", isDark),
              _tip("Keep the object centered, move around it.", isDark),
              _tip("Avoid reflective/transparent objects if possible.", isDark),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFFF72585).withOpacity(0.22) : const Color(0xFFF72585),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: isDark ? BorderSide(color: const Color(0xFFF72585).withOpacity(0.55), width: 1) : BorderSide.none,
                  ),
                  child: const Text("Got it", style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tip(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: TextStyle(color: isDark ? Colors.white.withOpacity(0.85) : Colors.black87, height: 1.25))),
        ],
      ),
    );
  }
}

class _HomeMarketModelPanel extends StatelessWidget {
  final MarketModel model;
  final VoidCallback onClose;
  final bool isDark;

  const _HomeMarketModelPanel({required this.model, required this.onClose, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWeb = size.width >= 900;

    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: Colors.black.withOpacity(0.60),
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isWeb ? 1100 : size.width - 18,
                maxHeight: isWeb ? 680 : size.height * 0.86,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black.withOpacity(0.22) : Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: isDark ? Colors.white.withOpacity(0.14) : Colors.white),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                model.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.w900, fontSize: 16),
                              ),
                            ),
                            InkWell(
                              onTap: onClose,
                              borderRadius: BorderRadius.circular(999),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white.withOpacity(0.10) : Colors.black.withOpacity(0.05),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: isDark ? Colors.white.withOpacity(0.12) : Colors.transparent),
                                ),
                                child: Icon(Icons.close, size: 18, color: isDark ? Colors.white70 : Colors.black87),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Container(
                              color: isDark ? Colors.black.withOpacity(0.18) : Colors.black.withOpacity(0.05),
                              child: ModelViewer(
                                key: ValueKey(model.glbAssetPath),
                                src: model.glbAssetPath,
                                poster: model.posterAssetPath,
                                backgroundColor: Colors.transparent,
                                cameraControls: true,
                                autoRotate: true,
                                environmentImage: "neutral",
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isDark;

  const _GlassBottomNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.isDark,
  });

  static const _items = <_BottomItem>[
    _BottomItem(icon: Icons.home_rounded, semantics: "Home"),
    _BottomItem(icon: Icons.bolt_rounded, semantics: "AI Studio"),
    _BottomItem(icon: Icons.photo_camera_rounded, semantics: "Scan"),
    _BottomItem(icon: Icons.storefront_rounded, semantics: "Market"),
    _BottomItem(icon: Icons.person_rounded, semantics: "Profile"),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: isDark ? Colors.white.withOpacity(0.12) : Colors.white),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 30,
                    color: Colors.black.withOpacity(isDark ? 0.45 : 0.1),
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, c) {
                  final segW = c.maxWidth / _items.length;
                  const pill = 44.0;
                  final left = (currentIndex * segW) + (segW - pill) / 2;

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOutCubic,
                        left: left,
                        top: (72 - pill) / 2,
                        child: Container(
                          width: pill,
                          height: pill,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF72585), Color(0xFFBC70FF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 18,
                                color: const Color(0xFFBC70FF).withOpacity(0.25),
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        children: List.generate(_items.length, (i) {
                          final active = i == currentIndex;
                          return Expanded(
                            child: Semantics(
                              label: _items[i].semantics,
                              button: true,
                              child: InkWell(
                                onTap: () => onTap(i),
                                splashColor: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
                                highlightColor: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.02),
                                child: Center(
                                  child: AnimatedScale(
                                    duration: const Duration(milliseconds: 180),
                                    curve: Curves.easeOut,
                                    scale: active ? 1.05 : 1.0,
                                    child: Icon(
                                      _items[i].icon,
                                      size: 22,
                                      color: active ? Colors.white : (isDark ? Colors.white.withOpacity(0.70) : Colors.black54),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomItem {
  final IconData icon;
  final String semantics;
  const _BottomItem({required this.icon, required this.semantics});
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
                ? [Colors.white.withOpacity(0.15), Colors.blue.shade300.withOpacity(0.35)]
                : [const Color(0xFFBC70FF).withOpacity(0.25), const Color(0xFF4895EF).withOpacity(0.25)],
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
    return RepaintBoundary(child: _MeshyBgCore(isDark: isDark));
  }
}

class _MeshyBgCore extends StatefulWidget {
  final bool isDark;
  const _MeshyBgCore({required this.isDark});

  @override
  State<_MeshyBgCore> createState() => _MeshyBgCoreState();
}

class _MeshyBgCoreState extends State<_MeshyBgCore> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final Random _rng = Random(42);

  Size _size = Size.zero;
  Offset _mouse = Offset.zero;
  bool _hasMouse = false;

  late List<_Particle> _ps;
  double _t = 0;

  @override
  void initState() {
    super.initState();
    _ps = <_Particle>[];
    _ticker = createTicker((elapsed) {
      _t = elapsed.inMilliseconds / 1000.0;
      if (!mounted) return;
      if (_size == Size.zero) return;

      const dt = 1 / 60;
      for (final p in _ps) {
        p.pos = p.pos + p.vel * dt;
        if (p.pos.dx < 0 || p.pos.dx > _size.width) p.vel = Offset(-p.vel.dx, p.vel.dy);
        if (p.pos.dy < 0 || p.pos.dy > _size.height) p.vel = Offset(p.vel.dx, -p.vel.dy);
        p.pos = Offset(p.pos.dx.clamp(0.0, _size.width), p.pos.dy.clamp(0.0, _size.height));
      }
      setState(() {});
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _ensureParticles(Size s) {
    if (s == Size.zero) return;

    final area = s.width * s.height;
    int target = (area / 18000).round();
    target = target.clamp(35, 95);

    if (_ps.length == target) return;

    _ps = List.generate(target, (i) {
      final pos = Offset(_rng.nextDouble() * s.width, _rng.nextDouble() * s.height);
      final speed = 8 + _rng.nextDouble() * 18;
      final ang = _rng.nextDouble() * pi * 2;
      final vel = Offset(cos(ang), sin(ang)) * speed;
      final r = 1.2 + _rng.nextDouble() * 1.9;
      return _Particle(pos: pos, vel: vel, radius: r);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final s = Size(c.maxWidth, c.maxHeight);
      if (_size != s) {
        _size = s;
        _ensureParticles(s);
      }

      return MouseRegion(
        onHover: (e) {
          _hasMouse = true;
          _mouse = e.localPosition;
        },
        onExit: (_) => _hasMouse = false,
        child: CustomPaint(
          painter: _MeshPainter(
            particles: _ps,
            time: _t,
            size: s,
            mouse: _mouse,
            hasMouse: _hasMouse,
            isDark: widget.isDark,
          ),
        ),
      );
    });
  }
}

class _Particle {
  Offset pos;
  Offset vel;
  final double radius;

  _Particle({required this.pos, required this.vel, required this.radius});
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
  });

  @override
  void paint(Canvas canvas, Size _) {
    final rect = Offset.zero & size;

    final bgColors = isDark
        ? const [Color(0xFF0F1118), Color(0xFF141625), Color(0xFF0B0D14)]
        : const [Color(0xFFF8FAFC), Color(0xFFF1F5F9), Color(0xFFE2E8F0)];

    final bg = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: bgColors,
        stops: const [0.0, 0.55, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, bg);

    void glowBlob(Offset c, double r, Color col, double a) {
      final p = Paint()
        ..color = col.withOpacity(a)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 90);
      canvas.drawCircle(c, r, p);
    }

    final center = Offset(size.width * 0.55, size.height * 0.35);
    final wobble = Offset(sin(time * 0.5) * 40, cos(time * 0.45) * 30);

    glowBlob(center + wobble, 280, isDark ? const Color(0xFF8A4FFF) : const Color(0xFFA855F7), isDark ? 0.18 : 0.12);
    glowBlob(
      Offset(size.width * 0.25, size.height * 0.70) + Offset(cos(time * 0.35) * 35, sin(time * 0.32) * 28),
      240,
      isDark ? const Color(0xFF4895EF) : const Color(0xFF38BDF8),
      isDark ? 0.14 : 0.10,
    );

    Offset parallax = Offset.zero;
    if (hasMouse) {
      final dx = (mouse.dx / max(1.0, size.width) - 0.5) * 18;
      final dy = (mouse.dy / max(1.0, size.height) - 0.5) * 18;
      parallax = Offset(dx, dy);
    }

    final connectDist = min(size.width, size.height) * 0.15;
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
          final t = 1.0 - (sqrt(d2) / connectDist);
          linePaint.color = isDark
              ? Colors.white.withOpacity(0.06 * t)
              : const Color(0xFF8A4FFF).withOpacity(0.15 * t);
          canvas.drawLine(ap, bp, linePaint);
        }
      }
    }

    final dotPaint = Paint()..style = PaintingStyle.fill;
    for (final p in particles) {
      final pos = p.pos + parallax * 0.6;
      dotPaint.color = isDark ? Colors.white.withOpacity(0.12) : const Color(0xFF8A4FFF).withOpacity(0.25);
      canvas.drawCircle(pos, p.radius, dotPaint);
    }

    final vignetteColors = isDark
        ? [Colors.transparent, Colors.black.withOpacity(0.55)]
        : [Colors.transparent, Colors.white.withOpacity(0.4)];

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
  bool shouldRepaint(covariant _MeshPainter oldDelegate) => true;
}