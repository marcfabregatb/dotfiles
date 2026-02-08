# 🚀 Marc's Dotfiles


This is my choice of configuration files, optimized for **Debian** and **VS Code DevContainers**. Use at your own risk!

## ✨ Features

- **Shell (Zsh):**
  - **Oh My Posh**: Custom prompt theme using `theme.omp.json`.
  - **Zoxide**: Smarter `cd` command for fast navigation.
  - **Syntax Highlighting**: Real-time coloring of commands.
  - **Auto-suggestions**: Command suggestions based on your history.
  - **Shared History**: Commands are synced across all open terminal sessions.

- **Editor (Vim):**
  - Minimal and fast configuration.
  - Incremental search and highlighting.
  - System clipboard support.
  - Smart indentation and line numbering.

---

## 🛠️ Installation

### Standalone Debian / Ubuntu VM

To install these dotfiles on a fresh Linux environment, run the following commands:

```bash
# 1. Install Git
sudo apt update && sudo apt install -y git

# 2. Clone the repository
git clone https://github.com/marcfabregatb/dotfiles.git ~/dotfiles

# 3. Run the installer
cd ~/dotfiles
chmod +x install.sh
./install.sh

# 4. Change default shell to Zsh (requires logout/restart)
chsh -s $(which zsh)
```

### VS Code DevContainers

To automatically use these dotfiles in any DevContainer, add the following to your VS Code user **settings.json**:

```json
"dotfiles.repository": "https://github.com/marcfabregatb/dotfiles.git",
"dotfiles.targetPath": "~/dotfiles",
"dotfiles.installCommand": "bash ./install.sh"
```

---

## 📋 Prerequisites

### 1. Nerd Fonts
To see the icons in the shell prompt correctly, you must have a [Nerd Font](https://www.nerdfonts.com/) installed on your **host machine** (the computer you are physically typing on).

You can install a font easily using the `oh-my-posh` command:

- **Windows (PowerShell):**
  ```powershell
  oh-my-posh font install
  ```
- **macOS / Linux:**
  ```bash
  oh-my-posh font install
  ```
*Recommended: Choose **CaskaydiaCove** or **Meslo** when prompted.*

### 2. VS Code Configuration
If using VS Code, update your `settings.json` to use the installed font:
```json
"terminal.integrated.fontFamily": "'CaskaydiaCove Nerd Font'",
```

## 📂 Structure

- `.zshrc`: Main Zsh configuration with dynamic path detection.
- `.vimrc`: Quality-of-life Vim settings.
- `install.sh`: Robust, idempotent installation script.
- `theme.omp.json`: Oh My Posh prompt theme configuration.
- `plugins/`: (Created during install) Directory for Zsh plugin clones.
