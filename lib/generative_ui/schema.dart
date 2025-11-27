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

/// Chip variant for styling
enum ChipVariant {
  assist,
  filter,
  input,
  suggestion;

  static ChipVariant? fromString(String? value) {
    if (value == null) return null;
    switch (value.toLowerCase()) {
      case 'assist':
        return ChipVariant.assist;
      case 'filter':
        return ChipVariant.filter;
      case 'input':
        return ChipVariant.input;
      case 'suggestion':
        return ChipVariant.suggestion;
      default:
        return null;
    }
  }

  String toJson() => name;
}

/// Progress variant
enum ProgressVariant {
  linear,
  circular;

  static ProgressVariant? fromString(String? value) {
    if (value == null) return null;
    switch (value.toLowerCase()) {
      case 'linear':
        return ProgressVariant.linear;
      case 'circular':
        return ProgressVariant.circular;
      default:
        return null;
    }
  }

  String toJson() => name;
}

/// FAB size variant
enum FabSize {
  small,
  regular,
  large,
  extended;

  static FabSize? fromString(String? value) {
    if (value == null) return null;
    switch (value.toLowerCase()) {
      case 'small':
        return FabSize.small;
      case 'regular':
        return FabSize.regular;
      case 'large':
        return FabSize.large;
      case 'extended':
        return FabSize.extended;
      default:
        return null;
    }
  }

  String toJson() => name;
}

/// TextField variant
enum TextFieldVariant {
  filled,
  outlined;

  static TextFieldVariant? fromString(String? value) {
    if (value == null) return null;
    switch (value.toLowerCase()) {
      case 'filled':
        return TextFieldVariant.filled;
      case 'outlined':
        return TextFieldVariant.outlined;
      default:
        return null;
    }
  }

  String toJson() => name;
}

/// Badge position
enum BadgePosition {
  topRight,
  topLeft,
  bottomRight,
  bottomLeft;

  static BadgePosition? fromString(String? value) {
    if (value == null) return null;
    switch (value.toLowerCase().replaceAll('_', '')) {
      case 'topright':
        return BadgePosition.topRight;
      case 'topleft':
        return BadgePosition.topLeft;
      case 'bottomright':
        return BadgePosition.bottomRight;
      case 'bottomleft':
        return BadgePosition.bottomLeft;
      default:
        return null;
    }
  }

  String toJson() {
    switch (this) {
      case BadgePosition.topRight:
        return 'top_right';
      case BadgePosition.topLeft:
        return 'top_left';
      case BadgePosition.bottomRight:
        return 'bottom_right';
      case BadgePosition.bottomLeft:
        return 'bottom_left';
    }
  }
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

/// Checkbox block: Toggle selection
class CheckboxBlock extends Block {
  final String? label;
  final bool checked;
  final bool? disabled;
  final Map<String, dynamic>? action;

  const CheckboxBlock({
    this.label,
    this.checked = false,
    this.disabled,
    this.action,
    super.emphasis,
    super.surface,
    super.motion,
  });

  @override
  String get type => 'checkbox';

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        if (label != null) 'label': label,
        'checked': checked,
        if (disabled != null) 'disabled': disabled,
        if (action != null) 'action': action,
        if (emphasis != null) 'emphasis': emphasis!.toJson(),
        if (surface != null) 'surface': surface!.toJson(),
        if (motion != null) 'motion': motion!.toJson(),
      };
}

/// Switch block: On/off toggle
class SwitchBlock extends Block {
  final String? label;
  final bool selected;
  final bool? disabled;
  final Map<String, dynamic>? action;

  const SwitchBlock({
    this.label,
    this.selected = false,
    this.disabled,
    this.action,
    super.emphasis,
    super.surface,
    super.motion,
  });

  @override
  String get type => 'switch';

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        if (label != null) 'label': label,
        'selected': selected,
        if (disabled != null) 'disabled': disabled,
        if (action != null) 'action': action,
        if (emphasis != null) 'emphasis': emphasis!.toJson(),
        if (surface != null) 'surface': surface!.toJson(),
        if (motion != null) 'motion': motion!.toJson(),
      };
}

/// Chip block: Filterable/selectable label
class ChipBlock extends Block {
  final String label;
  final ChipVariant? variant;
  final String? icon;
  final bool? selected;
  final bool? disabled;
  final Map<String, dynamic>? action;

  const ChipBlock({
    required this.label,
    this.variant,
    this.icon,
    this.selected,
    this.disabled,
    this.action,
    super.emphasis,
    super.surface,
    super.motion,
  });

  @override
  String get type => 'chip';

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'label': label,
        if (variant != null) 'variant': variant!.toJson(),
        if (icon != null) 'icon': icon,
        if (selected != null) 'selected': selected,
        if (disabled != null) 'disabled': disabled,
        if (action != null) 'action': action,
        if (emphasis != null) 'emphasis': emphasis!.toJson(),
        if (surface != null) 'surface': surface!.toJson(),
        if (motion != null) 'motion': motion!.toJson(),
      };
}

/// Progress block: Progress indicator
class ProgressBlock extends Block {
  final ProgressVariant? variant;
  final double? value; // 0.0 to 1.0, null for indeterminate
  final String? label;

  const ProgressBlock({
    this.variant,
    this.value,
    this.label,
    super.emphasis,
    super.surface,
    super.motion,
  });

  @override
  String get type => 'progress';

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        if (variant != null) 'variant': variant!.toJson(),
        if (value != null) 'value': value,
        if (label != null) 'label': label,
        if (emphasis != null) 'emphasis': emphasis!.toJson(),
        if (surface != null) 'surface': surface!.toJson(),
        if (motion != null) 'motion': motion!.toJson(),
      };
}

/// Divider block: Visual separator
class DividerBlock extends Block {
  final bool? inset;
  final String? label;

  const DividerBlock({
    this.inset,
    this.label,
    super.emphasis,
    super.surface,
    super.motion,
  });

  @override
  String get type => 'divider';

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        if (inset != null) 'inset': inset,
        if (label != null) 'label': label,
        if (emphasis != null) 'emphasis': emphasis!.toJson(),
        if (surface != null) 'surface': surface!.toJson(),
        if (motion != null) 'motion': motion!.toJson(),
      };
}

/// IconButton block: Clickable icon
class IconButtonBlock extends Block {
  final String icon;
  final String? tooltip;
  final bool? filled;
  final bool? disabled;
  final Map<String, dynamic>? action;

  const IconButtonBlock({
    required this.icon,
    this.tooltip,
    this.filled,
    this.disabled,
    this.action,
    super.emphasis,
    super.surface,
    super.motion,
  });

  @override
  String get type => 'icon_button';

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'icon': icon,
        if (tooltip != null) 'tooltip': tooltip,
        if (filled != null) 'filled': filled,
        if (disabled != null) 'disabled': disabled,
        if (action != null) 'action': action,
        if (emphasis != null) 'emphasis': emphasis!.toJson(),
        if (surface != null) 'surface': surface!.toJson(),
        if (motion != null) 'motion': motion!.toJson(),
      };
}

/// FAB block: Floating action button
class FabBlock extends Block {
  final String? label;
  final String? icon;
  final FabSize? size;
  final Map<String, dynamic>? action;

  const FabBlock({
    this.label,
    this.icon,
    this.size,
    this.action,
    super.emphasis,
    super.surface,
    super.motion,
  });

  @override
  String get type => 'fab';

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        if (label != null) 'label': label,
        if (icon != null) 'icon': icon,
        if (size != null) 'size': size!.toJson(),
        if (action != null) 'action': action,
        if (emphasis != null) 'emphasis': emphasis!.toJson(),
        if (surface != null) 'surface': surface!.toJson(),
        if (motion != null) 'motion': motion!.toJson(),
      };
}

/// TextField block: Text input field
class TextFieldBlock extends Block {
  final String? label;
  final String? placeholder;
  final String? value;
  final TextFieldVariant? variant;
  final String? leadingIcon;
  final String? trailingIcon;
  final bool? disabled;
  final bool? readOnly;
  final String? errorText;
  final String? helperText;
  final String? fieldId; // Used to identify field for action callbacks

  const TextFieldBlock({
    this.label,
    this.placeholder,
    this.value,
    this.variant,
    this.leadingIcon,
    this.trailingIcon,
    this.disabled,
    this.readOnly,
    this.errorText,
    this.helperText,
    this.fieldId,
    super.emphasis,
    super.surface,
    super.motion,
  });

  @override
  String get type => 'text_field';

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        if (label != null) 'label': label,
        if (placeholder != null) 'placeholder': placeholder,
        if (value != null) 'value': value,
        if (variant != null) 'variant': variant!.toJson(),
        if (leadingIcon != null) 'leadingIcon': leadingIcon,
        if (trailingIcon != null) 'trailingIcon': trailingIcon,
        if (disabled != null) 'disabled': disabled,
        if (readOnly != null) 'readOnly': readOnly,
        if (errorText != null) 'errorText': errorText,
        if (helperText != null) 'helperText': helperText,
        if (fieldId != null) 'fieldId': fieldId,
        if (emphasis != null) 'emphasis': emphasis!.toJson(),
        if (surface != null) 'surface': surface!.toJson(),
        if (motion != null) 'motion': motion!.toJson(),
      };
}

/// Slider block: Value range input
class SliderBlock extends Block {
  final double value;
  final double? min;
  final double? max;
  final int? divisions;
  final String? label;
  final bool? disabled;
  final String? fieldId;

  const SliderBlock({
    required this.value,
    this.min,
    this.max,
    this.divisions,
    this.label,
    this.disabled,
    this.fieldId,
    super.emphasis,
    super.surface,
    super.motion,
  });

  @override
  String get type => 'slider';

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'value': value,
        if (min != null) 'min': min,
        if (max != null) 'max': max,
        if (divisions != null) 'divisions': divisions,
        if (label != null) 'label': label,
        if (disabled != null) 'disabled': disabled,
        if (fieldId != null) 'fieldId': fieldId,
        if (emphasis != null) 'emphasis': emphasis!.toJson(),
        if (surface != null) 'surface': surface!.toJson(),
        if (motion != null) 'motion': motion!.toJson(),
      };
}

/// Badge block: Notification badge (wraps another block)
class BadgeBlock extends Block {
  final Block? child;
  final String? label; // Badge text, empty or null for dot badge
  final BadgePosition? position;

  const BadgeBlock({
    this.child,
    this.label,
    this.position,
    super.emphasis,
    super.surface,
    super.motion,
  });

  @override
  String get type => 'badge';

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        if (child != null) 'child': child!.toJson(),
        if (label != null) 'label': label,
        if (position != null) 'position': position!.toJson(),
        if (emphasis != null) 'emphasis': emphasis!.toJson(),
        if (surface != null) 'surface': surface!.toJson(),
        if (motion != null) 'motion': motion!.toJson(),
      };
}

/// Image block: Display an image
class ImageBlock extends Block {
  final String src; // URL or asset path
  final String? alt;
  final double? width;
  final double? height;
  final String? fit; // contain, cover, fill, etc.

  const ImageBlock({
    required this.src,
    this.alt,
    this.width,
    this.height,
    this.fit,
    super.emphasis,
    super.surface,
    super.motion,
  });

  @override
  String get type => 'image';

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'src': src,
        if (alt != null) 'alt': alt,
        if (width != null) 'width': width,
        if (height != null) 'height': height,
        if (fit != null) 'fit': fit,
        if (emphasis != null) 'emphasis': emphasis!.toJson(),
        if (surface != null) 'surface': surface!.toJson(),
        if (motion != null) 'motion': motion!.toJson(),
      };
}

/// Avatar block: User/entity avatar
class AvatarBlock extends Block {
  final String? imageUrl;
  final String? initials;
  final String? icon;
  final double? size;

  const AvatarBlock({
    this.imageUrl,
    this.initials,
    this.icon,
    this.size,
    super.emphasis,
    super.surface,
    super.motion,
  });

  @override
  String get type => 'avatar';

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (initials != null) 'initials': initials,
        if (icon != null) 'icon': icon,
        if (size != null) 'size': size,
        if (emphasis != null) 'emphasis': emphasis!.toJson(),
        if (surface != null) 'surface': surface!.toJson(),
        if (motion != null) 'motion': motion!.toJson(),
      };
}

/// Row block: Horizontal layout container
class RowBlock extends Block {
  final List<Block> children;
  final String? mainAxisAlignment; // start, end, center, spaceBetween, spaceAround, spaceEvenly
  final String? crossAxisAlignment; // start, end, center, stretch, baseline
  final double? spacing;

  const RowBlock({
    required this.children,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.spacing,
    super.emphasis,
    super.surface,
    super.motion,
  });

  @override
  String get type => 'row';

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'children': children.map((c) => c.toJson()).toList(),
        if (mainAxisAlignment != null) 'mainAxisAlignment': mainAxisAlignment,
        if (crossAxisAlignment != null) 'crossAxisAlignment': crossAxisAlignment,
        if (spacing != null) 'spacing': spacing,
        if (emphasis != null) 'emphasis': emphasis!.toJson(),
        if (surface != null) 'surface': surface!.toJson(),
        if (motion != null) 'motion': motion!.toJson(),
      };
}

/// Column block: Vertical layout container
class ColumnBlock extends Block {
  final List<Block> children;
  final String? mainAxisAlignment;
  final String? crossAxisAlignment;
  final double? spacing;

  const ColumnBlock({
    required this.children,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.spacing,
    super.emphasis,
    super.surface,
    super.motion,
  });

  @override
  String get type => 'column';

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'children': children.map((c) => c.toJson()).toList(),
        if (mainAxisAlignment != null) 'mainAxisAlignment': mainAxisAlignment,
        if (crossAxisAlignment != null) 'crossAxisAlignment': crossAxisAlignment,
        if (spacing != null) 'spacing': spacing,
        if (emphasis != null) 'emphasis': emphasis!.toJson(),
        if (surface != null) 'surface': surface!.toJson(),
        if (motion != null) 'motion': motion!.toJson(),
      };
}

/// Spacer block: Flexible space
class SpacerBlock extends Block {
  final double? size; // Fixed size, or null for flexible

  const SpacerBlock({
    this.size,
    super.emphasis,
    super.surface,
    super.motion,
  });

  @override
  String get type => 'spacer';

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        if (size != null) 'size': size,
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

      case 'checkbox':
        return CheckboxBlock(
          label: json['label'] as String?,
          checked: json['checked'] as bool? ?? false,
          disabled: json['disabled'] as bool?,
          action: _parseAction(json['action']),
          emphasis: emphasis,
          surface: surface,
          motion: motion,
        );

      case 'switch':
        return SwitchBlock(
          label: json['label'] as String?,
          selected: json['selected'] as bool? ?? false,
          disabled: json['disabled'] as bool?,
          action: _parseAction(json['action']),
          emphasis: emphasis,
          surface: surface,
          motion: motion,
        );

      case 'chip':
        final label = json['label'] as String?;
        if (label == null || label.isEmpty) return null;
        return ChipBlock(
          label: label,
          variant: ChipVariant.fromString(json['variant'] as String?),
          icon: json['icon'] as String?,
          selected: json['selected'] as bool?,
          disabled: json['disabled'] as bool?,
          action: _parseAction(json['action']),
          emphasis: emphasis,
          surface: surface,
          motion: motion,
        );

      case 'progress':
        return ProgressBlock(
          variant: ProgressVariant.fromString(json['variant'] as String?),
          value: (json['value'] as num?)?.toDouble(),
          label: json['label'] as String?,
          emphasis: emphasis,
          surface: surface,
          motion: motion,
        );

      case 'divider':
        return DividerBlock(
          inset: json['inset'] as bool?,
          label: json['label'] as String?,
          emphasis: emphasis,
          surface: surface,
          motion: motion,
        );

      case 'icon_button':
      case 'iconbutton':
        final icon = json['icon'] as String?;
        if (icon == null || icon.isEmpty) return null;
        return IconButtonBlock(
          icon: icon,
          tooltip: json['tooltip'] as String?,
          filled: json['filled'] as bool?,
          disabled: json['disabled'] as bool?,
          action: _parseAction(json['action']),
          emphasis: emphasis,
          surface: surface,
          motion: motion,
        );

      case 'fab':
        return FabBlock(
          label: json['label'] as String?,
          icon: json['icon'] as String?,
          size: FabSize.fromString(json['size'] as String?),
          action: _parseAction(json['action']),
          emphasis: emphasis,
          surface: surface,
          motion: motion,
        );

      case 'text_field':
      case 'textfield':
        return TextFieldBlock(
          label: json['label'] as String?,
          placeholder: json['placeholder'] as String?,
          value: json['value'] as String?,
          variant: TextFieldVariant.fromString(json['variant'] as String?),
          leadingIcon: json['leadingIcon'] as String?,
          trailingIcon: json['trailingIcon'] as String?,
          disabled: json['disabled'] as bool?,
          readOnly: json['readOnly'] as bool?,
          errorText: json['errorText'] as String?,
          helperText: json['helperText'] as String?,
          fieldId: json['fieldId'] as String?,
          emphasis: emphasis,
          surface: surface,
          motion: motion,
        );

      case 'slider':
        final value = (json['value'] as num?)?.toDouble();
        if (value == null) return null;
        return SliderBlock(
          value: value,
          min: (json['min'] as num?)?.toDouble(),
          max: (json['max'] as num?)?.toDouble(),
          divisions: json['divisions'] as int?,
          label: json['label'] as String?,
          disabled: json['disabled'] as bool?,
          fieldId: json['fieldId'] as String?,
          emphasis: emphasis,
          surface: surface,
          motion: motion,
        );

      case 'badge':
        Block? child;
        final childJson = json['child'];
        if (childJson is Map<String, dynamic>) {
          child = _parseBlock(childJson);
        }
        return BadgeBlock(
          child: child,
          label: json['label'] as String?,
          position: BadgePosition.fromString(json['position'] as String?),
          emphasis: emphasis,
          surface: surface,
          motion: motion,
        );

      case 'image':
        final src = json['src'] as String?;
        if (src == null || src.isEmpty) return null;
        return ImageBlock(
          src: src,
          alt: json['alt'] as String?,
          width: (json['width'] as num?)?.toDouble(),
          height: (json['height'] as num?)?.toDouble(),
          fit: json['fit'] as String?,
          emphasis: emphasis,
          surface: surface,
          motion: motion,
        );

      case 'avatar':
        return AvatarBlock(
          imageUrl: json['imageUrl'] as String?,
          initials: json['initials'] as String?,
          icon: json['icon'] as String?,
          size: (json['size'] as num?)?.toDouble(),
          emphasis: emphasis,
          surface: surface,
          motion: motion,
        );

      case 'row':
        final childrenJson = json['children'] as List<dynamic>?;
        if (childrenJson == null || childrenJson.isEmpty) return null;
        final children = <Block>[];
        for (final c in childrenJson) {
          if (c is Map<String, dynamic>) {
            final parsed = _parseBlock(c);
            if (parsed != null) children.add(parsed);
          }
        }
        if (children.isEmpty) return null;
        return RowBlock(
          children: children,
          mainAxisAlignment: json['mainAxisAlignment'] as String?,
          crossAxisAlignment: json['crossAxisAlignment'] as String?,
          spacing: (json['spacing'] as num?)?.toDouble(),
          emphasis: emphasis,
          surface: surface,
          motion: motion,
        );

      case 'column':
        final childrenJson = json['children'] as List<dynamic>?;
        if (childrenJson == null || childrenJson.isEmpty) return null;
        final children = <Block>[];
        for (final c in childrenJson) {
          if (c is Map<String, dynamic>) {
            final parsed = _parseBlock(c);
            if (parsed != null) children.add(parsed);
          }
        }
        if (children.isEmpty) return null;
        return ColumnBlock(
          children: children,
          mainAxisAlignment: json['mainAxisAlignment'] as String?,
          crossAxisAlignment: json['crossAxisAlignment'] as String?,
          spacing: (json['spacing'] as num?)?.toDouble(),
          emphasis: emphasis,
          surface: surface,
          motion: motion,
        );

      case 'spacer':
        return SpacerBlock(
          size: (json['size'] as num?)?.toDouble(),
          emphasis: emphasis,
          surface: surface,
          motion: motion,
        );

      default:
        // Unknown block type - skip
        return null;
    }
  }

  /// Parse an action object from JSON
  static Map<String, dynamic>? _parseAction(dynamic actionRaw) {
    if (actionRaw == null) return null;
    if (actionRaw is Map) {
      return actionRaw.cast<String, dynamic>();
    } else if (actionRaw is String) {
      return {'type': actionRaw};
    }
    return null;
  }
}
