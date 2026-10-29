# Claude and Codex marketplace use

Verified 2026-10-29 with Claude 2.1.312 and Codex 0.165.0 in offline disposable
containers, with the repository mounted read-only and no host credentials or
configuration. Local installation needs no paid model call. The same canonical
20 skill directories are declared in `.claude-plugin/plugin.json` and installed
through `.claude-plugin/marketplace.json`; no duplicate content tree is created.

From the checkout root, install into the intended runtime's local configuration:

```sh
codex plugin marketplace add . --json
codex plugin add windows-admin@chwezi-windows-admin --json
codex plugin list --json
```

Claude uses `/plugin marketplace add` and `/plugin install` as shown in README.
The official [Claude marketplace reference](https://code.claude.com/docs/en/plugin-marketplaces)
and [OpenAI local package reference](https://developers.openai.com/plugins/build/plugins)
were consulted 2026-10-29; review on 2026-11-05 or a runtime update. These are local
marketplace instructions, not public directory approval. Hook execution,
authenticated model behaviour and public submission remain NOT_ASSESSED.

The baseline Claude inventory included an unintended README command because it
scanned Markdown in `commands/`. That preserved document now lives at
[Direct command tree](operations/direct-command-tree.md). The package guard
rejects future Markdown in that script-only directory. Operational PowerShell
commands and all 20 declared skills remain present.

`python scripts/check_marketplace.py` checks exact canonical skill-path parity,
local entry identity/version, path containment, duplicate/symlink rejection and
router portability. Both full-checkout and package-oriented counts must be at
most 5,000. The full count includes Git and caches; package counts omit the named
cache/VCS directories in the checker. Directory symlinks count as one entry and
are never followed. Inventory errors fail closed. No option raises the ceiling.

The native Codex prompt-input inventory at the baseline exposed 20/20 paths.
The final local inventories and validators are recorded in the cycle's
[validation record](kaizen/2026-10-engine-kaizen/04-validation-record.md).
