# Agent Skills for Kelivo

This directory contains [Agent Skills](https://agentskills.io) - modular knowledge packages that AI coding assistants (like Claude, Cursor, GitHub Copilot, etc.) can use to better understand and work with the Kelivo codebase.

## What are Agent Skills?

Agent Skills are a simple, open format for giving AI agents new capabilities and expertise. Each skill is a folder containing:
- **SKILL.md**: Instructions and guidelines for the AI agent
- **scripts/** (optional): Automation scripts
- **references/** (optional): Additional documentation
- **assets/** (optional): Configuration files or resources

## Available Skills

### kelivo-development

Comprehensive guide for developing features in Kelivo. Includes:
- Project architecture and structure
- State management patterns (Provider)
- Feature module organization
- Localization guidelines
- Platform-specific development
- MCP integration patterns
- Common development workflows

**When to use**: Any time you're adding features, fixing bugs, or modifying the Kelivo codebase.

### flutter-best-practices

General Flutter development best practices. Covers:
- Widget architecture and optimization
- Performance best practices
- State management patterns
- Async operation handling
- Testing guidelines
- Null safety patterns
- Accessibility considerations

**When to use**: When writing any Flutter code, especially if you're new to Flutter or want to ensure best practices.

## How AI Agents Use These Skills

When you work with AI coding assistants in this repository, they can automatically discover and use these skills to:

1. **Understand the codebase** - Learn about Kelivo's architecture and conventions
2. **Follow project patterns** - Write code that matches existing patterns
3. **Make better suggestions** - Provide context-aware recommendations
4. **Avoid common mistakes** - Follow established best practices

## Skill Discovery

AI agents typically discover skills in these locations:

- **Project-level**: `.cursor/skills/`, `.claude/skills/`
- **User-level**: `~/.cursor/skills/`, `~/.claude/skills/`

The skills in this directory are project-level and apply to all contributors working on Kelivo.

## Supported AI Assistants

These skills work with:
- [Cursor](https://cursor.sh) - AI-first code editor
- [Claude](https://claude.ai) - Anthropic's AI assistant
- [GitHub Copilot](https://github.com/features/copilot) - GitHub's AI pair programmer
- [Cline](https://github.com/cline/cline) - VS Code AI assistant
- Any other tool that supports the Agent Skills format

## Adding New Skills

To add a new skill:

1. Create a new directory: `.cursor/skills/your-skill-name/`
2. Create a `SKILL.md` file with YAML frontmatter:

```markdown
---
name: your-skill-name
description: Brief description of what this skill does
license: AGPL-3.0
metadata:
  author: Your Name
  version: '1.0.0'
---

# Your Skill Name

Detailed instructions for the AI agent...
```

3. Add detailed instructions, examples, and edge cases in the Markdown body
4. Test the skill with your AI assistant

## Skill Format Specification

Each `SKILL.md` file follows this structure:

### YAML Frontmatter (Required)

```yaml
---
name: skill-name              # Required: Unique identifier
description: >                # Required: What the skill does
  Brief description
license: AGPL-3.0            # Optional: License identifier
metadata:                     # Optional: Additional metadata
  author: Author Name
  version: '1.0.0'
compatibility: flutter>=3.8.1 # Optional: Requirements
---
```

### Markdown Body

The body contains:
- **Overview**: What the skill teaches
- **When to use**: Triggering conditions
- **How to use**: Step-by-step instructions
- **Examples**: Code samples and patterns
- **Edge cases**: Special considerations
- **Resources**: Links to documentation

## Benefits of Using Skills

✅ **Consistency** - All contributors and AI assistants follow the same patterns
✅ **Onboarding** - New contributors learn the codebase faster
✅ **Quality** - Automated guidance reduces bugs and tech debt
✅ **Maintainability** - Codified knowledge that doesn't get outdated
✅ **Cross-tool** - Same skills work across different AI assistants

## Learn More

- [Agent Skills Official Site](https://agentskills.io)
- [Agent Skills Specification](https://agentskills.io/specification)
- [Agent Skills GitHub](https://github.com/agentskills/agentskills)
- [Example Skills Repository](https://github.com/anthropics/skills)
- [Skills Directory](https://skills.sh) - Browse community skills

## Contributing

When contributing to Kelivo, please:

1. Review the existing skills to understand project conventions
2. Update skills if you introduce new patterns or best practices
3. Add new skills for significant features or domain-specific knowledge
4. Keep skills focused and actionable

## License

The skills in this directory are licensed under the same AGPL-3.0 license as the Kelivo project, unless otherwise specified in individual skill files.
