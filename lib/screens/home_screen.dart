import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../services/game_service.dart';
import '../widgets/cast_dialog.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  final void Function({required bool isManual, required int intervalSeconds}) onNewGame;
  final VoidCallback onResume;
  final bool darkMode;
  final bool soundOn;
  final VoidCallback onToggleDark;
  final VoidCallback onToggleSound;
  final String themeId;
  final void Function(String) onThemeChanged;

  const HomeScreen({
    super.key,
    required this.onNewGame,
    required this.onResume,
    required this.darkMode,
    required this.soundOn,
    required this.onToggleDark,
    required this.onToggleSound,
    required this.themeId,
    required this.onThemeChanged,
  });

  void _showNewGameDialog(BuildContext context) {
    bool isManual = true;
    int intervalSeconds = 5;
    final theme = Theme.of(context);

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Icon(Icons.sports_esports, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                const Text('New Game'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mode', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Radio<bool>(
                        value: true,
                        groupValue: isManual,
                        onChanged: (v) => setDialogState(() => isManual = true),
                      ),
                      const Expanded(child: Text('Manual — tap Next for each number')),
                    ],
                  ),
                  Row(
                    children: [
                      Radio<bool>(
                        value: false,
                        groupValue: isManual,
                        onChanged: (v) => setDialogState(() => isManual = false),
                      ),
                      const Expanded(child: Text('Automatic — timer between numbers')),
                    ],
                  ),
                  if (!isManual) ...[
                    const SizedBox(height: 20),
                    Text('Interval', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: [3, 5, 7].map((sec) {
                        final selected = intervalSeconds == sec;
                        return ChoiceChip(
                          label: Text('$sec sec'),
                          selected: selected,
                          onSelected: (_) => setDialogState(() => intervalSeconds = sec),
                          selectedColor: theme.colorScheme.primaryContainer,
                          labelStyle: TextStyle(
                            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                            color: selected ? theme.colorScheme.onPrimaryContainer : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  onNewGame(isManual: isManual, intervalSeconds: intervalSeconds);
                },
                icon: const Icon(Icons.play_arrow, size: 20),
                label: const Text('Start'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    theme.colorScheme.surface,
                    theme.colorScheme.surface.withOpacity(0.97),
                    theme.colorScheme.primaryContainer.withOpacity(0.15),
                  ]
                : [
                    theme.colorScheme.primaryContainer.withOpacity(0.25),
                    theme.colorScheme.surface,
                    theme.colorScheme.secondaryContainer.withOpacity(0.3),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                title: Text(
                  'Tambola Caller',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                actions: [
                  IconButton(
                    icon: Icon(Icons.palette_outlined, color: theme.colorScheme.primary),
                    onPressed: () => showThemePickerDialog(
                      context,
                      currentThemeId: themeId,
                      isDark: darkMode,
                      onThemeSelected: onThemeChanged,
                    ),
                    tooltip: 'Theme',
                  ),
                  IconButton(
                    icon: Icon(Icons.cast_connected, color: theme.colorScheme.primary),
                    onPressed: () => showCastDialog(context),
                    tooltip: 'Cast to TV',
                  ),
                  IconButton(
                    icon: Icon(darkMode ? Icons.dark_mode : Icons.light_mode),
                    onPressed: onToggleDark,
                    tooltip: darkMode ? 'Light mode' : 'Dark mode',
                  ),
                  IconButton(
                    icon: Icon(soundOn ? Icons.volume_up : Icons.volume_off),
                    onPressed: onToggleSound,
                    tooltip: soundOn ? 'Sound off' : 'Sound on',
                  ),
                ],
              ),
              Expanded(
                child: FutureBuilder<bool>(
                  future: GameService().loadGame().then((s) => s != null && !s.isGameOver),
                  builder: (context, snapshot) {
                    final canResume = snapshot.data == true;
                    return Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Title card
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface.withOpacity(0.85),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.colorScheme.primary.withOpacity(0.2),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Tambola / Housie',
                                        style: theme.textTheme.headlineMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Number Caller',
                                        style: theme.textTheme.titleLarge?.copyWith(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 48),
                            FilledButton.icon(
                              onPressed: () => _showNewGameDialog(context),
                              icon: const Icon(Icons.add_circle_outline, size: 26),
                              label: const Text('New Game'),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
                                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                              ),
                            ),
                            if (canResume) ...[
                              const SizedBox(height: 16),
                              OutlinedButton.icon(
                                onPressed: () => onResume(),
                                icon: const Icon(Icons.play_arrow, size: 24),
                                label: const Text('Resume Game'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
                                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                                  side: BorderSide(color: theme.colorScheme.primary, width: 2),
                                ),
                              ),
                            ],
                            const SizedBox(height: 40),
                            TextButton.icon(
                              onPressed: () async {
                                final exit = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Close app?'),
                                    content: const Text('Do you want to exit Tambola Caller?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(ctx).pop(false),
                                        child: const Text('Cancel'),
                                      ),
                                      FilledButton(
                                        onPressed: () => Navigator.of(ctx).pop(true),
                                        child: const Text('Exit'),
                                      ),
                                    ],
                                  ),
                                );
                                if (exit == true) SystemNavigator.pop();
                              },
                              icon: Icon(Icons.logout_rounded, size: 22, color: theme.colorScheme.error),
                              label: Text('Logout', style: TextStyle(fontSize: 16, color: theme.colorScheme.error)),
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
    );
  }
}
