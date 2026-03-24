# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Installation

**Option A — curl (macOS + Linux):**
```sh
curl -fsSL https://raw.githubusercontent.com/afeldman/scripts/master/install.sh | sh
```
Installiert nach `$HOME/.local/bin/`, trägt den Pfad in `.zshrc`/`.bashrc`/`.bash_profile` ein.

**Option B — Homebrew Tap (macOS):**
```sh
brew tap afeldman/scripts https://github.com/afeldman/scripts
brew install --HEAD afeldman/scripts/scripts
```
Updates danach via `brew upgrade afeldman/scripts/scripts`.

## Repository Purpose

Personal collection of standalone utility scripts covering: encryption/decryption, file management, development tooling, system administration, network utilities, and data processing. All scripts live in the root directory with no build system.

## Architecture

- **Flat structure**: All scripts in root directory, no subdirectories
- **Polyglot**: Bash (majority), Python, Ruby — each script is self-contained with a shebang
- **No dependencies between scripts** — each is standalone
- **No tests, no CI** — scripts are run directly as executables

## Common Script Categories

| Category | Key Scripts |
|---|---|
| Encryption | `encrypt`, `decrypt`, `encryptdir`, `decryptdir` (OpenSSL AES-256-CBC) |
| Certificates | `2pem`, `pfx2cert` (DER/PFX → PEM) |
| File ops | `cp_n` (Ruby parallel copy), `dublicate`, `dublicate_dir` |
| Git | `githelper`, `git-blame-someone-else` |
| Installers | `install_go`, `install_nix`, `llvm_install`, `installdotnet` |
| Python tooling | `yapf`, `yapf-diff`, `pycc`, `nbstripout`, `pipreqs` |
| Data | `excel2csv`, `mat2h5`, `mongo2rethink` |
| System | `update`, `killprocess`, `fork_bomb`, `cleanboot` |

## Adding/Modifying Scripts

- Make scripts executable: `chmod +x <script>`
- Use appropriate shebang: `#!/usr/bin/env bash`, `#!/usr/bin/env python3`, `#!/usr/bin/env ruby`
- Bash scripts: use `set -euo pipefail` for robustness
- Ruby scripts use gems: `parallel`, `thor`, `colorize` (must be installed)
- Python scripts depend on system Python packages (no venv in this repo)
