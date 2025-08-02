import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GameTimer extends StatelessWidget {
  final int seconds;
  final int maxSeconds;
  final bool isRunning;
  final VoidCallback onStart;
  final String buttonText;

  const GameTimer({
    super.key,
    required this.seconds,
    required this.maxSeconds,
    required this.isRunning,
    required this.onStart,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return isRunning ? _buildTimer(context) : _buildStartButton(context);
  }

  Widget _buildTimer(BuildContext context) {
    final progress = 1 - (seconds / maxSeconds);
    final isUrgent = seconds <= 10;

    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        // Enhanced background with gradient
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Theme.of(context).colorScheme.surface, Theme.of(context).colorScheme.surface.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(45),
        // Enhanced shadow
        boxShadow: [
          BoxShadow(
            color: isUrgent ? Colors.red.withValues(alpha: 0.3) : Theme.of(context).primaryColor.withValues(alpha: 0.2),
            blurRadius: isUrgent ? 20 : 15,
            offset: const Offset(0, 5),
            spreadRadius: isUrgent ? 3 : 2,
          ),
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Enhanced circular progress indicator
          Padding(
            padding: const EdgeInsets.all(8),
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 8,
              strokeCap: StrokeCap.round,
              backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(isUrgent ? Colors.red : Theme.of(context).primaryColor),
            ),
          ),
          // Enhanced timer text
          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              transform: Matrix4.identity()..scale(isUrgent ? 1.1 : 1.0),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: GoogleFonts.varelaRound(
                  fontSize: isUrgent ? 26 : 22,
                  fontWeight: FontWeight.w900,
                  color: isUrgent ? Colors.red : Theme.of(context).colorScheme.onSurface,
                  shadows: [
                    Shadow(
                      color: (isUrgent ? Colors.red : Theme.of(context).primaryColor).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(seconds.toString()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // Enhanced gradient background
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(30),
        // Enhanced shadow
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: 3,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: onStart,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            child: Text(
              buttonText,
              style: GoogleFonts.varelaRound(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
