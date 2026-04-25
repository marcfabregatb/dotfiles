# Dotfiles

Minimal shell configuration for **production Debian/Ubuntu** VMs.

## What's included

**Shell (Zsh):**
- **Oh My Posh** prompt with environment-aware colors
- **zsh-autosuggestions** - fish-like history suggestions (Right Arrow to accept)
- **zsh-syntax-highlighting** - colors commands as you type

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
| `install.sh` | Idempotent installer (only installs what's missing) |
| `.zshrc` | Zsh config: plugins, tools, completion, history |
