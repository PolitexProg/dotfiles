# #######################################################################################
# CLEAN & FAST ZSH CONFIG (ARCH LINUX / HYPRLAND) - Ver. 10/10
# #######################################################################################

# 1. POWERLEVEL10K INSTANT PROMPT (Должен быть в самом верху)
# Подавляем вывод только для этапа инициализации
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# 2. ENVIRONMENT & PATH
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.pyenv/bin:$PATH"
typeset -U path # Убирает дубликаты из PATH
ZSH_DISABLE_COMPFIX=true

# 3. THEME SELECTION LOGIC
THEME_LOCKFILE="$HOME/.cache/zsh_use_p10k"

if [[ -f "$THEME_LOCKFILE" ]]; then
    ZSH_THEME="powerlevel10k/powerlevel10k"
    # Авто-установка P10K если отсутствует
    [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]] && \
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
else
    ZSH_THEME="robbyrussell" # Фолбэк для Starship
fi

# 4. LAZY LOAD PYTHON (Pyenv) - Оптимизировано
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"

_pyenv_init() {
    eval "$(pyenv init - --path 2>/dev/null)"
    eval "$(pyenv virtualenv-init - 2>/dev/null)"
    unset -f _pyenv_init python pip python3
}
python() { _pyenv_init; command python "$@"; }
python3() { _pyenv_init; command python3 "$@"; }
pip() { _pyenv_init; command pip "$@"; }

# 5. OH MY ZSH INIT
export ZSH="$HOME/.oh-my-zsh"

plugins=(
    git git-auto-fetch zsh-autosuggestions zsh-syntax-highlighting
    web-search zsh-history-substring-search extract
)

# Авто-установка плагинов
for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
    [[ ! -d $ZSH/custom/plugins/$plugin ]] && \
        git clone https://github.com/zsh-users/$plugin $ZSH/custom/plugins/$plugin
done

source $ZSH/oh-my-zsh.sh

# 6. THEME INITIALIZATION (После OMZ)
if [[ -f "$THEME_LOCKFILE" ]]; then
    [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
else
    export STARSHIP_CONFIG=~/.config/starship.toml
    if command -v starship &> /dev/null; then
        eval "$(starship init zsh)"
    fi
fi

# 7. HISTORY & SYSTEM SETTINGS
HISTSIZE=100000
SAVEHIST=100000
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE IGNORE_EOF CORRECT
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# #######################################################################################
# ALIASES & FUNCTIONS
# #######################################################################################

# --- SYSTEM ---
alias update="$(command -v yay &>/dev/null && echo "yay" || echo "sudo pacman") -Syu"
alias reload="zsh -n ~/.zshrc && source ~/.zshrc && echo 'ZSH config reloaded!'"
alias clr="clear"
alias path='echo -e ${PATH//:/\\n}'
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias zshconf="code ~/.zshrc"
# Управление питанием (Power Management)
alias poweroff='sudo systemctl poweroff'
alias reboot='sudo systemctl reboot'
alias suspend='sudo systemctl suspend'
alias hibernate='sudo systemctl hibernate'
alias drop-cache='sudo sync; echo 3 | sudo tee /proc/sys/vm/drop_caches'

# Быстрые сокращения (еще короче)
alias po='sudo systemctl poweroff'
alias rb='sudo systemctl reboot'
alias zz='sudo systemctl suspend'

# Проверка состояния (полезно для Arch)
alias listsys='systemctl list-units --type=service --state=running' # список запущенных сервисов
alias failed='systemctl --failed' # проверка упавших сервисов
# --- RM IMPROVED (Safe Delete) ---
unalias rm 2>/dev/null
rm() {
    [[ $# -eq 0 ]] && { echo "No files specified."; return 1 }

    if command -v rip &> /dev/null; then
        echo "Files to delete: $*"
        # -q значит "прочитать 1 символ", не нужен Enter
        if read -q "choice?Send to RIP graveyard? [y/N]: "; then
            echo "\nSent to graveyard."
            command rip "$@"
        else
            echo "\nCancelled."
        fi
    else
        command rm -i "$@"
    fi
}

# --- MODERN TOOLS ---
if command -v eza &> /dev/null; then
    alias ls="eza --icons --group-directories-first --time-style=long-iso"
    alias ll="eza -la --icons --group-directories-first --git"
    alias lt="eza --tree --icons --level=2"
fi

if command -v bat &> /dev/null; then
    alias cat="bat --theme=Nord --style=plain"
fi

alias grep="rg --color=auto"
alias du="ncdu --color dark"

# --- DEV & GIT ---
alias venv="python -m venv .venv && source .venv/bin/activate && pip install -U pip"
alias activate="[[ -f .venv/bin/activate ]] && source .venv/bin/activate"
alias gst="git status -sb"
alias gl="git log --oneline --graph --all"

# --- FUNCTIONS ---
toggletheme() {
    [[ -f "$THEME_LOCKFILE" ]] && rm "$THEME_LOCKFILE" || touch "$THEME_LOCKFILE"
    echo "Theme toggled. Restarting shell..."
    exec zsh
}

function info() {
    local PRJ="$HOME/SystemSctipts/1"
    [[ -d "$PRJ/venv" ]] && { source "$PRJ/venv/bin/activate"; python3 "$PRJ/main.py" "$@"; deactivate } || echo "Venv not found."
}

# #######################################################################################
# INITIALIZATION
# #######################################################################################

# Zoxide & FZF
command -v zoxide &> /dev/null && eval "$(zoxide init zsh --cmd cd)"
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh || { command -v fzf &>/dev/null && source <(fzf --zsh) }

# Fastfetch (Fix Instant Prompt)
if command -v fastfetch &> /dev/null; then
    # Запускаем только если это НЕ фоновый процесс p10k
    if [[ -z "$P9K_TTY" || "$P9K_TTY" == "old" ]]; then
        fastfetch
    fi
fi

. "$HOME/.local/share/../bin/env"
