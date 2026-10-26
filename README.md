# Dotfiles

Minimal shell configuration for **production Debian/Ubuntu** VMs.

## What's included

**Shell (Zsh):**
- **Native zsh prompt** (no external binaries) with OS, user@host, path, git and exit-status segments; user@host turns red as root and purple on `-dev` hosts
- **zsh-autosuggestions** - fish-like history suggestions (Right Arrow to accept)
- **zsh-syntax-highlighting** - colors commands as you type

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

## Files

| File | Purpose |
|---|---|
| `install.sh` | Idempotent installer (only installs what's missing; leaves root's login shell unchanged) |
| `.zshrc` | Zsh config: prompt, plugins, completion, history |
