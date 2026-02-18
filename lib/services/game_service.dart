import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_state.dart';

const _keyGameState = 'tambola_game_state';

/// Handles game logic: creating a new game (shuffle 1–90), calling next number,
/// and saving/loading state so the game survives app restart.
class GameService {
  static final GameService _instance = GameService._();
  factory GameService() => _instance;
  GameService._();

  GameState? _state;
  GameState? get state => _state;

  static List<int> _shuffleNumbers() {
    final list = List<int>.generate(90, (i) => i + 1);
    list.shuffle(Random());
    return list;
  }

  /// Start a new game: 1–90 in random order, no numbers called yet.
  GameState newGame({required bool isManual, required int intervalSeconds}) {
    _state = GameState(
      shuffleOrder: _shuffleNumbers(),
      currentIndex: 0,
      isManual: isManual,
      intervalSeconds: intervalSeconds,
      isPaused: false,
    );
    _persist();
    return _state!;
  }

  /// Call the next number. Returns null if game is over.
  int? callNext() {
    if (_state == null || _state!.isGameOver) return null;
    final next = _state!.shuffleOrder[_state!.currentIndex];
    _state = _state!.copyWith(currentIndex: _state!.currentIndex + 1);
    _persist();
    return next;
  }

  void setPaused(bool value) {
    if (_state == null) return;
    _state = _state!.copyWith(isPaused: value);
    _persist();
  }

  /// Change mode (Manual / Automatic) and optionally interval during the game.
  void setMode(bool isManual, [int? intervalSeconds]) {
    if (_state == null || _state!.isGameOver) return;
    final newInterval = intervalSeconds ?? _state!.intervalSeconds;
    _state = _state!.copyWith(
      isManual: isManual,
      intervalSeconds: newInterval.clamp(3, 7),
      isPaused: false,
    );
    _persist();
  }

  /// Change only the timer interval (3, 5, or 7 sec) during the game. Only applies in Auto mode.
  void setInterval(int seconds) {
    if (_state == null || _state!.isGameOver) return;
    _state = _state!.copyWith(intervalSeconds: seconds.clamp(3, 7));
    _persist();
  }

  /// Load saved game from device storage. Returns null if none saved.
  Future<GameState?> loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    final orderStr = prefs.getString(_keyGameState);
    if (orderStr == null || orderStr.isEmpty) {
      _state = null;
      return null;
    }
    try {
      final list = orderStr
          .split(',')
          .map((e) => int.tryParse(e.trim()))
          .whereType<int>()
          .toList();
      if (list.length != 90) {
        _state = null;
        return null;
      }
      final currentIndex = prefs.getInt('${_keyGameState}_index') ?? 0;
      final isManual = prefs.getBool('${_keyGameState}_manual') ?? true;
      final intervalSeconds = prefs.getInt('${_keyGameState}_interval') ?? 5;
      final isPaused = prefs.getBool('${_keyGameState}_paused') ?? false;
      final idx = currentIndex.clamp(0, 90);
      if (idx >= 90) {
        _state = null;
        await clearSaved();
        return null;
      }
      _state = GameState(
        shuffleOrder: list,
        currentIndex: idx,
        isManual: isManual,
        intervalSeconds: intervalSeconds,
        isPaused: isPaused,
      );
      return _state;
    } catch (_) {
      _state = null;
      return null;
    }
  }

  void _persist() {
    if (_state == null) return;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(_keyGameState, _state!.shuffleOrder.join(','));
      prefs.setInt('${_keyGameState}_index', _state!.currentIndex);
      prefs.setBool('${_keyGameState}_manual', _state!.isManual);
      prefs.setInt('${_keyGameState}_interval', _state!.intervalSeconds);
      prefs.setBool('${_keyGameState}_paused', _state!.isPaused);
    });
  }

  /// Clear saved game (e.g. after "New Game" and we want Resume to disappear until a new game is started).
  Future<void> clearSaved() async {
    _state = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyGameState);
    await prefs.remove('${_keyGameState}_index');
    await prefs.remove('${_keyGameState}_manual');
    await prefs.remove('${_keyGameState}_interval');
    await prefs.remove('${_keyGameState}_paused');
  }

  bool get hasSavedGame => _state != null && !_state!.isGameOver;
}
