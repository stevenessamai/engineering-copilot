# Contributing to Engineering Copilot

## Development setup

1. Clone the repository.
2. Install it locally in Claude Code for testing:
   ```
   /plugin marketplace add /path/to/your/local/clone
   /plugin install engineering-copilot@engineering-copilot-marketplace
   ```
3. Make your changes.
4. Run the local test suite before opening a PR:
   ```
   bash tests/run_all.sh
   ```

## Plugin structure

```
engineering-copilot/
├── .claude-plugin/       # plugin.json (manifest), marketplace.json — nothing else goes here
├── skills/<name>/SKILL.md
├── agents/<name>.md
├── hooks/hooks.json
├── scripts/              # hook implementations and shared utilities, called by hooks/skills
├── bin/                  # executables added to the Bash tool's PATH
├── examples/
├── tests/
└── docs/
```

## Adding a skill

1. Create `skills/<name>/SKILL.md` with YAML frontmatter (`name`, `description`) followed by: Purpose, When to use, Safety constraints, Workflow, Output format, Failure handling. Look at an existing skill (e.g. `skills/debug/SKILL.md`) as a template.
2. The `description` field is what Claude Code uses to decide when to invoke the skill — make it specific about triggers, not just a restatement of the name.
3. Every skill must state explicit safety constraints and failure-handling behavior. Vague or generic recommendations ("consider best practices") are not acceptable output for any skill — see `docs/workflows.md` for the standard this plugin holds itself to.
4. Add the new command to the table in `README.md`.
5. Add an example to `examples/` if the skill introduces a new kind of workflow.

## Adding an agent

1. Create `agents/<name>.md` with frontmatter (`name`, `description`, `tools`, `model`) followed by: Role, Responsibility (narrow), Instructions, Constraints, Expected output, Safety rules.
2. Keep the agent's responsibility narrow — one clear job, not a do-everything agent. If you're tempted to give an agent five responsibilities, it should probably be two agents.
3. Only grant `Write`/`Edit` tools to agents that genuinely need to modify files (e.g. `test-engineer`, `refactoring-engineer`). Read-only agents (`codebase-analyst`, `security-reviewer`, `architecture-reviewer`, `code-reviewer`, `dependency-analyst`) should stay that way.

## Adding a hook

Hooks are high-friction by nature — they run on every matching tool call. Before adding one, make sure it's conservative: it should inform, not block, unless there's a very strong reason (see `docs/safety.md`). Document any new hook in `docs/hooks.md`'s table, including its exact event, matcher, and purpose.

## Testing

`tests/run_all.sh` runs:
- JSON validity of `plugin.json` and `marketplace.json`
- Required frontmatter fields present on every `SKILL.md` and agent file
- `hooks.json` references scripts that actually exist and are executable
- No duplicate skill/agent names
- No obvious secrets in the repository

Add a corresponding check to `tests/` for any new structural requirement you introduce.

## Validation

Before submitting, also run, if available in your environment:

```
claude plugin validate .
```

If that command isn't available in your Claude Code version, rely on `tests/run_all.sh` and manual local installation (marketplace add → install → confirm skills/agents/hooks all load).

## Pull request expectations

- Describe what changed and why, not just what.
- Include the output of `tests/run_all.sh`.
- If you added or changed a skill's behavior, update or add an example in `examples/`.
- No placeholder content (`TODO`, `FIXME`, "implement later", fake commands or paths) in anything merged.
