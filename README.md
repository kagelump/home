# home

My custom configs, versioned. Currently: [OpenCode](https://opencode.ai) global configuration.

## What's inside

```
home/
├── opencode/
│   ├── opencode.json            # OpenRouter name mapping with cost multipliers, e.g. "Claude Opus 4.6 (42.1x)"
│   └── opencode-dollars.json    # Same mapping with real USD prices, e.g. "Claude Opus 4.6 ($5/$25 per M)"
├── setup.sh                     # Installer for Linux / macOS / WSL / Git Bash
├── setup.ps1                    # Installer for Windows PowerShell
└── README.md
```

### The OpenRouter name mapping

OpenCode shows OpenRouter models under their provider names in the model picker.
Both configs override `providers.openrouter.models.<model-id>.name` for every
OpenRouter model (~380 entries) so each entry also carries its cost — either as a
relative multiplier (`Nx`, compact) or as actual input/output prices per million
tokens including context-tier pricing (`$x/$y per M`). Pick whichever you read better;
the setup script installs one variant as the active config and keeps the other as an
inactive reference next to it.

These files contain no secrets. Auth is not part of this repo: on a new machine run
`opencode auth login` and authenticate with OpenRouter as usual.

## Setup on a new machine

```sh
git clone https://github.com/kagelump/home.git
cd home
```

**Linux / macOS / WSL / Git Bash**

```sh
./setup.sh                  # multiplier variant (default)
./setup.sh --variant dollars
```

**Windows (PowerShell)**

```powershell
.\setup.ps1                        # multiplier variant (default)
.\setup.ps1 -Variant dollars
```

The script installs into the global OpenCode config directory
(`~/.config/opencode/`, or `$XDG_CONFIG_HOME/opencode` if set):

- the chosen variant → `opencode.json` (this is the file OpenCode actually reads)
- the other variant → `opencode-dollars.json` / `opencode-multiplier.json` (inactive reference)

Existing files that would change are backed up as `*.bak.<timestamp>` first, so it is
safe to re-run and safe to switch variants. If OpenCode is already running, restart
its service afterwards (`opencode service restart`).

Manual install is equivalent to copying `opencode/opencode.json` to
`~/.config/opencode/opencode.json`.

## Updating

1. Edit the mapping in `opencode/*.json` (or regenerate it).
2. `git commit && git push` here.
3. On any other machine: `git pull` and re-run the setup script.

## Not in this repo

- `~/.config/opencode/service.json` — local background-service credentials (machine runtime state, gitignored).
- `~/.local/share/opencode/` — auth store, sessions, logs (machine data).

## Adding more configs

Future config homes should follow the same pattern: one top-level directory per tool,
a setup script entry to install it, and never commit machine-local secrets.
