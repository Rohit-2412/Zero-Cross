import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/ai_difficulty.dart';
import '../../models/game_statistics.dart';
import '../../services/local_storage_service.dart';
import '../../providers/theme_provider.dart';

class StatsScreen extends StatefulWidget {
  final GameStatistics gameStats;

  const StatsScreen({super.key, required this.gameStats});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _animationController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
    _animation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Game Statistics', style: GoogleFonts.varelaRound(fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), tooltip: 'Reset All Stats', onPressed: _showResetConfirmDialog),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(child: Text('Overview', style: GoogleFonts.varelaRound(fontSize: 12))),
            Tab(child: Text('Easy', style: GoogleFonts.varelaRound(fontSize: 12))),
            Tab(child: Text('Medium', style: GoogleFonts.varelaRound(fontSize: 12))),
            Tab(child: Text('Hard', style: GoogleFonts.varelaRound(fontSize: 12))),
          ],
        ),
      ),
      body: FadeTransition(
        opacity: _animation,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(),
            _buildDifficultyTab(AIDifficulty.easy),
            _buildDifficultyTab(AIDifficulty.medium),
            _buildDifficultyTab(AIDifficulty.hard),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    final totalStats = _calculateTotalStats();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall Statistics Card
          _buildStatsCard(
            title: 'Overall Performance',
            icon: Icons.bar_chart,
            color: Theme.of(context).colorScheme.primary,
            child: Column(
              children: [
                _buildStatRow('Total Games', totalStats['totalGames'].toString()),
                _buildStatRow('Wins', totalStats['playerWins'].toString(), Colors.green),
                _buildStatRow('Losses', totalStats['aiWins'].toString(), Colors.red),
                _buildStatRow('Draws', totalStats['draws'].toString(), Colors.orange),
                const Divider(),
                _buildStatRow(
                  'Win Rate',
                  '${totalStats['winRate'].toStringAsFixed(1)}%',
                  totalStats['winRate'] >= 50 ? Colors.green : Colors.red,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Difficulty Breakdown
          Text(
            'Performance by Difficulty',
            style: GoogleFonts.varelaRound(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 12),

          ...AIDifficulty.values.map((difficulty) {
            final stats = widget.gameStats.getStats(difficulty);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildDifficultyOverviewCard(difficulty, stats),
            );
          }),

          const SizedBox(height: 16),

          // Settings Section
          _buildSettingsSection(),
        ],
      ),
    );
  }

  Widget _buildDifficultyTab(AIDifficulty difficulty) {
    final stats = widget.gameStats.getStats(difficulty);
    final color = _getDifficultyColor(difficulty);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Difficulty Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                  child: Icon(_getDifficultyIcon(difficulty), color: color, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${difficulty.displayName} Mode',
                        style: GoogleFonts.varelaRound(fontSize: 24, fontWeight: FontWeight.w700, color: color),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        difficulty.description,
                        style: GoogleFonts.varelaRound(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          if (stats.totalGames > 0) ...[
            // Detailed Statistics
            _buildStatsCard(
              title: 'Game Statistics',
              icon: Icons.gamepad,
              color: color,
              child: Column(
                children: [
                  _buildStatRow('Total Games', stats.totalGames.toString()),
                  _buildStatRow('Wins', stats.playerWins.toString(), Colors.green),
                  _buildStatRow('Losses', stats.aiWins.toString(), Colors.red),
                  _buildStatRow('Draws', stats.draws.toString(), Colors.orange),
                  const Divider(),
                  _buildStatRow(
                    'Win Rate',
                    '${(stats.winRate * 100).toStringAsFixed(1)}%',
                    stats.winRate >= 0.5 ? Colors.green : Colors.red,
                  ),
                  _buildStatRow('Loss Rate', '${(stats.lossRate * 100).toStringAsFixed(1)}%', Colors.red),
                  _buildStatRow('Draw Rate', '${(stats.drawRate * 100).toStringAsFixed(1)}%', Colors.orange),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Performance Analysis
            _buildStatsCard(
              title: 'Performance Analysis',
              icon: Icons.analytics,
              color: color,
              child: Column(
                children: [
                  _buildPerformanceIndicator('Skill Level', _getSkillLevel(stats), color),
                  _buildPerformanceIndicator('Consistency', _getConsistency(stats), color),
                  _buildPerformanceIndicator('Challenge Rating', _getChallengeRating(difficulty), color),
                ],
              ),
            ),
          ] else ...[
            // No games played yet
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Icon(
                    Icons.sports_esports_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No games played yet',
                    style: GoogleFonts.varelaRound(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start playing on ${difficulty.displayName} mode to see your stats!',
                    style: GoogleFonts.varelaRound(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsCard({required String title, required IconData icon, required Color color, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.varelaRound(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.varelaRound(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.varelaRound(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyOverviewCard(AIDifficulty difficulty, DifficultyStats stats) {
    final color = _getDifficultyColor(difficulty);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(_getDifficultyIcon(difficulty), color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  difficulty.displayName,
                  style: GoogleFonts.varelaRound(fontSize: 16, fontWeight: FontWeight.w600, color: color),
                ),
                Text(
                  stats.totalGames > 0
                      ? '${stats.totalGames} games • ${(stats.winRate * 100).toStringAsFixed(1)}% win rate'
                      : 'No games played',
                  style: GoogleFonts.varelaRound(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          if (stats.totalGames > 0)
            Text(
              '${stats.playerWins}W ${stats.aiWins}L ${stats.draws}D',
              style: GoogleFonts.varelaRound(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPerformanceIndicator(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.varelaRound(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
            child: Text(value, style: GoogleFonts.varelaRound(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return _buildStatsCard(
          title: 'Settings',
          icon: Icons.settings,
          color: Theme.of(context).colorScheme.primary,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Dark Mode',
                    style: GoogleFonts.varelaRound(fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
                  ),
                  Switch(value: themeProvider.isDarkMode, onChanged: (value) => themeProvider.toggleTheme()),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Export Data',
                    style: GoogleFonts.varelaRound(fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
                  ),
                  IconButton(icon: const Icon(Icons.file_download), onPressed: _exportData),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Map<String, dynamic> _calculateTotalStats() {
    int totalGames = 0;
    int playerWins = 0;
    int aiWins = 0;
    int draws = 0;

    for (final difficulty in AIDifficulty.values) {
      final stats = widget.gameStats.getStats(difficulty);
      totalGames += stats.totalGames;
      playerWins += stats.playerWins;
      aiWins += stats.aiWins;
      draws += stats.draws;
    }

    final winRate = totalGames > 0 ? (playerWins / totalGames) * 100 : 0.0;

    return {'totalGames': totalGames, 'playerWins': playerWins, 'aiWins': aiWins, 'draws': draws, 'winRate': winRate};
  }

  String _getSkillLevel(DifficultyStats stats) {
    if (stats.totalGames < 5) return 'Beginner';
    if (stats.winRate >= 0.8) return 'Expert';
    if (stats.winRate >= 0.6) return 'Advanced';
    if (stats.winRate >= 0.4) return 'Intermediate';
    return 'Novice';
  }

  String _getConsistency(DifficultyStats stats) {
    if (stats.totalGames < 3) return 'Unknown';
    final drawRate = stats.drawRate;
    if (drawRate >= 0.3) return 'Very Consistent';
    if (drawRate >= 0.15) return 'Consistent';
    return 'Variable';
  }

  String _getChallengeRating(AIDifficulty difficulty) {
    switch (difficulty) {
      case AIDifficulty.easy:
        return 'Beginner Friendly';
      case AIDifficulty.medium:
        return 'Moderate Challenge';
      case AIDifficulty.hard:
        return 'Expert Level';
    }
  }

  Color _getDifficultyColor(AIDifficulty difficulty) {
    switch (difficulty) {
      case AIDifficulty.easy:
        return Colors.green;
      case AIDifficulty.medium:
        return Colors.orange;
      case AIDifficulty.hard:
        return Colors.red;
    }
  }

  IconData _getDifficultyIcon(AIDifficulty difficulty) {
    switch (difficulty) {
      case AIDifficulty.easy:
        return Icons.sentiment_satisfied;
      case AIDifficulty.medium:
        return Icons.sentiment_neutral;
      case AIDifficulty.hard:
        return Icons.sentiment_very_dissatisfied;
    }
  }

  void _showResetConfirmDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Reset Statistics', style: GoogleFonts.varelaRound(fontWeight: FontWeight.w600)),
            content: Text(
              'Are you sure you want to reset all game statistics? This action cannot be undone.',
              style: GoogleFonts.varelaRound(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel', style: GoogleFonts.varelaRound()),
              ),
              ElevatedButton(
                onPressed: () {
                  widget.gameStats.reset();
                  LocalStorageService.clearStatistics();
                  Navigator.of(context).pop();
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Statistics reset successfully', style: GoogleFonts.varelaRound())),
                  );
                },
                child: Text('Reset', style: GoogleFonts.varelaRound(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
    );
  }

  void _exportData() {
    // TODO: Implement data export functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Export feature coming soon!', style: GoogleFonts.varelaRound())));
  }
}
