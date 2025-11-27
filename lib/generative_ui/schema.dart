// Generative UI Schema
//
// This file defines the JSON schema types for the LLM-powered generative UI feature.
// The LLM outputs JSON matching these types, and the renderer transforms them into
// Material Design 3 Expressive components.
//
// Key design principles:
// - Strict typing for all schema elements
// - No code execution from LLM output
// - All output validated before rendering
//
// See docs/generative-ui-notes.md for full documentation.

import 'dart:convert';

// ===========================================================================
// Enums for expressive metadata
// ===========================================================================

/// Screen role indicates the visual prominence of the screen
enum ScreenRole {
  heroScreen,
  secondaryScreen;

  static ScreenRole? fromString(String? value) {
    if (value == null) return null;
    switch (value.toLowerCase().replaceAll('_', '')) {
      case 'heroscreen':
        return ScreenRole.heroScreen;
      case 'secondaryscreen':
        return ScreenRole.secondaryScreen;
      default:
        return null;
    }
  }

  String toJson() {
    switch (this) {
      case ScreenRole.heroScreen:
        return 'hero_screen';
      case ScreenRole.secondaryScreen:
        return 'secondary_screen';
    }
  }
}

/// Tone affects overall visual expression
enum Tone {
  expressive,
  standard;

  static Tone? fromString(String? value) {
    if (value == null) return null;
    switch (value.toLowerCase()) {
      case 'expressive':
        return Tone.expressive;
      case 'standard':
        return Tone.standard;
      default:
        return null;
    }
  }

  String toJson() => name;
}

/// Motion scheme for animations
enum MotionScheme {
  expressive,
  standard,
  reduced;

  static MotionScheme? fromString(String? value) {
    if (value == null) return null;
    switch (value.toLowerCase()) {
      case 'expressive':
        return MotionScheme.expressive;
      case 'standard':
        return MotionScheme.standard;
      case 'reduced':
        return MotionScheme.reduced;
      default:
        return null;
    }
  }

  String toJson() => name;
}

/// Color mode for theming
enum ColorMode {
  brand,
  dynamic;

  static ColorMode? fromString(String? value) {
    if (value == null) return null;
    switch (value.toLowerCase()) {
      case 'brand':
        return ColorMode.brand;
      case 'dynamic':
        return ColorMode.dynamic;
      default:
        return null;
    }
  }

  String toJson() => name;
}

/// Emphasis level affects typography, spacing, and elevation
enum Emphasis {
  hero,
  primary,
  secondary,
  tertiary;

  static Emphasis? fromString(String? value) {
    if (value == null) return null;
    switch (value.toLowerCase()) {
      case 'hero':
        return Emphasis.hero;
      case 'primary':
        return Emphasis.primary;
      case 'secondary':
        return Emphasis.secondary;
      case 'tertiary':
        return Emphasis.tertiary;
      default:
        return null;
    }
  }

  String toJson() => name;
}

/// Surface type for color mapping
enum Surface {
  surface,
  surfaceVariant,
  primary,
  secondary,
  tertiary;

  static Surface? fromString(String? value) {
    if (value == null) return null;
    switch (value.toLowerCase().replaceAll('_', '')) {
      case 'surface':
        return Surface.surface;
      case 'surfacevariant':
        return Surface.surfaceVariant;
      case 'primary':
        return Surface.primary;
      case 'secondary':
        return Surface.secondary;
      case 'tertiary':
        return Surface.tertiary;
      default:
        return null;
    }
  }

  String toJson() {
    switch (this) {
      case Surface.surface:
        return 'surface';
      case Surface.surfaceVariant:
        return 'surfaceVariant';
      case Surface.primary:
        return 'primary';
      case Surface.secondary:
        return 'secondary';
      case Surface.tertiary:
        return 'tertiary';
    }
  }
}

/// Motion type for individual blocks
enum Motion {
  expressive,
  standard,
  reduced;

  static Motion? fromString(String? value) {
    if (value == null) return null;
    switch (value.toLowerCase()) {
      case 'expressive':
        return Motion.expressive;
      case 'standard':
        return Motion.standard;
      case 'reduced':
        return Motion.reduced;
      default:
        return null;
    }
  }

  String toJson() => name;
}

/// Button role determines visual style
enum ButtonRole {
  primaryAction,
  secondaryAction,
  destructive;

  static ButtonRole? fromString(String? value) {
    if (value == null) return null;
    switch (value.toLowerCase().replaceAll('_', '')) {
      case 'primaryaction':
        return ButtonRole.primaryAction;
      case 'secondaryaction':
        return ButtonRole.secondaryAction;
      case 'destructive':
        return ButtonRole.destructive;
      default:
        return null;
    }
  }

  String toJson() {
    switch (this) {
      case ButtonRole.primaryAction:
        return 'primary_action';
      case ButtonRole.secondaryAction:
        return 'secondary_action';
      case ButtonRole.destructive:
        return 'destructive';
    }
  }
}

/// Button layout determines positioning
enum ButtonLayout {
  edgeHugging,
  inline,
  toolbar;

  static ButtonLayout? fromString(String? value) {
    if (value == null) return null;
    switch (value.toLowerCase().replaceAll('_', '')) {
      case 'edgehugging':
        return ButtonLayout.edgeHugging;
      case 'inline':
        return ButtonLayout.inline;
      case 'toolbar':
        return ButtonLayout.toolbar;
      default:
        return null;
    }
  }

  String toJson() {
    switch (this) {
      case ButtonLayout.edgeHugging:
        return 'edge_hugging';
      case ButtonLayout.inline:
        return 'inline';
      case ButtonLayout.toolbar:
        return 'toolbar';
    }
  }
}

/// Card variant for visual style
enum CardVariant {
  elevated,
  filled,
  outlined;

  static CardVariant? fromString(String? value) {
    if (value == null) return null;
    switch (value.toLowerCase()) {
      case 'elevated':
        return CardVariant.elevated;
      case 'filled':
        return CardVariant.filled;
      case 'outlined':
        return CardVariant.outlined;
      default:
        return null;
    }
  }

  String toJson() => name;
}

/// Text variant for typography
enum TextVariant {
  headline,
  title,
  body,
  label;

  static TextVariant? fromString(String? value) {
    if (value == null) return null;
    switch (value.toLowerCase()) {
      case 'headline':
        return TextVariant.headline;
      case 'title':
        return TextVariant.title;
      case 'body':
        return TextVariant.body;
      case 'label':
        return TextVariant.label;
      default:
        return null;
    }
  }

  String toJson() => name;
}

// ===========================================================================
// Block types (sealed class hierarchy)
// ===========================================================================

/// Base class for all UI blocks
sealed class Block {
  final Emphasis? emphasis;
  final Surface? surface;
  final Motion? motion;

  const Block({
    this.emphasis,
    this.surface,
    this.motion,
  });

  String get type;

  Map<String, dynamic> toJson();
}

/// Hero block: Large header section
class HeroBlock extends Block {
  final String headline;
  final String? subhead;
  final String? icon;

  const HeroBlock({
    required this.headline,
    this.subhead,
    this.icon,
    super.emphasis,
    super.surface,
    super.motion,
  });

  @override
  String get type => 'hero';

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'headline': headline,
        if (subhead != null) 'subhead': subhead,
        if (icon != null) 'icon': icon,
        if (emphasis != null) 'emphasis': emphasis!.toJson(),
        if (surface != null) 'surface': surface!.toJson(),
        if (motion != null) 'motion': motion!.toJson(),
      };
}

/// Card block: Container with content and actions
class CardBlock extends Block {
  final CardVariant? variant;
  final String? headline;
  final List<Block>? body;
  final List<ButtonBlock>? actions;

  const CardBlock({
    this.variant,
    this.headline,
    this.body,
    this.actions,
    super.emphasis,
    super.surface,
    super.motion,
  });

  @override
  String get type => 'card';

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        if (variant != null) 'variant': variant!.toJson(),
        if (headline != null) 'headline': headline,
        if (body != null) 'body': body!.map((b) => b.toJson()).toList(),
        if (actions != null) 'actions': actions!.map((b) => b.toJson()).toList(),
        if (emphasis != null) 'emphasis': emphasis!.toJson(),
        if (surface != null) 'surface': surface!.toJson(),
        if (motion != null) 'motion': motion!.toJson(),
      };
}

/// Text block: Simple text content
class TextBlock extends Block {
  final TextVariant? variant;
  final String text;

  const TextBlock({
    required this.text,
    this.variant,
    super.emphasis,
    super.surface,
    super.motion,
  });

  @override
  String get type => 'text';

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'text': text,
        if (variant != null) 'variant': variant!.toJson(),
        if (emphasis != null) 'emphasis': emphasis!.toJson(),
        if (surface != null) 'surface': surface!.toJson(),
        if (motion != null) 'motion': motion!.toJson(),
      };
}

/// List block: Vertical list of items
class ListBlock extends Block {
  final List<String> items;
  final bool? dense;

  const ListBlock({
    required this.items,
    this.dense,
    super.emphasis,
    super.surface,
    super.motion,
  });

  @override
  String get type => 'list';

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'items': items,
        if (dense != null) 'dense': dense,
        if (emphasis != null) 'emphasis': emphasis!.toJson(),
        if (surface != null) 'surface': surface!.toJson(),
        if (motion != null) 'motion': motion!.toJson(),
      };
}

/// Button block: Interactive button
class ButtonBlock extends Block {
  final String label;
  final ButtonRole? role;
  final ButtonLayout? layout;
  final Map<String, dynamic> action;

  const ButtonBlock({
    required this.label,
    required this.action,
    this.role,
    this.layout,
    super.emphasis,
    super.surface,
    super.motion,
  });

  @override
  String get type => 'button';

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'label': label,
        'action': action,
        if (role != null) 'role': role!.toJson(),
        if (layout != null) 'layout': layout!.toJson(),
        if (emphasis != null) 'emphasis': emphasis!.toJson(),
        if (surface != null) 'surface': surface!.toJson(),
        if (motion != null) 'motion': motion!.toJson(),
      };
}

// ===========================================================================
// Screen definition
// ===========================================================================

/// Screen: Top-level container for blocks
class Screen {
  final String screenId;
  final ScreenRole? role;
  final Tone? tone;
  final MotionScheme? motionScheme;
  final ColorMode? colorMode;
  final List<Block> blocks;

  const Screen({
    required this.screenId,
    required this.blocks,
    this.role,
    this.tone,
    this.motionScheme,
    this.colorMode,
  });

  Map<String, dynamic> toJson() => {
        'screenId': screenId,
        'blocks': blocks.map((b) => b.toJson()).toList(),
        if (role != null) 'role': role!.toJson(),
        if (tone != null) 'tone': tone!.toJson(),
        if (motionScheme != null) 'motionScheme': motionScheme!.toJson(),
        if (colorMode != null) 'colorMode': colorMode!.toJson(),
      };
}

// ===========================================================================
// Parser and Validator
// ===========================================================================

/// Parses and validates JSON into a Screen object
class ScreenParser {
  /// Parse a JSON string into a Screen, or throw if invalid
  static Screen parse(String jsonString) {
    final Map<String, dynamic> json;
    try {
      json = jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw FormatException('Invalid JSON: $e');
    }
    return parseMap(json);
  }

  /// Parse a Map into a Screen
  static Screen parseMap(Map<String, dynamic> json) {
    final screenId = json['screenId'] as String? ?? 'unknown';
    final role = ScreenRole.fromString(json['role'] as String?);
    final tone = Tone.fromString(json['tone'] as String?);
    final motionScheme = MotionScheme.fromString(json['motionScheme'] as String?);
    final colorMode = ColorMode.fromString(json['colorMode'] as String?);

    final blocksJson = json['blocks'] as List<dynamic>? ?? [];
    final blocks = <Block>[];

    for (final blockJson in blocksJson) {
      if (blockJson is Map<String, dynamic>) {
        final block = _parseBlock(blockJson);
        if (block != null) {
          blocks.add(block);
        }
      }
    }

    return Screen(
      screenId: screenId,
      role: role,
      tone: tone,
      motionScheme: motionScheme,
      colorMode: colorMode,
      blocks: blocks,
    );
  }

  /// Parse a single block from JSON
  static Block? _parseBlock(Map<String, dynamic> json) {
    final type = (json['type'] as String?)?.toLowerCase();
    if (type == null) return null;

    // Common expressive metadata
    final emphasis = Emphasis.fromString(json['emphasis'] as String?);
    final surface = Surface.fromString(json['surface'] as String?);
    final motion = Motion.fromString(json['motion'] as String?);

    switch (type) {
      case 'hero':
        final headline = json['headline'] as String?;
        if (headline == null || headline.isEmpty) return null;
        return HeroBlock(
          headline: headline,
          subhead: json['subhead'] as String?,
          icon: json['icon'] as String?,
          emphasis: emphasis,
          surface: surface,
          motion: motion,
        );

      case 'card':
        // Parse nested body blocks
        List<Block>? body;
        final bodyJson = json['body'];
        if (bodyJson is List) {
          body = [];
          for (final b in bodyJson) {
            if (b is Map<String, dynamic>) {
              final parsed = _parseBlock(b);
              if (parsed != null) body.add(parsed);
            }
          }
        } else if (bodyJson is Map<String, dynamic>) {
          final parsed = _parseBlock(bodyJson);
          if (parsed != null) body = [parsed];
        }

        // Parse action buttons
        List<ButtonBlock>? actions;
        final actionsJson = json['actions'] as List<dynamic>?;
        if (actionsJson != null) {
          actions = [];
          for (final a in actionsJson) {
            if (a is Map<String, dynamic>) {
              final parsed = _parseBlock(a);
              if (parsed is ButtonBlock) actions.add(parsed);
            }
          }
        }

        return CardBlock(
          variant: CardVariant.fromString(json['variant'] as String?),
          headline: json['headline'] as String?,
          body: body,
          actions: actions,
          emphasis: emphasis,
          surface: surface,
          motion: motion,
        );

      case 'text':
        final text = json['text'] as String?;
        if (text == null) return null;
        return TextBlock(
          text: text,
          variant: TextVariant.fromString(json['variant'] as String?),
          emphasis: emphasis,
          surface: surface,
          motion: motion,
        );

      case 'list':
        final itemsRaw = json['items'] as List<dynamic>?;
        if (itemsRaw == null || itemsRaw.isEmpty) return null;
        final items = itemsRaw.map((e) => e.toString()).toList();
        return ListBlock(
          items: items,
          dense: json['dense'] as bool?,
          emphasis: emphasis,
          surface: surface,
          motion: motion,
        );

      case 'button':
        final label = json['label'] as String?;
        if (label == null || label.isEmpty) return null;
        final actionRaw = json['action'];
        final Map<String, dynamic> action;
        if (actionRaw is Map) {
          action = actionRaw.cast<String, dynamic>();
        } else if (actionRaw is String) {
          action = {'type': actionRaw};
        } else {
          action = {};
        }
        return ButtonBlock(
          label: label,
          action: action,
          role: ButtonRole.fromString(json['role'] as String?),
          layout: ButtonLayout.fromString(json['layout'] as String?),
          emphasis: emphasis,
          surface: surface,
          motion: motion,
        );

      default:
        // Unknown block type - skip
        return null;
    }
  }
}
