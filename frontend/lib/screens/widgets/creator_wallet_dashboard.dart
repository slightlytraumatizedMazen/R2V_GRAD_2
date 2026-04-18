import 'package:flutter/material.dart';
import 'dart:ui';

class CreatorWalletDashboard extends StatefulWidget {
  const CreatorWalletDashboard({super.key});

  @override
  State<CreatorWalletDashboard> createState() => _CreatorWalletDashboardState();
}

class _CreatorWalletDashboardState extends State<CreatorWalletDashboard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _cardsFade;
  late Animation<Offset> _cardsSlide;
  late Animation<double> _historyFade;
  late Animation<Offset> _historySlide;
  late Animation<double> _supportFade;
  late Animation<Offset> _supportSlide;

  final List<Map<String, dynamic>> _transactions = [
    {
      "icon": Icons.account_balance_wallet_rounded,
      "title": "Hyper-Reality Suite #04",
      "client": "Neon Dynamics Inc.",
      "date": "Oct 24, 2023",
      "status": "Completed",
      "statusColor": const Color(0xFF9333EA),
      "amount": "+\$2,400.00",
      "isPositive": true,
    },
    {
      "icon": Icons.watch_later_rounded,
      "title": "Avatar Rigging Package",
      "client": "Metaverse Collective",
      "date": "Oct 21, 2023",
      "status": "In Escrow",
      "statusColor": const Color(0xFF6B7280),
      "amount": "+\$850.00",
      "isPositive": true,
    },
    {
      "icon": Icons.account_balance_rounded,
      "title": "Bank Withdrawal",
      "client": "Method: Chase Business ****4422",
      "date": "Oct 18, 2023",
      "status": "Processed",
      "statusColor": const Color(0xFFBC70FF),
      "amount": "-\$5,000.00",
      "isPositive": false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));

    _headerFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)));
    _headerSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)));

    _cardsFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.6, curve: Curves.easeOut)));
    _cardsSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.6, curve: Curves.easeOut)));

    _historyFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.9, curve: Curves.easeOut)));
    _historySlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.9, curve: Curves.easeOut)));

    _supportFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.6, 1.0, curve: Curves.easeOut)));
    _supportSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.6, 1.0, curve: Curves.easeOut)));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showSnackbar(String text, bool isDark) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          style: TextStyle(fontFamily: 'Inter', color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600),
        ),
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: const Color(0xFFBC70FF).withOpacity(0.5)),
        ),
        duration: const Duration(seconds: 2),
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
          // 1. Header Row
          FadeTransition(
            opacity: _headerFade,
            child: SlideTransition(
              position: _headerSlide,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Financials",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                      fontSize: isWeb ? 32 : 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Manage your earnings, track secure escrowed funds, and execute seamless withdrawals across the R2V Studio ecosystem.",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: isWeb ? 48 : 24),

          // 2. Financial Cards Row
          FadeTransition(
            opacity: _cardsFade,
            child: SlideTransition(
              position: _cardsSlide,
              child: isWeb 
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 6, child: _buildAvailableBalanceCard(isDark, isWeb)),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 4, 
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildEscrowCard(isDark),
                              const SizedBox(height: 24),
                              _buildPendingCreditsCard(isDark),
                            ],
                          )
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildAvailableBalanceCard(isDark, isWeb),
                        const SizedBox(height: 16),
                        _buildEscrowCard(isDark),
                        const SizedBox(height: 16),
                        _buildPendingCreditsCard(isDark),
                      ],
                    ),
            ),
          ),
          SizedBox(height: isWeb ? 56 : 32),

          // 3. Transaction History
          FadeTransition(
            opacity: _historyFade,
            child: SlideTransition(
              position: _historySlide,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isWeb)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Transaction History",
                              style: TextStyle(fontFamily: 'Inter', color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 22, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Review all financial activity and contract payments.",
                              style: TextStyle(fontFamily: 'Inter', color: isDark ? Colors.white70 : Colors.black54, fontSize: 13),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            _buildGlassButton("Filter", Icons.filter_list_rounded, isDark),
                            const SizedBox(width: 12),
                            _buildGlassButton("Export", Icons.download_rounded, isDark),
                          ],
                        ),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Transaction History", style: TextStyle(fontFamily: 'Inter', color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 20, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        Text("Review all financial activity.", style: TextStyle(fontFamily: 'Inter', color: isDark ? Colors.white70 : Colors.black54, fontSize: 13)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildGlassButton("Filter", Icons.filter_list_rounded, isDark)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildGlassButton("Export", Icons.download_rounded, isDark)),
                          ],
                        ),
                      ],
                    ),
                  
                  const SizedBox(height: 24),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _transactions.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final tx = _transactions[index];
                      return _buildTransactionRow(tx, isDark, isWeb);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 48),

          // 4. Support Banner (Bottom)
          FadeTransition(
            opacity: _supportFade,
            child: SlideTransition(
              position: _supportSlide,
              child: CustomPaint(
                painter: _DashedBorderPainter(
                  color: isDark ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.1),
                  strokeWidth: 1.5,
                  dashWidth: 8,
                  dashSpace: 6,
                  borderRadius: 24,
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: isWeb ? 32 : 20, vertical: 32),
                  child: isWeb 
                    ? Row(
                        children: [
                          _buildSupportIcon(),
                          const SizedBox(width: 24),
                          Expanded(child: _buildSupportText(isDark)),
                          _buildSupportButton(isDark),
                        ],
                      )
                    : Column(
                        children: [
                          Row(
                            children: [
                              _buildSupportIcon(),
                              const SizedBox(width: 16),
                              Expanded(child: _buildSupportText(isDark)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(width: double.infinity, child: _buildSupportButton(isDark)),
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

  // --- COMPONENTS ---

  Widget _buildAvailableBalanceCard(bool isDark, bool isWeb) {
    return Container(
      padding: EdgeInsets.all(isWeb ? 32 : 24),
      decoration: _glassDecoration(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "AVAILABLE BALANCE",
                style: TextStyle(fontFamily: 'Inter', color: isDark ? Colors.white70 : Colors.black54, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5),
              ),
              const SizedBox(height: 16),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.end,
                children: [
                  Text(
                    "\$12,450.00",
                    style: TextStyle(fontFamily: 'Inter', color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: isWeb ? 48 : 36, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(width: 12),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Text("USD", style: TextStyle(fontFamily: 'Inter', color: Color(0xFFBC70FF), fontSize: 18, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.verified_rounded, color: Color(0xFFBC70FF), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text("Verified Funds • Ready for withdrawal", style: TextStyle(fontFamily: 'Inter', color: isDark ? Colors.white70 : Colors.black54, fontSize: 13)),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: isWeb ? 48 : 32),
          // ✅ FIX: Wrapped in Expanded inside the Row, and added FittedBox to buttons to stop overflows
          isWeb ? Row(
            children: [
              Expanded(child: _buildPrimaryBtn("WITHDRAW FUNDS", () => _showSnackbar("Initiating Withdrawal...", isDark), isDark)),
              const SizedBox(width: 16),
              Expanded(child: _buildSecondaryBtn("ADD PAYOUT METHOD", () => _showSnackbar("Routing to Setup...", isDark), isDark)),
            ],
          ) : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPrimaryBtn("WITHDRAW FUNDS", () => _showSnackbar("Initiating Withdrawal...", isDark), isDark),
              const SizedBox(height: 12),
              _buildSecondaryBtn("ADD PAYOUT METHOD", () => _showSnackbar("Routing to Setup...", isDark), isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEscrowCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _glassDecoration(isDark, borderColor: const Color(0xFFBC70FF).withOpacity(0.3)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Escrow Protection", style: TextStyle(fontFamily: 'Inter', color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text("Active Project Funds", style: TextStyle(fontFamily: 'Inter', color: isDark ? Colors.white70 : Colors.black54, fontSize: 12)),
                ],
              ),
              const Icon(Icons.shield_rounded, color: Color(0xFFBC70FF), size: 20),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Active Milestones", style: TextStyle(fontFamily: 'Inter', color: isDark ? Colors.white70 : Colors.black54, fontSize: 13)),
              Text("\$4,200.00", style: TextStyle(fontFamily: 'Inter', color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 16, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: 0.68,
              minHeight: 4,
              backgroundColor: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFBC70FF)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("PENDING REVIEW", style: TextStyle(fontFamily: 'Inter', color: isDark ? Colors.white60 : Colors.black45, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.0)),
              const Text("68% RELEASED", style: TextStyle(fontFamily: 'Inter', color: Color(0xFFBC70FF), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.0)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPendingCreditsCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _glassDecoration(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("PENDING CREDITS", style: TextStyle(fontFamily: 'Inter', color: isDark ? Colors.white70 : Colors.black54, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              Text("\$1,840.50", style: TextStyle(fontFamily: 'Inter', color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 28, fontWeight: FontWeight.w800)),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Text("Clearing in 3 days", style: TextStyle(fontFamily: 'Inter', color: isDark ? Colors.white70 : Colors.black54, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {},
              child: Row(
                children: const [
                  Text("View clearing schedule", style: TextStyle(fontFamily: 'Inter', color: Color(0xFFBC70FF), fontSize: 12, fontWeight: FontWeight.w700)),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, color: Color(0xFFBC70FF), size: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionRow(Map<String, dynamic> tx, bool isDark, bool isWeb) {
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subColor = isDark ? Colors.white70 : Colors.black54;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: _glassDecoration(isDark),
      child: isWeb 
        ? Row(
            children: [
              _buildTxIcon(tx['icon'], isDark),
              const SizedBox(width: 20),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tx['title'], style: TextStyle(fontFamily: 'Inter', color: textColor, fontSize: 15, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text("Client: ${tx['client']}", style: TextStyle(fontFamily: 'Inter', color: subColor, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("DATE", style: TextStyle(fontFamily: 'Inter', color: subColor, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.0)),
                    const SizedBox(height: 6),
                    Text(tx['date'], style: TextStyle(fontFamily: 'Inter', color: textColor, fontSize: 13, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("STATUS", style: TextStyle(fontFamily: 'Inter', color: subColor, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.0)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          width: 8, height: 8,
                          decoration: BoxDecoration(color: tx['statusColor'], shape: BoxShape.circle, boxShadow: [BoxShadow(color: (tx['statusColor'] as Color).withOpacity(0.5), blurRadius: 4)]),
                        ),
                        const SizedBox(width: 8),
                        Text(tx['status'], style: TextStyle(fontFamily: 'Inter', color: textColor, fontSize: 13, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(tx['amount'], style: TextStyle(fontFamily: 'Inter', color: textColor, fontSize: 16, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildTxIcon(tx['icon'], isDark),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tx['title'], style: TextStyle(fontFamily: 'Inter', color: textColor, fontSize: 15, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text("Client: ${tx['client']}", style: TextStyle(fontFamily: 'Inter', color: subColor, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tx['date'], style: TextStyle(fontFamily: 'Inter', color: subColor, fontSize: 12)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(width: 8, height: 8, decoration: BoxDecoration(color: tx['statusColor'], shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text(tx['status'], style: TextStyle(fontFamily: 'Inter', color: textColor, fontSize: 12, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                  Text(tx['amount'], style: TextStyle(fontFamily: 'Inter', color: textColor, fontSize: 16, fontWeight: FontWeight.w800)),
                ],
              )
            ],
          ),
    );
  }

  Widget _buildTxIcon(IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.04),
        shape: BoxShape.circle,
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.transparent),
      ),
      child: Icon(icon, color: isDark ? Colors.white70 : Colors.black54, size: 20),
    );
  }

  Widget _buildSupportIcon() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFBC70FF).withOpacity(0.15), shape: BoxShape.circle),
      child: const Icon(Icons.gavel_rounded, color: Color(0xFFBC70FF), size: 24),
    );
  }

  Widget _buildSupportText(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Having trouble with a contract?", style: TextStyle(fontFamily: 'Inter', color: isDark ? Colors.white : const Color(0xFF1E293B), fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text("Our secure mediation system protects both creators and clients.", style: TextStyle(fontFamily: 'Inter', color: isDark ? Colors.white70 : Colors.black54, fontSize: 13)),
      ],
    );
  }

  Widget _buildSupportButton(bool isDark) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        foregroundColor: isDark ? Colors.white : const Color(0xFF1E293B),
        side: BorderSide(color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text("GET SUPPORT", style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.0)),
    );
  }

  Widget _buildGlassButton(String label, IconData icon, bool isDark) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: isDark ? Colors.white : const Color(0xFF1E293B),
        side: BorderSide(color: isDark ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.1)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }

  // ✅ FIX: Added FittedBox to scale down text before overflowing
  Widget _buildPrimaryBtn(String text, VoidCallback onTap, bool isDark) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF8A4FFF),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: isDark ? 0 : 4,
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(text, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1.0)),
      ),
    );
  }

  // ✅ FIX: Added FittedBox to scale down text before overflowing
  Widget _buildSecondaryBtn(String text, VoidCallback onTap, bool isDark) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: isDark ? Colors.white : const Color(0xFF1E293B),
        side: BorderSide(color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.15)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(text, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1.0)),
      ),
    );
  }

  BoxDecoration _glassDecoration(bool isDark, {Color? borderColor}) {
    return BoxDecoration(
      color: isDark ? Colors.black.withOpacity(0.25) : Colors.white.withOpacity(0.85),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: borderColor ?? (isDark ? Colors.white.withOpacity(0.1) : Colors.white)),
      boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double borderRadius;

  _DashedBorderPainter({required this.color, required this.strokeWidth, required this.dashWidth, required this.dashSpace, required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = color..strokeWidth = strokeWidth..style = PaintingStyle.stroke;
    final RRect rrect = RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), Radius.circular(borderRadius));
    Path path = Path()..addRRect(rrect);
    Path dashPath = Path();
    for (PathMetric pathMetric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        dashPath.addPath(pathMetric.extractPath(distance, distance + dashWidth), Offset.zero);
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}