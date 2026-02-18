/// Game state that we save and load.
/// - shuffleOrder: numbers 1–90 in the order they will be called (random).
/// - currentIndex: how many we've already called (0 = none, 90 = game over).
/// - isManual: true = Manual mode (Next button), false = Auto with timer.
/// - intervalSeconds: 3, 5, or 7 (used only in Auto mode).
/// - isPaused: only for Auto mode; when true, timer is stopped.
class GameState {
  final List<int> shuffleOrder;
  final int currentIndex;
  final bool isManual;
  final int intervalSeconds;
  final bool isPaused;

  const GameState({
    required this.shuffleOrder,
    required this.currentIndex,
    required this.isManual,
    required this.intervalSeconds,
    this.isPaused = false,
  });

  bool get isGameOver => currentIndex >= 90;
  int? get currentNumber =>
      currentIndex > 0 ? shuffleOrder[currentIndex - 1] : null;
  List<int> get calledNumbers => shuffleOrder.sublist(0, currentIndex);
  List<int> get lastFive =>
      calledNumbers.length <= 5
          ? calledNumbers.reversed.toList()
          : calledNumbers.sublist(calledNumbers.length - 5).reversed.toList();

  GameState copyWith({
    List<int>? shuffleOrder,
    int? currentIndex,
    bool? isManual,
    int? intervalSeconds,
    bool? isPaused,
  }) {
    return GameState(
      shuffleOrder: shuffleOrder ?? this.shuffleOrder,
      currentIndex: currentIndex ?? this.currentIndex,
      isManual: isManual ?? this.isManual,
      intervalSeconds: intervalSeconds ?? this.intervalSeconds,
      isPaused: isPaused ?? this.isPaused,
    );
  }

  Map<String, dynamic> toJson() => {
        'shuffleOrder': shuffleOrder,
        'currentIndex': currentIndex,
        'isManual': isManual,
        'intervalSeconds': intervalSeconds,
        'isPaused': isPaused,
      };

  static GameState? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final list = json['shuffleOrder'];
    if (list is! List) return null;
    final order = list.map((e) => (e is int) ? e : (e as num).toInt()).toList();
    if (order.length != 90) return null;
    return GameState(
      shuffleOrder: order,
      currentIndex: (json['currentIndex'] as num?)?.toInt() ?? 0,
      isManual: json['isManual'] as bool? ?? true,
      intervalSeconds: (json['intervalSeconds'] as num?)?.toInt() ?? 5,
      isPaused: json['isPaused'] as bool? ?? false,
    );
  }
}
