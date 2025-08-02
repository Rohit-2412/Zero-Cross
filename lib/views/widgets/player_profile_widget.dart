import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/local_storage_service.dart';

class PlayerProfileWidget extends StatefulWidget {
  final Function(String) onNameChanged;

  const PlayerProfileWidget({super.key, required this.onNameChanged});

  @override
  State<PlayerProfileWidget> createState() => _PlayerProfileWidgetState();
}

class _PlayerProfileWidgetState extends State<PlayerProfileWidget> {
  String _playerName = '';
  final List<IconData> _avatarIcons = [
    Icons.person,
    Icons.face,
    Icons.sports_esports,
    Icons.emoji_emotions,
    Icons.star,
    Icons.favorite,
    Icons.flash_on,
    Icons.pets,
    Icons.music_note,
    Icons.cake,
  ];

  int _selectedAvatarIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadPlayerProfile();
  }

  void _loadPlayerProfile() {
    setState(() {
      _playerName = LocalStorageService.getPlayerName();
      // Load avatar selection from preferences if implemented
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Player Profile',
              style: GoogleFonts.varelaRound(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),

            // Avatar Selection
            Text(
              'Choose Avatar',
              style: GoogleFonts.varelaRound(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _avatarIcons.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedAvatarIndex == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedAvatarIndex = index;
                      });
                    },
                    child: Container(
                      width: 60,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        _avatarIcons[index],
                        color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                        size: 24,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Player Name Input
            Text(
              'Player Name',
              style: GoogleFonts.varelaRound(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: TextEditingController(text: _playerName),
              decoration: InputDecoration(
                hintText: 'Enter your name',
                hintStyle: GoogleFonts.varelaRound(),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: Icon(_avatarIcons[_selectedAvatarIndex]),
              ),
              style: GoogleFonts.varelaRound(),
              onChanged: (value) {
                setState(() {
                  _playerName = value;
                });
                LocalStorageService.savePlayerName(value);
                widget.onNameChanged(value);
              },
            ),

            const SizedBox(height: 16),

            // Player Stats Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    'Games',
                    '${LocalStorageService.getGameStatistics().getTotalGames()}',
                    Icons.sports_esports,
                  ),
                  _buildStatItem(
                    'Wins',
                    '${LocalStorageService.getGameStatistics().getTotalPlayerWins()}',
                    Icons.emoji_events,
                  ),
                  _buildStatItem(
                    'Win %',
                    '${LocalStorageService.getGameStatistics().getOverallWinRate().toStringAsFixed(1)}%',
                    Icons.trending_up,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.varelaRound(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.varelaRound(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
