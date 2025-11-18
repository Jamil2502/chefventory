import 'dart:async';

/// Helper class for debouncing search input
class SearchDebouncer {
  final Duration duration;
  Timer? _timer;
  final void Function(String) onSearch;

  SearchDebouncer({
    required this.onSearch,
    this.duration = const Duration(milliseconds: 500),
  });

  /// Call this method on each search input change
  void search(String query) {
    _timer?.cancel();
    _timer = Timer(duration, () {
      onSearch(query);
    });
  }

  /// Cancel any pending search
  void cancel() {
    _timer?.cancel();
  }

  /// Dispose the debouncer
  void dispose() {
    _timer?.cancel();
  }
}


