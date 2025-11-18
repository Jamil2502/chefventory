/// Service for managing undo functionality for critical actions
class UndoService {
  static final UndoService _instance = UndoService._internal();

  factory UndoService() {
    return _instance;
  }

  UndoService._internal();

  final List<UndoAction> _history = [];
  int _currentIndex = -1;

  /// Add an action to undo history
  void addAction(UndoAction action) {
    // Remove any redo history when a new action is added
    _history.removeRange(_currentIndex + 1, _history.length);
    _history.add(action);
    _currentIndex = _history.length - 1;

    // Keep only last 20 actions to save memory
    if (_history.length > 20) {
      _history.removeAt(0);
      _currentIndex--;
    }
  }

  /// Undo the last action
  Future<bool> undo() async {
    if (canUndo()) {
      final action = _history[_currentIndex];
      final success = await action.undo();
      if (success) {
        _currentIndex--;
      }
      return success;
    }
    return false;
  }

  /// Redo the last undone action
  Future<bool> redo() async {
    if (canRedo()) {
      _currentIndex++;
      final action = _history[_currentIndex];
      final success = await action.redo();
      if (!success) {
        _currentIndex--;
      }
      return success;
    }
    return false;
  }

  /// Check if undo is available
  bool canUndo() => _currentIndex >= 0;

  /// Check if redo is available
  bool canRedo() => _currentIndex < _history.length - 1;

  /// Clear all undo history
  void clear() {
    _history.clear();
    _currentIndex = -1;
  }

  /// Get number of available undo actions
  int getUndoCount() => _currentIndex + 1;

  /// Get number of available redo actions
  int getRedoCount() => _history.length - _currentIndex - 1;
}

/// Base class for undoable actions
abstract class UndoAction {
  /// Execute the action
  Future<bool> execute();

  /// Undo the action
  Future<bool> undo();

  /// Redo the action
  Future<bool> redo();

  /// Get action description for display
  String getDescription();
}

/// Action for deleting an ingredient
class DeleteIngredientAction extends UndoAction {
  final String ingredientId;
  final String ingredientName;
  final dynamic ingredientData;
  final Function(String) onUndo;
  final Function(String) onRedo;

  DeleteIngredientAction({
    required this.ingredientId,
    required this.ingredientName,
    required this.ingredientData,
    required this.onUndo,
    required this.onRedo,
  });

  @override
  Future<bool> execute() async {
    // Action already executed before adding to history
    return true;
  }

  @override
  Future<bool> undo() async {
    try {
      onUndo(ingredientId);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> redo() async {
    try {
      onRedo(ingredientId);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  String getDescription() => 'Delete $ingredientName';
}

/// Action for deleting a dish
class DeleteDishAction extends UndoAction {
  final String dishId;
  final String dishName;
  final Function(String) onUndo;
  final Function(String) onRedo;

  DeleteDishAction({
    required this.dishId,
    required this.dishName,
    required this.onUndo,
    required this.onRedo,
  });

  @override
  Future<bool> execute() async {
    return true;
  }

  @override
  Future<bool> undo() async {
    try {
      onUndo(dishId);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> redo() async {
    try {
      onRedo(dishId);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  String getDescription() => 'Delete $dishName';
}

/// Action for removing staff
class RemoveStaffAction extends UndoAction {
  final String staffId;
  final String staffName;
  final Function(String) onUndo;
  final Function(String) onRedo;

  RemoveStaffAction({
    required this.staffId,
    required this.staffName,
    required this.onUndo,
    required this.onRedo,
  });

  @override
  Future<bool> execute() async {
    return true;
  }

  @override
  Future<bool> undo() async {
    try {
      onUndo(staffId);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> redo() async {
    try {
      onRedo(staffId);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  String getDescription() => 'Remove $staffName';
}
