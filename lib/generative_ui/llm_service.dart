// Generative UI LLM Service
//
// This file handles communication with the LLM to generate UI specifications.
// It uses the existing ChatApiService and validates all output against the schema.
//
// Key features (Cline-like conversational UI):
// - Maintains conversation history for context
// - Sends user interactions back to LLM as events
// - LLM responds with updated UI based on user actions
// - Supports streaming for real-time feedback
//
// See docs/generative-ui-notes.md for full documentation.

import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../core/providers/settings_provider.dart';
import '../core/services/api/chat_api_service.dart';
import 'schema.dart';

// ===========================================================================
// User Context for UI Generation
// ===========================================================================

/// Context about the user and device for UI generation
class GenerativeUIUserContext {
  final String deviceType; // 'mobile' | 'tablet' | 'desktop'
  final bool isDarkMode;
  final bool reducedMotion;
  final String? locale;

  const GenerativeUIUserContext({
    this.deviceType = 'mobile',
    this.isDarkMode = false,
    this.reducedMotion = false,
    this.locale,
  });

  Map<String, dynamic> toJson() => {
        'deviceType': deviceType,
        'isDarkMode': isDarkMode,
        'reducedMotion': reducedMotion,
        if (locale != null) 'locale': locale,
      };
}

/// Application context data for UI generation
class GenerativeUIAppContext {
  final String? userName;
  final int? chatCount;
  final int? assistantCount;
  final List<String>? recentTopics;
  final Map<String, dynamic>? customData;

  const GenerativeUIAppContext({
    this.userName,
    this.chatCount,
    this.assistantCount,
    this.recentTopics,
    this.customData,
  });

  Map<String, dynamic> toJson() => {
        if (userName != null) 'userName': userName,
        if (chatCount != null) 'chatCount': chatCount,
        if (assistantCount != null) 'assistantCount': assistantCount,
        if (recentTopics != null) 'recentTopics': recentTopics,
        if (customData != null) ...customData!,
      };
}

/// Represents a user interaction event sent back to the LLM
class UIInteractionEvent {
  final String type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  UIInteractionEvent({
    required this.type,
    required this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'type': type,
        'data': data,
        'timestamp': timestamp.toIso8601String(),
      };

  /// Create from an action map (from UI components)
  factory UIInteractionEvent.fromAction(Map<String, dynamic> action) {
    final type = action['type'] as String? ?? 'unknown';
    final data = Map<String, dynamic>.from(action)..remove('type');
    return UIInteractionEvent(type: type, data: data);
  }
}

// ===========================================================================
// Conversation Message Types
// ===========================================================================

/// A message in the generative UI conversation
sealed class GenerativeUIMessage {
  DateTime get timestamp;
  Map<String, dynamic> toJson();
}

/// System message providing context
class SystemMessage extends GenerativeUIMessage {
  final String content;
  @override
  final DateTime timestamp;

  SystemMessage({required this.content, DateTime? timestamp})
      : timestamp = timestamp ?? DateTime.now();

  @override
  Map<String, dynamic> toJson() => {
        'role': 'system',
        'content': content,
      };
}

/// User request or interaction
class UserMessage extends GenerativeUIMessage {
  final String? text;
  final UIInteractionEvent? event;
  final GenerativeUIAppContext? appContext;
  @override
  final DateTime timestamp;

  UserMessage({
    this.text,
    this.event,
    this.appContext,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  Map<String, dynamic> toJson() {
    final buffer = StringBuffer();
    
    if (text != null) {
      buffer.writeln(text);
    }
    
    if (event != null) {
      buffer.writeln('\n[USER_INTERACTION]');
      buffer.writeln(jsonEncode(event!.toJson()));
    }
    
    if (appContext != null) {
      buffer.writeln('\n[APP_CONTEXT]');
      buffer.writeln(jsonEncode(appContext!.toJson()));
    }
    
    return {
      'role': 'user',
      'content': buffer.toString().trim(),
    };
  }
}

/// Assistant response with UI specification
class AssistantMessage extends GenerativeUIMessage {
  final Screen screen;
  final String? rawResponse;
  @override
  final DateTime timestamp;

  AssistantMessage({
    required this.screen,
    this.rawResponse,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  Map<String, dynamic> toJson() => {
        'role': 'assistant',
        'content': rawResponse ?? jsonEncode(screen.toJson()),
      };
}

// ===========================================================================
// System Prompt Builder
// ===========================================================================

/// Builds the system prompt for conversational UI generation
String _buildSystemPrompt(GenerativeUIUserContext userContext) {
  return '''
You are an interactive UI assistant that generates Material Design 3 Expressive interfaces.
You work in a conversational manner - users interact with your generated UI, and you respond with updated UI based on their actions.

## How It Works
1. You receive requests to generate UI screens
2. Users interact with your UI (clicking buttons, filling forms, toggling switches, etc.)
3. You receive those interactions as [USER_INTERACTION] events
4. You respond with updated UI based on their actions

## Output Format
You must output **only valid JSON** matching the Screen schema. No prose, no markdown, just JSON.

## Schema Reference

### Screen
{
  "screenId": string (required - unique identifier),
  "role": "hero_screen" | "secondary_screen",
  "tone": "expressive" | "standard",
  "motionScheme": "expressive" | "standard" | "reduced",
  "blocks": Block[] (required)
}

### Block Types

1. **hero** - Large header section
   { "type": "hero", "headline": string, "subhead": string?, "icon": string? }

2. **card** - Container with content
   { "type": "card", "variant": "elevated"|"filled"|"outlined", "headline": string?, "body": Block[], "actions": Button[] }

3. **text** - Text content
   { "type": "text", "text": string, "variant": "headline"|"title"|"body"|"label" }

4. **list** - Bullet list
   { "type": "list", "items": string[], "dense": boolean? }

5. **button** - Interactive button (triggers action sent back to you)
   { "type": "button", "label": string, "role": "primary_action"|"secondary_action"|"destructive", "layout": "edge_hugging"|"inline"|"toolbar", "action": { "type": string, ...data } }

6. **checkbox** - Toggle selection
   { "type": "checkbox", "label": string?, "checked": boolean, "action": { "id": string } }

7. **switch** - On/off toggle
   { "type": "switch", "label": string?, "selected": boolean, "action": { "id": string } }

8. **chip** - Selectable label
   { "type": "chip", "label": string, "variant": "filter"|"input"|"suggestion"|"assist", "selected": boolean?, "action": { "id": string } }

9. **text_field** - Text input (value sent back on submit)
   { "type": "text_field", "label": string?, "placeholder": string?, "value": string?, "fieldId": string, "variant": "filled"|"outlined" }

10. **slider** - Range input
    { "type": "slider", "value": number, "min": number?, "max": number?, "label": string?, "fieldId": string }

11. **progress** - Progress indicator
    { "type": "progress", "variant": "linear"|"circular", "value": number? (0-1, null=indeterminate) }

12. **divider** - Visual separator
    { "type": "divider", "label": string?, "inset": boolean? }

13. **icon_button** - Clickable icon
    { "type": "icon_button", "icon": string, "tooltip": string?, "action": { "type": string } }

14. **fab** - Floating action button
    { "type": "fab", "icon": string?, "label": string?, "size": "small"|"regular"|"large"|"extended", "action": { "type": string } }

15. **image** - Display image
    { "type": "image", "src": string (URL), "alt": string?, "width": number?, "height": number? }

16. **avatar** - User avatar
    { "type": "avatar", "imageUrl": string?, "initials": string?, "icon": string?, "size": number? }

17. **row** - Horizontal layout
    { "type": "row", "children": Block[], "spacing": number?, "mainAxisAlignment": "start"|"end"|"center"|"spaceBetween" }

18. **column** - Vertical layout
    { "type": "column", "children": Block[], "spacing": number? }

19. **badge** - Notification badge
    { "type": "badge", "label": string?, "child": Block }

20. **spacer** - Empty space
    { "type": "spacer", "size": number? }

### Common Block Properties
All blocks support: "emphasis": "hero"|"primary"|"secondary"|"tertiary", "surface": "surface"|"surfaceVariant"|"primary"|"secondary"|"tertiary"

## Interaction Events You'll Receive

When users interact with your UI, you receive events like:
- { "type": "button_pressed", "action": {...} } - Button clicked
- { "type": "checkbox_change", "checked": boolean } - Checkbox toggled
- { "type": "switch_change", "selected": boolean } - Switch toggled
- { "type": "chip_select", "selected": boolean, "label": string } - Chip selected
- { "type": "text_field_submit", "value": string, "fieldId": string } - Text submitted
- { "type": "slider_change", "value": number, "fieldId": string } - Slider changed
- { "type": "navigate", "screen": string } - Navigation requested

## Design Guidelines

1. Keep UI focused - show what's relevant to the current task
2. Use exactly 1 primary_action button per screen (usually edge_hugging on mobile)
3. Use emphasis levels: hero for headers, primary for main content, secondary/tertiary for supporting
4. When receiving interactions, update the UI appropriately:
   - Button press → Show result or next step
   - Form input → Validate and show feedback
   - Toggle → Reflect the new state
   - Navigation → Show the requested screen

## User Context
Device: ${userContext.deviceType}
Dark Mode: ${userContext.isDarkMode}
Reduced Motion: ${userContext.reducedMotion}
${userContext.locale != null ? 'Locale: ${userContext.locale}' : ''}

Remember: Output ONLY the JSON Screen object. React to user interactions by providing updated UI.
''';
}

// ===========================================================================
// Conversational UI Session
// ===========================================================================

/// Manages a conversational UI session with the LLM
class GenerativeUISession {
  final ProviderConfig config;
  final String modelId;
  final GenerativeUIUserContext userContext;
  final List<GenerativeUIMessage> _history = [];
  
  Screen? _currentScreen;
  Screen? get currentScreen => _currentScreen;
  
  List<GenerativeUIMessage> get history => List.unmodifiable(_history);

  GenerativeUISession({
    required this.config,
    required this.modelId,
    required this.userContext,
  }) {
    // Initialize with system prompt
    _history.add(SystemMessage(content: _buildSystemPrompt(userContext)));
  }

  /// Start a new conversation with an initial request
  Stream<GenerativeUIProgress> start({
    required String instruction,
    required GenerativeUIAppContext appContext,
  }) async* {
    final userMessage = UserMessage(
      text: instruction,
      appContext: appContext,
    );
    _history.add(userMessage);

    yield* _sendAndParse();
  }

  /// Send a user interaction event and get updated UI
  Stream<GenerativeUIProgress> sendInteraction({
    required UIInteractionEvent event,
    GenerativeUIAppContext? appContext,
    String? additionalText,
  }) async* {
    final userMessage = UserMessage(
      text: additionalText,
      event: event,
      appContext: appContext,
    );
    _history.add(userMessage);

    yield* _sendAndParse();
  }

  /// Send a text message and get updated UI
  Stream<GenerativeUIProgress> sendMessage({
    required String text,
    GenerativeUIAppContext? appContext,
  }) async* {
    final userMessage = UserMessage(
      text: text,
      appContext: appContext,
    );
    _history.add(userMessage);

    yield* _sendAndParse();
  }

  /// Internal: Send messages to LLM and parse response
  Stream<GenerativeUIProgress> _sendAndParse() async* {
    yield GenerativeUIProgress.loading();

    try {
      // Convert history to API format
      final messages = _history.map((m) => m.toJson()).toList();

      final stream = ChatApiService.sendMessageStream(
        config: config,
        modelId: modelId,
        messages: messages,
        temperature: 0.7,
        stream: true,
      );

      final buffer = StringBuffer();

      await for (final chunk in stream) {
        buffer.write(chunk.content);
        yield GenerativeUIProgress.streaming(buffer.toString());

        if (chunk.isDone) {
          break;
        }
      }

      final response = buffer.toString().trim();
      final jsonString = _extractJson(response);
      final screen = ScreenParser.parse(jsonString);

      // Add assistant response to history
      _history.add(AssistantMessage(screen: screen, rawResponse: response));
      _currentScreen = screen;

      yield GenerativeUIProgress.complete(screen);
    } catch (e) {
      debugPrint('[GenerativeUI] Error: $e');
      yield GenerativeUIProgress.error(e.toString());
    }
  }

  /// Clear conversation history (keeps system prompt)
  void clearHistory() {
    final systemMessage = _history.first;
    _history.clear();
    _history.add(systemMessage);
    _currentScreen = null;
  }

  /// Extract JSON from a response that might be wrapped in markdown
  String _extractJson(String response) {
    // Try to find JSON in markdown code block
    final codeBlockPattern = RegExp(r'```(?:json)?\s*\n?([\s\S]*?)\n?```');
    final match = codeBlockPattern.firstMatch(response);
    if (match != null) {
      return match.group(1)?.trim() ?? response;
    }

    // Try to find JSON object directly
    final jsonPattern = RegExp(r'\{[\s\S]*\}');
    final jsonMatch = jsonPattern.firstMatch(response);
    if (jsonMatch != null) {
      return jsonMatch.group(0) ?? response;
    }

    return response;
  }
}

// ===========================================================================
// Legacy Service (for backward compatibility)
// ===========================================================================

/// Service for generating UI specifications via LLM
class GenerativeUIService {
  final ProviderConfig config;
  final String modelId;

  GenerativeUIService({
    required this.config,
    required this.modelId,
  });

  /// Generate a UI screen from the given context and instruction
  Future<Screen> generateScreen({
    required String instruction,
    required GenerativeUIUserContext userContext,
    required GenerativeUIAppContext appContext,
    Screen? previousScreen,
  }) async {
    final session = GenerativeUISession(
      config: config,
      modelId: modelId,
      userContext: userContext,
    );

    Screen? result;
    await for (final progress in session.start(
      instruction: instruction,
      appContext: appContext,
    )) {
      if (progress is _GenerativeUIComplete) {
        result = progress.screen;
      }
    }

    if (result == null) {
      throw Exception('Failed to generate screen');
    }
    return result;
  }

  /// Generate a UI screen with streaming updates
  Stream<GenerativeUIProgress> generateScreenStream({
    required String instruction,
    required GenerativeUIUserContext userContext,
    required GenerativeUIAppContext appContext,
    Screen? previousScreen,
  }) {
    final session = GenerativeUISession(
      config: config,
      modelId: modelId,
      userContext: userContext,
    );

    return session.start(
      instruction: instruction,
      appContext: appContext,
    );
  }
}

/// Progress state for streaming UI generation
sealed class GenerativeUIProgress {
  const GenerativeUIProgress._();

  factory GenerativeUIProgress.loading() = _GenerativeUILoading;
  factory GenerativeUIProgress.streaming(String partialContent) =
      _GenerativeUIStreaming;
  factory GenerativeUIProgress.complete(Screen screen) = _GenerativeUIComplete;
  factory GenerativeUIProgress.error(String message) = _GenerativeUIError;
}

class _GenerativeUILoading extends GenerativeUIProgress {
  const _GenerativeUILoading() : super._();
}

class _GenerativeUIStreaming extends GenerativeUIProgress {
  final String partialContent;
  const _GenerativeUIStreaming(this.partialContent) : super._();
}

class _GenerativeUIComplete extends GenerativeUIProgress {
  final Screen screen;
  const _GenerativeUIComplete(this.screen) : super._();
}

class _GenerativeUIError extends GenerativeUIProgress {
  final String message;
  const _GenerativeUIError(this.message) : super._();
}

// ===========================================================================
// Example Screens (for testing/demo)
// ===========================================================================

/// Create a sample dashboard screen for testing
Screen createSampleDashboardScreen({
  String? userName,
  int chatCount = 0,
  int assistantCount = 0,
}) {
  return Screen(
    screenId: 'sample_dashboard',
    role: ScreenRole.heroScreen,
    tone: Tone.expressive,
    motionScheme: MotionScheme.expressive,
    blocks: [
      HeroBlock(
        headline: 'Welcome${userName != null ? ', $userName' : ''}!',
        subhead: 'Here\'s your AI assistant dashboard',
        icon: 'sparkles',
        emphasis: Emphasis.hero,
        surface: Surface.primary,
        motion: Motion.expressive,
      ),
      CardBlock(
        variant: CardVariant.filled,
        headline: 'Quick Stats',
        emphasis: Emphasis.primary,
        surface: Surface.surfaceVariant,
        body: [
          ListBlock(
            items: [
              '$chatCount conversations',
              '$assistantCount assistants configured',
            ],
          ),
        ],
        actions: [
          ButtonBlock(
            label: 'View History',
            action: {'type': 'navigate', 'screen': 'history'},
            role: ButtonRole.secondaryAction,
            layout: ButtonLayout.inline,
          ),
        ],
      ),
      CardBlock(
        variant: CardVariant.outlined,
        headline: 'What would you like to do?',
        emphasis: Emphasis.secondary,
        body: [
          TextBlock(
            text: 'Start a new conversation or explore your assistants.',
            variant: TextVariant.body,
          ),
        ],
      ),
      ButtonBlock(
        label: 'Start New Chat',
        action: {'type': 'navigate', 'screen': 'new_chat'},
        role: ButtonRole.primaryAction,
        layout: ButtonLayout.edgeHugging,
        emphasis: Emphasis.primary,
      ),
    ],
  );
}
