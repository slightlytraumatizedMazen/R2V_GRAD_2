import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../main.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  static const String _adminAccessCode = "r2v-admin-2026";

  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  bool _unlocked = false;
  bool _loading = false;
  String? _error;
  int _selectedIndex = 0;

  _AdminSnapshot _snapshot = _AdminSnapshot.empty();

  final List<_AdminTab> _tabs = const [
    _AdminTab("Dashboard", Icons.grid_view_rounded),
    _AdminTab("AI Generation", Icons.view_in_ar_rounded),
    _AdminTab("Marketplace", Icons.storefront_rounded),
    _AdminTab("Users", Icons.people_alt_rounded),
    _AdminTab("Moderation", Icons.admin_panel_settings_rounded),
    _AdminTab("System Health", Icons.monitor_heart_rounded),
    _AdminTab("Settings", Icons.settings_rounded),
  ];

  @override
  void dispose() {
    _codeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _unlock() async {
    final code = _codeController.text.trim();

    if (code != _adminAccessCode) {
      setState(() => _error = "Wrong admin code");
      return;
    }

    setState(() {
      _unlocked = true;
      _error = null;
    });

    await _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    setState(() => _loading = true);

    try {
      final data = await _AdminDataSource.fetchSnapshot();

      if (!mounted) return;

      setState(() {
        _snapshot = data;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _snapshot = _AdminSnapshot.notConnected();
        _loading = false;
      });
    }
  }

  void _setThemeMode(ThemeMode mode) {
    themeNotifier.value = mode;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!_unlocked) {
      return _AdminGate(
        controller: _codeController,
        error: _error,
        onUnlock: _unlock,
        isDark: isDark,
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0414) : const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          Positioned.fill(child: _AdminBackground(isDark: isDark)),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 920;

                if (isWide) {
                  return Row(
                    children: [
                      _AdminSidebar(
                        tabs: _tabs,
                        selectedIndex: _selectedIndex,
                        onSelect: (index) => setState(() => _selectedIndex = index),
                        isDark: isDark,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(26),
                          child: _buildPage(isDark),
                        ),
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    _MobileAdminTopbar(
                      isDark: isDark,
                      onRefresh: _loadAdminData,
                    ),
                    SizedBox(
                      height: 68,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        scrollDirection: Axis.horizontal,
                        itemCount: _tabs.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          return _MobileTabChip(
                            tab: _tabs[index],
                            active: index == _selectedIndex,
                            isDark: isDark,
                            onTap: () => setState(() => _selectedIndex = index),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
                        child: _buildPage(isDark),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(bool isDark) {
    if (_loading) {
      return _LoadingPanel(isDark: isDark);
    }

    switch (_selectedIndex) {
      case 0:
        return _dashboardPage(isDark);
      case 1:
        return _aiGenerationPage(isDark);
      case 2:
        return _marketplacePage(isDark);
      case 3:
        return _usersPage(isDark);
      case 4:
        return _moderationPage(isDark);
      case 5:
        return _systemHealthPage(isDark);
      case 6:
        return _settingsPage(isDark);
      default:
        return _dashboardPage(isDark);
    }
  }

  Widget _dashboardPage(bool isDark) {
    return _PageShell(
      title: "System Overview",
      subtitle: "Monitoring R2V Engine, marketplace activity, users, and platform health.",
      isDark: isDark,
      trailing: _RefreshButton(onTap: _loadAdminData),
      children: [
        _ConnectionBanner(snapshot: _snapshot, isDark: isDark),
        const SizedBox(height: 18),
        _MetricGrid(
          isDark: isDark,
          items: [
            _MetricItem("Total AI Generations", _snapshot.metrics.totalGenerations, Icons.view_in_ar_rounded, const Color(0xFFBC70FF)),
            _MetricItem("Active Projects", _snapshot.metrics.activeProjects, Icons.work_outline_rounded, const Color(0xFF4CC9F0)),
            _MetricItem("Marketplace Revenue", _snapshot.metrics.marketplaceRevenue, Icons.payments_rounded, const Color(0xFF22C55E)),
            _MetricItem("Cluster Utilization", _snapshot.metrics.clusterUtilization, Icons.memory_rounded, const Color(0xFFF59E0B)),
          ],
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, c) {
            final wide = c.maxWidth >= 900;
            return Flex(
              direction: wide ? Axis.horizontal : Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: wide ? 2 : 0,
                  child: _AdminPanel(
                    title: "Recent AI Generations",
                    icon: Icons.auto_awesome_rounded,
                    isDark: isDark,
                    child: _EmptyState(
                      title: "No AI generation data yet",
                      subtitle: "Connect the admin API to display real AI generation activity here.",
                      icon: Icons.view_in_ar_outlined,
                      isDark: isDark,
                    ),
                  ),
                ),
                SizedBox(width: wide ? 18 : 0, height: wide ? 0 : 18),
                Expanded(
                  flex: wide ? 1 : 0,
                  child: _AdminPanel(
                    title: "Market Activity",
                    icon: Icons.storefront_rounded,
                    isDark: isDark,
                    child: _EmptyState(
                      title: "No market activity yet",
                      subtitle: "Sales, uploads, and approvals will appear here after backend integration.",
                      icon: Icons.receipt_long_outlined,
                      isDark: isDark,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _aiGenerationPage(bool isDark) {
    return _PageShell(
      title: "AI Model Management",
      subtitle: "Monitor and control active 3D generation jobs, queues, failures, and engine health.",
      isDark: isDark,
      trailing: _StatusBadge(
        label: _snapshot.connected ? "CLUSTER ONLINE" : "BACKEND NOT CONNECTED",
        color: _snapshot.connected ? const Color(0xFF22C55E) : const Color(0xFFF59E0B),
      ),
      children: [
        _ConnectionBanner(snapshot: _snapshot, isDark: isDark),
        const SizedBox(height: 18),
        _MetricGrid(
          isDark: isDark,
          items: [
            _MetricItem("Global Queue", _snapshot.metrics.queueSize, Icons.queue_rounded, const Color(0xFFBC70FF)),
            _MetricItem("Average Gen Time", _snapshot.metrics.averageGenerationTime, Icons.timer_rounded, const Color(0xFF4CC9F0)),
            _MetricItem("Failed Jobs", _snapshot.metrics.failedJobs, Icons.error_outline_rounded, const Color(0xFFEF4444)),
            _MetricItem("GPU / VRAM", _snapshot.metrics.gpuStatus, Icons.memory_rounded, const Color(0xFFF59E0B)),
          ],
        ),
        const SizedBox(height: 18),
        _AdminPanel(
          title: "Active Engines",
          icon: Icons.developer_board_rounded,
          isDark: isDark,
          child: _EmptyState(
            title: "No engine telemetry connected",
            subtitle: "Hunyuan3D, Gemini, Stable Diffusion, queue status, GPU load, and VRAM usage will appear here.",
            icon: Icons.precision_manufacturing_outlined,
            isDark: isDark,
          ),
        ),
        const SizedBox(height: 18),
        _AdminPanel(
          title: "System Log",
          icon: Icons.article_outlined,
          isDark: isDark,
          child: _EmptyState(
            title: "No logs available",
            subtitle: "Generation logs, failed jobs, warnings, and deployment events will be shown after connecting admin endpoints.",
            icon: Icons.list_alt_outlined,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _marketplacePage(bool isDark) {
    return _PageShell(
      title: "Marketplace Console",
      subtitle: "Review assets, monitor uploads, approve models, and track marketplace performance.",
      isDark: isDark,
      trailing: _OutlineAdminButton(
        label: "Export Report",
        icon: Icons.download_rounded,
        onTap: () {},
      ),
      children: [
        _ConnectionBanner(snapshot: _snapshot, isDark: isDark),
        const SizedBox(height: 18),
        _MetricGrid(
          isDark: isDark,
          items: [
            _MetricItem("Pending Review", _snapshot.metrics.pendingAssets, Icons.pending_actions_rounded, const Color(0xFFF59E0B)),
            _MetricItem("Flagged Assets", _snapshot.metrics.flaggedAssets, Icons.flag_rounded, const Color(0xFFEF4444)),
            _MetricItem("Approved Today", _snapshot.metrics.approvedToday, Icons.verified_rounded, const Color(0xFF22C55E)),
            _MetricItem("Downloads", _snapshot.metrics.downloads, Icons.download_rounded, const Color(0xFF4CC9F0)),
          ],
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, c) {
            final wide = c.maxWidth >= 960;

            return Flex(
              direction: wide ? Axis.horizontal : Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: wide ? 2 : 0,
                  child: _AdminPanel(
                    title: "Asset Moderation",
                    icon: Icons.inventory_2_rounded,
                    isDark: isDark,
                    child: _EmptyState(
                      title: "No assets to review",
                      subtitle: "Pending, approved, rejected, and flagged assets will appear here from your marketplace backend.",
                      icon: Icons.view_in_ar_outlined,
                      isDark: isDark,
                    ),
                  ),
                ),
                SizedBox(width: wide ? 18 : 0, height: wide ? 0 : 18),
                Expanded(
                  flex: wide ? 1 : 0,
                  child: _AdminPanel(
                    title: "Review Mode",
                    icon: Icons.rate_review_rounded,
                    isDark: isDark,
                    child: _EmptyState(
                      title: "Select an asset",
                      subtitle: "Asset details, file formats, polycount, compliance checks, approve, and reject actions will appear here.",
                      icon: Icons.fact_check_outlined,
                      isDark: isDark,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _usersPage(bool isDark) {
    return _PageShell(
      title: "Directory",
      subtitle: "Manage users, creators, freelancers, roles, verification requests, and account status.",
      isDark: isDark,
      trailing: _SearchBox(
        controller: _searchController,
        isDark: isDark,
        hint: "Search by name, email, ID, or role...",
      ),
      children: [
        _ConnectionBanner(snapshot: _snapshot, isDark: isDark),
        const SizedBox(height: 18),
        _MetricGrid(
          isDark: isDark,
          items: [
            _MetricItem("Total Users", _snapshot.metrics.totalUsers, Icons.people_alt_rounded, const Color(0xFFBC70FF)),
            _MetricItem("Active Creators", _snapshot.metrics.activeCreators, Icons.brush_rounded, const Color(0xFF4CC9F0)),
            _MetricItem("Pending Approval", _snapshot.metrics.pendingUsers, Icons.how_to_reg_rounded, const Color(0xFFF59E0B)),
            _MetricItem("Suspended", _snapshot.metrics.suspendedUsers, Icons.block_rounded, const Color(0xFFEF4444)),
          ],
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, c) {
            final wide = c.maxWidth >= 960;

            return Flex(
              direction: wide ? Axis.horizontal : Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: wide ? 2 : 0,
                  child: _AdminPanel(
                    title: "Global Directory",
                    icon: Icons.people_outline_rounded,
                    isDark: isDark,
                    child: _EmptyState(
                      title: "No user data connected",
                      subtitle: "Real users, roles, creator status, joined date, and account actions will appear here.",
                      icon: Icons.people_outline_rounded,
                      isDark: isDark,
                    ),
                  ),
                ),
                SizedBox(width: wide ? 18 : 0, height: wide ? 0 : 18),
                Expanded(
                  flex: wide ? 1 : 0,
                  child: Column(
                    children: [
                      _AdminPanel(
                        title: "Verification Requests",
                        icon: Icons.verified_user_rounded,
                        isDark: isDark,
                        child: _EmptyState(
                          title: "No pending requests",
                          subtitle: "Creator and freelancer verification requests will appear here.",
                          icon: Icons.verified_outlined,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _AdminPanel(
                        title: "Top Creators",
                        icon: Icons.star_rounded,
                        isDark: isDark,
                        child: _EmptyState(
                          title: "No creator ranking yet",
                          subtitle: "Creator performance and marketplace activity will appear here.",
                          icon: Icons.leaderboard_outlined,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _moderationPage(bool isDark) {
    return _PageShell(
      title: "Moderation Hub",
      subtitle: "Review reports, appeals, suspicious users, flagged assets, and safety actions.",
      isDark: isDark,
      trailing: _OutlineAdminButton(
        label: "Generate Report",
        icon: Icons.description_rounded,
        onTap: () {},
      ),
      children: [
        _ConnectionBanner(snapshot: _snapshot, isDark: isDark),
        const SizedBox(height: 18),
        _MetricGrid(
          isDark: isDark,
          items: [
            _MetricItem("Open Reports", _snapshot.metrics.openReports, Icons.flag_rounded, const Color(0xFFEF4444)),
            _MetricItem("Appeals", _snapshot.metrics.appeals, Icons.gavel_rounded, const Color(0xFFF59E0B)),
            _MetricItem("Flagged Users", _snapshot.metrics.flaggedUsers, Icons.person_off_rounded, const Color(0xFFBC70FF)),
            _MetricItem("Flagged Assets", _snapshot.metrics.flaggedAssets, Icons.inventory_2_rounded, const Color(0xFF4CC9F0)),
          ],
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, c) {
            final wide = c.maxWidth >= 960;

            return Flex(
              direction: wide ? Axis.horizontal : Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: wide ? 1 : 0,
                  child: _AdminPanel(
                    title: "Target Entity Review",
                    icon: Icons.person_search_rounded,
                    isDark: isDark,
                    child: _EmptyState(
                      title: "No selected entity",
                      subtitle: "Reported user or asset profile, trust score, and execution actions will appear here.",
                      icon: Icons.manage_accounts_outlined,
                      isDark: isDark,
                    ),
                  ),
                ),
                SizedBox(width: wide ? 18 : 0, height: wide ? 0 : 18),
                Expanded(
                  flex: wide ? 2 : 0,
                  child: Column(
                    children: [
                      _AdminPanel(
                        title: "Violation Matrix",
                        icon: Icons.rule_rounded,
                        isDark: isDark,
                        child: _EmptyState(
                          title: "No violations recorded",
                          subtitle: "TOS violations, suspicious logins, automated flags, and strike history will appear here.",
                          icon: Icons.security_outlined,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _AdminPanel(
                        title: "Active Petition",
                        icon: Icons.forum_rounded,
                        isDark: isDark,
                        child: _EmptyState(
                          title: "No active appeal",
                          subtitle: "Appeal messages, evidence, deny, and restore actions will appear here.",
                          icon: Icons.mark_chat_read_outlined,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _systemHealthPage(bool isDark) {
    return _PageShell(
      title: "System Health",
      subtitle: "Monitor backend, AI pipeline, queue, storage, GPU, and service availability.",
      isDark: isDark,
      trailing: _StatusBadge(
        label: _snapshot.connected ? "SYSTEM NOMINAL" : "NOT CONNECTED",
        color: _snapshot.connected ? const Color(0xFF22C55E) : const Color(0xFFF59E0B),
      ),
      children: [
        _ConnectionBanner(snapshot: _snapshot, isDark: isDark),
        const SizedBox(height: 18),
        _MetricGrid(
          isDark: isDark,
          items: [
            _MetricItem("Backend", _snapshot.metrics.backendStatus, Icons.cloud_done_rounded, const Color(0xFF22C55E)),
            _MetricItem("GPU Status", _snapshot.metrics.gpuStatus, Icons.memory_rounded, const Color(0xFF4CC9F0)),
            _MetricItem("Queue Size", _snapshot.metrics.queueSize, Icons.queue_rounded, const Color(0xFFF59E0B)),
            _MetricItem("Storage Used", _snapshot.metrics.storageUsed, Icons.storage_rounded, const Color(0xFFBC70FF)),
          ],
        ),
        const SizedBox(height: 18),
        _AdminPanel(
          title: "Pipeline Status",
          icon: Icons.account_tree_rounded,
          isDark: isDark,
          child: Column(
            children: [
              _SystemStatusRow(label: "Stable Diffusion image generation", value: _snapshot.services.stableDiffusion, isDark: isDark),
              _SystemStatusRow(label: "Hunyuan3D mesh generation", value: _snapshot.services.hunyuan, isDark: isDark),
              _SystemStatusRow(label: "Gemini multi-view generation", value: _snapshot.services.gemini, isDark: isDark),
              _SystemStatusRow(label: "Marketplace moderation", value: _snapshot.services.marketplace, isDark: isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _settingsPage(bool isDark) {
    return _PageShell(
      title: "Admin Settings",
      subtitle: "Control admin appearance, access, platform flags, and future system configuration.",
      isDark: isDark,
      children: [
        _AdminPanel(
          title: "Appearance",
          icon: Icons.palette_rounded,
          isDark: isDark,
          child: LayoutBuilder(
            builder: (context, c) {
              final wide = c.maxWidth >= 760;
              final children = [
                _ThemeChoice(
                  title: "Dark",
                  subtitle: "Use dark admin console",
                  icon: Icons.dark_mode_rounded,
                  active: themeNotifier.value == ThemeMode.dark,
                  onTap: () => _setThemeMode(ThemeMode.dark),
                  isDark: isDark,
                ),
                _ThemeChoice(
                  title: "Light",
                  subtitle: "Use light admin console",
                  icon: Icons.light_mode_rounded,
                  active: themeNotifier.value == ThemeMode.light,
                  onTap: () => _setThemeMode(ThemeMode.light),
                  isDark: isDark,
                ),
                _ThemeChoice(
                  title: "System",
                  subtitle: "Follow device setting",
                  icon: Icons.computer_rounded,
                  active: themeNotifier.value == ThemeMode.system,
                  onTap: () => _setThemeMode(ThemeMode.system),
                  isDark: isDark,
                ),
              ];

              if (wide) {
                return Row(
                  children: children
                      .map(
                        (child) => Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: child == children.last ? 0 : 12),
                            child: child,
                          ),
                        ),
                      )
                      .toList(),
                );
              }

              return Column(
                children: children
                    .map(
                      (child) => Padding(
                        padding: EdgeInsets.only(bottom: child == children.last ? 0 : 12),
                        child: child,
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ),
        const SizedBox(height: 18),
        _AdminPanel(
          title: "Access",
          icon: Icons.lock_rounded,
          isDark: isDark,
          child: Column(
            children: [
              _InfoRow(label: "Secret route", value: "/r2v-admin-control", isDark: isDark),
              _InfoRow(label: "Access method", value: "Private route + admin code", isDark: isDark),
              _InfoRow(label: "Recommended next step", value: "Replace local code with backend role check", isDark: isDark),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _AdminPanel(
          title: "Platform Controls",
          icon: Icons.tune_rounded,
          isDark: isDark,
          child: Column(
            children: [
              _DisabledSettingRow(
                title: "Maintenance Mode",
                subtitle: "Requires admin backend endpoint",
                value: false,
                isDark: isDark,
              ),
              _DisabledSettingRow(
                title: "Marketplace Uploads",
                subtitle: "Enable or disable creator uploads",
                value: false,
                isDark: isDark,
              ),
              _DisabledSettingRow(
                title: "New User Registration",
                subtitle: "Control signup availability",
                value: false,
                isDark: isDark,
              ),
              _DisabledSettingRow(
                title: "Freelance Requests",
                subtitle: "Control freelance project creation",
                value: false,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AdminDataSource {
  static Future<_AdminSnapshot> fetchSnapshot() async {
    return _AdminSnapshot.notConnected();
  }
}

class _AdminSnapshot {
  final bool connected;
  final String message;
  final _AdminMetrics metrics;
  final _AdminServices services;

  const _AdminSnapshot({
    required this.connected,
    required this.message,
    required this.metrics,
    required this.services,
  });

  factory _AdminSnapshot.empty() {
    return _AdminSnapshot(
      connected: false,
      message: "Admin backend is not connected yet.",
      metrics: _AdminMetrics.empty(),
      services: _AdminServices.empty(),
    );
  }

  factory _AdminSnapshot.notConnected() {
    return _AdminSnapshot(
      connected: false,
      message: "No admin API is connected yet. The console is ready, but it is showing empty states until backend endpoints are added.",
      metrics: _AdminMetrics.empty(),
      services: _AdminServices.empty(),
    );
  }
}

class _AdminMetrics {
  final String totalUsers;
  final String totalGenerations;
  final String activeProjects;
  final String marketplaceRevenue;
  final String clusterUtilization;
  final String queueSize;
  final String averageGenerationTime;
  final String failedJobs;
  final String gpuStatus;
  final String pendingAssets;
  final String flaggedAssets;
  final String approvedToday;
  final String downloads;
  final String activeCreators;
  final String pendingUsers;
  final String suspendedUsers;
  final String openReports;
  final String appeals;
  final String flaggedUsers;
  final String backendStatus;
  final String storageUsed;

  const _AdminMetrics({
    required this.totalUsers,
    required this.totalGenerations,
    required this.activeProjects,
    required this.marketplaceRevenue,
    required this.clusterUtilization,
    required this.queueSize,
    required this.averageGenerationTime,
    required this.failedJobs,
    required this.gpuStatus,
    required this.pendingAssets,
    required this.flaggedAssets,
    required this.approvedToday,
    required this.downloads,
    required this.activeCreators,
    required this.pendingUsers,
    required this.suspendedUsers,
    required this.openReports,
    required this.appeals,
    required this.flaggedUsers,
    required this.backendStatus,
    required this.storageUsed,
  });

  factory _AdminMetrics.empty() {
    return const _AdminMetrics(
      totalUsers: "—",
      totalGenerations: "—",
      activeProjects: "—",
      marketplaceRevenue: "—",
      clusterUtilization: "—",
      queueSize: "—",
      averageGenerationTime: "—",
      failedJobs: "—",
      gpuStatus: "—",
      pendingAssets: "—",
      flaggedAssets: "—",
      approvedToday: "—",
      downloads: "—",
      activeCreators: "—",
      pendingUsers: "—",
      suspendedUsers: "—",
      openReports: "—",
      appeals: "—",
      flaggedUsers: "—",
      backendStatus: "Not connected",
      storageUsed: "—",
    );
  }
}

class _AdminServices {
  final String stableDiffusion;
  final String hunyuan;
  final String gemini;
  final String marketplace;

  const _AdminServices({
    required this.stableDiffusion,
    required this.hunyuan,
    required this.gemini,
    required this.marketplace,
  });

  factory _AdminServices.empty() {
    return const _AdminServices(
      stableDiffusion: "Not connected",
      hunyuan: "Not connected",
      gemini: "Not connected",
      marketplace: "Not connected",
    );
  }
}

class _AdminGate extends StatelessWidget {
  final TextEditingController controller;
  final String? error;
  final VoidCallback onUnlock;
  final bool isDark;

  const _AdminGate({
    required this.controller,
    required this.error,
    required this.onUnlock,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0414) : const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          Positioned.fill(child: _AdminBackground(isDark: isDark)),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: _GlassContainer(
                  isDark: isDark,
                  borderRadius: 30,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8A4FFF), Color(0xFFF72585)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8A4FFF).withOpacity(0.35),
                              blurRadius: 28,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        "R2V Admin",
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Enter the private admin code to continue.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? Colors.white.withOpacity(0.64) : Colors.black54,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 22),
                      TextField(
                        controller: controller,
                        obscureText: true,
                        onSubmitted: (_) => onUnlock(),
                        style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A)),
                        decoration: InputDecoration(
                          hintText: "Admin code",
                          errorText: error,
                          prefixIcon: const Icon(Icons.lock_rounded),
                          filled: true,
                          fillColor: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: onUnlock,
                          icon: const Icon(Icons.login_rounded),
                          label: const Text("Enter Admin Console"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8A4FFF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminSidebar extends StatelessWidget {
  final List<_AdminTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final bool isDark;

  const _AdminSidebar({
    required this.tabs,
    required this.selectedIndex,
    required this.onSelect,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF050914).withOpacity(0.92) : Colors.white.withOpacity(0.86),
        border: Border(
          right: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.07) : Colors.black.withOpacity(0.06),
          ),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8A4FFF), Color(0xFFF72585)],
                    ),
                  ),
                  child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "R2V Admin",
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        "Terminal v1.0.0",
                        style: TextStyle(
                          color: isDark ? Colors.white.withOpacity(0.54) : Colors.black54,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: tabs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                return _SidebarItem(
                  tab: tabs[index],
                  active: index == selectedIndex,
                  isDark: isDark,
                  onTap: () => onSelect(index),
                );
              },
            ),
          ),
          Divider(color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06)),
          _SidebarFooterItem(icon: Icons.menu_book_rounded, label: "Docs", isDark: isDark),
          _SidebarFooterItem(icon: Icons.logout_rounded, label: "Logout", isDark: isDark),
          const SizedBox(height: 18),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final _AdminTab tab;
  final bool active;
  final bool isDark;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.tab,
    required this.active,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = const Color(0xFFBC70FF);

    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(left: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        decoration: BoxDecoration(
          color: active ? activeColor.withOpacity(isDark ? 0.18 : 0.12) : Colors.transparent,
          border: Border(
            right: BorderSide(
              color: active ? activeColor : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              tab.icon,
              color: active ? activeColor : (isDark ? Colors.white.withOpacity(0.48) : Colors.black45),
              size: 22,
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                tab.title,
                style: TextStyle(
                  color: active ? activeColor : (isDark ? Colors.white.withOpacity(0.54) : Colors.black54),
                  fontWeight: active ? FontWeight.w900 : FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarFooterItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _SidebarFooterItem({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: isDark ? Colors.white.withOpacity(0.48) : Colors.black45),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white.withOpacity(0.50) : Colors.black54,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PageShell extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;
  final Widget? trailing;
  final bool isDark;

  const _PageShell({
    required this.title,
    required this.subtitle,
    required this.children,
    required this.isDark,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, c) {
              final wide = c.maxWidth >= 780;

              if (wide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _TitleBlock(title: title, subtitle: subtitle, isDark: isDark)),
                    if (trailing != null) trailing!,
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TitleBlock(title: title, subtitle: subtitle, isDark: isDark),
                  if (trailing != null) ...[
                    const SizedBox(height: 14),
                    trailing!,
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }
}

class _TitleBlock extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isDark;

  const _TitleBlock({
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            fontSize: 38,
            height: 1.05,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          style: TextStyle(
            color: isDark ? Colors.white.withOpacity(0.68) : Colors.black54,
            fontSize: 15.5,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _ConnectionBanner extends StatelessWidget {
  final _AdminSnapshot snapshot;
  final bool isDark;

  const _ConnectionBanner({
    required this.snapshot,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final color = snapshot.connected ? const Color(0xFF22C55E) : const Color(0xFFF59E0B);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.10 : 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.28)),
      ),
      child: Row(
        children: [
          Icon(snapshot.connected ? Icons.cloud_done_rounded : Icons.info_outline_rounded, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              snapshot.message,
              style: TextStyle(
                color: isDark ? Colors.white.withOpacity(0.78) : const Color(0xFF334155),
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  final List<_MetricItem> items;
  final bool isDark;

  const _MetricGrid({
    required this.items,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final columns = c.maxWidth >= 1100 ? 4 : c.maxWidth >= 760 ? 2 : 1;
        const gap = 16.0;
        final width = (c.maxWidth - (gap * (columns - 1))) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: items.map((item) {
            return SizedBox(
              width: width,
              child: _MetricCard(item: item, isDark: isDark),
            );
          }).toList(),
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final _MetricItem item;
  final bool isDark;

  const _MetricCard({
    required this.item,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassContainer(
      isDark: isDark,
      borderRadius: 18,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: item.color.withOpacity(0.26)),
                ),
                child: Icon(item.icon, color: item.color, size: 22),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  "Live",
                  style: TextStyle(
                    color: isDark ? Colors.white.withOpacity(0.62) : Colors.black45,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            item.title.toUpperCase(),
            style: TextStyle(
              color: isDark ? Colors.white.withOpacity(0.54) : Colors.black54,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.9,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.value,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              fontSize: 31,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminPanel extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final bool isDark;

  const _AdminPanel({
    required this.title,
    required this.icon,
    required this.child,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassContainer(
      isDark: isDark,
      borderRadius: 20,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFE0AAFF), size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isDark;

  const _EmptyState({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 190),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withOpacity(0.12) : Colors.black.withOpacity(0.025),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.07) : Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isDark ? Colors.white.withOpacity(0.35) : Colors.black26, size: 42),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white.withOpacity(0.86) : const Color(0xFF0F172A),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white.withOpacity(0.54) : Colors.black54,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _SystemStatusRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _SystemStatusRow({
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final connected = value.toLowerCase().contains("active") || value.toLowerCase().contains("online");
    final color = connected ? const Color(0xFF22C55E) : const Color(0xFFF59E0B);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.045) : Colors.black.withOpacity(0.025),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.07) : Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white.withOpacity(0.80) : const Color(0xFF334155),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _StatusBadge(label: value, color: color),
        ],
      ),
    );
  }
}

class _ThemeChoice extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  final bool isDark;

  const _ThemeChoice({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.active,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFFBC70FF) : (isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.08));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFBC70FF).withOpacity(isDark ? 0.16 : 0.10) : (isDark ? Colors.white.withOpacity(0.045) : Colors.black.withOpacity(0.025)),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color),
        ),
        child: Row(
          children: [
            Icon(icon, color: active ? const Color(0xFFE0AAFF) : (isDark ? Colors.white70 : Colors.black54)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isDark ? Colors.white.withOpacity(0.54) : Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (active) const Icon(Icons.check_circle_rounded, color: Color(0xFFBC70FF)),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.045) : Colors.black.withOpacity(0.025),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white.withOpacity(0.58) : Colors.black54,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DisabledSettingRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final bool isDark;

  const _DisabledSettingRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.62,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.045) : Colors.black.withOpacity(0.025),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isDark ? Colors.white.withOpacity(0.52) : Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: null,
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassContainer extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final double borderRadius;
  final EdgeInsets padding;

  const _GlassContainer({
    required this.child,
    required this.isDark,
    required this.borderRadius,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.075) : Colors.white.withOpacity(0.84),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.10) : Colors.white,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.26 : 0.06),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool isDark;

  const _SearchBox({
    required this.controller,
    required this.hint,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      height: 48,
      child: TextField(
        controller: controller,
        style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A)),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.search_rounded),
          filled: true,
          fillColor: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: BorderSide(
              color: isDark ? Colors.white.withOpacity(0.10) : Colors.black.withOpacity(0.06),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: BorderSide(
              color: isDark ? Colors.white.withOpacity(0.10) : Colors.black.withOpacity(0.06),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        color: color.withOpacity(0.13),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.34)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _OutlineAdminButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _OutlineAdminButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFE0AAFF),
          side: BorderSide(color: const Color(0xFFE0AAFF).withOpacity(0.45)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}

class _RefreshButton extends StatelessWidget {
  final VoidCallback onTap;

  const _RefreshButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _OutlineAdminButton(
      label: "Refresh",
      icon: Icons.refresh_rounded,
      onTap: onTap,
    );
  }
}

class _LoadingPanel extends StatelessWidget {
  final bool isDark;

  const _LoadingPanel({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _GlassContainer(
        isDark: isDark,
        borderRadius: 24,
        padding: const EdgeInsets.all(24),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4, color: Color(0xFFBC70FF)),
            ),
            const SizedBox(width: 14),
            Text(
              "Loading admin console…",
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileAdminTopbar extends StatelessWidget {
  final bool isDark;
  final VoidCallback onRefresh;

  const _MobileAdminTopbar({
    required this.isDark,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(colors: [Color(0xFF8A4FFF), Color(0xFFF72585)]),
            ),
            child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "R2V Admin",
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
    );
  }
}

class _MobileTabChip extends StatelessWidget {
  final _AdminTab tab;
  final bool active;
  final bool isDark;
  final VoidCallback onTap;

  const _MobileTabChip({
    required this.tab,
    required this.active,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = const Color(0xFFBC70FF);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: active ? color : (isDark ? Colors.white.withOpacity(0.08) : Colors.white),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active ? color : (isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.06)),
          ),
        ),
        child: Row(
          children: [
            Icon(tab.icon, size: 18, color: active ? Colors.white : (isDark ? Colors.white70 : Colors.black54)),
            const SizedBox(width: 8),
            Text(
              tab.title,
              style: TextStyle(
                color: active ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminBackground extends StatelessWidget {
  final bool isDark;

  const _AdminBackground({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: _AdminMeshyParticleBackground(isDark: isDark)),
        Positioned.fill(child: _AdminReactHeroBackground(isDark: isDark)),
      ],
    );
  }
}

class _AdminReactHeroBackground extends StatelessWidget {
  final bool isDark;

  const _AdminReactHeroBackground({required this.isDark});

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
                    _AdminGradientBlob(isDark: isDark),
                    const SizedBox(width: 50),
                    _AdminGradientBlob(isDark: isDark),
                    const SizedBox(width: 50),
                    _AdminGradientBlob(isDark: isDark),
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
                    _AdminGradientBlob(isDark: isDark),
                    const SizedBox(width: 50),
                    _AdminGradientBlob(isDark: isDark),
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

class _AdminGradientBlob extends StatelessWidget {
  final bool isDark;

  const _AdminGradientBlob({required this.isDark});

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
                    Colors.white.withOpacity(0.15),
                    Colors.blue.shade300.withOpacity(0.35),
                  ]
                : [
                    const Color(0xFFBC70FF).withOpacity(0.25),
                    const Color(0xFF4895EF).withOpacity(0.25),
                  ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
      ),
    );
  }
}

class _AdminMeshyParticleBackground extends StatelessWidget {
  final bool isDark;

  const _AdminMeshyParticleBackground({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: _AdminMeshyBgCore(isDark: isDark),
    );
  }
}

class _AdminMeshyBgCore extends StatefulWidget {
  final bool isDark;

  const _AdminMeshyBgCore({required this.isDark});

  @override
  State<_AdminMeshyBgCore> createState() => _AdminMeshyBgCoreState();
}

class _AdminMeshyBgCoreState extends State<_AdminMeshyBgCore>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final Random _rng = Random(42);

  Size _size = Size.zero;
  Offset _mouse = Offset.zero;
  bool _hasMouse = false;

  late List<_AdminParticle> _particles;
  double _time = 0;

  @override
  void initState() {
    super.initState();
    _particles = <_AdminParticle>[];

    _ticker = createTicker((elapsed) {
      _time = elapsed.inMilliseconds / 1000.0;

      if (!mounted) return;
      if (_size == Size.zero) return;

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

      setState(() {});
    });

    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
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
      final angle = _rng.nextDouble() * pi * 2;
      final vel = Offset(cos(angle), sin(angle)) * speed;
      final radius = 1.2 + _rng.nextDouble() * 1.9;

      return _AdminParticle(
        pos: pos,
        vel: vel,
        radius: radius,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        if (_size != size) {
          _size = size;
          _ensureParticles(size);
        }

        return MouseRegion(
          onHover: (event) {
            _hasMouse = true;
            _mouse = event.localPosition;
          },
          onExit: (_) => _hasMouse = false,
          child: CustomPaint(
            painter: _AdminMeshPainter(
              particles: _particles,
              time: _time,
              size: size,
              mouse: _mouse,
              hasMouse: _hasMouse,
              isDark: widget.isDark,
            ),
          ),
        );
      },
    );
  }
}

class _AdminParticle {
  Offset pos;
  Offset vel;
  final double radius;

  _AdminParticle({
    required this.pos,
    required this.vel,
    required this.radius,
  });
}

class _AdminMeshPainter extends CustomPainter {
  final List<_AdminParticle> particles;
  final double time;
  final Size size;
  final Offset mouse;
  final bool hasMouse;
  final bool isDark;

  _AdminMeshPainter({
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
        stops: const [0.0, 0.55, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, bg);

    void glowBlob(Offset center, double radius, Color color, double opacity) {
      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 90);

      canvas.drawCircle(center, radius, paint);
    }

    final center = Offset(size.width * 0.55, size.height * 0.35);
    final wobble = Offset(
      sin(time * 0.5) * 40,
      cos(time * 0.45) * 30,
    );

    glowBlob(
      center + wobble,
      280,
      isDark ? const Color(0xFF8A4FFF) : const Color(0xFFA855F7),
      isDark ? 0.18 : 0.12,
    );

    glowBlob(
      Offset(size.width * 0.25, size.height * 0.70) +
          Offset(cos(time * 0.35) * 35, sin(time * 0.32) * 28),
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

      dotPaint.color = isDark
          ? Colors.white.withOpacity(0.12)
          : const Color(0xFF8A4FFF).withOpacity(0.25);

      canvas.drawCircle(pos, p.radius, dotPaint);
    }

    final vignetteColors = isDark
        ? [
            Colors.transparent,
            Colors.black.withOpacity(0.55),
          ]
        : [
            Colors.transparent,
            Colors.white.withOpacity(0.4),
          ];

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
  bool shouldRepaint(covariant _AdminMeshPainter oldDelegate) => true;
}

class _AdminTab {
  final String title;
  final IconData icon;

  const _AdminTab(this.title, this.icon);
}

class _MetricItem {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricItem(this.title, this.value, this.icon, this.color);
}