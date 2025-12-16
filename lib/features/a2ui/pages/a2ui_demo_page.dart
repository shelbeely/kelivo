import 'package:flutter/material.dart';
import '../widgets/a2ui_renderer.dart';
import '../models/a2ui_examples.dart';

/// A2UI Demo Page
/// 
/// Demonstrates the A2UI rendering capabilities with various examples
class A2uiDemoPage extends StatefulWidget {
  const A2uiDemoPage({super.key});

  @override
  State<A2uiDemoPage> createState() => _A2uiDemoPageState();
}

class _A2uiDemoPageState extends State<A2uiDemoPage> {
  String _selectedExample = 'Simple Card';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('A2UI Demo'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Example selector
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Example:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: A2uiExamples.allExamples.keys.map((exampleName) {
                    final isSelected = _selectedExample == exampleName;
                    return ChoiceChip(
                      label: Text(exampleName),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedExample = exampleName;
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Rendered A2UI
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Rendered UI:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  A2uiRenderer(
                    specification: A2uiExamples.allExamples[_selectedExample]!,
                    onError: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Error rendering A2UI'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  ExpansionTile(
                    title: const Text('View JSON Specification'),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SelectableText(
                            A2uiExamples.allExamples[_selectedExample]!,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
