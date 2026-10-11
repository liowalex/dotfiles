# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Homebrew PATH is set in ~/.zprofile

# ---------------------------------------------------------------------------
# oh-my-zsh
# ---------------------------------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
zstyle ':omz:update' mode reminder

# zsh-completions must be on fpath before oh-my-zsh runs compinit
fpath+=${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-completions/src

# zsh-syntax-highlighting must stay last
plugins=(git z web-search zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# ---------------------------------------------------------------------------
# History: keep (practically) everything, forever
# ---------------------------------------------------------------------------
HISTFILE="$HOME/.zsh_history"
HISTSIZE=1000000
SAVEHIST=1000000
setopt EXTENDED_HISTORY        # save timestamp + duration
setopt INC_APPEND_HISTORY      # write immediately, not on shell exit
setopt SHARE_HISTORY           # share across open tabs
setopt HIST_IGNORE_DUPS        # skip immediate repeats
setopt HIST_IGNORE_SPACE       # prefix a command with a space to keep it out
setopt HIST_REDUCE_BLANKS
HIST_STAMPS="yyyy-mm-dd"

# ---------------------------------------------------------------------------
# Tooling
# ---------------------------------------------------------------------------
export EDITOR="code --wait"

# Claude Code (native install: curl -fsSL https://claude.ai/install.sh | bash)
export PATH="$HOME/.local/bin:$PATH"

# mise: Node / Python versions (mise use -g node@lts, mise use python@3.13)
command -v mise >/dev/null && eval "$(mise activate zsh)"

# direnv: auto-activate devenv / .envrc when you cd into a project
command -v direnv >/dev/null && eval "$(direnv hook zsh)"

# fzf: Ctrl-R fuzzy history, Ctrl-T file picker, Alt-C fuzzy cd
command -v fzf >/dev/null && source <(fzf --zsh)

# ---------------------------------------------------------------------------
# Aliases
# ---------------------------------------------------------------------------
alias ls="ls -p -G"
alias la="ls -A"
alias ll="eza -l -g --icons --git"
alias lla="ll -A"
alias lt="eza --tree --level=2 -a --ignore-glob=.git"

alias ws="cd ~/workspaces"

# ssh agent switch commands (for using multiple keys with multiple github accts)
alias ssh-add-public="ssh-add -D; ssh-add ~/.ssh/id_ed25519"
alias ssh-add-private="ssh-add -D; ssh-add ~/.ssh/id_ed25519_30yo-without-401k"
alias ssh-add-owl="ssh-add -D; ssh-add ~/.ssh/id_ed25519_the0w1"

# git commands
alias g="git"
alias gs="git status"
alias gc="git commit"
alias gr="git remote -v"
alias gl="git log"
alias gp="git pull"
alias glo="git log --graph --decorate --pretty=oneline --abbrev-commit"

# local AI services (launchd agents in ~/Library/LaunchAgents)
# stop lasts until next login; start/stop don't change whether they run at login
_agent_start() {
  local plist="$HOME/Library/LaunchAgents/$1.plist"
  [[ -f "$plist" ]] || { echo "no launch agent at $plist"; return 1; }
  if launchctl print "gui/$(id -u)/$1" &>/dev/null; then
    echo "$1 already loaded"
  else
    launchctl bootstrap "gui/$(id -u)" "$plist" && echo "$1 started"
  fi
}
_agent_stop() {
  if launchctl print "gui/$(id -u)/$1" &>/dev/null; then
    launchctl bootout "gui/$(id -u)/$1" && echo "$1 stopped"
  else
    echo "$1 not running"
  fi
}
alias llama-start="_agent_start local.llama-server"
alias llama-stop="_agent_stop local.llama-server"
alias hermes-start="_agent_start ai.hermes.gateway"
alias hermes-stop="_agent_stop ai.hermes.gateway"
alias loop-start="_agent_start tech.gud.agentloop"
alias loop-stop="_agent_stop tech.gud.agentloop"
alias ai-status="launchctl list | grep -E 'llama|hermes|tech.gud' || echo 'none running'"

# zsh-autosuggestions color
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8,bg=cyan,bold,underline"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
