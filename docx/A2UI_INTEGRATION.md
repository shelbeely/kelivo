# A2UI Integration Guide

## Overview

Kelivo now integrates **A2UI (Agent-to-User Interface)** protocol support, enabling AI agents to generate dynamic, safe, and updateable user interfaces beyond simple text responses.

**Implementation Note**: Kelivo uses a custom, self-contained A2UI implementation built from scratch. This implementation follows the A2UI specification and is fully compatible with the A2UI protocol, while being optimized for Kelivo's architecture.

## What is A2UI?

A2UI is Google's open-source specification that allows generative AI agents to produce declarative JSON descriptions of UI components. Instead of just returning text, agents can create forms, cards, buttons, selectors, charts, and more - all rendered safely using Flutter widgets.

### Key Benefits

- **Security First**: Declarative format prevents code injection - agents select from pre-approved UI components
- **LLM-Friendly**: Simple JSON structure that's easy for AI models to generate and update
- **Framework-Agnostic**: The protocol works across platforms (Flutter, React, Angular, etc.)
- **Streaming Support**: Progressive UI rendering as agents generate updates
- **Dynamic Updates**: UIs can be updated in real-time during conversations

## Features

### Widget Catalog

Kelivo's A2UI implementation includes a catalog of safe, pre-approved widgets:

- **Card**: Container with elevation and padding
- **Button**: Interactive button with callbacks
- **Text**: Styled text with customizable fonts, colors, and weight
- **TextField**: Input fields with labels and hints
- **Container**: Layout container with padding, margins, borders
- **Row/Column**: Flex layouts with alignment options
- **Divider**: Visual separator
- **Checkbox**: Boolean selection with labels
- **Switch**: Toggle switch with labels
- **Slider**: Numeric value selection

### A2UI Renderer

The `A2uiRenderer` widget safely parses and renders A2UI specifications:

```dart
A2uiRenderer(
  specification: jsonString, // or Map<String, dynamic>
  onError: () {
    // Handle rendering errors
  },
)
```

### Stream Support

For progressive rendering, use `A2uiStreamRenderer`:

```dart
A2uiStreamRenderer(
  specificationStream: streamOfJsonLines,
  onError: () {
    // Handle errors
  },
)
```

## Usage

### Accessing the Demo

1. Open Kelivo
2. Navigate to **Settings**
3. Tap on **A2UI Demo** in the General section
4. Explore different UI examples:
   - Simple Card
   - Form Example
   - Settings Panel
   - Layout Example

### Example A2UI Specification

```json
{
  "type": "card",
  "padding": 16,
  "children": [
    {
      "type": "text",
      "text": "Hello from A2UI!",
      "fontSize": 18,
      "bold": true
    },
    {
      "type": "button",
      "id": "submit",
      "label": "Click Me"
    }
  ]
}
```

### Creating Custom A2UI UIs

AI agents can generate A2UI specifications in their responses. The specifications will be automatically rendered by Kelivo when detected in chat messages.

#### Supported Properties

**Card**:
- `type`: "card"
- `elevation`: number (default: 1.0)
- `padding`: number or {left, top, right, bottom}
- `margin`: number or {left, top, right, bottom}
- `children`: array of widgets

**Button**:
- `type`: "button"
- `id`: string (for callbacks)
- `label`: string
- `margin`: number or {left, top, right, bottom}

**Text**:
- `type`: "text"
- `text`: string
- `fontSize`: number
- `bold`: boolean
- `color`: string (hex format: "#FF0000") or number
- `margin`: number or {left, top, right, bottom}

**TextField**:
- `type`: "textfield"
- `id`: string (for value tracking)
- `label`: string
- `hint`: string
- `margin`: number or {left, top, right, bottom}

**Container**:
- `type`: "container"
- `padding`: number or {left, top, right, bottom}
- `margin`: number or {left, top, right, bottom}
- `backgroundColor`: string or number
- `border`: boolean
- `borderColor`: string or number
- `borderWidth`: number
- `borderRadius`: number
- `children`: array of widgets

**Row**:
- `type`: "row"
- `mainAxisAlignment`: "start" | "center" | "end" | "spaceBetween" | "spaceAround" | "spaceEvenly"
- `crossAxisAlignment`: "start" | "center" | "end" | "stretch"
- `children`: array of widgets

**Column**:
- `type`: "column"
- `mainAxisAlignment`: "start" | "center" | "end" | "spaceBetween" | "spaceAround" | "spaceEvenly"
- `crossAxisAlignment`: "start" | "center" | "end" | "stretch"
- `children`: array of widgets

**Divider**:
- `type`: "divider"
- `color`: string or number
- `thickness`: number
- `height`: number

**Checkbox**:
- `type`: "checkbox"
- `id`: string
- `label`: string
- `value`: boolean

**Switch**:
- `type`: "switch"
- `id`: string
- `label`: string
- `value`: boolean

**Slider**:
- `type`: "slider"
- `id`: string
- `value`: number
- `min`: number
- `max`: number

## Security

A2UI ensures security through:

1. **Declarative Format**: No executable code - only data structures
2. **Widget Catalog**: Only pre-approved components can be rendered
3. **Safe Parsing**: JSON parsing with error handling
4. **No Dynamic Code Execution**: Widgets are statically defined

## Integration with Chat

The A2UI system is designed to work seamlessly with Kelivo's chat interface. Future updates will enable:

- Automatic detection of A2UI specifications in AI responses
- Interactive widgets within chat bubbles
- User interaction callbacks to agents
- Progressive UI updates during streaming responses

## Developer Guide

### Adding Custom Widgets

To extend the widget catalog:

1. Open `lib/features/a2ui/widgets/a2ui_widget_catalog.dart`
2. Add a new case to the `buildWidget` switch statement
3. Implement the widget builder method
4. Follow security best practices (no dynamic code execution)

### Using A2UI in Your Features

```dart
import 'package:Kelivo/features/a2ui/widgets/a2ui_renderer.dart';

// In your widget:
A2uiRenderer(
  specification: yourA2uiSpec,
  onError: () {
    // Handle errors
  },
)
```

## Resources

- [A2UI Official Website](https://a2ui.org/)
- [A2UI GitHub Repository](https://github.com/google/A2UI)
- [Flutter GenUI A2UI Package](https://pub.dev/packages/genui_a2ui)
- [A2UI Package](https://pub.dev/packages/a2ui)

## Future Enhancements

Planned improvements include:

- Full integration with chat message rendering
- WebSocket/streaming support for real-time updates
- Extended widget catalog (charts, maps, etc.)
- Custom widget registration API
- User interaction event handling
- A2UI template library
- Agent-side A2UI generation helpers

## Contributing

Contributions to improve A2UI integration are welcome! Please follow the project's contribution guidelines when submitting pull requests.

## License

The A2UI integration follows Kelivo's AGPL-3.0 license. The A2UI protocol itself is open-source from Google.
