# Direct command tree

The `commands/` tree is the script-first operator surface. Commands use the
`wsa-` prefix to reduce collisions and are grouped by category/subcategory.
They call the shared PowerShell module or a bounded read-only native collector;
they do not duplicate safety logic.

Run `scripts/install-windows-admin.ps1 -WhatIf` to inspect every directory,
collision, and proposed user-PATH change. A real install adds every directory
containing a `.ps1` or `.cmd` command, plus `commands/bin`, to the user PATH.
The installer refuses a collision or an 8,191-character user PATH unless the
operator chooses a different installation approach.

PowerShell can invoke `wsa-inventory` directly. Command Prompt users can use the
checked-in `wsa.cmd <subcommand>` dispatcher; installation can generate
collision-checked `.cmd` shims for all registered commands in `commands/bin`.

Use `wsa-list` to inspect catalogue capabilities and `wsa-route "request"` when
the command name is not known.
