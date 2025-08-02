import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GameOverDialog extends StatelessWidget {
  final String result;
  final String winnerName;
  final VoidCallback onRestart;
  final VoidCallback onHome;

  const GameOverDialog({
    super.key,
    required this.result,
    required this.winnerName,
    required this.onRestart,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 400;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Trophy or result icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(color: _getResultColor(result).withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(_getResultIcon(result), size: 40, color: _getResultColor(result)),
            ),

            const SizedBox(height: 16),

            // Result text
            Text(
              _getResultTitle(result, winnerName),
              style: GoogleFonts.varelaRound(
                fontSize: isSmallScreen ? 24 : 28,
                fontWeight: FontWeight.bold,
                color: _getResultColor(result),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Text(
              _getResultSubtitle(result),
              style: GoogleFonts.inter(
                fontSize: isSmallScreen ? 14 : 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onHome,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text("Home", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton(
                    onPressed: onRestart,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text("Play Again", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getResultColor(String result) {
    if (result.contains("Win")) {
      return Colors.green;
    } else if (result.contains("Draw") || result.contains("Tie")) {
      return Colors.orange;
    }
    return Colors.blue;
  }

  IconData _getResultIcon(String result) {
    if (result.contains("Win")) {
      return Icons.emoji_events;
    } else if (result.contains("Draw") || result.contains("Tie")) {
      return Icons.handshake;
    }
    return Icons.sports_esports;
  }

  String _getResultTitle(String result, String winnerName) {
    if (result.contains("Win")) {
      return "$winnerName Wins!";
    } else if (result.contains("Draw") || result.contains("Tie")) {
      return "It's a Draw!";
    }
    return "Game Over";
  }

  String _getResultSubtitle(String result) {
    if (result.contains("Win")) {
      return "Congratulations on your victory!";
    } else if (result.contains("Draw") || result.contains("Tie")) {
      return "Great game, well played!";
    }
    return "Thanks for playing!";
  }
}

class PlayerNameDialog extends StatefulWidget {
  final String title;
  final String initialName;
  final Function(String) onNameSubmitted;

  const PlayerNameDialog({super.key, required this.title, required this.initialName, required this.onNameSubmitted});

  @override
  State<PlayerNameDialog> createState() => _PlayerNameDialogState();
}

class _PlayerNameDialogState extends State<PlayerNameDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: GoogleFonts.varelaRound(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Enter name...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              textAlign: TextAlign.center,
              maxLength: 15,
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Cancel"),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final name = _controller.text.trim();
                      if (name.isNotEmpty) {
                        widget.onNameSubmitted(name);
                        Navigator.of(context).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("OK"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
