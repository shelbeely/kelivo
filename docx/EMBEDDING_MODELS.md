# Understanding Embedding Model Type in Kelivo

## Overview

Kelivo supports two types of AI models: **Chat Models** and **Embedding Models**. This document explains what happens when you set a model's type to "embedding" and how it differs from chat models.

## What are Embedding Models?

Embedding models are specialized AI models that convert text into numerical vectors (embeddings). Unlike chat models that generate conversational responses, embedding models are typically used for:

- **Semantic search**: Finding similar text based on meaning
- **Text classification**: Categorizing content
- **Recommendation systems**: Suggesting related items
- **Clustering**: Grouping similar documents

Common examples include:
- Google's `text-embedding-004`
- OpenAI's `text-embedding-3-small` and `text-embedding-3-large`
- Models with "embed" or "embedding" in their names

## What Happens When You Set Type to "Embedding"?

When you configure a model with the "embedding" type in Kelivo, the following changes occur:

### 1. **UI Configuration Differences**

In the model edit dialog, embedding models have a **simplified interface**:

- ✅ **Model ID**: Still configurable (the API model identifier)
- ✅ **Model Name**: Still configurable (display name)
- ✅ **Type Selection**: Chat vs Embedding toggle
- ❌ **Input Modes**: Hidden (no text/image selection)
- ❌ **Output Modes**: Hidden (no text/image selection)
- ❌ **Abilities**: Hidden (no tool/reasoning capabilities)

**Why?** Embedding models don't have conversational capabilities, tool usage, or multimodal input/output like chat models do.

### 2. **Model Grouping**

Embedding models are automatically grouped separately in the UI:

```dart
// In model_grouping.dart
if (m.type == ModelType.embedding || id.contains('embedding') || id.contains('embed')) {
  return embeddingsLabel;  // Groups under "Embeddings" section
}
```

This makes it easy to distinguish between chat and embedding models in the provider's model list.

### 3. **Configuration Storage**

The model type is stored in the provider configuration:

```json
{
  "type": "embedding",
  "apiModelId": "text-embedding-004",
  "name": "Gemini Embedding",
  "input": ["text"],
  "output": ["text"],
  "abilities": []
}
```

### 4. **Automatic Detection**

For Google providers, Kelivo automatically detects embedding models:

```dart
// In model_provider.dart (GoogleProvider)
type: methods.contains('generateContent') ? ModelType.chat : ModelType.embedding
```

If a model supports `embedContent` but not `generateContent`, it's automatically classified as an embedding model.

## How to Configure an Embedding Model

### Via UI

1. Navigate to **Settings** → **Providers** → Select your provider
2. Click **Add Model** or edit an existing model
3. In the **Type** field, select **"Embedding"** instead of "Chat"
4. Configure the Model ID (e.g., `text-embedding-004`)
5. Set a display name (e.g., `Gemini Embedding`)
6. Save the configuration

### Via Configuration

The model override is stored in the provider config:

```dart
// settings_provider.dart
// {'<key>': {'apiModelId': String?, 'name': String?, 'type': 'chat'|'embedding', 
//            'input': ['text','image'], 'output': [...], 'abilities': ['tool','reasoning']}}
final Map<String, dynamic> modelOverrides;
```

## When to Use Embedding Type

Set a model to "embedding" type when:

- ✅ The model is designed for text embeddings (vector generation)
- ✅ The model name contains "embed" or "embedding"
- ✅ You want to distinguish it from chat models in the UI
- ✅ The model doesn't support conversational interactions

**Do NOT** set a model to "embedding" type if:
- ❌ It's a chat/conversational model (GPT, Gemini, Claude, etc.)
- ❌ It supports tool calling or reasoning
- ❌ It generates text responses to prompts

## Technical Details

### Model Type Enum

```dart
// lib/core/providers/model_provider.dart
enum ModelType { chat, embedding }
```

### Code Locations

The embedding model type affects these key areas:

1. **Model Provider** (`lib/core/providers/model_provider.dart`):
   - Defines the `ModelType` enum
   - Auto-detects embedding models in `GoogleProvider`

2. **Model Grouping** (`lib/utils/model_grouping.dart`):
   - Groups embedding models separately

3. **UI Components**:
   - `lib/desktop/model_edit_dialog.dart`: Desktop model editor
   - `lib/features/model/widgets/model_detail_sheet.dart`: Mobile model editor
   - Both hide input/output/abilities options for embedding models

4. **Settings Storage** (`lib/core/providers/settings_provider.dart`):
   - Stores type in `modelOverrides` configuration

### Model Info Class

```dart
class ModelInfo {
  final String id;
  final String displayName;
  final ModelType type;  // chat or embedding
  final List<Modality> input;
  final List<Modality> output;
  final List<ModelAbility> abilities;
}
```

## Common Use Cases

### Example 1: Google Gemini Embeddings

```dart
// Automatically detected as embedding model
ModelInfo(
  id: "text-embedding-004",
  displayName: "Gemini Text Embedding",
  type: ModelType.embedding,
  input: [Modality.text],
  output: [Modality.text],
  abilities: [],
)
```

### Example 2: OpenAI Embeddings

```dart
// User-configured as embedding model
{
  "apiModelId": "text-embedding-3-large",
  "name": "OpenAI Embedding Large",
  "type": "embedding",
  "input": ["text"],
  "output": ["text"],
  "abilities": []
}
```

## Summary

Setting a model's type to "embedding" in Kelivo:

1. **Simplifies the UI** by hiding irrelevant chat model options
2. **Groups models logically** in a separate "Embeddings" section
3. **Stores the configuration** for proper model classification
4. **Signals the intended use** of the model (embeddings vs conversation)

This distinction helps users organize their models and prevents confusion between conversational AI models and embedding/vectorization models.

## Related Files

- `lib/core/providers/model_provider.dart` - Model type definitions and provider logic
- `lib/utils/model_grouping.dart` - Model grouping by type
- `lib/desktop/model_edit_dialog.dart` - Desktop UI for model configuration
- `lib/features/model/widgets/model_detail_sheet.dart` - Mobile UI for model configuration
- `lib/core/providers/settings_provider.dart` - Configuration storage

## Questions?

For more information about model configuration in Kelivo, see:
- [README.md](../README.md) - Main project documentation
- [GitHub Issues](https://github.com/Chevey339/kelivo/issues) - Report issues or ask questions
