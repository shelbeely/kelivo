import 'package:flutter/foundation.dart';

/// Provider for managing A2UI (Agent-to-User Interface) state and configuration
/// 
/// This provider handles:
/// - A2UI enabled/disabled state
/// - Widget catalog registration
/// - A2UI message processing
class A2uiProvider extends ChangeNotifier {
  bool _isEnabled = true;
  final Map<String, dynamic> _widgetCatalog = {};

  /// Whether A2UI rendering is enabled
  bool get isEnabled => _isEnabled;

  /// Get the widget catalog
  Map<String, dynamic> get widgetCatalog => Map.unmodifiable(_widgetCatalog);

  /// Enable or disable A2UI rendering
  void setEnabled(bool enabled) {
    if (_isEnabled != enabled) {
      _isEnabled = enabled;
      notifyListeners();
    }
  }

  /// Register a widget type in the catalog
  void registerWidget(String type, dynamic widgetBuilder) {
    _widgetCatalog[type] = widgetBuilder;
    notifyListeners();
  }

  /// Unregister a widget type from the catalog
  void unregisterWidget(String type) {
    if (_widgetCatalog.remove(type) != null) {
      notifyListeners();
    }
  }

  /// Clear all registered widgets
  void clearCatalog() {
    if (_widgetCatalog.isNotEmpty) {
      _widgetCatalog.clear();
      notifyListeners();
    }
  }

  /// Check if a widget type is registered
  bool hasWidget(String type) {
    return _widgetCatalog.containsKey(type);
  }
}
