import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../core/constants.dart';
import '../../models/game_state.dart';
import '../../services/local_storage_service.dart';
import 'game_screen.dart';
import 'single_player_game_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String player1Name = AppConstants.defaultPlayer1Name;
  String player2Name = AppConstants.defaultPlayer2Name;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this);

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: const Interval(0.3, 1.0, curve: Curves.easeOut)));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                themeProvider.isDarkMode
                    ? [const Color(0xFF1A1A2E), const Color(0xFF16213E), const Color(0xFF0F3460)]
                    : [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB), const Color(0xFF90CAF9)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.08, vertical: 20),
            child: Column(
              children: [
                // Header with theme toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 48), // Balance the toggle button
                    Expanded(
                      child: Center(
                        child: Text(
                          'Tic Tac Toe',
                          style: GoogleFonts.fredoka(
                            fontSize: screenSize.width < 400 ? 28 : 32,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: themeProvider.toggleTheme,
                      icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
                      iconSize: 28,
                    ),
                  ],
                ),

                Expanded(
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Animated Title
                              _buildAnimatedTitle(),

                              SizedBox(height: screenSize.height * 0.06),

                              // Game Mode Selection
                              Text(
                                AppStrings.chooseGameMode,
                                style: GoogleFonts.inter(
                                  fontSize: screenSize.width < AppConstants.mobileBreakpoint ? 18 : 24,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.8),
                                ),
                                textAlign: TextAlign.center,
                              ),

                              SizedBox(height: screenSize.height * 0.04),

                              // Game Mode Buttons
                              _buildGameModeButton(
                                context: context,
                                title: AppStrings.singlePlayer,
                                subtitle: AppStrings.playVsAI,
                                icon: Icons.smart_toy,
                                onPressed: () => _startSinglePlayer(context),
                                gradient: const LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)]),
                                isSmallScreen: screenSize.width < AppConstants.mobileBreakpoint,
                              ),

                              const SizedBox(height: 20),

                              _buildGameModeButton(
                                context: context,
                                title: AppStrings.multiplayer,
                                subtitle: AppStrings.playWithFriend,
                                icon: Icons.people,
                                onPressed: () => _startMultiplayer(context),
                                gradient: const LinearGradient(colors: [Color(0xFFf093fb), Color(0xFFf5576c)]),
                                isSmallScreen: screenSize.width < AppConstants.mobileBreakpoint,
                              ),

                              const SizedBox(height: 20),

                              _buildGameModeButton(
                                context: context,
                                title: 'Statistics',
                                subtitle: 'View your game stats',
                                icon: Icons.bar_chart,
                                onPressed: () => _viewStats(context),
                                gradient: const LinearGradient(colors: [Color(0xFF4facfe), Color(0xFF00f2fe)]),
                                isSmallScreen: screenSize.width < AppConstants.mobileBreakpoint,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedTitle() {
    final colors = [Colors.red.shade400, Colors.pink.shade400, Colors.orange.shade400];

    final titles = ['Tic', 'Tac', 'Toe'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:
          titles.asMap().entries.map((entry) {
            final index = entry.key;
            final title = entry.value;

            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 800 + (index * 200)),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      title,
                      style: GoogleFonts.fredoka(fontSize: 48, fontWeight: FontWeight.w700, color: colors[index]),
                    ),
                  ),
                );
              },
            );
          }).toList(),
    );
  }

  Widget _buildGameModeButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onPressed,
    required Gradient gradient,
    required bool isSmallScreen,
  }) {
    return Container(
      width: double.infinity,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Material(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.white, size: 24),
                  ),

                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                        const SizedBox(height: 2),
                        Text(subtitle, style: GoogleFonts.inter(fontSize: 14, color: Colors.white.withOpacity(0.8))),
                      ],
                    ),
                  ),

                  const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _startSinglePlayer(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const SinglePlayerGameScreen()));
  }

  void _startMultiplayer(BuildContext context) {
    log('Multiplayer mode selected - navigating to game screen with default names');

    // Use default names or handle custom name input
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => GameScreen(mode: GameMode.multiplayer, player1Name: player1Name, player2Name: player2Name),
      ),
    );
  }

  void _viewStats(BuildContext context) {
    final gameStats = LocalStorageService.getGameStatistics();
    Navigator.push(context, MaterialPageRoute(builder: (context) => StatsScreen(gameStats: gameStats)));
  }
}
