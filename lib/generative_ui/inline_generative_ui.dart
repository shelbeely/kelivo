// Inline Generative UI Widget
//
// This widget renders generative UI blocks inline within chat messages.
// It detects JSON blocks with "screenId" and "blocks" and renders them
// as interactive M3 components.
//
// Integration with chat:
// - Parses assistant message content for generative UI JSON
// - Renders blocks inline with the message
// - Sends user interactions back through onAction callback
//
// See docs/generative-ui-notes.md for full documentation.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'schema.dart';
import 'renderer.dart';

/// Detects if content contains a generative UI JSON block
class GenerativeUIDetector {
  /// Pattern to match JSON that looks like a generative UI screen
  static final RegExp _screenPattern = RegExp(
    r'\{[^{}]*"screenId"\s*:\s*"[^"]+"\s*,\s*[^{}]*"blocks"\s*:\s*\[',
    multiLine: true,
  );

  /// Check if content contains generative UI
  static bool containsGenerativeUI(String content) {
    return _screenPattern.hasMatch(content);
  }

  /// Extract generative UI JSON from content
  /// Returns a tuple of (textBefore, Screen?, textAfter)
  static GenerativeUIParseResult parse(String content) {
    // Try to find a JSON block that looks like a generative UI screen
    final jsonStart = content.indexOf('{');
    if (jsonStart == -1) {
      return GenerativeUIParseResult(text: content);
    }

    // Try to extract balanced JSON
    int depth = 0;
    int jsonEnd = -1;
    bool inString = false;
    bool escaped = false;

    for (int i = jsonStart; i < content.length; i++) {
      final char = content[i];

      if (escaped) {
        escaped = false;
        continue;
      }

      if (char == '\\') {
        escaped = true;
        continue;
      }

      if (char == '"') {
        inString = !inString;
        continue;
      }

      if (inString) continue;

      if (char == '{') {
        depth++;
      } else if (char == '}') {
        depth--;
        if (depth == 0) {
          jsonEnd = i;
          break;
        }
      }
    }

    if (jsonEnd == -1) {
      return GenerativeUIParseResult(text: content);
    }

    final jsonStr = content.substring(jsonStart, jsonEnd + 1);

    // Try to parse as generative UI
    try {
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;

      // Check if it's a valid screen structure
      if (!json.containsKey('screenId') || !json.containsKey('blocks')) {
        return GenerativeUIParseResult(text: content);
      }

      final screen = ScreenParser.parseMap(json);
      final textBefore = content.substring(0, jsonStart).trim();
      final textAfter = content.substring(jsonEnd + 1).trim();

      return GenerativeUIParseResult(
        text: textBefore.isNotEmpty ? textBefore : null,
        screen: screen,
        textAfter: textAfter.isNotEmpty ? textAfter : null,
      );
    } catch (e) {
      // Not valid generative UI JSON
      return GenerativeUIParseResult(text: content);
    }
  }
}

/// Result of parsing content for generative UI
class GenerativeUIParseResult {
  final String? text;
  final Screen? screen;
  final String? textAfter;

  const GenerativeUIParseResult({
    this.text,
    this.screen,
    this.textAfter,
  });

  bool get hasScreen => screen != null;
}

/// Renders inline generative UI within a chat message
class InlineGenerativeUI extends StatelessWidget {
  final Screen screen;
  final void Function(Map<String, dynamic> action)? onAction;
  final bool reduceMotion;

  const InlineGenerativeUI({
    super.key,
    required this.screen,
    this.onAction,
    this.reduceMotion = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Inline version: no SafeArea, no bottom button bar, compact styling
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? cs.surfaceContainerHighest.withOpacity(0.5)
            : cs.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.outlineVariant.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Optional label
          Row(
            children: [
              Icon(
                Icons.widgets_outlined,
                size: 14,
                color: cs.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Interactive UI',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: cs.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Render blocks
          for (int i = 0; i < screen.blocks.length; i++) ...[
            _InlineBlockRenderer(
              block: screen.blocks[i],
              screenMotion:
                  reduceMotion ? MotionScheme.reduced : screen.motionScheme,
              onAction: onAction,
            ),
            if (i < screen.blocks.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

/// Renders a single block inline (simplified version without entrance animations)
class _InlineBlockRenderer extends StatelessWidget {
  final Block block;
  final MotionScheme? screenMotion;
  final void Function(Map<String, dynamic> action)? onAction;

  const _InlineBlockRenderer({
    required this.block,
    this.screenMotion,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    // Reuse the block renderers from the main renderer
    // But skip edge-hugging buttons (render them inline instead)
    Widget child;

    switch (block) {
      case HeroBlock():
        child = _buildHero(context, block);
      case CardBlock():
        child = _buildCard(context, block);
      case TextBlock():
        child = _buildText(context, block);
      case ListBlock():
        child = _buildList(context, block);
      case ButtonBlock():
        child = _buildButton(context, block);
      case CheckboxBlock():
        child = _buildCheckbox(context, block);
      case SwitchBlock():
        child = _buildSwitch(context, block);
      case ChipBlock():
        child = _buildChip(context, block);
      case ProgressBlock():
        child = _buildProgress(context, block);
      case DividerBlock():
        child = _buildDivider(context, block);
      case IconButtonBlock():
        child = _buildIconButton(context, block);
      case FabBlock():
        child = _buildFab(context, block);
      case TextFieldBlock():
        child = _buildTextField(context, block);
      case SliderBlock():
        child = _buildSlider(context, block);
      case BadgeBlock():
        child = _buildBadge(context, block);
      case ImageBlock():
        child = _buildImage(context, block);
      case AvatarBlock():
        child = _buildAvatar(context, block);
      case RowBlock():
        child = _buildRow(context, block);
      case ColumnBlock():
        child = _buildColumn(context, block);
      case SpacerBlock():
        child = SizedBox(height: block.size ?? 8);
    }

    return child;
  }

  Widget _buildHero(BuildContext context, HeroBlock block) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (block.icon != null) ...[
            Icon(
              mapIconName(block.icon!),
              size: 32,
              color: cs.onPrimaryContainer,
            ),
            const SizedBox(height: 8),
          ],
          Text(
            block.headline,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: cs.onPrimaryContainer,
                ),
          ),
          if (block.subhead != null) ...[
            const SizedBox(height: 4),
            Text(
              block.subhead!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onPrimaryContainer.withOpacity(0.8),
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, CardBlock block) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (block.headline != null) ...[
              Text(
                block.headline!,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
            ],
            if (block.body != null)
              for (final b in block.body!)
                _InlineBlockRenderer(
                  block: b,
                  screenMotion: screenMotion,
                  onAction: onAction,
                ),
            if (block.actions != null && block.actions!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final a in block.actions!)
                    _InlineBlockRenderer(
                      block: a,
                      screenMotion: screenMotion,
                      onAction: onAction,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildText(BuildContext context, TextBlock block) {
    TextStyle? style;
    switch (block.variant) {
      case TextVariant.headline:
        style = Theme.of(context).textTheme.headlineSmall;
        break;
      case TextVariant.title:
        style = Theme.of(context).textTheme.titleMedium;
        break;
      case TextVariant.label:
        style = Theme.of(context).textTheme.labelMedium;
        break;
      case TextVariant.body:
      case null:
        style = Theme.of(context).textTheme.bodyMedium;
    }
    return Text(block.text, style: style);
  }

  Widget _buildList(BuildContext context, ListBlock block) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in block.items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• '),
                Expanded(child: Text(item)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildButton(BuildContext context, ButtonBlock block) {
    final cs = Theme.of(context).colorScheme;

    void handlePress() {
      onAction?.call(block.action);
    }

    switch (block.role) {
      case ButtonRole.primaryAction:
        return FilledButton(
          onPressed: handlePress,
          child: Text(block.label),
        );
      case ButtonRole.secondaryAction:
        return OutlinedButton(
          onPressed: handlePress,
          child: Text(block.label),
        );
      case ButtonRole.destructive:
        return FilledButton(
          onPressed: handlePress,
          style: FilledButton.styleFrom(
            backgroundColor: cs.error,
            foregroundColor: cs.onError,
          ),
          child: Text(block.label),
        );
      case null:
        return TextButton(
          onPressed: handlePress,
          child: Text(block.label),
        );
    }
  }

  Widget _buildCheckbox(BuildContext context, CheckboxBlock block) {
    return _InlineCheckbox(
      block: block,
      onAction: onAction,
    );
  }

  Widget _buildSwitch(BuildContext context, SwitchBlock block) {
    return _InlineSwitch(
      block: block,
      onAction: onAction,
    );
  }

  Widget _buildChip(BuildContext context, ChipBlock block) {
    return _InlineChip(
      block: block,
      onAction: onAction,
    );
  }

  Widget _buildProgress(BuildContext context, ProgressBlock block) {
    if (block.variant == ProgressVariant.circular) {
      return block.value != null
          ? CircularProgressIndicator(value: block.value)
          : const CircularProgressIndicator();
    }
    return block.value != null
        ? LinearProgressIndicator(value: block.value)
        : const LinearProgressIndicator();
  }

  Widget _buildDivider(BuildContext context, DividerBlock block) {
    if (block.label != null) {
      return Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              block.label!,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
          const Expanded(child: Divider()),
        ],
      );
    }
    return const Divider();
  }

  Widget _buildIconButton(BuildContext context, IconButtonBlock block) {
    return IconButton(
      icon: Icon(mapIconName(block.icon)),
      onPressed: block.disabled == true
          ? null
          : () => onAction?.call(block.action ?? {'type': 'icon_button_pressed', 'icon': block.icon}),
      tooltip: block.tooltip,
    );
  }

  Widget _buildFab(BuildContext context, FabBlock block) {
    final icon = block.icon != null ? Icon(mapIconName(block.icon!)) : null;
    
    if (block.size == FabSize.extended && block.label != null) {
      return FloatingActionButton.extended(
        onPressed: () => onAction?.call(block.action ?? {'type': 'fab_pressed'}),
        icon: icon,
        label: Text(block.label!),
      );
    }
    
    return FloatingActionButton.small(
      onPressed: () => onAction?.call(block.action ?? {'type': 'fab_pressed'}),
      child: icon,
    );
  }

  Widget _buildTextField(BuildContext context, TextFieldBlock block) {
    return _InlineTextField(
      block: block,
      onAction: onAction,
    );
  }

  Widget _buildSlider(BuildContext context, SliderBlock block) {
    return _InlineSlider(
      block: block,
      onAction: onAction,
    );
  }

  Widget _buildBadge(BuildContext context, BadgeBlock block) {
    Widget child = block.child != null
        ? _InlineBlockRenderer(
            block: block.child!,
            screenMotion: screenMotion,
            onAction: onAction,
          )
        : const SizedBox.shrink();

    return Badge(
      label: block.label != null ? Text(block.label!) : null,
      child: child,
    );
  }

  Widget _buildImage(BuildContext context, ImageBlock block) {
    if (block.src.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          block.src,
          width: block.width,
          height: block.height,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: block.width,
            height: block.height ?? 80,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const Icon(Icons.broken_image),
          ),
        ),
      );
    }
    return Container(
      width: block.width,
      height: block.height ?? 80,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.image),
    );
  }

  Widget _buildAvatar(BuildContext context, AvatarBlock block) {
    final size = block.size ?? 40;
    final cs = Theme.of(context).colorScheme;

    if (block.imageUrl != null) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: NetworkImage(block.imageUrl!),
      );
    }

    if (block.initials != null) {
      return CircleAvatar(
        radius: size / 2,
        child: Text(block.initials!),
      );
    }

    return CircleAvatar(
      radius: size / 2,
      child: Icon(
        block.icon != null ? mapIconName(block.icon!) : Icons.person,
        size: size * 0.5,
      ),
    );
  }

  Widget _buildRow(BuildContext context, RowBlock block) {
    return Row(
      children: [
        for (int i = 0; i < block.children.length; i++) ...[
          _InlineBlockRenderer(
            block: block.children[i],
            screenMotion: screenMotion,
            onAction: onAction,
          ),
          if (i < block.children.length - 1)
            SizedBox(width: block.spacing ?? 8),
        ],
      ],
    );
  }

  Widget _buildColumn(BuildContext context, ColumnBlock block) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < block.children.length; i++) ...[
          _InlineBlockRenderer(
            block: block.children[i],
            screenMotion: screenMotion,
            onAction: onAction,
          ),
          if (i < block.children.length - 1)
            SizedBox(height: block.spacing ?? 8),
        ],
      ],
    );
  }
}

// Stateful widgets for interactive controls

class _InlineCheckbox extends StatefulWidget {
  final CheckboxBlock block;
  final void Function(Map<String, dynamic> action)? onAction;

  const _InlineCheckbox({required this.block, this.onAction});

  @override
  State<_InlineCheckbox> createState() => _InlineCheckboxState();
}

class _InlineCheckboxState extends State<_InlineCheckbox> {
  late bool _checked;

  @override
  void initState() {
    super.initState();
    _checked = widget.block.checked;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.block.label != null) {
      return CheckboxListTile(
        value: _checked,
        title: Text(widget.block.label!),
        dense: true,
        onChanged: widget.block.disabled == true
            ? null
            : (v) {
                setState(() => _checked = v ?? false);
                widget.onAction?.call({
                  'type': 'checkbox_change',
                  'checked': _checked,
                  ...?widget.block.action,
                });
              },
      );
    }
    return Checkbox(
      value: _checked,
      onChanged: widget.block.disabled == true
          ? null
          : (v) {
              setState(() => _checked = v ?? false);
              widget.onAction?.call({
                'type': 'checkbox_change',
                'checked': _checked,
                ...?widget.block.action,
              });
            },
    );
  }
}

class _InlineSwitch extends StatefulWidget {
  final SwitchBlock block;
  final void Function(Map<String, dynamic> action)? onAction;

  const _InlineSwitch({required this.block, this.onAction});

  @override
  State<_InlineSwitch> createState() => _InlineSwitchState();
}

class _InlineSwitchState extends State<_InlineSwitch> {
  late bool _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.block.selected;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.block.label != null) {
      return SwitchListTile(
        value: _selected,
        title: Text(widget.block.label!),
        dense: true,
        onChanged: widget.block.disabled == true
            ? null
            : (v) {
                setState(() => _selected = v);
                widget.onAction?.call({
                  'type': 'switch_change',
                  'selected': _selected,
                  ...?widget.block.action,
                });
              },
      );
    }
    return Switch(
      value: _selected,
      onChanged: widget.block.disabled == true
          ? null
          : (v) {
              setState(() => _selected = v);
              widget.onAction?.call({
                'type': 'switch_change',
                'selected': _selected,
                ...?widget.block.action,
              });
            },
    );
  }
}

class _InlineChip extends StatefulWidget {
  final ChipBlock block;
  final void Function(Map<String, dynamic> action)? onAction;

  const _InlineChip({required this.block, this.onAction});

  @override
  State<_InlineChip> createState() => _InlineChipState();
}

class _InlineChipState extends State<_InlineChip> {
  late bool _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.block.selected ?? false;
  }

  @override
  Widget build(BuildContext context) {
    Widget? avatar;
    if (widget.block.icon != null) {
      avatar = Icon(mapIconName(widget.block.icon!), size: 18);
    }

    if (widget.block.variant == ChipVariant.filter) {
      return FilterChip(
        label: Text(widget.block.label),
        selected: _selected,
        avatar: avatar,
        onSelected: widget.block.disabled == true
            ? null
            : (v) {
                setState(() => _selected = v);
                widget.onAction?.call({
                  'type': 'chip_select',
                  'selected': _selected,
                  'label': widget.block.label,
                  ...?widget.block.action,
                });
              },
      );
    }

    return ActionChip(
      label: Text(widget.block.label),
      avatar: avatar,
      onPressed: widget.block.disabled == true
          ? null
          : () {
              widget.onAction?.call({
                'type': 'chip_pressed',
                'label': widget.block.label,
                ...?widget.block.action,
              });
            },
    );
  }
}

class _InlineTextField extends StatefulWidget {
  final TextFieldBlock block;
  final void Function(Map<String, dynamic> action)? onAction;

  const _InlineTextField({required this.block, this.onAction});

  @override
  State<_InlineTextField> createState() => _InlineTextFieldState();
}

class _InlineTextFieldState extends State<_InlineTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.block.value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: widget.block.label,
        hintText: widget.block.placeholder,
        errorText: widget.block.errorText,
        helperText: widget.block.helperText,
        border: widget.block.variant == TextFieldVariant.outlined
            ? const OutlineInputBorder()
            : null,
        filled: widget.block.variant == TextFieldVariant.filled,
      ),
      enabled: widget.block.disabled != true,
      readOnly: widget.block.readOnly == true,
      onSubmitted: (v) {
        widget.onAction?.call({
          'type': 'text_field_submit',
          'value': v,
          if (widget.block.fieldId != null) 'fieldId': widget.block.fieldId,
        });
      },
    );
  }
}

class _InlineSlider extends StatefulWidget {
  final SliderBlock block;
  final void Function(Map<String, dynamic> action)? onAction;

  const _InlineSlider({required this.block, this.onAction});

  @override
  State<_InlineSlider> createState() => _InlineSliderState();
}

class _InlineSliderState extends State<_InlineSlider> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.block.value;
  }

  @override
  Widget build(BuildContext context) {
    final slider = Slider(
      value: _value,
      min: widget.block.min ?? 0,
      max: widget.block.max ?? 1,
      divisions: widget.block.divisions,
      label: widget.block.label ?? _value.toStringAsFixed(2),
      onChanged: widget.block.disabled == true
          ? null
          : (v) => setState(() => _value = v),
      onChangeEnd: widget.block.disabled == true
          ? null
          : (v) {
              widget.onAction?.call({
                'type': 'slider_change',
                'value': v,
                if (widget.block.fieldId != null)
                  'fieldId': widget.block.fieldId,
              });
            },
    );

    if (widget.block.label != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.block.label!,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          slider,
        ],
      );
    }

    return slider;
  }
}
