# Dotfiles

My personal configuration files for Linux/Unix environments, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## System Dependencies

You must install the following tools before applying these configurations.

### Core Utilities
*   **[stow](https://www.gnu.org/software/stow/)**: Symlink manager.
*   **[git](https://git-scm.com/)**: Version control.
*   **[curl](https://curl.se/)** / **wget**: For downloading installers/fonts.
*   **[unzip](https://linux.die.net/man/1/unzip)** & **tar**: Required by Mason (Neovim) to extract servers.
*   **[tree-sitter](https://github.com/tree-sitter/tree-sitter):** Parser generator tool.
*   **[firefox](https://www.firefox.com/en-US/):** Browser.
*   **[yay](https://github.com/Jguer/yay):** Package manager for AUR.
*   **[Node.js](https://github.com/nodejs/node):** Run JavaScript Everywhere.
*   **[npm](https://github.com/npm/cli):** JavaScript package manager.

### Shell & Terminal
*   **[zsh](https://www.zsh.org/)**: The shell.
*   **[kitty](https://sw.kovidgoyal.net/kitty/)**: Terminal emulator.
*   **[fzf](https://github.com/junegunn/fzf)**: Fuzzy finder (Required by `.zshrc` and `fzf-lua`).
*   **[zoxide](https://github.com/ajeetdsouza/zoxide)**: Smarter `cd` (Required by `.zshrc`).
*   **[oh-my-posh](https://ohmyposh.dev/)**: Prompt engine.
*   **[lazygit](https://github.com/jesseduffield/lazygit)**: Git TUI.
*   **[Nerd Fonts](https://www.nerdfonts.com/)**: Required for icons (e.g., *JetBrainsMono Nerd Font*).

### Neovim Core
*   **[Neovim](https://neovim.io/)** (>= 0.9.0): Text editor.
*   **[ripgrep](https://github.com/BurntSushi/ripgrep)** (`rg`): Required by `fzf-lua` for grep searching.
*   **[fd](https://github.com/sharkdp/fd)**: Faster `find` alternative, required for file lookups.

### MPV
*   **[Mpv](https://github.com/mpv-player/mpv):** Free media player for the command line
*   **[uosc](https://github.com/tomasklaen/uosc):** Feature-rich minimalist proximity-based UI 
*   **[yt-dlp](https://github.com/yt-dlp/yt-dlp):** Command-line audio/video downloander

## Installation

1.  **Clone the repository:**
    ```sh
    git clone https://github.com/Juzekkk/dotfiles.git ~/dotfiles
    cd ~/dotfiles
    ```

2.  **Install dependencies (Arch Linux example):**
    ```sh
    sudo pacman -S stow git zsh kitty fzf zoxide lazygit neovim ripgrep fd gcc make unzip firefox yay yt-dlp nodejs npm
    npm install tree-sitter-cli
    ```

3.  **Apply configurations with Stow:**
    Run this command from inside the `~/dotfiles` directory. This will symlink all top-level files/folders to your home directory.

    ```sh
    stow .
    ```
