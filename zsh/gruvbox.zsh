# Gruvbox colors for Powerlevel10k (lean style) and fzf.
# Sourced from ~/.zshrc after ~/.p10k.zsh – only overrides colors, nothing else.

# ── Palette ──────────────────────────────────────────────
local gb_bg='#282828' gb_bg1='#3c3836' gb_gray='#928374' gb_fg='#ebdbb2' gb_fg4='#a89984'
local gb_red='#fb4934' gb_green='#b8bb26' gb_yellow='#fabd2f' gb_blue='#83a598'
local gb_purple='#d3869b' gb_aqua='#8ec07c' gb_orange='#fe8019'

# ── Prompt character ❯ ──────────────────────────────────
typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=$gb_green
typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=$gb_red

# ── Directory ───────────────────────────────────────────
typeset -g POWERLEVEL9K_DIR_FOREGROUND=$gb_blue
typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=$gb_gray
typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=$gb_aqua

# ── Git ─────────────────────────────────────────────────
typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=$gb_green
typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=$gb_aqua
typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=$gb_yellow
typeset -g POWERLEVEL9K_VCS_LOADING_FOREGROUND=$gb_gray
typeset -g POWERLEVEL9K_VCS_VISUAL_IDENTIFIER_COLOR=$gb_green

# ── Status, timing, jobs, time ──────────────────────────
typeset -g POWERLEVEL9K_STATUS_OK_FOREGROUND=$gb_green
typeset -g POWERLEVEL9K_STATUS_OK_PIPE_FOREGROUND=$gb_green
typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=$gb_red
typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_FOREGROUND=$gb_red
typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE_FOREGROUND=$gb_red
typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=$gb_yellow
typeset -g POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND=$gb_aqua
typeset -g POWERLEVEL9K_TIME_FOREGROUND=$gb_gray

# ── Context (user@host), environments ───────────────────
typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND=$gb_fg4
typeset -g POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND=$gb_red
typeset -g POWERLEVEL9K_CONTEXT_{REMOTE,REMOTE_SUDO}_FOREGROUND=$gb_yellow
typeset -g POWERLEVEL9K_VIRTUALENV_FOREGROUND=$gb_aqua
typeset -g POWERLEVEL9K_ANACONDA_FOREGROUND=$gb_aqua
typeset -g POWERLEVEL9K_PYENV_FOREGROUND=$gb_aqua
typeset -g POWERLEVEL9K_NODENV_FOREGROUND=$gb_green
typeset -g POWERLEVEL9K_NVM_FOREGROUND=$gb_green
typeset -g POWERLEVEL9K_NODE_VERSION_FOREGROUND=$gb_green
typeset -g POWERLEVEL9K_GO_VERSION_FOREGROUND=$gb_blue
typeset -g POWERLEVEL9K_RUST_VERSION_FOREGROUND=$gb_orange
typeset -g POWERLEVEL9K_JAVA_VERSION_FOREGROUND=$gb_orange
typeset -g POWERLEVEL9K_KUBECONTEXT_DEFAULT_FOREGROUND=$gb_purple
typeset -g POWERLEVEL9K_AWS_DEFAULT_FOREGROUND=$gb_yellow
typeset -g POWERLEVEL9K_VIM_SHELL_FOREGROUND=$gb_green
typeset -g POWERLEVEL9K_DIRENV_FOREGROUND=$gb_yellow

# Apply to an already-running prompt
(( ${+functions[p10k]} )) && p10k reload 2>/dev/null

# ── fzf ─────────────────────────────────────────────────
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:+$FZF_DEFAULT_OPTS }\
--color=bg+:$gb_bg1,bg:-1,spinner:$gb_aqua,hl:$gb_yellow,fg:$gb_fg4,header:$gb_gray,info:$gb_aqua,pointer:$gb_orange,\
marker:$gb_orange,fg+:$gb_fg,prompt:$gb_yellow,hl+:$gb_yellow,border:$gb_bg1"

unset gb_bg gb_bg1 gb_gray gb_fg gb_fg4 gb_red gb_green gb_yellow gb_blue gb_purple gb_aqua gb_orange
