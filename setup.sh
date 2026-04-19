#!/bin/bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()  { echo -e "${GREEN}[setup]${NC} $1"; }
warn() { echo -e "${YELLOW}[warn]${NC} $1"; }
die()  { echo -e "${RED}[error]${NC} $1"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── 1. System packages ─────────────────────────────────────────────────────────
log "Installing system packages..."
sudo apt-get update -qq
sudo apt-get install -y \
    curl git vim python3 python3-dev python3-pip \
    cmake build-essential ripgrep tmux \
    mono-complete golang nodejs npm

# ── 2. oh-my-tmux (requires tmux, installed above) ────────────────────────────
log "Installing oh-my-tmux..."
if [ ! -d "$HOME/.tmux" ]; then
    git clone https://github.com/gpakosz/.tmux.git "$HOME/.tmux"
    ln -sf "$HOME/.tmux/.tmux.conf" "$HOME/.tmux.conf"
    cp "$HOME/.tmux/.tmux.conf.local" "$HOME/.tmux.conf.local"
    cat "$SCRIPT_DIR/.tmux.conf.local" >> "$HOME/.tmux.conf.local"
else
    warn "oh-my-tmux already present, skipping"
fi

# ── 3. oh-my-bash ─────────────────────────────────────────────────────────────
log "Installing oh-my-bash..."
if [ ! -d "$HOME/.oh-my-bash" ]; then
    bash -c "$(curl -fsSL \
        https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh \
    )" "" --unattended
else
    warn "oh-my-bash already present, skipping"
fi

# ── 4. .vimrc ─────────────────────────────────────────────────────────────────
log "Copying .vimrc to \$HOME..."
cp "$SCRIPT_DIR/.vimrc" "$HOME/.vimrc"
# Fix any hardcoded home path left over from another machine
sed -i "s|/home/[^/]*/\.vim|$HOME/.vim|g" "$HOME/.vimrc"

# ── 5. .vim directory skeleton ────────────────────────────────────────────────
log "Creating .vim directory structure..."
mkdir -p "$HOME/.vim/bundle" "$HOME/.vim/colors"

# ── 6. Vundle ─────────────────────────────────────────────────────────────────
log "Installing Vundle..."
if [ ! -d "$HOME/.vim/bundle/Vundle.vim" ]; then
    git clone https://github.com/VundleVim/Vundle.vim.git \
        "$HOME/.vim/bundle/Vundle.vim"
else
    warn "Vundle already present, skipping"
fi

# ── 7. molokai color scheme ───────────────────────────────────────────────────
log "Installing molokai color scheme..."
MOLOKAI_TMP=$(mktemp -d)
git clone --depth 1 https://github.com/tomasr/molokai "$MOLOKAI_TMP/molokai"
cp "$MOLOKAI_TMP/molokai/colors/molokai.vim" "$HOME/.vim/colors/"
rm -rf "$MOLOKAI_TMP"

# ── 8. Vundle plugin install ──────────────────────────────────────────────────
log "Installing vim plugins via Vundle (this may take a while)..."
vim -E -s -u "$HOME/.vimrc" \
    +"set nomore" \
    +PluginInstall \
    +qall \
    </dev/null \
    2>&1 || true   # vim exits non-zero even on success in -E mode

# ── 9. fzf binary ─────────────────────────────────────────────────────────────
# The junegunn/fzf vim plugin ships fzf itself; wire up the binary.
log "Setting up fzf binary..."
FZF_PLUGIN="$HOME/.vim/bundle/fzf"
if [ -d "$FZF_PLUGIN" ] && [ -f "$FZF_PLUGIN/install" ]; then
    "$FZF_PLUGIN/install" --bin   # puts binary in $FZF_PLUGIN/bin, no shell rc edits
else
    warn "fzf plugin not found; falling back to apt"
    sudo apt-get install -y fzf
fi

# ── 10. YouCompleteMe ─────────────────────────────────────────────────────────
log "Compiling YouCompleteMe..."
YCM_DIR="$HOME/.vim/bundle/YouCompleteMe"
if [ ! -d "$YCM_DIR" ]; then
    die "YouCompleteMe was not installed by Vundle. Check vim plugin output above."
fi

# Ensure submodules are present (Vundle doesn't init them)
git -C "$YCM_DIR" submodule update --init --recursive

python3 "$YCM_DIR/install.py" --clangd-completer

# ── 11. Atuin ─────────────────────────────────────────────────────────────────
log "Installing atuin..."
if ! command -v atuin &>/dev/null; then
    bash -c "$(curl -fsSL https://setup.atuin.sh)" "" --unattended
else
    warn "atuin already installed, skipping"
fi

# ── Done ──────────────────────────────────────────────────────────────────────
log "Setup complete!"
log "  • Reload your shell or run: source ~/.bashrc"
log "  • Start a new tmux session to pick up oh-my-tmux"
log "  • If YCM C/C++ completions don't work, create ~/.vim/.ycm_extra_conf.py"
