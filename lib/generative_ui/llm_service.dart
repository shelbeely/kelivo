// Generative UI LLM Service
//
// This file handles communication with the LLM to generate UI specifications.
// It uses the existing ChatApiService and validates all output against the schema.
//
// Key responsibilities:
// - Build system prompts with UI generation guidelines
// - Call LLM API and parse responses
// - Validate output against schema before returning
// - Handle errors gracefully
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

// ===========================================================================
// System Prompt Builder
// ===========================================================================

/// Builds the system prompt for UI generation
String _buildSystemPrompt(GenerativeUIUserContext userContext) {
  return '''
You are a UI layout planner for a Material Design 3 Expressive interface.
You must output **only valid JSON** according to the Screen and Block schema.
Do NOT include any prose, code, or commentary - output ONLY the JSON object.

## Schema Reference

### Screen
{
  "screenId": string (required),
  "role": "hero_screen" | "secondary_screen" (optional),
  "tone": "expressive" | "standard" (optional),
  "motionScheme": "expressive" | "standard" | "reduced" (optional),
  "colorMode": "brand" | "dynamic" (optional),
  "blocks": Block[] (required)
}

### Block Types

1. Hero Block - Large header section
{
  "type": "hero",
  "headline": string (required),
  "subhead": string (optional),
  "icon": string (optional - icon name like "sparkles", "dashboard", "user"),
  "emphasis": "hero" | "primary" | "secondary" | "tertiary",
  "surface": "surface" | "surfaceVariant" | "primary" | "secondary" | "tertiary",
  "motion": "expressive" | "standard" | "reduced"
}

2. Card Block - Container with content
{
  "type": "card",
  "variant": "elevated" | "filled" | "outlined",
  "headline": string (optional),
  "body": Block | Block[] (optional - nested blocks),
  "actions": ButtonBlock[] (optional),
  "emphasis": ...,
  "surface": ...,
  "motion": ...
}

3. Text Block - Simple text
{
  "type": "text",
  "text": string (required),
  "variant": "headline" | "title" | "body" | "label",
  "emphasis": ...,
  "surface": ...,
  "motion": ...
}

4. List Block - Bullet list
{
  "type": "list",
  "items": string[] (required),
  "dense": boolean (optional),
  "emphasis": ...,
  "surface": ...,
  "motion": ...
}

5. Button Block - Interactive button
{
  "type": "button",
  "label": string (required),
  "role": "primary_action" | "secondary_action" | "destructive",
  "layout": "edge_hugging" | "inline" | "toolbar",
  "action": { type: string, ...payload } (required),
  "emphasis": ...,
  "surface": ...,
  "motion": ...
}

## Design Guidelines

1. Use a small number of high-emphasis components:
   - At most 1 "hero" block per screen with emphasis: "hero"
   - Exactly 1 button with role: "primary_action" for main screens
   - Use emphasis: "primary" for key content cards
   - Use emphasis: "secondary" or "tertiary" for supporting content

2. Button layouts:
   - Use layout: "edge_hugging" for the main primary action on mobile screens (makes it thumb-reachable at bottom)
   - Use layout: "inline" for secondary actions within cards
   - Use layout: "toolbar" for actions in a horizontal row

3. Surface colors:
   - Use "primary" surface for hero sections
   - Use "surfaceVariant" for secondary cards
   - Use "surface" for regular content

4. Motion:
   - Use "expressive" motion for hero and key interactions
   - Use "standard" for most content
   - Use "reduced" when reducedMotion is true in user context

## User Context
Device: ${userContext.deviceType}
Dark Mode: ${userContext.isDarkMode}
Reduced Motion: ${userContext.reducedMotion}
${userContext.locale != null ? 'Locale: ${userContext.locale}' : ''}

## Output Format
Output ONLY the JSON object for a Screen. No markdown code blocks, no explanation.
Example:
{
  "screenId": "dashboard",
  "role": "hero_screen",
  "tone": "expressive",
  "blocks": [...]
}
''';
}

/// Builds the user prompt with app context
String _buildUserPrompt(
  String instruction,
  GenerativeUIAppContext appContext,
  Screen? previousScreen,
) {
  final contextJson = jsonEncode(appContext.toJson());

  final buffer = StringBuffer();
  buffer.writeln('Generate a UI screen based on this request:');
  buffer.writeln(instruction);
  buffer.writeln();
  buffer.writeln('App context:');
  buffer.writeln(contextJson);

  if (previousScreen != null) {
    buffer.writeln();
    buffer.writeln('Previous screen (for context, update if needed):');
    buffer.writeln(jsonEncode(previousScreen.toJson()));
  }

  buffer.writeln();
  buffer.writeln('Output only the JSON for the Screen object.');

  return buffer.toString();
}

// ===========================================================================
// LLM Service
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
    final systemPrompt = _buildSystemPrompt(userContext);
    final userPrompt = _buildUserPrompt(instruction, appContext, previousScreen);

    final messages = <Map<String, dynamic>>[
      {'role': 'system', 'content': systemPrompt},
      {'role': 'user', 'content': userPrompt},
    ];

    try {
      // Use the existing ChatApiService to send the request
      final stream = ChatApiService.sendMessageStream(
        config: config,
        modelId: modelId,
        messages: messages,
        temperature: 0.7,
        stream: false, // Non-streaming for simplicity
      );

      // Collect the full response
      final buffer = StringBuffer();
      await for (final chunk in stream) {
        buffer.write(chunk.content);
      }

      final response = buffer.toString().trim();

      // Extract JSON from response (handle potential markdown wrapping)
      final jsonString = _extractJson(response);

      // Parse and validate
      final screen = ScreenParser.parse(jsonString);

      return screen;
    } catch (e) {
      debugPrint('[GenerativeUI] Error generating screen: $e');
      rethrow;
    }
  }

  /// Generate a UI screen with streaming updates
  Stream<GenerativeUIProgress> generateScreenStream({
    required String instruction,
    required GenerativeUIUserContext userContext,
    required GenerativeUIAppContext appContext,
    Screen? previousScreen,
  }) async* {
    final systemPrompt = _buildSystemPrompt(userContext);
    final userPrompt = _buildUserPrompt(instruction, appContext, previousScreen);

    final messages = <Map<String, dynamic>>[
      {'role': 'system', 'content': systemPrompt},
      {'role': 'user', 'content': userPrompt},
    ];

    yield GenerativeUIProgress.loading();

    try {
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

        // Yield partial content for UI feedback
        yield GenerativeUIProgress.streaming(buffer.toString());

        if (chunk.isDone) {
          break;
        }
      }

      final response = buffer.toString().trim();
      final jsonString = _extractJson(response);
      final screen = ScreenParser.parse(jsonString);

      yield GenerativeUIProgress.complete(screen);
    } catch (e) {
      debugPrint('[GenerativeUI] Error generating screen: $e');
      yield GenerativeUIProgress.error(e.toString());
    }
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
