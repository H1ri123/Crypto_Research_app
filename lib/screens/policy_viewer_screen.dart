import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../core/theme/app_theme.dart';

class PolicyViewerScreen extends StatefulWidget {
  final int initialTabIndex; // 0 for Privacy Policy, 1 for Terms of Service

  const PolicyViewerScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<PolicyViewerScreen> createState() => _PolicyViewerScreenState();
}

class _PolicyViewerScreenState extends State<PolicyViewerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedArrowLeft01,
                size: 20,
                color: AppColors.textPrimary,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title: const Text(
          'Legal & Compliance',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              labelColor: Colors.black,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              unselectedLabelStyle:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              tabs: const [
                Tab(text: 'Privacy Policy'),
                Tab(text: 'Terms of Service'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPolicyContent(),
          _buildTermsContent(),
        ],
      ),
    );
  }

  Widget _buildPolicyContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('1. Information Collection & Usage'),
          _buildParagraph(
            'Crypto Research respects your digital privacy. We do not store, sell, or monetize your personal credentials, private keys, or wallet seed phrases. The application collects anonymous telemetry and market search queries solely to optimize app performance and deliver real-time pricing feeds.',
          ),
          _buildSectionHeader('2. Data Encryption & Security Standards'),
          _buildParagraph(
            'All data in transit is protected using industry-grade TLS 1.3 encryption. Your watchlist configurations and custom preferences are stored locally on your device in secure sandbox storage using native platform encryption APIs.',
          ),
          _buildSectionHeader('3. Third-Party Market Data APIs'),
          _buildParagraph(
            'Market capitalization, 24-hour volume, and price ticker feeds are aggregated from vetted cryptographic market indexing services. These third parties do not receive personal identifiers or user profile data from your device session.',
          ),
          _buildSectionHeader('4. User Rights & Data Deletion'),
          _buildParagraph(
            'You have full control over your stored preferences. Logging out or clearing app storage immediately purges all locally cached authentication tokens, search histories, and custom watchlist entries.',
          ),
          _buildSectionHeader('5. Policy Updates'),
          _buildParagraph(
            'We periodically review and update this privacy policy to reflect new regulatory guidelines and crypto market compliance rules. Last updated: September 2026.',
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildTermsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('1. Non-Financial Advisory Disclaimer'),
          _buildParagraph(
            'The charts, rankings, dominance metrics, and statistical data displayed in Crypto Research are for general informational and educational purposes only. They do not constitute financial, investment, legal, or tax advice. Always conduct your own independent research before making trading decisions.',
          ),
          _buildSectionHeader('2. Platform Usage & Eligibility'),
          _buildParagraph(
            'By using the Crypto Research platform, you certify that you are legally permitted to view and interact with cryptocurrency information under the regulations of your local jurisdiction.',
          ),
          _buildSectionHeader('3. Market Volatility & Risk Disclosure'),
          _buildParagraph(
            'Cryptocurrency assets are subject to severe market volatility and rapid price movements. Crypto Research and its contributors bear no liability for financial gains or losses incurred through trading actions taken based on platform data.',
          ),
          _buildSectionHeader('4. Intellectual Property & Prohibited Actions'),
          _buildParagraph(
            'All proprietary UI designs, analytical metrics, logos, and custom charting tools are protected intellectual property. Reverse-engineering, unauthorized scraping, or automated spamming of app endpoints is strictly prohibited.',
          ),
          _buildSectionHeader('5. Termination & Service Amendments'),
          _buildParagraph(
            'We reserve the right to modify, suspend, or terminate platform features at any time without prior liability. Continued usage signifies ongoing acceptance of amended terms.',
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 18.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
          letterSpacing: -0.3,
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13.5,
          color: AppColors.textSecondary,
          height: 1.55,
        ),
      ),
    );
  }
}
