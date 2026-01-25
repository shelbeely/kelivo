---
name: kelivo-development
description: >
  Guide for developing features in the Kelivo Flutter LLM chat client. 
  Provides project-specific conventions, architecture patterns, and best practices
  for contributing to the Kelivo codebase.
license: AGPL-3.0
metadata:
  author: Kelivo Contributors
  version: '1.0.0'
  project: Kelivo Flutter LLM Client
compatibility: flutter>=3.8.1, dart>=3.8.1
---

# Kelivo Development Skill

This skill provides comprehensive guidance for developing features and fixing bugs in the Kelivo Flutter LLM chat client.

## Project Overview

Kelivo is a modern, cross-platform LLM chat client built with Flutter that supports:
- Multiple AI providers (OpenAI, Google Gemini, Anthropic, etc.)
- Model Context Protocol (MCP) tool integration
- Voice/TTS capabilities
- Web search integration
- Custom assistants
- Multimodal input (images, documents, PDFs)
- Multi-platform support (Android, iOS, Windows, macOS, Linux, Harmony)

## Architecture

### Directory Structure

```
lib/
├── core/               # Core business logic and services
│   ├── models/        # Data models
│   ├── providers/     # State management (Provider pattern)
│   └── services/      # Business logic and external integrations
├── features/          # Feature modules
│   ├── chat/         # Chat functionality
│   ├── mcp/          # Model Context Protocol
│   ├── provider/     # AI provider management
│   ├── assistant/    # Custom assistants
│   ├── settings/     # App settings
│   └── ...
├── desktop/          # Desktop-specific UI and logic
├── shared/           # Shared widgets and utilities
├── theme/            # Theming and styling
├── utils/            # Utility functions
└── l10n/             # Internationalization
```

### State Management

- **Provider Pattern**: Uses the `provider` package for state management
- **Key Providers**:
  - `ChatProvider`: Manages chat sessions and messages
  - `UserProvider`: User configuration and preferences
  - `SettingsProvider`: App settings and theme
  - `McpProvider`: MCP server connections and tools
  - `AssistantProvider`: Custom assistant management
  - `TtsProvider`: Text-to-speech functionality

### Feature Module Pattern

Each feature follows this structure:
```
feature_name/
├── pages/           # Full-page screens
├── widgets/         # Feature-specific widgets
└── models/          # Feature-specific models (if needed)
```

## Development Guidelines

### Code Style

1. **Follow Flutter/Dart conventions**:
   - Use `camelCase` for variable and function names
   - Use `PascalCase` for class names
   - Use `lowercase_with_underscores` for file names
   - Add trailing commas for better formatting

2. **Widget Organization**:
   - Prefer stateless widgets when possible
   - Extract complex widgets into separate files
   - Use `const` constructors when possible for performance

3. **State Management**:
   - Use `Provider.of<T>(context, listen: false)` for one-time reads
   - Use `context.watch<T>()` for reactive updates
   - Use `context.read<T>()` for non-reactive access
   - Keep providers focused on single responsibility

4. **Async Operations**:
   - Always handle errors in async operations
   - Use `try-catch` blocks for API calls
   - Show user feedback for long-running operations
   - Use `unawaited` from `dart:async` for fire-and-forget operations

### Adding New Features

1. **Create Feature Module**:
   ```
   lib/features/my_feature/
   ├── pages/my_feature_page.dart
   └── widgets/my_feature_widget.dart
   ```

2. **Add Provider (if needed)**:
   ```dart
   // In lib/core/providers/my_feature_provider.dart
   class MyFeatureProvider extends ChangeNotifier {
     // State and methods
     void updateState() {
       // Update logic
       notifyListeners();
     }
   }
   ```

3. **Register Provider in main.dart**:
   ```dart
   MultiProvider(
     providers: [
       // ... existing providers
       ChangeNotifierProvider(create: (_) => MyFeatureProvider()),
     ],
     child: MyApp(),
   )
   ```

4. **Add Localization**:
   - Add strings to `lib/l10n/app_en.arb` (English)
   - Add translations to `lib/l10n/app_zh.arb` (Chinese)
   - Run `flutter gen-l10n` to generate localization files

### MCP Integration

When working with MCP (Model Context Protocol):

1. **MCP Service**: Located in `lib/core/services/mcp/mcp_tool_service.dart`
2. **MCP Provider**: Located in `lib/core/providers/mcp_provider.dart`
3. **Adding MCP Servers**: Users can add servers through the MCP settings UI
4. **Tool Calling**: Tools are automatically discovered and made available to AI models

### Testing

- Run tests with: `flutter test`
- Follow existing test patterns in the `test/` directory
- Write unit tests for business logic
- Write widget tests for UI components

### Building

- **Android**: `flutter build apk` or `flutter build appbundle`
- **iOS**: `flutter build ios`
- **Windows**: `flutter build windows`
- **macOS**: `flutter build macos`
- **Linux**: `flutter build linux`

### Localization

- Use `AppLocalizations.of(context)!.stringKey` to access localized strings
- All user-facing strings must be localized
- Support both English and Chinese

### Platform-Specific Code

- Use `Platform.isAndroid`, `Platform.isIOS`, etc. for platform checks
- Desktop-specific UI goes in `lib/desktop/`
- Mobile-specific code stays in main `lib/features/`

## Common Patterns

### Showing Dialogs/Sheets

```dart
// Mobile - Bottom Sheet
showModalBottomSheet(
  context: context,
  builder: (context) => MySheet(),
);

// Desktop - Dialog
showDialog(
  context: context,
  builder: (context) => MyDialog(),
);
```

### Using Providers

```dart
// In a widget
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Watch for changes
    final provider = context.watch<MyProvider>();
    
    return Column(
      children: [
        Text(provider.someValue),
        ElevatedButton(
          onPressed: () {
            // Update state
            context.read<MyProvider>().doSomething();
          },
          child: Text('Action'),
        ),
      ],
    );
  }
}
```

### API Calls

```dart
try {
  final response = await dio.post(
    endpoint,
    data: requestData,
    options: Options(headers: headers),
  );
  // Process response
} catch (e) {
  // Show error to user
  if (context.mounted) {
    showErrorSnackBar(context, 'Error: $e');
  }
}
```

## Important Notes

1. **AGPL-3.0 License**: All contributions must be compatible with AGPL-3.0
2. **Cross-platform**: Always consider all supported platforms when adding features
3. **Internationalization**: All user-facing text must be localized
4. **Material Design**: Follow Material Design 3 (Material You) guidelines
5. **Performance**: Use `const` constructors and avoid unnecessary rebuilds
6. **Accessibility**: Consider accessibility in UI design

## Resources

- Project Repository: https://github.com/Chevey339/kelivo
- Flutter Documentation: https://flutter.dev/docs
- Provider Package: https://pub.dev/packages/provider
- Material Design 3: https://m3.material.io/

## Getting Help

- Check existing issues and PRs on GitHub
- Join the Discord community (link in README)
- Review the README.md and README_ZH_CN.md files
- Look at similar existing features for patterns

## Edge Cases to Consider

1. **Null Safety**: All code must be null-safe
2. **Context Mounting**: Always check `if (context.mounted)` before using context in async callbacks
3. **Memory Leaks**: Properly dispose controllers and listeners
4. **Platform Differences**: Test on multiple platforms before submitting
5. **Network Errors**: Handle offline scenarios gracefully
6. **Large Files**: Consider memory usage when handling files
7. **Background Tasks**: Handle app lifecycle events properly (especially on mobile)
