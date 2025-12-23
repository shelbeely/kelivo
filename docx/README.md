# Kelivo Documentation References

This directory contains supplementary documentation for the Kelivo project.

## Main Documentation Site

The primary documentation for Kelivo is maintained in a separate repository:
- **Repository**: https://github.com/Chevey339/kelivo-docx
- **Documentation includes**: Setup guides, provider configuration, model management, and more
- **Languages**: English and Simplified Chinese (简体中文)

## Files in This Directory

- `EMBEDDING_MODELS.md` - Comprehensive guide explaining what embedding models are and how they differ from chat models
- Screenshots and assets for the README

## Adding to External Documentation

To add or update documentation in the main documentation site:

1. Clone the documentation repository:
   ```bash
   git clone https://github.com/Chevey339/kelivo-docx.git
   ```

2. Documentation files are located in:
   - English: `docs/docs/`
   - Chinese: `docs/zh/docs/`

3. The navigation sidebar is configured in: `docs/.vitepress/config.mts`

4. Follow the existing structure and format when adding new pages

## Current Documentation Sections

### Getting Started
- Quick Start
- FAQ
- Terminology

### Models
- **Embedding Models** (NEW) - Explanation of embedding vs chat models

### Assistant
- Basics
- Prompts
- Memory
- Custom Requests
- MCP (Model Context Protocol)

### AI Providers
- OpenAI
- Anthropic
- Google

## Contributing

For documentation contributions, please submit pull requests to the main documentation repository at https://github.com/Chevey339/kelivo-docx
