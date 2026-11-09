# Dotfiles

Minimal shell configuration for **production Debian/Ubuntu** VMs.

## What's included

**Shell (Zsh):**
- **Native zsh prompt** (no external binaries) with OS, user@host, path, git and exit-status segments; user@host turns red as root and purple on `-dev` hosts
- **zsh-autosuggestions** - fish-like history suggestions (Right Arrow to accept)
- **zsh-syntax-highlighting** - colors commands as you type

**Viewing and editing `.env` files:**
- **bat** - `bat .env` prints any file with syntax colors, like `cat` (no pager). `.env`, `.env.*`, `*.env` and `.envrc` use bat's DotENV syntax. Piped or redirected output is plain, as with `cat`.
- **nano** - `.env`-style files get colored keys, values, `${VAR}` references and comments, and trailing whitespace is flagged in red (many dotenv parsers keep it in the value). Other file types keep nano's system syntaxes.

Everything is installed from apt; nothing is downloaded from outside the distribution's repositories. Prompt icons need a [Nerd Font](https://www.nerdfonts.com/) in your local terminal.

## Install

One-liner:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/marcfabregatb/dotfiles/main/install.sh)
```

Or manually:

```bash
git clone https://github.com/marcfabregatb/dotfiles.git ~/dotfiles
cd ~/dotfiles && ./install.sh
```

Both install `main`. Re-running the one-liner updates an existing `~/dotfiles` clone to the latest `main`. To install a different branch or tag, set `DOTFILES_REF` (e.g. `DOTFILES_REF=v1.2.0`) before running the one-liner. Running as root works without `sudo`.

## Files

| File | Purpose |
|---|---|
| `install.sh` | Idempotent installer (only installs what's missing; works as root without sudo; leaves root's login shell unchanged) |
| `.zshrc` | Zsh config: prompt, plugins, completion, history, `bat` alias |
| `.nanorc` | Adds a dotenv syntax on top of nano's system syntaxes |
| `bat/config` | bat defaults: no pager, plain style, DotENV for all `.env`-style names |

The installer symlinks these into `~` (bat's into `~/.config/bat/`), backing up any existing file first as `<name>.bak.<timestamp>`.
