import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

    return Container(
      width: boardSize,
      height: boardSize,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // Enhanced gradient background for the game board
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Theme.of(context).colorScheme.surface, Theme.of(context).colorScheme.surface.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(24),
        // Enhanced shadow for depth
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 8), spreadRadius: 2),
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.05),
            blurRadius: 40,
            offset: const Offset(0, 16),
            spreadRadius: 4,
          ),
        ],
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 9,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          return GameCell(
            value: board[index],
            index: index,
            isWinning: winningIndices.contains(index),
            onTap: () => isGameActive ? onTap(index) : null,
          );
        },
      ),
    );
  }
}

class GameCell extends StatefulWidget {
  final String value;
  final int index;
  final bool isWinning;
  final VoidCallback? onTap;

  const GameCell({super.key, required this.value, required this.index, required this.isWinning, this.onTap});

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
  }

  @override
  void didUpdateWidget(GameCell oldWidget) {
    super.didUpdateWidget(oldWidget);

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

  @override
  void dispose() {
    _animationController.dispose();
    _tapController.dispose();
    _appearController.dispose();
    super.dispose();
  }

  Color _getCellColor(String value, BuildContext context) {
    if (value == 'X') {
      return Theme.of(context).brightness == Brightness.dark ? Colors.blue.shade300 : Colors.blue.shade600;
    } else if (value == 'O') {
      return Theme.of(context).brightness == Brightness.dark ? Colors.red.shade300 : Colors.red.shade600;
    }
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) {
        if (widget.value.isEmpty && widget.onTap != null) {
          _tapController.forward().then((_) {
            _tapController.reverse();
          });
        }
      },
      child: AnimatedBuilder(
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
              decoration: BoxDecoration(
                // Enhanced gradient background for cells
                gradient:
                    widget.value.isEmpty
                        ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Theme.of(context).cardColor, Theme.of(context).cardColor.withOpacity(0.8)],
                        )
                        : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _getCellColor(widget.value, context).withOpacity(0.1),
                            _getCellColor(widget.value, context).withOpacity(0.05),
                          ],
                        ),
                borderRadius: BorderRadius.circular(16),
                // Enhanced border for winning cells
                border:
                    widget.isWinning
                        ? Border.all(color: Colors.amber, width: 3)
                        : Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1), width: 1),
                // Enhanced shadow effects
                boxShadow: [
                  if (widget.isWinning) ...[
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.4 * _glowAnimation.value),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.2 * _glowAnimation.value),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ] else ...[
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
                    if (widget.value.isNotEmpty)
                      BoxShadow(
                        color: _getCellColor(widget.value, context).withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                        spreadRadius: 2,
                      ),
                  ],
                ],
              ),
              child: Center(
                child:
                    widget.value.isNotEmpty
                        ? Transform.scale(
                          scale: _appearAnimation.value,
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            style: GoogleFonts.varelaRound(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: _getCellColor(widget.value, context),
                            ),
                            child: Text(
                              widget.value,
                              style: TextStyle(
                                shadows: [
                                  Shadow(
                                    color: _getCellColor(widget.value, context).withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(2, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        : Icon(Icons.add, size: 24, color: Theme.of(context).hintColor.withOpacity(0.3)),
              ),
            ),
          );
        },
      ),
    );
  }
}
