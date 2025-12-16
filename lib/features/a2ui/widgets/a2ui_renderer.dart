import 'package:flutter/material.dart';
import 'a2ui_widget_catalog.dart';
import 'dart:convert';

/// A2UI Renderer Widget
/// 
/// Renders A2UI (Agent-to-User Interface) specifications into Flutter widgets.
/// Accepts either a JSON string or a parsed Map specification.
class A2uiRenderer extends StatelessWidget {
  final dynamic specification;
  final VoidCallback? onError;

  const A2uiRenderer({
    super.key,
    required this.specification,
    this.onError,
  });

  @override
  Widget build(BuildContext context) {
    try {
      Map<String, dynamic> spec;
      
      if (specification is String) {
        // Parse JSON string
        spec = json.decode(specification) as Map<String, dynamic>;
      } else if (specification is Map<String, dynamic>) {
        spec = specification;
      } else {
        return _buildError('Invalid A2UI specification type');
      }

      // Handle root-level UI specification
      if (spec.containsKey('ui')) {
        spec = spec['ui'] as Map<String, dynamic>;
      }

      // Render the widget tree from the specification
      return A2uiWidgetCatalog.buildWidget(spec);
    } catch (e, stackTrace) {
      debugPrint('A2UI Rendering Error: $e');
      debugPrint('Stack trace: $stackTrace');
      onError?.call();
      return _buildError('Failed to render A2UI: ${e.toString()}');
    }
  }

  Widget _buildError(String message) {
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
                message,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A2UI Stream Renderer
/// 
/// Renders A2UI specifications that may be updated in real-time via a stream.
/// Useful for progressive rendering as agent generates UI updates.
class A2uiStreamRenderer extends StatefulWidget {
  final Stream<String> specificationStream;
  final VoidCallback? onError;

  const A2uiStreamRenderer({
    super.key,
    required this.specificationStream,
    this.onError,
  });

  @override
  State<A2uiStreamRenderer> createState() => _A2uiStreamRendererState();
}

class _A2uiStreamRendererState extends State<A2uiStreamRenderer> {
  Map<String, dynamic>? _currentSpec;
  String? _error;

  @override
  void initState() {
    super.initState();
    _listenToStream();
  }

  void _listenToStream() {
    widget.specificationStream.listen(
      (jsonLine) {
        try {
          final spec = json.decode(jsonLine) as Map<String, dynamic>;
          setState(() {
            _currentSpec = spec;
            _error = null;
          });
        } catch (e) {
          setState(() {
            _error = 'Failed to parse A2UI stream: ${e.toString()}';
          });
          widget.onError?.call();
        }
      },
      onError: (error) {
        setState(() {
          _error = 'Stream error: ${error.toString()}';
        });
        widget.onError?.call();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _buildError(_error!);
    }

    if (_currentSpec == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return A2uiRenderer(
      specification: _currentSpec,
      onError: widget.onError,
    );
  }

  Widget _buildError(String message) {
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
                message,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
