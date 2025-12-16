# A2UI Feature Module

This module provides integration with Google's A2UI (Agent-to-User Interface) protocol, enabling AI agents to generate dynamic, secure user interfaces.

## Directory Structure

```
a2ui/
├── models/           # Data models
│   ├── a2ui_message.dart    # A2UI message model
│   └── a2ui_examples.dart   # Example A2UI specifications
├── pages/            # UI pages
│   └── a2ui_demo_page.dart  # Demo page showcasing A2UI
├── providers/        # State management
│   └── a2ui_provider.dart   # A2UI state provider
└── widgets/          # Reusable widgets
    ├── a2ui_renderer.dart         # Main renderer widget
    └── a2ui_widget_catalog.dart   # Widget catalog
```

## Components

### Models

- **A2uiMessage**: Represents a message containing A2UI specification
- **A2uiExamples**: Pre-built example A2UI specifications for testing and demonstration

### Providers

- **A2uiProvider**: Manages A2UI state, widget catalog registration, and enable/disable state

### Widgets

- **A2uiRenderer**: Renders A2UI specifications from JSON or Map
- **A2uiStreamRenderer**: Renders streaming A2UI updates
- **A2uiWidgetCatalog**: Catalog of safe, pre-approved widgets

### Pages

- **A2uiDemoPage**: Interactive demo showcasing various A2UI examples

## Usage Example

```dart
import 'package:Kelivo/features/a2ui/widgets/a2ui_renderer.dart';

// Render from JSON string
A2uiRenderer(
  specification: '''
  {
    "type": "card",
    "children": [
      {
        "type": "text",
        "text": "Hello A2UI!"
      }
    ]
  }
  ''',
  onError: () {
    print('Rendering failed');
  },
)

// Render from Map
A2uiRenderer(
  specification: {
    'type': 'button',
    'label': 'Click Me',
    'id': 'my_button',
  },
)
```

## Security

The A2UI implementation ensures security through:

1. **Declarative Format**: Only JSON data structures, no executable code
2. **Widget Catalog**: Limited to pre-approved, safe widgets
3. **Safe Parsing**: Error handling for malformed specifications
4. **No Dynamic Code**: Widgets are statically defined in the catalog

## Extending the Widget Catalog

To add a new widget type:

1. Add a case in `A2uiWidgetCatalog.buildWidget()`
2. Implement the builder method (e.g., `_buildMyWidget()`)
3. Follow the existing pattern for property parsing
4. Ensure no dynamic code execution

Example:

```dart
case 'mywidget':
  return _buildMyWidget(spec);

static Widget _buildMyWidget(Map<String, dynamic> spec) {
  final label = spec['label'] as String? ?? 'Default';
  return MyWidget(label: label);
}
```

## Testing

Tests are located in `/test/a2ui_test.dart` and cover:

- Widget catalog rendering
- JSON parsing
- Error handling
- Example specifications

Run tests with:
```bash
flutter test test/a2ui_test.dart
```

## Future Enhancements

- Chat message integration
- Interactive callbacks
- Streaming updates
- Extended widget catalog
- Custom widget registration API

## Resources

- [A2UI Documentation](https://a2ui.org/)
- [Google A2UI GitHub](https://github.com/google/A2UI)
- [Integration Guide](/docx/A2UI_INTEGRATION.md)
