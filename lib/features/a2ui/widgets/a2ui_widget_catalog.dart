import 'package:flutter/material.dart';

/// A2UI Widget Catalog
/// 
/// Provides a catalog of safe, pre-approved UI components that can be
/// rendered from A2UI specifications. This ensures security by limiting
/// agents to a predefined set of trusted widgets.
class A2uiWidgetCatalog {
  /// Build a widget from an A2UI component specification
  static Widget buildWidget(Map<String, dynamic> spec) {
    final type = spec['type'] as String?;
    if (type == null) {
      return _buildError('Missing widget type');
    }

    switch (type) {
      case 'card':
        return _buildCard(spec);
      case 'button':
        return _buildButton(spec);
      case 'text':
        return _buildText(spec);
      case 'textfield':
        return _buildTextField(spec);
      case 'container':
        return _buildContainer(spec);
      case 'row':
        return _buildRow(spec);
      case 'column':
        return _buildColumn(spec);
      case 'divider':
        return _buildDivider(spec);
      case 'checkbox':
        return _buildCheckbox(spec);
      case 'switch':
        return _buildSwitch(spec);
      case 'slider':
        return _buildSlider(spec);
      default:
        return _buildError('Unknown widget type: $type');
    }
  }

  static Widget _buildCard(Map<String, dynamic> spec) {
    final children = (spec['children'] as List?)
        ?.map((child) => buildWidget(child as Map<String, dynamic>))
        .toList() ?? [];

    return Card(
      elevation: (spec['elevation'] as num?)?.toDouble() ?? 1.0,
      margin: _parseEdgeInsets(spec['margin']),
      child: Padding(
        padding: _parseEdgeInsets(spec['padding']) ?? const EdgeInsets.all(16.0),
        child: children.length == 1 
            ? children.first 
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
      ),
    );
  }

  static Widget _buildButton(Map<String, dynamic> spec) {
    final label = spec['label'] as String? ?? 'Button';
    final id = spec['id'] as String?;
    
    return Padding(
      padding: _parseEdgeInsets(spec['margin']) ?? EdgeInsets.zero,
      child: ElevatedButton(
        onPressed: () {
          // Button callbacks would be handled by the A2UI framework
          debugPrint('A2UI Button pressed: $id');
        },
        child: Text(label),
      ),
    );
  }

  static Widget _buildText(Map<String, dynamic> spec) {
    final text = spec['text'] as String? ?? '';
    final fontSize = (spec['fontSize'] as num?)?.toDouble();
    final bold = spec['bold'] as bool? ?? false;
    final color = _parseColor(spec['color']);

    return Padding(
      padding: _parseEdgeInsets(spec['margin']) ?? EdgeInsets.zero,
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          color: color,
        ),
      ),
    );
  }

  static Widget _buildTextField(Map<String, dynamic> spec) {
    final label = spec['label'] as String?;
    final hint = spec['hint'] as String?;
    final id = spec['id'] as String?;

    return Padding(
      padding: _parseEdgeInsets(spec['margin']) ?? const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        onChanged: (value) {
          // Text changes would be handled by the A2UI framework
          debugPrint('A2UI TextField changed: $id = $value');
        },
      ),
    );
  }

  static Widget _buildContainer(Map<String, dynamic> spec) {
    final children = (spec['children'] as List?)
        ?.map((child) => buildWidget(child as Map<String, dynamic>))
        .toList() ?? [];

    final child = children.length == 1 
        ? children.first 
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: children,
          );

    return Container(
      padding: _parseEdgeInsets(spec['padding']),
      margin: _parseEdgeInsets(spec['margin']),
      decoration: BoxDecoration(
        color: _parseColor(spec['backgroundColor']),
        border: spec['border'] != null 
            ? Border.all(
                color: _parseColor(spec['borderColor']) ?? Colors.grey,
                width: (spec['borderWidth'] as num?)?.toDouble() ?? 1.0,
              )
            : null,
        borderRadius: spec['borderRadius'] != null
            ? BorderRadius.circular((spec['borderRadius'] as num).toDouble())
            : null,
      ),
      child: child,
    );
  }

  static Widget _buildRow(Map<String, dynamic> spec) {
    final children = (spec['children'] as List?)
        ?.map((child) => buildWidget(child as Map<String, dynamic>))
        .toList() ?? [];

    return Row(
      mainAxisAlignment: _parseMainAxisAlignment(spec['mainAxisAlignment']),
      crossAxisAlignment: _parseCrossAxisAlignment(spec['crossAxisAlignment']),
      children: children,
    );
  }

  static Widget _buildColumn(Map<String, dynamic> spec) {
    final children = (spec['children'] as List?)
        ?.map((child) => buildWidget(child as Map<String, dynamic>))
        .toList() ?? [];

    return Column(
      mainAxisAlignment: _parseMainAxisAlignment(spec['mainAxisAlignment']),
      crossAxisAlignment: _parseCrossAxisAlignment(spec['crossAxisAlignment']),
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  static Widget _buildDivider(Map<String, dynamic> spec) {
    return Divider(
      color: _parseColor(spec['color']),
      thickness: (spec['thickness'] as num?)?.toDouble(),
      height: (spec['height'] as num?)?.toDouble(),
    );
  }

  static Widget _buildCheckbox(Map<String, dynamic> spec) {
    final label = spec['label'] as String?;
    final value = spec['value'] as bool? ?? false;
    final id = spec['id'] as String?;

    return CheckboxListTile(
      title: label != null ? Text(label) : null,
      value: value,
      onChanged: (newValue) {
        debugPrint('A2UI Checkbox changed: $id = $newValue');
      },
    );
  }

  static Widget _buildSwitch(Map<String, dynamic> spec) {
    final label = spec['label'] as String?;
    final value = spec['value'] as bool? ?? false;
    final id = spec['id'] as String?;

    return SwitchListTile(
      title: label != null ? Text(label) : null,
      value: value,
      onChanged: (newValue) {
        debugPrint('A2UI Switch changed: $id = $newValue');
      },
    );
  }

  static Widget _buildSlider(Map<String, dynamic> spec) {
    final value = (spec['value'] as num?)?.toDouble() ?? 0.5;
    final min = (spec['min'] as num?)?.toDouble() ?? 0.0;
    final max = (spec['max'] as num?)?.toDouble() ?? 1.0;
    final id = spec['id'] as String?;

    // Log when value is clamped for debugging
    if (value < min || value > max) {
      debugPrint('A2UI Slider: value $value clamped to range [$min, $max] for $id');
    }

    return Slider(
      value: value.clamp(min, max),
      min: min,
      max: max,
      onChanged: (newValue) {
        debugPrint('A2UI Slider changed: $id = $newValue');
      },
    );
  }

  static Widget _buildError(String message) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'A2UI Error: $message',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods for parsing common properties

  static EdgeInsets? _parseEdgeInsets(dynamic value) {
    if (value == null) return null;
    if (value is num) {
      return EdgeInsets.all(value.toDouble());
    }
    if (value is Map) {
      return EdgeInsets.only(
        left: (value['left'] as num?)?.toDouble() ?? 0.0,
        top: (value['top'] as num?)?.toDouble() ?? 0.0,
        right: (value['right'] as num?)?.toDouble() ?? 0.0,
        bottom: (value['bottom'] as num?)?.toDouble() ?? 0.0,
      );
    }
    return null;
  }

  static Color? _parseColor(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      // Parse hex color strings like "#FF0000" (RGB) or "#AARRGGBB" (ARGB)
      try {
        String colorStr = value.replaceAll('#', '');
        // Only add alpha prefix if the string is RGB format (6 chars)
        // ARGB format (8 chars) already includes alpha
        if (colorStr.length == 6) {
          colorStr = 'FF$colorStr'; // Add full opacity
        } else if (colorStr.length != 8) {
          // Invalid length, return null
          return null;
        }
        return Color(int.parse(colorStr, radix: 16));
      } catch (_) {
        return null;
      }
    }
    if (value is int) {
      return Color(value);
    }
    return null;
  }

  static MainAxisAlignment _parseMainAxisAlignment(dynamic value) {
    if (value == null) return MainAxisAlignment.start;
    switch (value) {
      case 'start':
        return MainAxisAlignment.start;
      case 'center':
        return MainAxisAlignment.center;
      case 'end':
        return MainAxisAlignment.end;
      case 'spaceBetween':
        return MainAxisAlignment.spaceBetween;
      case 'spaceAround':
        return MainAxisAlignment.spaceAround;
      case 'spaceEvenly':
        return MainAxisAlignment.spaceEvenly;
      default:
        return MainAxisAlignment.start;
    }
  }

  static CrossAxisAlignment _parseCrossAxisAlignment(dynamic value) {
    if (value == null) return CrossAxisAlignment.start;
    switch (value) {
      case 'start':
        return CrossAxisAlignment.start;
      case 'center':
        return CrossAxisAlignment.center;
      case 'end':
        return CrossAxisAlignment.end;
      case 'stretch':
        return CrossAxisAlignment.stretch;
      default:
        return CrossAxisAlignment.start;
    }
  }
}
