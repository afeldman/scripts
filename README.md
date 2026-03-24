# scripts

Personal utility scripts for macOS and Linux (zsh/bash).

Covers: encryption/decryption, certificate handling, file operations, git helpers, development tooling, system administration, data processing.

## Install

**curl (macOS + Linux):**

```sh
curl -fsSL https://raw.githubusercontent.com/afeldman/scripts/master/install.sh | sh
```

**Homebrew (macOS):**

```sh
brew tap afeldman/scripts https://github.com/afeldman/scripts
brew install afeldman/scripts/scripts
```

Both install scripts to `$HOME/.local/bin/` and add the path to your shell config.

## Update

```sh
scripts-update
```

Or manually: re-run the install command above, or `brew upgrade afeldman/scripts/scripts`.

## Uninstall

```sh
curl -fsSL https://raw.githubusercontent.com/afeldman/scripts/master/uninstall.sh | sh
```

## Scripts

| Script | Description |
|---|---|
| `encrypt` / `decrypt` | AES-256-CBC file encryption (OpenSSL) |
| `encryptdir` / `decryptdir` | Encrypt/decrypt entire directories |
| `2pem` / `pfx2cert` | Convert DER/PFX certificates to PEM |
| `passgen` | Generate random passwords |
| `cp_n` | Parallel file copy with digest verification |
| `dublicate` / `dublicate_dir` | Find duplicate files |
| `githelper` | Delete tags locally and remotely |
| `git-blame-someone-else` | Rewrite blame for a file |
| `install_go` / `install_nix` / `llvm_install` | Language/toolchain installers |
| `installdotnet` | .NET SDK installer |
| `yapf` / `yapf-diff` | Python code formatter |
| `nbstripout` | Strip output from Jupyter notebooks |
| `pipreqs` | Generate requirements.txt from imports |
| `excel2csv` | Convert Excel files to CSV |
| `mat2h5` | Convert MATLAB .mat files to HDF5 |
| `update` | System package update (brew / apt / dnf / yum) |
| `scripts-update` | Update all afeldman/scripts to latest version |
| `remote_cmd` | Run commands on remote hosts via SSH |
| `calc` | CLI calculator |
| `prettyjson` | Pretty-print JSON |
| `tomlq` / `xq` | Query TOML/XML from the command line |
| `checksumdir` | Compute checksum of a directory tree |
| `chkfilehash` | Verify file hash against expected value |

## Platform notes

The following scripts are **Linux-only** and will not work on macOS:

| Script | Reason |
|---|---|
| `remove_old_snap` | Snap is not available on macOS |
| `llvm_install` | Uses apt/dpkg directly |
| `emacs_install_ubuntu.sh` | Ubuntu/Debian specific |
| `install_nix` | Uses lsb_release + distro-specific paths |

## Release

```sh
./release.sh 0.2.0
```

Creates a git tag, pushes it, computes the sha256 of the release tarball, updates `Formula/scripts.rb`, and pushes the formula commit.
