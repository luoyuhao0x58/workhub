# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="dst"
HYPHEN_INSENSITIVE="true"
zstyle ':omz:update' mode disabled
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

HIST_STAMPS="yyyy-mm-dd"

zstyle ':omz:plugins:*' aliases no

plugins=(
  debian
  git
  command-not-found
)

source $ZSH/oh-my-zsh.sh
PROMPT='%F{242}[%D{%H:%M:%S}]%f%(?, ,%{$fg[red]%}FAIL%{$reset_color%}
)%{$fg[magenta]%}%n%{$reset_color%}@%{$fg[yellow]%}%m%{$reset_color%}: %{$fg_bold[blue]%}%1~%{$reset_color%}$(git_prompt_info)
$(prompt_char) '
RPROMPT=''

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

for filename in $(ls $HOME/.bashrc.d/*.sh 2>/dev/null | sort); do
  source "$filename"
done
