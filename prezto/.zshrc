#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# alias
alias ll="ls -lt"
alias la="ls -alt"
alias sss="source ~/.zshrc"
function mlx_lm.generate() {
  "$(ghq root)/github.com/ml-explore/mlx-lm/.venv/bin/mlx_lm.generate" "$@"
}

# M1 Mac brew
PATH="/opt/homebrew/bin:$PATH"

# Rust
CARGO_HOME="$HOME/.cargo"
PATH="$CARGO_HOME/bin:$PATH"

# Node.js
NVS_HOME="$HOME/.nvs"
# invoke as just `nvs` without any path
if [[ -s "${NVS_HOME}/nvs.sh" ]]; then
  . "${NVS_HOME}/nvs.sh" install
fi

# Android
ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
PATH="$ANDROID_SDK_ROOT/platform-tools:$PATH"
PATH="$ANDROID_SDK_ROOT/emulator:$PATH"

# fzf
eval "$(fzf --zsh)"

# ghq + fzf: Ctrl+G でリポジトリを選択して移動
function ghq-fzf() {
  local repo
  repo=$(ghq list | fzf --preview "ls $(ghq root)/{}" --preview-window=right:50%)
  if [[ -n "$repo" ]]; then
    cd "$(ghq root)/$repo"
  fi
  zle reset-prompt
}
zle -N ghq-fzf
bindkey '^g' ghq-fzf

# ghq + fzf + code: Ctrl+O でリポジトリを選択して VS Code で開く
function ghq-fzf-code() {
  local repo
  repo=$(ghq list | fzf --preview "ls $(ghq root)/{}" --preview-window=right:50%)
  if [[ -n "$repo" ]]; then
    code "$(ghq root)/$repo"
  fi
  zle reset-prompt
}
zle -N ghq-fzf-code
bindkey '^o' ghq-fzf-code