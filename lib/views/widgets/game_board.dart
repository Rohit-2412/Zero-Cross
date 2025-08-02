import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class GameBoard extends StatelessWidget {
  final List<String> board;
  final List<int> winningIndices;
  final Function(int) onTap;
  final bool isGameActive;

  const GameBoard({
    super.key,
    required this.board,
    required this.winningIndices,
    required this.onTap,
    required this.isGameActive,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final boardSize = screenSize.width < screenSize.height ? screenSize.width * 0.9 : screenSize.height * 0.6;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      width: boardSize,
      height: boardSize,
      padding: const EdgeInsets.all(12),
      decoration: _getBoardDecoration(context, themeProvider),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 9,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: _getCellSpacing(themeProvider.boardStyle),
          mainAxisSpacing: _getCellSpacing(themeProvider.boardStyle),
        ),
        itemBuilder: (context, index) {
          return GameCell(
            value: board[index],
            index: index,
            isWinning: winningIndices.contains(index),
            onTap: () => isGameActive ? onTap(index) : null,
            boardStyle: themeProvider.boardStyle,
            cornerRadius: themeProvider.boardCornerRadius,
            animationsEnabled: themeProvider.animationsEnabled,
            primaryColor: themeProvider.primaryColor,
            playerXSymbol: themeProvider.playerXSymbol,
            playerOSymbol: themeProvider.playerOSymbol,
          );
        },
      ),
    );
  }

  BoxDecoration _getBoardDecoration(BuildContext context, ThemeProvider themeProvider) {
    switch (themeProvider.boardStyle) {
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
          borderRadius: BorderRadius.circular(themeProvider.boardCornerRadius * 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 2,
            ),
          ],
        );
      case BoardStyle.modern:
        return BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(themeProvider.boardCornerRadius * 2),
          border: Border.all(color: themeProvider.primaryColor.withValues(alpha: 0.2), width: 2),
          boxShadow: [
            BoxShadow(
              color: themeProvider.primaryColor.withValues(alpha: 0.1),
              blurRadius: 30,
              offset: const Offset(0, 10),
              spreadRadius: 5,
            ),
          ],
        );
      case BoardStyle.neon:
        return BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(themeProvider.boardCornerRadius * 2),
          border: Border.all(color: themeProvider.primaryColor, width: 2),
          boxShadow: [
            BoxShadow(color: themeProvider.primaryColor.withValues(alpha: 0.5), blurRadius: 20, spreadRadius: 2),
            BoxShadow(color: themeProvider.primaryColor.withValues(alpha: 0.3), blurRadius: 40, spreadRadius: 5),
          ],
        );
      case BoardStyle.minimal:
        return BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(themeProvider.boardCornerRadius),
          border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.3), width: 1),
        );
      case BoardStyle.retro:
        return BoxDecoration(
          color: const Color(0xFF2D1B69),
          border: Border.all(color: const Color(0xFF00FF00), width: 3),
          boxShadow: [
            BoxShadow(color: const Color(0xFF00FF00).withValues(alpha: 0.3), blurRadius: 15, spreadRadius: 2),
          ],
        );
      case BoardStyle.glass:
        return BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(themeProvider.boardCornerRadius * 2),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -5,
            ),
          ],
        );
      case BoardStyle.wood:
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [const Color(0xFF8D6E63), const Color(0xFF6D4C41), const Color(0xFF5D4037)],
          ),
          borderRadius: BorderRadius.circular(themeProvider.boardCornerRadius),
          border: Border.all(color: const Color(0xFF3E2723), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
              spreadRadius: 2,
            ),
          ],
        );
      case BoardStyle.cyberpunk:
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [const Color(0xFF0A0A0A), const Color(0xFF1A1A2E), const Color(0xFF16213E)],
          ),
          borderRadius: BorderRadius.circular(themeProvider.boardCornerRadius),
          border: Border.all(color: const Color(0xFF00FFFF), width: 2),
          boxShadow: [
            BoxShadow(color: const Color(0xFF00FFFF).withValues(alpha: 0.4), blurRadius: 25, spreadRadius: 3),
            BoxShadow(color: const Color(0xFFFF0080).withValues(alpha: 0.2), blurRadius: 40, spreadRadius: 5),
          ],
        );
    }
  }

  double _getCellSpacing(BoardStyle style) {
    switch (style) {
      case BoardStyle.classic:
      case BoardStyle.modern:
        return 12.0;
      case BoardStyle.neon:
        return 8.0;
      case BoardStyle.minimal:
        return 16.0;
      case BoardStyle.retro:
        return 6.0;
      case BoardStyle.glass:
        return 14.0;
      case BoardStyle.wood:
        return 10.0;
      case BoardStyle.cyberpunk:
        return 8.0;
    }
  }
}

class GameCell extends StatefulWidget {
  final String value;
  final int index;
  final bool isWinning;
  final VoidCallback? onTap;
  final BoardStyle boardStyle;
  final double cornerRadius;
  final bool animationsEnabled;
  final Color primaryColor;
  final String playerXSymbol;
  final String playerOSymbol;

  const GameCell({
    super.key,
    required this.value,
    required this.index,
    required this.isWinning,
    this.onTap,
    required this.boardStyle,
    required this.cornerRadius,
    required this.animationsEnabled,
    required this.primaryColor,
    required this.playerXSymbol,
    required this.playerOSymbol,
  });

  @override
  State<GameCell> createState() => _GameCellState();
}

class _GameCellState extends State<GameCell> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _tapController;
  late AnimationController _appearController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _tapAnimation;
  late Animation<double> _appearAnimation;

  @override
  void initState() {
    super.initState();

    if (widget.animationsEnabled) {
      // Main animation controller for winning cells
      _animationController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);

      // Tap animation controller
      _tapController = AnimationController(duration: const Duration(milliseconds: 150), vsync: this);

      // Appear animation controller for when a symbol is placed
      _appearController = AnimationController(duration: const Duration(milliseconds: 400), vsync: this);

      _scaleAnimation = Tween<double>(
        begin: 1.0,
        end: 1.1,
      ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

      _glowAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

      _tapAnimation = Tween<double>(
        begin: 1.0,
        end: 0.95,
      ).animate(CurvedAnimation(parent: _tapController, curve: Curves.easeInOut));

      _appearAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: _appearController, curve: Curves.elasticOut));

      // Start appear animation if cell has value
      if (widget.value.isNotEmpty) {
        _appearController.forward();
      }
    } else {
      // Create dummy controllers when animations are disabled
      _animationController = AnimationController(duration: Duration.zero, vsync: this);
      _tapController = AnimationController(duration: Duration.zero, vsync: this);
      _appearController = AnimationController(duration: Duration.zero, vsync: this);

      _scaleAnimation = AlwaysStoppedAnimation(1.0);
      _glowAnimation = AlwaysStoppedAnimation(1.0);
      _tapAnimation = AlwaysStoppedAnimation(1.0);
      _appearAnimation = AlwaysStoppedAnimation(1.0);
    }
  }

  @override
  void didUpdateWidget(GameCell oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.animationsEnabled) {
      // Handle winning animation
      if (widget.isWinning && !oldWidget.isWinning) {
        _animationController.repeat(reverse: true);
      } else if (!widget.isWinning && oldWidget.isWinning) {
        _animationController.stop();
        _animationController.reset();
      }

      // Handle symbol appear animation
      if (widget.value.isNotEmpty && oldWidget.value.isEmpty) {
        _appearController.reset();
        _appearController.forward();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tapController.dispose();
    _appearController.dispose();
    super.dispose();
  }

  Color _getCellColor(String value, BuildContext context) {
    if (value == 'X') {
      return widget.primaryColor;
    } else if (value == 'O') {
      return Theme.of(context).brightness == Brightness.dark ? Colors.red.shade300 : Colors.red.shade600;
    }
    return Colors.transparent;
  }

  String _getDisplaySymbol(String value) {
    if (value == 'X') {
      return widget.playerXSymbol;
    } else if (value == 'O') {
      return widget.playerOSymbol;
    }
    return value;
  }

  BoxDecoration _getCellDecoration(BuildContext context) {
    switch (widget.boardStyle) {
      case BoardStyle.classic:
        return BoxDecoration(
          gradient:
              widget.value.isEmpty
                  ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Theme.of(context).cardColor, Theme.of(context).cardColor.withValues(alpha: 0.8)],
                  )
                  : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getCellColor(widget.value, context).withValues(alpha: 0.1),
                      _getCellColor(widget.value, context).withValues(alpha: 0.05),
                    ],
                  ),
          borderRadius: BorderRadius.circular(widget.cornerRadius),
          border:
              widget.isWinning
                  ? Border.all(color: Colors.amber, width: 3)
                  : Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1), width: 1),
          boxShadow:
              widget.isWinning
                  ? [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.4 * _glowAnimation.value),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ]
                  : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
        );
      case BoardStyle.modern:
        return BoxDecoration(
          color:
              widget.value.isEmpty
                  ? Theme.of(context).cardColor
                  : _getCellColor(widget.value, context).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(widget.cornerRadius),
          border:
              widget.isWinning
                  ? Border.all(color: Colors.amber, width: 2)
                  : Border.all(color: widget.primaryColor.withValues(alpha: 0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color:
                  widget.isWinning ? Colors.amber.withValues(alpha: 0.3) : widget.primaryColor.withValues(alpha: 0.1),
              blurRadius: widget.isWinning ? 15 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        );
      case BoardStyle.neon:
        return BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(widget.cornerRadius),
          border: Border.all(
            color:
                widget.isWinning
                    ? Colors.amber
                    : (widget.value.isEmpty
                        ? widget.primaryColor.withValues(alpha: 0.3)
                        : _getCellColor(widget.value, context)),
            width: 2,
          ),
          boxShadow: [
            if (widget.isWinning)
              BoxShadow(
                color: Colors.amber.withValues(alpha: 0.6 * _glowAnimation.value),
                blurRadius: 20,
                spreadRadius: 3,
              )
            else if (widget.value.isNotEmpty)
              BoxShadow(
                color: _getCellColor(widget.value, context).withValues(alpha: 0.4),
                blurRadius: 15,
                spreadRadius: 2,
              ),
          ],
        );
      case BoardStyle.minimal:
        return BoxDecoration(
          color:
              widget.value.isEmpty
                  ? Theme.of(context).cardColor
                  : _getCellColor(widget.value, context).withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(widget.cornerRadius / 2),
          border: widget.isWinning ? Border.all(color: Colors.amber, width: 2) : null,
        );
      case BoardStyle.retro:
        return BoxDecoration(
          color: const Color(0xFF1A1A1A),
          border: Border.all(
            color:
                widget.isWinning
                    ? Colors.amber
                    : (widget.value.isEmpty ? const Color(0xFF00FF00) : _getCellColor(widget.value, context)),
            width: 2,
          ),
          boxShadow: [
            if (widget.isWinning)
              BoxShadow(color: Colors.amber.withValues(alpha: 0.6), blurRadius: 15, spreadRadius: 2)
            else if (widget.value.isNotEmpty)
              BoxShadow(
                color: _getCellColor(widget.value, context).withValues(alpha: 0.5),
                blurRadius: 10,
                spreadRadius: 1,
              ),
          ],
        );
      case BoardStyle.glass:
        return BoxDecoration(
          color: Theme.of(context).cardColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(widget.cornerRadius),
          border: Border.all(color: widget.isWinning ? Colors.amber : Colors.white.withValues(alpha: 0.3), width: 1),
          boxShadow: [
            if (widget.isWinning)
              BoxShadow(color: Colors.amber.withValues(alpha: 0.4), blurRadius: 15, spreadRadius: 2)
            else
              BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        );
      case BoardStyle.wood:
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                widget.value.isEmpty
                    ? [const Color(0xFFA1887F), const Color(0xFF8D6E63)]
                    : [_getCellColor(widget.value, context).withValues(alpha: 0.3), const Color(0xFF8D6E63)],
          ),
          borderRadius: BorderRadius.circular(widget.cornerRadius / 2),
          border: Border.all(
            color: widget.isWinning ? Colors.amber : const Color(0xFF5D4037),
            width: widget.isWinning ? 3 : 1,
          ),
          boxShadow: [
            if (widget.isWinning)
              BoxShadow(color: Colors.amber.withValues(alpha: 0.5), blurRadius: 15, spreadRadius: 2)
            else
              BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 3)),
          ],
        );
      case BoardStyle.cyberpunk:
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                widget.value.isEmpty
                    ? [const Color(0xFF0F0F23), const Color(0xFF1A1A2E)]
                    : [_getCellColor(widget.value, context).withValues(alpha: 0.2), const Color(0xFF0F0F23)],
          ),
          borderRadius: BorderRadius.circular(widget.cornerRadius / 3),
          border: Border.all(
            color:
                widget.isWinning
                    ? Colors.amber
                    : (widget.value.isEmpty ? const Color(0xFF00FFFF) : _getCellColor(widget.value, context)),
            width: 1,
          ),
          boxShadow: [
            if (widget.isWinning)
              BoxShadow(color: Colors.amber.withValues(alpha: 0.6), blurRadius: 20, spreadRadius: 3)
            else if (widget.value.isNotEmpty)
              BoxShadow(
                color: _getCellColor(widget.value, context).withValues(alpha: 0.4),
                blurRadius: 15,
                spreadRadius: 2,
              )
            else
              BoxShadow(color: const Color(0xFF00FFFF).withValues(alpha: 0.2), blurRadius: 10, spreadRadius: 1),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) {
        if (widget.animationsEnabled && widget.value.isEmpty && widget.onTap != null) {
          _tapController.forward().then((_) {
            _tapController.reverse();
          });
        }
      },
      child:
          widget.animationsEnabled
              ? AnimatedBuilder(
                animation: Listenable.merge([_animationController, _tapController, _appearController]),
                builder: (context, child) {
                  // Combine scale effects from tap and winning animations
                  double finalScale = widget.value.isEmpty ? _tapAnimation.value : 1.0;
                  if (widget.isWinning) {
                    finalScale *= _scaleAnimation.value;
                  }

                  return Transform.scale(
                    scale: finalScale,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: _getCellDecoration(context),
                      child: Center(
                        child:
                            widget.value.isNotEmpty
                                ? Transform.scale(scale: _appearAnimation.value, child: _buildSymbol(context))
                                : _buildEmptyCell(context),
                      ),
                    ),
                  );
                },
              )
              : Container(
                decoration: _getCellDecoration(context),
                child: Center(child: widget.value.isNotEmpty ? _buildSymbol(context) : _buildEmptyCell(context)),
              ),
    );
  }

  Widget _buildSymbol(BuildContext context) {
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 300),
      style: GoogleFonts.varelaRound(
        fontSize: _getSymbolSize(),
        fontWeight: FontWeight.w900,
        color: _getCellColor(widget.value, context),
      ),
      child: Text(
        _getDisplaySymbol(widget.value),
        style: TextStyle(
          shadows:
              widget.boardStyle == BoardStyle.neon
                  ? [
                    Shadow(
                      color: _getCellColor(widget.value, context).withValues(alpha: 0.8),
                      blurRadius: 10,
                      offset: const Offset(0, 0),
                    ),
                    Shadow(
                      color: _getCellColor(widget.value, context).withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 0),
                    ),
                  ]
                  : [
                    Shadow(
                      color: _getCellColor(widget.value, context).withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(2, 2),
                    ),
                  ],
        ),
      ),
    );
  }

  Widget _buildEmptyCell(BuildContext context) {
    if (widget.boardStyle == BoardStyle.minimal) {
      return const SizedBox.shrink();
    }

    return Icon(Icons.add, size: 24, color: Theme.of(context).hintColor.withValues(alpha: 0.3));
  }

  double _getSymbolSize() {
    switch (widget.boardStyle) {
      case BoardStyle.classic:
      case BoardStyle.modern:
        return 48;
      case BoardStyle.neon:
        return 42;
      case BoardStyle.minimal:
        return 40;
      case BoardStyle.retro:
        return 46;
      case BoardStyle.glass:
        return 44;
      case BoardStyle.wood:
        return 45;
      case BoardStyle.cyberpunk:
        return 43;
    }
  }
}
