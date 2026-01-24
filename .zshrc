# #######################################################################################
# 🚀 ULTRA-ZSH CONFIG (ARCH / HYPRLAND / UV / DOTFILES)
# #######################################################################################

# 1. P10K INSTANT PROMPT
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# 2. ENVIRONMENT & PATH
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
export ZSH="$HOME/.oh-my-zsh"
export STARSHIP_CONFIG=~/.config/starship.toml
typeset -U path
ZSH_DISABLE_COMPFIX=true

# 3. THEME LOGIC
THEME_LOCKFILE="$HOME/.cache/zsh_use_p10k"
[[ -f "$THEME_LOCKFILE" ]] && ZSH_THEME="powerlevel10k/powerlevel10k" || ZSH_THEME="robbyrussell"

# 4. PLUGINS (Auto-install)
plugins=(git git-auto-fetch zsh-autosuggestions zsh-syntax-highlighting web-search zsh-history-substring-search extract)
for p in zsh-autosuggestions zsh-syntax-highlighting; do
    [[ ! -d $ZSH/custom/plugins/$p ]] && git clone --depth=1 https://github.com/zsh-users/$p $ZSH/custom/plugins/$p
done
source $ZSH/oh-my-zsh.sh

# 5. TOOL INIT
[[ -f "$THEME_LOCKFILE" && -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
[[ ! -f "$THEME_LOCKFILE" ]] && command -v starship &>/dev/null && eval "$(starship init zsh)"
command -v zoxide &>/dev/null && eval "$(zoxide init zsh --cmd cd)"
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh || { command -v fzf &>/dev/null && source <(fzf --zsh) }
command -v uv &>/dev/null && eval "$(uv generate-shell-completion zsh)"

# #######################################################################################
# ALIASES SECTION
# #######################################################################################

# --- PACKAGE MANAGER ---
PAC_HELPER=$(command -v yay || command -v paru || echo "sudo pacman")
alias up="$PAC_HELPER -Syu"
alias install="$PAC_HELPER -S"
alias search="$PAC_HELPER -Ss"
alias info="$PAC_HELPER -Qi"
alias remove="sudo pacman -Rns"
alias cleanup="sudo pacman -Rns \$(pacman -Qdtq)"
alias cleanpkg="sudo paccache -rk2"
alias bigpkg="expac -S '%-20n %m' | sort -rhk 2 | head -n 10"
alias installed="pacman -Q"
alias check="command -v checkupdates &>/dev/null && checkupdates || $PAC_HELPER -Qu"

# --- SYSTEM & UTILS ---
alias clr="clear"
alias reload="exec zsh"
alias path='echo -e ${PATH//:/\\n}'
alias zshconf="code ~/.zshrc"
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias tofish='exec fish'
alias music='cd ~/Music && uv run --project ~/Projects/PythonProjects/tui-player ~/Projects/PythonProjects/tui-player/main.py'
# Power Management
alias poweroff='sudo systemctl poweroff'
alias reboot='sudo systemctl reboot'
alias suspend='sudo systemctl suspend'
alias po='poweroff'; alias rb='reboot'; alias zz='suspend'
alias drop-cache='sudo sync; echo 3 | sudo tee /proc/sys/vm/drop_caches'
alias listsys='systemctl list-units --type=service --state=running'
alias failed='systemctl --failed'

# --- HYPRLAND FULL SUITE ---
alias hypr='code ~/.config/hypr/hyprland.conf'
alias hyprconf='cd ~/.config/hypr && nvim'
alias hyprfiles='cd ~/.config/hypr'
alias hyprreload='hyprctl reload'
alias hypr-display='hyprctl monitors'
alias hypr-devices='hyprctl devices'
alias hypr-binds='hyprctl binds'
alias hypr-activewindow='hyprctl activewindow'
alias hypr-log='journalctl -fu hyprland -b 0 | grep -E "(ERROR|WARN|hyprland)"'
alias hypr-vram='command -v radeontop &>/dev/null && radeontop -d - || nvidia-smi'
alias waybar-conf='nvim ~/.config/waybar/config'
alias waybar-style='nvim ~/.config/waybar/style.css'

# --- MODERN CLI TOOLS ---
if command -v eza &>/dev/null; then
    alias ls="eza --icons --group-directories-first"
    alias ll="eza -la --icons --group-directories-first --git"
    alias lt="eza --tree --icons --level=2"
fi
command -v bat &>/dev/null && alias cat="bat --theme=Nord --style=plain"
command -v rg &>/dev/null && alias grep="rg --color=auto"
command -v ncdu &>/dev/null && alias du="ncdu --color dark"

# --- RIP (Safe Delete) MANAGEMENT ---
if command -v rip &>/dev/null; then
    alias rip-list="rip -s"       # Показать файлы в текущей директории (seance)
    alias rip-undo="rip -u"       # Восстановить последний
    alias rip-empty="rip -d"      # Полная очистка кладбища (decompose)
fi

# --- DEV, GIT & UV ---
alias venv="uv venv"
alias activate="source .venv/bin/activate"
alias python="uv run python"
alias pip="uv pip"
alias gst="git status -sb"
alias gl="git log --oneline --graph --all"
alias vikunja-start='cd ~/vikunja && docker-compose up -d'
alias vikunja-stop='cd ~/vikunja && docker-compose down'

# #######################################################################################
# FUNCTIONS
# #######################################################################################

# Безопасный RM
rm() {
    if command -v rip &>/dev/null; then
        echo "Files to delete: $*"
        read -q "choice?Send to RIP graveyard? [y/N]: " && { echo "\nSent."; command rip "$@"; } || echo "\nCancelled."
    else
        command rm -i "$@"
    fi
}

# Тема
toggletheme() {
    [[ -f "$THEME_LOCKFILE" ]] && rm "$THEME_LOCKFILE" || touch "$THEME_LOCKFILE"
    exec zsh
}

# Твой скрипт (переименован во избежание конфликта с pacman info)
sysinfo() {
    local PRJ="$HOME/SystemSctipts/1"
    [[ -d "$PRJ/.venv" ]] && "$PRJ/.venv/bin/python" "$PRJ/main.py" "$@" || echo "Venv not found."
}

# #######################################################################################
# FINAL SETUP
# #######################################################################################
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE CORRECT
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

fastfetch
export PATH=$PATH:~/.npm-global/bin
