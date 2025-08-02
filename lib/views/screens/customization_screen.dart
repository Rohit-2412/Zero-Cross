import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/local_storage_service.dart';
import '../../services/sound_service.dart';

class CustomizationScreen extends StatefulWidget {
  const CustomizationScreen({super.key});

  @override
  State<CustomizationScreen> createState() => _CustomizationScreenState();
}

class _CustomizationScreenState extends State<CustomizationScreen> with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  bool _soundEnabled = true;
  bool _vibrationsEnabled = true;
  bool _showHints = true;
  bool _autoSaveGame = true;
  bool _backgroundMusic = false;
  bool _gameTimerEnabled = true;
  int _gameTimerDuration = 30;

  @override
  void initState() {
    super.initState();
    _loadSettings();

    _slideController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _loadSettings() {
    setState(() {
      _soundEnabled = LocalStorageService.getSoundEnabled();
      _vibrationsEnabled = LocalStorageService.getVibrationsEnabled();
      _showHints = LocalStorageService.getShowHints();
      _autoSaveGame = LocalStorageService.getAutoSaveGame();
      _backgroundMusic = LocalStorageService.getBackgroundMusic();
      _gameTimerEnabled = LocalStorageService.getGameTimerEnabled();
      _gameTimerDuration = LocalStorageService.getGameTimerDuration();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Customization', style: GoogleFonts.varelaRound(fontWeight: FontWeight.w600)),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
      ),
      body: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.05, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Theme Section
              _buildSectionCard(
                title: 'Theme & Appearance',
                icon: Icons.palette,
                children: [
                  _buildThemeToggle(themeProvider),
                  const SizedBox(height: 16),
                  _buildColorSchemeSelector(themeProvider),
                  const SizedBox(height: 16),
                  _buildBoardStyleSelector(themeProvider),
                  const SizedBox(height: 16),
                  _buildSymbolSelector(themeProvider),
                  const SizedBox(height: 16),
                  _buildCornerRadiusSlider(themeProvider),
                ],
              ),

              const SizedBox(height: 20),

              // Game Settings Section
              _buildSectionCard(
                title: 'Game Settings',
                icon: Icons.sports_esports,
                children: [
                  _buildGameTimerSettings(),
                  const SizedBox(height: 16),
                  _buildSwitchTile(
                    title: 'Show Hints',
                    subtitle: 'Display helpful hints during gameplay',
                    value: _showHints,
                    onChanged: (value) {
                      setState(() => _showHints = value);
                      LocalStorageService.saveShowHints(value);
                    },
                  ),
                  _buildSwitchTile(
                    title: 'Auto Save Game',
                    subtitle: 'Automatically save game progress',
                    value: _autoSaveGame,
                    onChanged: (value) {
                      setState(() => _autoSaveGame = value);
                      LocalStorageService.saveAutoSaveGame(value);
                    },
                  ),
                  _buildSwitchTile(
                    title: 'Animations Enabled',
                    subtitle: 'Enable smooth animations throughout the app',
                    value: themeProvider.animationsEnabled,
                    onChanged: (value) {
                      themeProvider.setAnimationsEnabled(value);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Audio & Feedback Section
              _buildSectionCard(
                title: 'Audio & Feedback',
                icon: Icons.volume_up,
                children: [
                  _buildSwitchTile(
                    title: 'Sound Effects',
                    subtitle: 'Play sound effects during gameplay',
                    value: _soundEnabled,
                    onChanged: (value) {
                      setState(() => _soundEnabled = value);
                      LocalStorageService.saveSoundEnabled(value);
                      // Update SoundService internal state
                      if (value != SoundService.soundEnabled) {
                        SoundService.toggleSound();
                      }
                    },
                  ),
                  _buildSwitchTile(
                    title: 'Background Music',
                    subtitle: 'Play ambient background music',
                    value: _backgroundMusic,
                    onChanged: (value) {
                      setState(() => _backgroundMusic = value);
                      LocalStorageService.saveBackgroundMusic(value);
                    },
                  ),
                  _buildSwitchTile(
                    title: 'Vibrations',
                    subtitle: 'Vibrate on game actions (if supported)',
                    value: _vibrationsEnabled,
                    onChanged: (value) {
                      setState(() => _vibrationsEnabled = value);
                      LocalStorageService.saveVibrationsEnabled(value);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Reset Section
              _buildSectionCard(title: 'Reset Options', icon: Icons.refresh, children: [_buildResetButtons()]),

              const SizedBox(height: 80), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required List<Widget> children}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
                ),
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
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildThemeToggle(ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(
            themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Theme Mode',
                  style: GoogleFonts.varelaRound(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  themeProvider.isDarkMode ? 'Dark Mode' : 'Light Mode',
                  style: GoogleFonts.varelaRound(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .7),
                  ),
                ),
              ],
            ),
          ),
          Switch(value: themeProvider.isDarkMode, onChanged: (_) => themeProvider.toggleTheme()),
        ],
      ),
    );
  }

  Widget _buildColorSchemeSelector(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color Scheme',
          style: GoogleFonts.varelaRound(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: AppColorScheme.values.length,
            itemBuilder: (context, index) {
              final scheme = AppColorScheme.values[index];
              final isSelected = themeProvider.colorScheme == scheme;

              return GestureDetector(
                onTap: () => themeProvider.setColorScheme(scheme),
                child: Container(
                  width: 60,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode ? scheme.darkColor : scheme.lightColor,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: isSelected ? Colors.white : Colors.transparent, width: 3),
                    boxShadow:
                        isSelected
                            ? [
                              BoxShadow(
                                color: (themeProvider.isDarkMode ? scheme.darkColor : scheme.lightColor).withValues(
                                  alpha: 0.4,
                                ),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                            : null,
                  ),
                  child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                ),
              );
            },
          ),
        ),
        Text(
          themeProvider.colorScheme.displayName,
          style: GoogleFonts.varelaRound(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildBoardStyleSelector(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Board Style',
          style: GoogleFonts.varelaRound(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: BoardStyle.values.length,
          itemBuilder: (context, index) {
            final style = BoardStyle.values[index];
            final isSelected = themeProvider.boardStyle == style;

            return InkWell(
              onTap: () => themeProvider.setBoardStyle(style),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                          : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color:
                        isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Expanded(child: _buildBoardStylePreview(style, themeProvider)),
                      const SizedBox(height: 8),
                      Text(
                        style.displayName,
                        style: GoogleFonts.varelaRound(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color:
                              isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        style.description,
                        style: GoogleFonts.varelaRound(
                          fontSize: 10,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBoardStylePreview(BoardStyle style, ThemeProvider themeProvider) {
    return Container(
      decoration: _getPreviewBoardDecoration(style, themeProvider),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: _getPreviewCellSpacing(style),
          mainAxisSpacing: _getPreviewCellSpacing(style),
        ),
        itemCount: 9,
        itemBuilder: (context, index) {
          // Sample board pattern
          String value = '';
          if (index == 0 || index == 4 || index == 8) value = 'X';
          if (index == 2 || index == 6) value = 'O';

          String displayValue = '';
          if (value == 'X') displayValue = themeProvider.playerXSymbol;
          if (value == 'O') displayValue = themeProvider.playerOSymbol;

          return Container(
            decoration: _getPreviewCellDecoration(style, value, themeProvider),
            child: Center(
              child:
                  displayValue.isNotEmpty
                      ? Text(
                        displayValue,
                        style: GoogleFonts.varelaRound(
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          color: _getPreviewCellColor(value, style, themeProvider),
                        ),
                      )
                      : null,
            ),
          );
        },
      ),
    );
  }

  BoxDecoration _getPreviewBoardDecoration(BoardStyle style, ThemeProvider themeProvider) {
    switch (style) {
      case BoardStyle.classic:
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        );
      case BoardStyle.modern:
        return BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: themeProvider.primaryColor.withValues(alpha: 0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: themeProvider.primaryColor.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        );
      case BoardStyle.neon:
        return BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: themeProvider.primaryColor, width: 1),
          boxShadow: [
            BoxShadow(color: themeProvider.primaryColor.withValues(alpha: 0.3), blurRadius: 8, spreadRadius: 1),
          ],
        );
      case BoardStyle.minimal:
        return BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.3), width: 1),
        );
      case BoardStyle.retro:
        return BoxDecoration(
          color: const Color(0xFF2D1B69),
          border: Border.all(color: const Color(0xFF00FF00), width: 1),
          boxShadow: [BoxShadow(color: const Color(0xFF00FF00).withValues(alpha: 0.2), blurRadius: 6, spreadRadius: 1)],
        );
      case BoardStyle.glass:
        return BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 6, offset: const Offset(0, 2))],
        );
      case BoardStyle.wood:
        return BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF8D6E63), Color(0xFF6D4C41), Color(0xFF5D4037)],
          ),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFF3E2723), width: 1),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 6, offset: const Offset(0, 2))],
        );
      case BoardStyle.cyberpunk:
        return BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0A0A), Color(0xFF1A1A2E), Color(0xFF16213E)],
          ),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFF00FFFF), width: 1),
          boxShadow: [BoxShadow(color: const Color(0xFF00FFFF).withValues(alpha: 0.2), blurRadius: 8, spreadRadius: 1)],
        );
    }
  }

  BoxDecoration _getPreviewCellDecoration(BoardStyle style, String value, ThemeProvider themeProvider) {
    switch (style) {
      case BoardStyle.classic:
        return BoxDecoration(
          gradient:
              value.isEmpty
                  ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Theme.of(context).cardColor, Theme.of(context).cardColor.withValues(alpha: 0.8)],
                  )
                  : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getPreviewCellColor(value, style, themeProvider).withValues(alpha: 0.1),
                      _getPreviewCellColor(value, style, themeProvider).withValues(alpha: 0.05),
                    ],
                  ),
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1), width: 0.5),
        );
      case BoardStyle.modern:
        return BoxDecoration(
          color:
              value.isEmpty
                  ? Theme.of(context).cardColor
                  : _getPreviewCellColor(value, style, themeProvider).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: themeProvider.primaryColor.withValues(alpha: 0.3), width: 0.5),
        );
      case BoardStyle.neon:
        return BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(
            color:
                value.isEmpty
                    ? themeProvider.primaryColor.withValues(alpha: 0.3)
                    : _getPreviewCellColor(value, style, themeProvider),
            width: 0.5,
          ),
        );
      case BoardStyle.minimal:
        return BoxDecoration(
          color:
              value.isEmpty
                  ? Theme.of(context).cardColor
                  : _getPreviewCellColor(value, style, themeProvider).withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(2),
        );
      case BoardStyle.retro:
        return BoxDecoration(
          color: const Color(0xFF1A1A1A),
          border: Border.all(
            color: value.isEmpty ? const Color(0xFF00FF00) : _getPreviewCellColor(value, style, themeProvider),
            width: 0.5,
          ),
        );
      case BoardStyle.glass:
        return BoxDecoration(
          color: Theme.of(context).cardColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 0.5),
        );
      case BoardStyle.wood:
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                value.isEmpty
                    ? [const Color(0xFFA1887F), const Color(0xFF8D6E63)]
                    : [
                      _getPreviewCellColor(value, style, themeProvider).withValues(alpha: 0.3),
                      const Color(0xFF8D6E63),
                    ],
          ),
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: const Color(0xFF5D4037), width: 0.5),
        );
      case BoardStyle.cyberpunk:
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                value.isEmpty
                    ? [const Color(0xFF0F0F23), const Color(0xFF1A1A2E)]
                    : [
                      _getPreviewCellColor(value, style, themeProvider).withValues(alpha: 0.2),
                      const Color(0xFF0F0F23),
                    ],
          ),
          borderRadius: BorderRadius.circular(2),
          border: Border.all(
            color: value.isEmpty ? const Color(0xFF00FFFF) : _getPreviewCellColor(value, style, themeProvider),
            width: 0.5,
          ),
        );
    }
  }

  Color _getPreviewCellColor(String value, BoardStyle style, ThemeProvider themeProvider) {
    if (value == 'X') {
      return themeProvider.primaryColor;
    } else if (value == 'O') {
      return Theme.of(context).brightness == Brightness.dark ? Colors.red.shade300 : Colors.red.shade600;
    }
    return Colors.transparent;
  }

  double _getPreviewCellSpacing(BoardStyle style) {
    switch (style) {
      case BoardStyle.classic:
      case BoardStyle.modern:
        return 1.5;
      case BoardStyle.neon:
        return 1.0;
      case BoardStyle.minimal:
        return 2.0;
      case BoardStyle.retro:
        return 0.8;
      case BoardStyle.glass:
        return 1.8;
      case BoardStyle.wood:
        return 1.2;
      case BoardStyle.cyberpunk:
        return 1.0;
    }
  }

  Widget _buildCornerRadiusSlider(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Board Corner Radius',
          style: GoogleFonts.varelaRound(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              'Sharp',
              style: GoogleFonts.varelaRound(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            Expanded(
              child: Slider(
                value: themeProvider.boardCornerRadius,
                min: 0,
                max: 24,
                divisions: 12,
                onChanged: (value) => themeProvider.setBoardCornerRadius(value),
              ),
            ),
            Text(
              'Rounded',
              style: GoogleFonts.varelaRound(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        Text(
          '${themeProvider.boardCornerRadius.round()}px',
          style: GoogleFonts.varelaRound(
            fontSize: 12,
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildGameTimerSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSwitchTile(
          title: 'Game Timer',
          subtitle: 'Enable turn-based timer',
          value: _gameTimerEnabled,
          onChanged: (value) {
            setState(() => _gameTimerEnabled = value);
            LocalStorageService.saveGameTimerEnabled(value);
          },
        ),
        if (_gameTimerEnabled) ...[
          const SizedBox(height: 16),
          Text(
            'Timer Duration',
            style: GoogleFonts.varelaRound(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '15s',
                style: GoogleFonts.varelaRound(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              Expanded(
                child: Slider(
                  value: _gameTimerDuration.toDouble(),
                  min: 15,
                  max: 120,
                  divisions: 21,
                  onChanged: (value) {
                    setState(() => _gameTimerDuration = value.round());
                    LocalStorageService.saveGameTimerDuration(_gameTimerDuration);
                  },
                ),
              ),
              Text(
                '2m',
                style: GoogleFonts.varelaRound(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          Text(
            '${_gameTimerDuration}s per turn',
            style: GoogleFonts.varelaRound(
              fontSize: 12,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.varelaRound(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.varelaRound(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildResetButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _showResetStatsDialog,
            icon: const Icon(Icons.bar_chart_outlined),
            label: Text('Reset Statistics', style: GoogleFonts.varelaRound(fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.orange),
              foregroundColor: Colors.orange,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _showResetAllDialog,
            icon: const Icon(Icons.refresh),
            label: Text('Reset All Settings', style: GoogleFonts.varelaRound(fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.red),
              foregroundColor: Colors.red,
            ),
          ),
        ),
      ],
    );
  }

  void _showResetStatsDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Reset Statistics', style: GoogleFonts.varelaRound(fontWeight: FontWeight.w600)),
            content: Text(
              'This will permanently delete all your game statistics. This action cannot be undone.',
              style: GoogleFonts.varelaRound(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel', style: GoogleFonts.varelaRound()),
              ),
              ElevatedButton(
                onPressed: () async {
                  await LocalStorageService.clearStatistics();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Statistics reset successfully', style: GoogleFonts.varelaRound())),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: Text('Reset', style: GoogleFonts.varelaRound(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
    );
  }

  void _showResetAllDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Reset All Settings', style: GoogleFonts.varelaRound(fontWeight: FontWeight.w600)),
            content: Text(
              'This will reset all settings and data to their default values. This action cannot be undone.',
              style: GoogleFonts.varelaRound(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel', style: GoogleFonts.varelaRound()),
              ),
              ElevatedButton(
                onPressed: () async {
                  await LocalStorageService.clearAllData();
                  // The theme provider will be recreated when the app restarts
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Go back to previous screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'All settings reset successfully. Restart the app to see changes.',
                        style: GoogleFonts.varelaRound(),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Reset All', style: GoogleFonts.varelaRound(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
    );
  }

  Widget _buildSymbolSelector(ThemeProvider themeProvider) {
    final List<String> popularSymbols = [
      'X', 'O', // Default
      '❌', '⭕', // Classic emojis
      '🔥', '💧', // Fire & Water
      '⚡', '🌟', // Lightning & Star
      '🎯', '🎪', // Target & Circus
      '🦁', '🐸', // Lion & Frog
      '🍎', '🍊', // Apple & Orange
      '⚽', '🏀', // Football & Basketball
      '🎵', '🎸', // Music note & Guitar
      '🌙', '☀️', // Moon & Sun
      '💎', '🌺', // Diamond & Flower
      '🚀', '⭐', // Rocket & Star
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Player Symbols',
          style: GoogleFonts.varelaRound(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
        ),
        const SizedBox(height: 12),

        // Player X Symbol Section
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: themeProvider.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: themeProvider.primaryColor.withValues(alpha: 0.3)),
              ),
              child: Center(
                child: Text(
                  themeProvider.playerXSymbol,
                  style: GoogleFonts.varelaRound(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: themeProvider.primaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Player X Symbol',
                    style: GoogleFonts.varelaRound(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: popularSymbols.length,
                      itemBuilder: (context, index) {
                        final symbol = popularSymbols[index];
                        final isSelected = themeProvider.playerXSymbol == symbol;

                        return GestureDetector(
                          onTap: () => themeProvider.setPlayerXSymbol(symbol),
                          child: Container(
                            width: 35,
                            height: 35,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? themeProvider.primaryColor.withValues(alpha: 0.2)
                                      : Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? themeProvider.primaryColor
                                        : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                symbol,
                                style: GoogleFonts.varelaRound(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Player O Symbol Section
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (Theme.of(context).brightness == Brightness.dark ? Colors.red.shade300 : Colors.red.shade600)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: (Theme.of(context).brightness == Brightness.dark ? Colors.red.shade300 : Colors.red.shade600)
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Center(
                child: Text(
                  themeProvider.playerOSymbol,
                  style: GoogleFonts.varelaRound(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.red.shade300 : Colors.red.shade600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Player O Symbol',
                    style: GoogleFonts.varelaRound(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: popularSymbols.length,
                      itemBuilder: (context, index) {
                        final symbol = popularSymbols[index];
                        final isSelected = themeProvider.playerOSymbol == symbol;
                        final oColor =
                            Theme.of(context).brightness == Brightness.dark ? Colors.red.shade300 : Colors.red.shade600;

                        return GestureDetector(
                          onTap: () => themeProvider.setPlayerOSymbol(symbol),
                          child: Container(
                            width: 35,
                            height: 35,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? oColor.withValues(alpha: 0.2) : Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color:
                                    isSelected ? oColor : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                symbol,
                                style: GoogleFonts.varelaRound(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),
        Text(
          'Tap any symbol to select it for the respective player',
          style: GoogleFonts.varelaRound(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
