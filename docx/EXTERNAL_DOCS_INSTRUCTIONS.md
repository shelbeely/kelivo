# Instructions for Adding Embedding Models Documentation to kelivo-docx

This file contains the changes needed to add the embedding models documentation to the main documentation site at https://github.com/Chevey339/kelivo-docx

## Files to Add

### 1. English Documentation
**File:** `docs/docs/models/embedding-models.md`
- Location: Create `docs/docs/models/` directory if it doesn't exist
- Content: See `/tmp/kelivo-docx/docs/docs/models/embedding-models.md`
- This file is also available in this repo at: `docx/models/embedding-models.md`

### 2. Chinese Documentation
**File:** `docs/zh/docs/models/embedding-models.md`
- Location: Create `docs/zh/docs/models/` directory if it doesn't exist
- Content: See `/tmp/kelivo-docx/docs/zh/docs/models/embedding-models.md`
- This file is also available in this repo at: `docx/zh-models/embedding-models.md`

## Configuration Changes

### Update Navigation in `docs/.vitepress/config.mts`

Add a new "Models" section to the sidebar navigation in both English and Chinese sections.

#### For English (around line 58):
```typescript
{
  text: 'Models',
  items: [
    { text: 'Embedding Models', link: '/docs/models/embedding-models' }
  ]
},
```
Insert this BEFORE the "Assistant" section.

#### For Chinese (around line 103):
```typescript
{
  text: '模型',
  items: [
    { text: '嵌入模型', link: '/zh/docs/models/embedding-models' }
  ]
},
```
Insert this BEFORE the "助手" (Assistant) section.

## Verification Steps

1. Clone the kelivo-docx repository:
   ```bash
   git clone https://github.com/Chevey339/kelivo-docx.git
   cd kelivo-docx
   ```

2. Create directories:
   ```bash
   mkdir -p docs/docs/models
   mkdir -p docs/zh/docs/models
   ```

3. Copy the documentation files from this repository:
   - Copy `docx/models/embedding-models.md` to `docs/docs/models/`
   - Copy `docx/zh-models/embedding-models.md` to `docs/zh/docs/models/`

4. Update `docs/.vitepress/config.mts` as described above

5. Test locally (if you have the environment set up):
   ```bash
   npm install
   npm run docs:dev
   ```

6. Commit and push:
   ```bash
   git add .
   git commit -m "Add embedding models documentation (English + Chinese)"
   git push
   ```

## What This Documentation Adds

The embedding models documentation explains:
- What embedding models are and how they differ from chat models
- When to use embedding vs chat model types
- How Kelivo automatically detects embedding models (Google provider)
- How to manually configure a model as an embedding model
- Why certain UI options are hidden for embedding models
- Model grouping behavior
- Configuration examples

This addresses the question: "What does setting the type to embedding model do?"

## Files in This Kelivo Repository

For reference, the following files were added to the main Kelivo repository:
- `docx/EMBEDDING_MODELS.md` - Standalone comprehensive guide
- `docx/README.md` - Documentation directory README with references
- `docx/models/embedding-models.md` - English version for external docs
- `docx/zh-models/embedding-models.md` - Chinese version for external docs

## Code Comments Added

The following source files were updated with explanatory comments:
- `lib/core/providers/model_provider.dart` - ModelType enum documentation
- `lib/utils/model_grouping.dart` - Grouping logic explanation
- `lib/desktop/model_edit_dialog.dart` - UI simplification explanation
- `lib/features/model/widgets/model_detail_sheet.dart` - UI simplification explanation
