import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Kelivo/features/a2ui/widgets/a2ui_renderer.dart';
import 'package:Kelivo/features/a2ui/widgets/a2ui_widget_catalog.dart';
import 'package:Kelivo/features/a2ui/models/a2ui_examples.dart';

void main() {
  group('A2UI Widget Catalog Tests', () {
    testWidgets('Renders simple card correctly', (WidgetTester tester) async {
      final spec = {
        'type': 'card',
        'padding': 16.0,
        'children': [
          {
            'type': 'text',
            'text': 'Test Card',
            'fontSize': 18.0,
            'bold': true,
          }
        ]
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: A2uiWidgetCatalog.buildWidget(spec),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
      expect(find.text('Test Card'), findsOneWidget);
    });

    testWidgets('Renders button correctly', (WidgetTester tester) async {
      final spec = {
        'type': 'button',
        'id': 'test_button',
        'label': 'Click Me',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: A2uiWidgetCatalog.buildWidget(spec),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Click Me'), findsOneWidget);
    });

    testWidgets('Renders text field correctly', (WidgetTester tester) async {
      final spec = {
        'type': 'textfield',
        'id': 'test_input',
        'label': 'Name',
        'hint': 'Enter your name',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: A2uiWidgetCatalog.buildWidget(spec),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
    });

    testWidgets('Renders row with multiple children', (WidgetTester tester) async {
      final spec = {
        'type': 'row',
        'mainAxisAlignment': 'spaceBetween',
        'children': [
          {'type': 'text', 'text': 'Left'},
          {'type': 'text', 'text': 'Right'},
        ]
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: A2uiWidgetCatalog.buildWidget(spec),
          ),
        ),
      );

      expect(find.byType(Row), findsOneWidget);
      expect(find.text('Left'), findsOneWidget);
      expect(find.text('Right'), findsOneWidget);
    });

    testWidgets('Handles unknown widget type', (WidgetTester tester) async {
      final spec = {
        'type': 'unknown_widget',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: A2uiWidgetCatalog.buildWidget(spec),
          ),
        ),
      );

      expect(find.textContaining('Unknown widget type'), findsOneWidget);
    });
  });

  group('A2UI Renderer Tests', () {
    testWidgets('Renders from JSON string', (WidgetTester tester) async {
      const jsonSpec = '''
      {
        "type": "card",
        "children": [
          {
            "type": "text",
            "text": "Hello A2UI"
          }
        ]
      }
      ''';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: A2uiRenderer(
              specification: jsonSpec,
            ),
          ),
        ),
      );

      expect(find.text('Hello A2UI'), findsOneWidget);
    });

    testWidgets('Renders from Map', (WidgetTester tester) async {
      final spec = {
        'type': 'text',
        'text': 'Test from Map',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: A2uiRenderer(
              specification: spec,
            ),
          ),
        ),
      );

      expect(find.text('Test from Map'), findsOneWidget);
    });

    testWidgets('Handles invalid JSON gracefully', (WidgetTester tester) async {
      const invalidJson = 'not valid json';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: A2uiRenderer(
              specification: invalidJson,
            ),
          ),
        ),
      );

      expect(find.textContaining('Failed to render A2UI'), findsOneWidget);
    });
  });

  group('A2UI Examples Tests', () {
    testWidgets('Simple card example renders', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: A2uiRenderer(
              specification: A2uiExamples.simpleCard,
            ),
          ),
        ),
      );

      expect(find.text('Hello from A2UI!'), findsOneWidget);
    });

    testWidgets('Form example renders', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: A2uiRenderer(
              specification: A2uiExamples.formExample,
            ),
          ),
        ),
      );

      expect(find.text('Booking Form'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2)); // Name and Email fields
    });

    testWidgets('Settings example renders', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: A2uiRenderer(
              specification: A2uiExamples.settingsExample,
            ),
          ),
        ),
      );

      expect(find.text('Settings'), findsOneWidget);
      expect(find.byType(SwitchListTile), findsNWidgets(2));
      expect(find.byType(Slider), findsOneWidget);
    });
  });
}
