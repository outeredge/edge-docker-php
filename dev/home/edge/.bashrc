# Inspired by https://github.com/devcontainers/features/blob/main/src/common-utils

source /etc/profile.d/00-workspace-env.sh
source /etc/profile.d/edge-env.sh

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length
HISTSIZE=1000
HISTFILESIZE=2000

# enable color support of ls and also add handy aliases
eval "$(dircolors -b)"
alias ls='ls --color=auto'
alias grep='grep --color=auto'

# bash theme
__bash_prompt() {
    local lastcmdstatus='`export XIT=$? \
        && [ "$XIT" -ne "0" ] && echo -n "\[\033[1;31m\]  " || echo -n "  "`'
    local gitbranch='`\
        export BRANCH="$(git --no-optional-locks symbolic-ref --short HEAD 2>/dev/null || git --no-optional-locks rev-parse --short HEAD 2>/dev/null)"; \
        if [ "${BRANCH:-}" != "" ]; then \
            echo -n "\[\033[0;36m\](\[\033[1;31m\]${BRANCH:-}" \
            && if git --no-optional-locks ls-files --error-unmatch -m --directory --no-empty-directory -o --exclude-standard ":/*" > /dev/null 2>&1; then \
                echo -n " \[\033[1;33m\]✗"; \
            fi \
            && echo -n "\[\033[0;36m\])"; \
        fi`'
    local lightblue='\[\033[1;34m\]'
    local removecolor='\[\033[0m\]'
    local cleandir='`p="${PWD}"; if [[ "$p" == "$HOME"* ]]; then echo -n "~${p#$HOME}"; else echo -n "${p#/workspaces/}"; fi`'

    PS1="${lastcmdstatus}${lightblue}${cleandir}${gitbranch}${removecolor}\$ "
    unset -f __bash_prompt
}
__bash_prompt

# Enable bash completions
source /usr/share/bash-completion/completions/git

# Set common aliases
alias magento="$WEB_ROOT/bin/magento"
alias magerun2="magerun2 --root-dir=$WEB_ROOT"
alias magerun="magerun2"
alias nuke="$WEB_ROOT/bin/magento outeredge:nuke"
alias mysql="mysql --skip-ssl"
alias redis-cli="valkey-cli"
alias code="code-server"

# Set EDITOR to VS Code only if running inside VS Code's integrated terminal
if [ "$TERM_PROGRAM" = "vscode" ] || [ -n "$VSCODE_IPC_HOOK_CLI" ]; then
    export EDITOR="code-server --wait"
fi
