# 🚀 Marc's Dotfiles

This is my choice of configuration files, optimized for **Debian** and **VS Code DevContainers**. 

## ✨ Features

- **Shell (Zsh):**
  - **Oh My Posh**: Custom prompt theme with **environment colors**:
    - 🟣 **Purple**: Dev Containers.
    - 🟠 **Orange**: GitHub Codespaces.
    - 🟢 **Green**: Development servers (`mydeployments-dev`).
  - **Plugins**:
    - **zsh-autosuggestions**: Fish-like history suggestions (Right Arrow to accept).
    - **zsh-history-substring-search**: Search history with **Up/Down Arrows** using what you've already typed.
    - **zsh-syntax-highlighting**: Highlights commands as you type.

- **Productivity Tools:**
  - **Zoxide**: Smarter `cd` command for fast navigation.
  - **fzf**: Fuzzy finder integration for command history and file searching.

- **Infrastructure:**
  - **Docker Ready**: Automatically installs Docker Engine and Compose on fresh systems.
  - **Container Aware**: Installer skips redundant steps when running inside a container.

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

# 4. Restart shell
source ~/.zshrc
```

### VS Code DevContainers

To automatically use these dotfiles in any DevContainer, add the following to your VS Code user **settings.json** (or your `devcontainer.json`):

```json
"dotfiles.repository": "https://github.com/marcfabregatb/dotfiles.git",
"dotfiles.targetPath": "~/dotfiles",
"dotfiles.installCommand": "bash ./install.sh"
```

---

## 📋 Prerequisites

### 1. Nerd Fonts
To see the icons in the shell prompt correctly, you must have a [Nerd Font](https://www.nerdfonts.com/) installed on your **host machine**.

- **Installation**: Run `oh-my-posh font install` and pick **CaskaydiaCove**.
- **VS Code Configuration**: Update your `settings.json`:
  ```json
  "terminal.integrated.fontFamily": "'CaskaydiaCove Nerd Font'",
  ```

## 📂 Structure

- `.zshrc`: Main Zsh configuration with dynamic path detection and completion logic.
- `.vimrc`: Quality-of-life Vim settings.
- `install.sh`: Robust, idempotent installation script (supports Docker & Homebrew).
- `theme.omp.json`: Oh My Posh prompt theme with environment-aware colors.
- `plugins/`: (Created during install) Directory for Zsh plugin clones.
