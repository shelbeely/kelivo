---
title: Embedding Models
date: 2025-01-24 09:38:00
---

# Embedding Models

## Overview

Kelivo supports two types of AI models: **Chat Models** and **Embedding Models**. This guide explains what embedding models are and how to configure them.

## What are Embedding Models?

Embedding models are specialized AI models that convert text into numerical vectors (embeddings). Unlike chat models that generate conversational responses, embedding models are used for:

- **Semantic search**: Finding similar text based on meaning
- **Text classification**: Categorizing content
- **Recommendation systems**: Suggesting related items
- **Clustering**: Grouping similar documents

### Examples

Common embedding models include:
- Google: `text-embedding-004`, `text-embedding-005`
- OpenAI: `text-embedding-3-small`, `text-embedding-3-large`, `text-embedding-ada-002`
- Models with "embed" or "embedding" in their names

## Differences from Chat Models

| Feature | Chat Models | Embedding Models |
|---------|-------------|------------------|
| **Purpose** | Generate conversational responses | Convert text to vectors |
| **Input/Output** | Text/images → text/images | Text → numerical vectors |
| **Tool Calling** | ✅ Supported | ❌ Not supported |
| **Multimodal** | ✅ Often supported | ❌ Text only |
| **Use Cases** | Conversations, Q&A, generation | Search, classification, similarity |

## Configuring Embedding Models

### Automatic Detection

For **Google** providers, Kelivo automatically detects embedding models based on their API capabilities:
- Models with `embedContent` method → Embedding model
- Models with `generateContent` method → Chat model

### Manual Configuration

1. Navigate to **Settings** → **Providers** → Select your provider
2. Click **Add Model** or edit an existing model
3. Configure the following:
   - **Model ID**: The API identifier (e.g., `text-embedding-004`)
   - **Display Name**: Human-readable name (e.g., `Gemini Embedding`)
   - **Type**: Select **"Embedding"** instead of "Chat"
4. Save the configuration

### UI Simplification

When you set a model type to "Embedding", the configuration interface simplifies:

**Visible Options:**
- ✅ Model ID
- ✅ Display Name
- ✅ Type selection (Chat/Embedding)
- ✅ Custom headers (Advanced)
- ✅ Custom body parameters (Advanced)

**Hidden Options:**
- ❌ Input modes (text/image)
- ❌ Output modes (text/image)
- ❌ Abilities (tool calling/reasoning)

These options are hidden because embedding models don't support conversational features, multimodal input/output, or tool calling.

## Model Grouping

Embedding models are automatically grouped separately in the model selection interface under the "Embeddings" section. This makes it easy to distinguish between chat and embedding models when browsing your available models.

## When to Use Embedding Type

✅ **Set a model to "embedding" type when:**
- The model is designed for text embeddings (vector generation)
- The model name contains "embed" or "embedding"
- You want to distinguish it from chat models in the UI
- The model doesn't support conversational interactions

❌ **Do NOT set to "embedding" type if:**
- It's a chat/conversational model (GPT, Gemini, Claude, etc.)
- It supports tool calling or reasoning
- It generates text responses to prompts

## Configuration Example

Here's how an embedding model is stored in the configuration:

```json
{
  "apiModelId": "text-embedding-004",
  "name": "Gemini Text Embedding",
  "type": "embedding",
  "input": ["text"],
  "output": ["text"],
  "abilities": []
}
```

## Tips

- Embedding models are typically **not used directly** in chat conversations
- They are specialized tools for specific technical use cases
- If unsure whether a model is for embedding, check the provider's documentation
- Most users will primarily use **chat models** for everyday interactions

## See Also

- [Terminology](/docs/getting-started/terminology) - Understanding embeddings
- [Google Provider](/docs/providers/google) - Auto-detection of embedding models
- [OpenAI Provider](/docs/providers/openai) - OpenAI embedding models
