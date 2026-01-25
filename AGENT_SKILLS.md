# Agent Skills Support in Kelivo

Kelivo now supports [Agent Skills](https://agentskills.io) - an open standard for extending AI coding assistants with project-specific knowledge and capabilities.

## What are Agent Skills?

Agent Skills are modular knowledge packages that teach AI coding assistants (like Claude, Cursor, GitHub Copilot, etc.) about your project's specific conventions, architecture, and best practices. Think of them as "onboarding manuals" for AI assistants.

## Why Use Agent Skills in Kelivo?

🎯 **Better Code Quality** - AI assistants understand Kelivo's architecture and write code that matches project patterns

🚀 **Faster Development** - AI suggestions are context-aware and follow established conventions

📚 **Knowledge Preservation** - Project conventions are documented in a machine-readable format

🤝 **Easier Onboarding** - New contributors (human and AI) learn the codebase faster

🔄 **Cross-Tool Compatibility** - Same skills work with multiple AI coding assistants

## Available Skills

Kelivo includes these built-in skills in the `.cursor/skills/` directory:

### 1. kelivo-development

**Purpose**: Complete guide for Kelivo development

**Covers**:
- Project architecture and directory structure
- State management with Provider pattern
- Feature module organization
- MCP (Model Context Protocol) integration
- Localization (English/Chinese)
- Platform-specific development
- Common coding patterns
- Development workflows

**When it helps**: 
- Adding new features
- Fixing bugs
- Refactoring code
- Understanding the codebase

### 2. flutter-best-practices

**Purpose**: General Flutter development excellence

**Covers**:
- Widget architecture and const constructors
- Performance optimization
- State management best practices
- Async operation handling
- Error handling patterns
- Testing strategies
- Null safety
- Accessibility

**When it helps**:
- Writing any Flutter code
- Optimizing performance
- Following Flutter conventions
- Avoiding common pitfalls

## Supported AI Assistants

Agent Skills work with any tool supporting the Agent Skills format:

- ✅ [Cursor](https://cursor.sh) - AI-first code editor
- ✅ [Claude](https://claude.ai) - Anthropic's AI assistant  
- ✅ [GitHub Copilot](https://github.com/features/copilot) - GitHub's AI pair programmer
- ✅ [Cline](https://github.com/cline/cline) - VS Code AI assistant
- ✅ [Windsurf](https://codeium.com/windsurf) - Codeium's AI IDE
- ✅ Any tool supporting the open Agent Skills standard

## How to Use Agent Skills

### Automatic Discovery

Most AI coding assistants automatically discover skills in:

```
.cursor/skills/     # Project-level skills (committed to repo)
.claude/skills/     # Alternative location
~/.cursor/skills/   # User-level skills (personal)
```

Kelivo's skills are in `.cursor/skills/` and automatically available to all AI assistants.

### Manual Activation (if needed)

Some tools may require you to explicitly enable or reference skills:

**Cursor**:
- Skills are automatically discovered
- No additional configuration needed

**Claude Desktop**:
- Skills in `.claude/skills/` are automatically loaded
- You can also reference skills in your conversations

**GitHub Copilot Chat**:
- Use the `@workspace` command to give Copilot workspace context
- Skills enhance the context awareness

**VS Code with Cline/Copilot**:
- Install the [Agent Skills extension](https://marketplace.visualstudio.com/items?itemName=laurids.agent-skills-sh)
- Browse and manage skills directly in VS Code

### Testing Skills

To verify skills are working:

1. **Ask for project guidance**:
   ```
   "How should I add a new feature in Kelivo?"
   ```
   The AI should reference Kelivo's architecture and patterns.

2. **Request code following conventions**:
   ```
   "Create a new settings page following Kelivo patterns"
   ```
   The AI should use Provider pattern, proper structure, and localization.

3. **Check Flutter practices**:
   ```
   "Review this widget for best practices"
   ```
   The AI should apply Flutter optimization patterns.

## Adding Custom Skills

You can add your own skills to Kelivo:

### 1. Create a new skill directory

```bash
mkdir -p .cursor/skills/my-skill-name
```

### 2. Create a SKILL.md file

```markdown
---
name: my-skill-name
description: Brief description of what this skill does
license: AGPL-3.0
metadata:
  author: Your Name
  version: '1.0.0'
---

# My Skill Name

Detailed instructions for the AI agent...

## When to Use

Describe when this skill should be applied...

## How to Use

Step-by-step guidance...

## Examples

Code examples...

## Edge Cases

Special considerations...
```

### 3. Test your skill

Verify the AI assistant recognizes and uses your skill appropriately.

### 4. Share with the team

Commit useful skills to the repository so all contributors benefit.

## Skill Development Best Practices

When creating skills for Kelivo:

✅ **Be specific** - Include concrete examples and code patterns
✅ **Stay focused** - One skill should cover one domain or feature area
✅ **Include examples** - Show correct and incorrect patterns
✅ **Document edge cases** - Cover special scenarios and exceptions
✅ **Keep it current** - Update skills when conventions change
✅ **Test thoroughly** - Verify AI assistants interpret instructions correctly

❌ **Avoid vagueness** - "Write good code" is not helpful
❌ **Don't overlap** - Each skill should have clear boundaries
❌ **Skip implementation details** - Focus on patterns, not specific functions
❌ **Avoid outdated info** - Remove obsolete practices

## Skill Format Reference

### YAML Frontmatter

Required fields:
```yaml
name: skill-name              # Unique identifier (kebab-case)
description: >                # Clear, concise description
  What this skill does and when to use it
```

Optional fields:
```yaml
license: AGPL-3.0            # License identifier
metadata:                     # Custom metadata
  author: Author Name
  version: '1.0.0'
  category: development
compatibility: flutter>=3.8.1 # Technical requirements
allowed-tools:                # Permitted tools/scripts
  - bash
  - flutter
```

### Markdown Body Structure

Recommended sections:
1. **Overview** - What the skill teaches
2. **When to Use** - Trigger conditions
3. **How to Use** - Step-by-step instructions
4. **Examples** - Code samples with ✅ good and ❌ bad patterns
5. **Edge Cases** - Special considerations
6. **Resources** - Links to relevant docs

## Troubleshooting

### Skills not working?

1. **Check file structure**:
   ```
   .cursor/skills/
   └── skill-name/
       └── SKILL.md
   ```

2. **Validate YAML frontmatter** - Must be valid YAML between `---` markers

3. **Restart your AI assistant** - Some tools need a restart to detect new skills

4. **Check AI tool documentation** - Each tool may have specific requirements

### Skills partially working?

- Review skill instructions for clarity
- Add more concrete examples
- Reduce ambiguity in guidelines
- Test with different AI assistants

### Want to disable a skill?

- Rename the directory (e.g., `skill-name.disabled`)
- Move it outside the `.cursor/skills/` directory
- Delete the skill directory

## Contributing Skills

We welcome skill contributions! To contribute:

1. **Fork the repository**
2. **Create a new skill** or improve an existing one
3. **Test thoroughly** with at least one AI assistant
4. **Submit a pull request** with:
   - Description of the skill
   - Use cases where it helps
   - Testing results

Good skill contributions:
- Fill gaps in current documentation
- Codify tribal knowledge
- Address common mistakes
- Cover new features or patterns

## Resources

- **Agent Skills Official Site**: https://agentskills.io
- **Specification**: https://agentskills.io/specification  
- **GitHub Repository**: https://github.com/agentskills/agentskills
- **Skills Directory**: https://skills.sh - Browse community skills
- **Example Skills**: https://github.com/anthropics/skills
- **VS Code Extension**: [Agent Skills Browser](https://marketplace.visualstudio.com/items?itemName=laurids.agent-skills-sh)

## Examples in Action

### Example 1: Adding a New Feature

**Without Agent Skills**:
```
You: "Create a new chat export feature"
AI: *Creates code with generic patterns that don't match Kelivo's architecture*
```

**With Agent Skills**:
```
You: "Create a new chat export feature"
AI: *References kelivo-development skill*
    - Uses Provider pattern for state
    - Creates feature module in lib/features/export/
    - Adds localization in app_en.arb and app_zh.arb
    - Follows existing UI patterns
    - Includes desktop and mobile implementations
```

### Example 2: Code Review

**Without Agent Skills**:
```
You: "Review this widget"
AI: *Generic Flutter advice*
```

**With Agent Skills**:
```
You: "Review this widget"
AI: *References flutter-best-practices and kelivo-development skills*
    - Checks for const constructors
    - Verifies Provider usage patterns
    - Ensures localization is used
    - Validates platform-specific handling
    - Suggests Kelivo-specific improvements
```

## FAQ

**Q: Do I need to install anything?**
A: No, if you're using an AI assistant that supports Agent Skills, they're automatically discovered.

**Q: Can I create personal skills?**
A: Yes! Add them to `~/.cursor/skills/` for personal skills not shared with the team.

**Q: How do I know if a skill is active?**
A: Ask your AI assistant to list available skills or reference project conventions.

**Q: Can skills access my code?**
A: Skills are just documentation. The AI assistant reads them and your code separately.

**Q: What if skills conflict?**
A: More specific skills take precedence. Project-level skills override user-level skills.

**Q: Are skills version controlled?**
A: Yes, project-level skills in `.cursor/skills/` are committed to the repository.

## License

Agent Skills in Kelivo are licensed under AGPL-3.0, consistent with the main project license.

---

## Getting Started

Ready to use Agent Skills in Kelivo?

1. ✅ **Skills are already set up** - They're in `.cursor/skills/`
2. ✅ **Use your favorite AI assistant** - Skills work automatically
3. ✅ **Start developing** - AI assistants now understand Kelivo's patterns
4. ✅ **Contribute improvements** - Help make skills even better

Happy coding with AI! 🚀
