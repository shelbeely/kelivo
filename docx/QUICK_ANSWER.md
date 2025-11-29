# What Does Setting the Type to Embedding Model Do?

## Quick Answer

Setting a model's type to "embedding" in Kelivo **changes how the model is presented and configured** in the user interface. It signals that the model is designed for text vectorization (converting text to numbers) rather than conversational AI.

## Key Effects

### 1. **Simplified Configuration UI**

When you set type to "embedding", these options are **hidden**:
- ❌ Input modes (text/image selection)
- ❌ Output modes (text/image selection)  
- ❌ Abilities (tool calling, reasoning)

Why? Embedding models don't support these conversational features.

### 2. **Separate Model Grouping**

Embedding models appear in their own "Embeddings" group in the model selector, separate from chat models like GPT, Gemini, and Claude.

### 3. **Automatic Detection (Google)**

For Google providers, Kelivo automatically sets the type based on API capabilities:
- Has `embedContent` method only → Embedding
- Has `generateContent` method → Chat

### 4. **Configuration Storage**

The type is saved in your provider settings:
```json
{
  "type": "embedding",
  "apiModelId": "text-embedding-004",
  "name": "Gemini Embedding"
}
```

## What are Embedding Models?

**Embedding models** convert text into numerical vectors (arrays of numbers). They are used for:
- Semantic search
- Text classification
- Similarity detection
- Clustering

**They are NOT used for** generating conversational responses.

## Examples

**Embedding Models:**
- `text-embedding-004` (Google)
- `text-embedding-3-large` (OpenAI)
- Any model with "embed" in the name

**Chat Models:**
- `gpt-4o` (OpenAI)
- `gemini-1.5-pro` (Google)
- `claude-3.5-sonnet` (Anthropic)

## When to Use "Embedding" Type

✅ Use "embedding" type when:
- Model name contains "embed" or "embedding"
- Model is designed for text vectorization
- You want to separate it from chat models visually

❌ Don't use "embedding" type for:
- Conversational AI models (GPT, Gemini, Claude, etc.)
- Models that generate text responses
- Models with tool calling or reasoning capabilities

## See Full Documentation

For complete details, see:
- `EMBEDDING_MODELS.md` - Comprehensive guide in this directory
- External docs: https://github.com/Chevey339/kelivo-docx

## Code Locations

The embedding model type affects these files:
- `lib/core/providers/model_provider.dart` - Type definition
- `lib/utils/model_grouping.dart` - Grouping logic
- `lib/desktop/model_edit_dialog.dart` - Desktop UI
- `lib/features/model/widgets/model_detail_sheet.dart` - Mobile UI
