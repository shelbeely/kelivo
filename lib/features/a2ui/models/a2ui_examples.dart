/// A2UI Example Configurations
/// 
/// Provides example A2UI specifications for demonstration and testing purposes.
class A2uiExamples {
  /// Example: Simple card with text
  static const String simpleCard = '''
{
  "type": "card",
  "padding": 16,
  "children": [
    {
      "type": "text",
      "text": "Hello from A2UI!",
      "fontSize": 18,
      "bold": true
    },
    {
      "type": "text",
      "text": "This is a dynamically generated interface."
    }
  ]
}
''';

  /// Example: Form with input fields
  static const String formExample = '''
{
  "type": "card",
  "padding": 16,
  "children": [
    {
      "type": "text",
      "text": "Booking Form",
      "fontSize": 20,
      "bold": true,
      "margin": {"bottom": 16}
    },
    {
      "type": "textfield",
      "id": "name",
      "label": "Name",
      "hint": "Enter your name"
    },
    {
      "type": "textfield",
      "id": "email",
      "label": "Email",
      "hint": "Enter your email"
    },
    {
      "type": "divider",
      "margin": {"top": 16, "bottom": 16}
    },
    {
      "type": "row",
      "mainAxisAlignment": "end",
      "children": [
        {
          "type": "button",
          "id": "submit",
          "label": "Submit"
        }
      ]
    }
  ]
}
''';

  /// Example: Settings panel with switches
  static const String settingsExample = '''
{
  "type": "card",
  "padding": 16,
  "children": [
    {
      "type": "text",
      "text": "Settings",
      "fontSize": 20,
      "bold": true,
      "margin": {"bottom": 8}
    },
    {
      "type": "switch",
      "id": "notifications",
      "label": "Enable Notifications",
      "value": true
    },
    {
      "type": "switch",
      "id": "darkMode",
      "label": "Dark Mode",
      "value": false
    },
    {
      "type": "divider",
      "margin": {"top": 8, "bottom": 8}
    },
    {
      "type": "text",
      "text": "Volume",
      "fontSize": 14,
      "bold": true
    },
    {
      "type": "slider",
      "id": "volume",
      "value": 0.7,
      "min": 0.0,
      "max": 1.0
    }
  ]
}
''';

  /// Example: Multi-column layout
  static const String layoutExample = '''
{
  "type": "card",
  "padding": 16,
  "children": [
    {
      "type": "text",
      "text": "Feature Comparison",
      "fontSize": 20,
      "bold": true,
      "margin": {"bottom": 16}
    },
    {
      "type": "row",
      "mainAxisAlignment": "spaceBetween",
      "children": [
        {
          "type": "column",
          "children": [
            {
              "type": "text",
              "text": "Basic",
              "bold": true
            },
            {
              "type": "checkbox",
              "id": "feature1",
              "label": "Feature 1",
              "value": true
            },
            {
              "type": "checkbox",
              "id": "feature2",
              "label": "Feature 2",
              "value": false
            }
          ]
        },
        {
          "type": "column",
          "children": [
            {
              "type": "text",
              "text": "Premium",
              "bold": true
            },
            {
              "type": "checkbox",
              "id": "feature3",
              "label": "Feature 3",
              "value": true
            },
            {
              "type": "checkbox",
              "id": "feature4",
              "label": "Feature 4",
              "value": true
            }
          ]
        }
      ]
    }
  ]
}
''';

  /// Get all examples as a map
  static Map<String, String> get allExamples => {
    'Simple Card': simpleCard,
    'Form Example': formExample,
    'Settings Panel': settingsExample,
    'Layout Example': layoutExample,
  };
}
