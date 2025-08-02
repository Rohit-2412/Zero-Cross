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

    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 6,
            backgroundColor: Theme.of(context).colorScheme.surface,
            valueColor: AlwaysStoppedAnimation<Color>(isUrgent ? Colors.red : Theme.of(context).primaryColor),
          ),
          Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: GoogleFonts.inter(
                fontSize: isUrgent ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: isUrgent ? Colors.red : Theme.of(context).colorScheme.onSurface,
              ),
              child: Text(seconds.toString()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return ElevatedButton(
      onPressed: onStart,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        elevation: 4,
      ),
      child: Text(buttonText, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
    );
  }
}
