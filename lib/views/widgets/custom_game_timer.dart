import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/local_storage_service.dart';

class CustomGameTimer extends StatefulWidget {
  final Function() onTimeUp;
  final bool isActive;
  final Function() onReset;

  const CustomGameTimer({super.key, required this.onTimeUp, required this.isActive, required this.onReset});

  @override
  State<CustomGameTimer> createState() => _CustomGameTimerState();
}

class _CustomGameTimerState extends State<CustomGameTimer> with TickerProviderStateMixin {
  Timer? _timer;
  int _seconds = 30;
  int _maxSeconds = 30;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _loadTimerSettings();

    _pulseController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  void _loadTimerSettings() {
    final enabled = LocalStorageService.getGameTimerEnabled();
    final duration = LocalStorageService.getGameTimerDuration();

    setState(() {
      _maxSeconds = duration;
      _seconds = duration;
    });

    if (!enabled) {
      // Timer is disabled, don't show anything
      return;
    }

    if (widget.isActive) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _pulseController.stop();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_seconds > 0) {
            _seconds--;

            // Start warning animations when 5 seconds or less
            if (_seconds <= 5) {
              _pulseController.repeat(reverse: true);
            }
          } else {
            timer.cancel();
            widget.onTimeUp();
          }
        });
      }
    });
  }

  void resetTimer() {
    _timer?.cancel();
    _pulseController.stop();

    setState(() {
      _seconds = _maxSeconds;
    });

    if (widget.isActive) {
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(CustomGameTimer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive && !oldWidget.isActive) {
      _startTimer();
    } else if (!widget.isActive && oldWidget.isActive) {
      _timer?.cancel();
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Don't show timer if disabled
    if (!LocalStorageService.getGameTimerEnabled()) {
      return const SizedBox.shrink();
    }

    final progress = _seconds / _maxSeconds;
    final isWarning = _seconds <= 10;
    final isCritical = _seconds <= 5;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: isCritical ? _pulseAnimation.value : 1.0,
          child: SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circle
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.surface,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2)),
                    ],
                  ),
                ),

                // Progress indicator
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 4,
                    backgroundColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCritical
                          ? Colors.red
                          : isWarning
                          ? Colors.orange
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),

                // Timer text
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$_seconds',
                      style: GoogleFonts.varelaRound(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color:
                            isCritical
                                ? Colors.red
                                : isWarning
                                ? Colors.orange
                                : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      's',
                      style: GoogleFonts.varelaRound(
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
