# Quick Start: Using Agent Skills with Kelivo

This is a quick reference guide for using Agent Skills when developing Kelivo.

## What You Get

✅ **Automatic Context** - AI assistants automatically understand Kelivo's architecture
✅ **Better Code Suggestions** - AI suggestions follow project conventions
✅ **Faster Development** - Spend less time explaining patterns to AI assistants

## Supported Tools

- **Cursor**: Skills are automatically discovered in `.cursor/skills/`
- **Claude Desktop**: Works with `.claude/skills/` (copy from `.cursor/skills/` if needed)
- **GitHub Copilot**: Enhanced with workspace context
- **VS Code + Cline**: Install the Agent Skills extension

## Quick Test

Try asking your AI assistant:

```
"How should I structure a new feature in Kelivo?"
```

The AI should reference:
- Provider pattern for state management
- Feature module structure in `lib/features/`
- Localization requirements
- Platform-specific considerations

## Common Use Cases

### 1. Adding a New Feature

**Ask**: "Create a new export feature for Kelivo"

**Expected AI behavior**:
- Creates `lib/features/export/` directory
- Adds appropriate Provider
- Includes localization strings
- Follows existing UI patterns

### 2. Code Review

**Ask**: "Review this widget for best practices"

**Expected AI behavior**:
- Checks for `const` constructors
- Validates Provider usage
- Ensures proper null safety
- Verifies localization

### 3. Understanding Architecture

**Ask**: "How does MCP integration work in Kelivo?"

**Expected AI behavior**:
- References MCP service and provider
- Explains tool calling mechanism
- Shows relevant code locations

## Skill Locations

```
.cursor/skills/
├── README.md                           # Skills overview
├── kelivo-development/                 # Project-specific patterns
│   └── SKILL.md
└── flutter-best-practices/             # Flutter best practices
    └── SKILL.md
```

## When to Update Skills

Update skills when you:
- Introduce new architectural patterns
- Change project conventions
- Add major features with specific patterns
- Discover common mistakes to document

## Need Help?

- Read [AGENT_SKILLS.md](AGENT_SKILLS.md) for comprehensive documentation
- Check [.cursor/skills/README.md](.cursor/skills/README.md) for skill details
- Visit https://agentskills.io for the official specification

## Benefits in Practice

**Before Agent Skills**:
```
Developer: "Add a settings page"
AI: *Creates generic Flutter page*
Developer: "No, use our Provider pattern and add localization"
AI: *Adjusts code*
Developer: "Also need desktop-specific layout"
AI: *More adjustments*
```

**With Agent Skills**:
```
Developer: "Add a settings page"
AI: *Creates page with Provider, localization, desktop support, following all conventions*
Developer: ✅
```

## Troubleshooting

**Skills not working?**
1. Ensure your AI assistant supports Agent Skills
2. Check that `.cursor/skills/` directory exists
3. Restart your IDE/AI assistant
4. Verify YAML frontmatter in SKILL.md files

**Unexpected behavior?**
1. Skills are guidelines, not strict rules
2. AI may interpret skills differently
3. Provide specific feedback to improve results
4. Update skills to be more explicit

---

Happy coding with AI assistance! 🚀
