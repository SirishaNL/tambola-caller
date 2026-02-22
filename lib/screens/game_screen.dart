import 'dart:async';
import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../services/game_service.dart';
import '../services/tts_service.dart';
import '../widgets/number_grid.dart';
import '../widgets/cast_dialog.dart';
import '../theme/app_theme.dart';

class GameScreen extends StatefulWidget {
  final bool resumed;
  final bool isManual;
  final int intervalSeconds;
  final VoidCallback onExit;
  final bool darkMode;
  final bool soundOn;
  final VoidCallback onToggleDark;
  final VoidCallback onToggleSound;
  final String themeId;
  final void Function(String) onThemeChanged;

  const GameScreen({
    super.key,
    required this.resumed,
    required this.isManual,
    required this.intervalSeconds,
    required this.onExit,
    required this.darkMode,
    required this.soundOn,
    required this.onToggleDark,
    required this.onToggleSound,
    required this.themeId,
    required this.onThemeChanged,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  final GameService _game = GameService();
  final TtsService _tts = TtsService();
  GameState? _state;
  Timer? _autoTimer;
  Timer? _resumeAfterDelayTimer;
  int _countdown = 0;
  late AnimationController _pulseController;

  static const _resumeDelay = Duration(seconds: 3);

  /// Pause auto-calling temporarily (so user can change theme/cast/dark/sound without missing numbers).
  void _pauseTemporarily() {
    if (_state == null || _state!.isManual || _state!.isPaused || _state!.isGameOver) return;
    _resumeAfterDelayTimer?.cancel();
    _resumeAfterDelayTimer = null;
    _autoTimer?.cancel();
    _game.setPaused(true);
    setState(() => _state = _game.state);
  }

  /// Schedule auto-calling to resume after a short delay (e.g. after dialog closes).
  void _scheduleResumeAfterDelay() {
    _resumeAfterDelayTimer?.cancel();
    if (_state == null || _state!.isManual || _state!.isGameOver) return;
    if (mounted && !_state!.isManual) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Auto-calling will resume in 3 seconds'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    _resumeAfterDelayTimer = Timer(_resumeDelay, () {
      if (!mounted) return;
      _resumeAfterDelayTimer = null;
      if (_state == null || _state!.isManual || !_state!.isPaused || _state!.isGameOver) return;
      _game.setPaused(false);
      setState(() => _state = _game.state);
      _startAutoTimer();
    });
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    if (widget.resumed) {
      _state = _game.state;
      if (_state != null && !_state!.isManual && !_state!.isPaused) {
        _startAutoTimer();
      }
    } else {
      _state = _game.newGame(
        isManual: widget.isManual,
        intervalSeconds: widget.intervalSeconds,
      );
      if (!_state!.isManual) _startAutoTimer();
    }
  }

  void _startAutoTimer() {
    _autoTimer?.cancel();
    _countdown = _state!.intervalSeconds;
    _runCountdownThenCall();
  }

  void _runCountdownThenCall() {
    if (_state == null || _state!.isGameOver || _state!.isPaused) return;
    _autoTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _countdown--;
        if (_countdown <= 0) {
          _autoTimer?.cancel();
          _callNext();
          if (_state != null && !_state!.isGameOver && !_state!.isPaused) {
            _countdown = _state!.intervalSeconds;
            _runCountdownThenCall();
          }
        }
      });
    });
  }

  void _callNext() {
    final next = _game.callNext();
    if (next != null) {
      _tts.speak(next);
      setState(() => _state = _game.state);
    }
  }

  void _pauseResume() {
    if (_state == null || _state!.isManual) return;
    _autoTimer?.cancel();
    final newPaused = !_state!.isPaused;
    _game.setPaused(newPaused);
    setState(() => _state = _game.state);
    if (!newPaused) {
      _countdown = _state!.intervalSeconds;
      _runCountdownThenCall();
    }
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _resumeAfterDelayTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _switchToManual() {
    _autoTimer?.cancel();
    _game.setMode(true);
    setState(() => _state = _game.state);
  }

  void _switchToAuto([int? intervalSeconds]) {
    final sec = intervalSeconds ?? _state!.intervalSeconds;
    _game.setMode(false, sec);
    setState(() => _state = _game.state);
    _startAutoTimer();
  }

  void _changeInterval(int sec) {
    _game.setInterval(sec);
    setState(() => _state = _game.state);
    if (!_state!.isManual) _startAutoTimer();
  }

  Future<bool> _onWillPop() async {
    final theme = Theme.of(context);
    final quit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Icon(Icons.exit_to_app, color: theme.colorScheme.primary, size: 40),
        title: const Text('Exit game?'),
        content: const Text(
          'Your progress is saved. You can resume later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(ctx).pop(true),
            icon: const Icon(Icons.check, size: 20),
            label: const Text('Exit'),
          ),
        ],
      ),
    );
    if (quit == true) {
      widget.onExit();
      return false;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (_state == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final theme = Theme.of(context);
    final calledSet = _state!.calledNumbers.toSet();

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) return;
        await _onWillPop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Tambola Caller', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () async => await _onWillPop(),
            tooltip: 'Back',
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.history_rounded, color: theme.colorScheme.primary),
              onPressed: _showNumberHistoryModal,
              tooltip: 'Number History',
            ),
            IconButton(
              icon: Icon(Icons.palette_outlined, color: theme.colorScheme.primary),
              onPressed: () {
                _pauseTemporarily();
                showThemePickerDialog(
                  context,
                  currentThemeId: widget.themeId,
                  isDark: widget.darkMode,
                  onThemeSelected: widget.onThemeChanged,
                ).then((_) => _scheduleResumeAfterDelay());
              },
              tooltip: 'Theme',
            ),
            IconButton(
              icon: Icon(Icons.cast_connected, color: theme.colorScheme.primary),
              onPressed: () {
                _pauseTemporarily();
                showCastDialog(context).then((_) => _scheduleResumeAfterDelay());
              },
              tooltip: 'Cast to TV',
            ),
            IconButton(
              icon: Icon(widget.darkMode ? Icons.dark_mode : Icons.light_mode),
              onPressed: () {
                _pauseTemporarily();
                widget.onToggleDark();
                _scheduleResumeAfterDelay();
              },
              tooltip: 'Dark / Light mode',
            ),
            IconButton(
              icon: Icon(widget.soundOn ? Icons.volume_up : Icons.volume_off),
              onPressed: () {
                _pauseTemporarily();
                widget.onToggleSound();
                _scheduleResumeAfterDelay();
              },
              tooltip: 'Sound on / off',
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'speed') _showSpeedDialog();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'speed', child: Text('Voice speed')),
              ],
            ),
          ],
        ),
        body: SafeArea(
          child: _state!.isGameOver
              ? _buildGameOver(theme)
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [_buildModeAndSpeedRow(theme)],
                      ),
                      const SizedBox(height: 10),
                      // Current number - compact
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.primary.withOpacity(0.85),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          _state!.currentNumber != null ? '${_state!.currentNumber}' : '—',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 40,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Last 5: ', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(width: 6),
                          ..._state!.lastFive.map((n) => Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: theme.colorScheme.primary.withOpacity(0.5)),
                                  ),
                                  child: Text('$n', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                                ),
                              )),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_state!.isManual)
                        _buildCallNextButton(theme)
                      else
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _pauseResume,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: theme.colorScheme.primary, width: 2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(_state!.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded, size: 22, color: theme.colorScheme.primary),
                                  const SizedBox(width: 8),
                                  Text(_state!.isPaused ? 'Resume' : 'Pause', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 14),
                      Text('1 – 90', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                      const SizedBox(height: 6),
                      NumberGrid(
                        calledNumbers: calledSet,
                        isDark: theme.brightness == Brightness.dark,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  void _showNumberHistoryModal() {
    _pauseTemporarily();
    final theme = Theme.of(context);
    // Show most recent first (reversed order)
    final list = _state!.calledNumbers.reversed.toList();
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360, maxHeight: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
                child: Row(
                  children: [
                    Icon(Icons.history_rounded, color: theme.colorScheme.primary, size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Number History', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                          Text('Most recent first', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: list.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text('No numbers called yet', style: theme.textTheme.bodyMedium),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: list.length,
                        itemBuilder: (context, i) {
                          final n = list[i];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 24,
                                  child: Text('${i + 1}.', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                                ),
                                const SizedBox(width: 8),
                                Text('$n', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    ).then((_) => _scheduleResumeAfterDelay());
  }

  Widget _buildModeAndSpeedRow(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Auto: Switch (toggle like the reference)
          Text('Auto ', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
          Switch(
            value: !_state!.isManual,
            onChanged: (on) => on ? _switchToAuto() : _switchToManual(),
          ),
          const SizedBox(width: 8),
          // Speed: radio when Auto is on
          if (!_state!.isManual) ...[
            Text('Speed ', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
            ...([3, 5, 7].map((sec) => SizedBox(
                  height: 32,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<int>(
                        value: sec,
                        groupValue: _state!.intervalSeconds,
                        onChanged: (_) => _changeInterval(sec),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                      Text('$sec', style: theme.textTheme.bodySmall),
                    ],
                  ),
                ))),
          ],
        ],
      ),
    );
  }

  Widget _buildCallNextButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(10),
        elevation: 2,
        shadowColor: theme.colorScheme.primary.withOpacity(0.35),
        child: InkWell(
          onTap: _callNext,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.skip_next_rounded, size: 20, color: theme.colorScheme.onPrimary),
                const SizedBox(width: 8),
                Text('Call Next Number', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimary)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameOver(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.celebration, size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Game Over!',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'All 90 numbers have been called.',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: () => widget.onExit(),
              icon: const Icon(Icons.home, size: 22),
              label: const Text('Back to Home'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSpeedDialog() {
    double speed = _tts.speechRate;
    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) {
          return AlertDialog(
            title: const Text('Voice speed'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Slider(
                  value: speed,
                  min: 0,
                  max: 1,
                  divisions: 5,
                  label: speed < 0.3 ? 'Slower' : (speed > 0.7 ? 'Faster' : 'Normal'),
                  onChanged: (v) {
                    setDlg(() => speed = v);
                    _tts.speechRate = v;
                  },
                ),
                Text(speed < 0.3 ? 'Slower' : (speed > 0.7 ? 'Faster' : 'Normal')),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Done'),
              ),
            ],
          );
        },
      ),
    );
  }
}
