#!/usr/bin/env bash
# vim: ft=bash ts=2 sw=2 sts=2
#
# agnoster's Theme - https://gist.github.com/3712874
# A Powerline-inspired theme for BASH
#
# (Converted from ZSH theme by Kenny Root)
# https://gist.github.com/kruton/8345450
#
# Updated & fixed by Erik Selberg erik@selberg.org 1/14/17
# Tested on MacOSX, Ubuntu, Amazon Linux
# Bash v3 and v4
#
# # README
#
# In order for this theme to render correctly, you will need a
# [Powerline-patched font](https://gist.github.com/1595572).
# I recommend: https://github.com/powerline/fonts.git
# > git clone https://github.com/powerline/fonts.git fonts
# > cd fonts
# > install.sh

# In addition, I recommend the
# [Solarized theme](https://github.com/altercation/solarized/) and, if you're
# using it on Mac OS X, [iTerm 2](http://www.iterm2.com/) over Terminal.app -
# it has significantly better color fidelity.

# Install:

# I recommend the following:
# $ cd home
# $ mkdir -p .bash/themes/agnoster-bash
# $ git clone https://github.com/speedenator/agnoster-bash.git .bash/themes/agnoster-bash

# then add the following to your .bashrc:

# export THEME=$HOME/.bash/themes/agnoster-bash/agnoster.bash
# if [[ -f $THEME ]]; then
#     export DEFAULT_USER=`whoami`
#     source $THEME ${DEFAULT_USER}
# fi

#
# # Goals
#
# The aim of this theme is to only show you *relevant* information. Like most
# prompts, it will only show git information when in a git working directory.
# However, it goes a step further: everything from the current user and
# hostname to whether the last call exited with an error to whether background
# jobs are running in this shell will all be displayed automatically when
# appropriate.

# Generally speaking, this script has limited support for right
# prompts (ala powerlevel9k on zsh), but it's pretty problematic in Bash.
# The general pattern is to write out the right prompt, hit \r, then
# write the left. This is problematic for the following reasons:
# - Doesn't properly resize dynamically when you resize the terminal
# - Changes to the prompt (like clearing and re-typing, super common) deletes the prompt
# - Getting the right alignment via columns / tput cols is pretty problematic (and is a bug in this version)
# - Bash prompt escapes (like \h or \w) don't get interpolated
#
# all in all, if you really, really want right-side prompts without a
# ton of work, recommend going to zsh for now. If you know how to fix this,
# would appreciate it!

# note: requires bash v4+... Mac users - you often have bash3.
# 'brew install bash' will set you free

__ag_main(){
  >&2 echo -e "${*}"

  local options
  options=$(getopt -n 'rand_t' -o 'dvu:' \
    --long 'debug,verbose,user:' -- "${@}")
  eval set -- "${options}"

  local DEFAULT_USER
  local VERBOSE_MODE=false

  local -r CURRENT_BG='NONE'
  local -r CURRENT_RBG='NONE'
  local -r SEGMENT_SEPARATOR='▒░'
  local -r RIGHT_SEPARATOR='▒░'


  while [[ -n ${options} ]]; do
    case ${1} in
    -u | --user)
      DEFAULT_USER="${2}"
      shift 2
      ;;
    -v | -d | --debug | --verbose)
      VERBOSE_MODE=true
      shift 1
      ;;
    '--' | '')
      shift 1
      break
      ;;
    *)
      echo "Unknown parameter '${1}'." >&0
      shift 1
      ;;
    esac
  done

  PROMPT_COMMAND=__ag_set_bash_prompt
}

__ag_debug() {
  if [[ ${VERBOSE_MODE} == true ]]; then
    local -ir offset=2
    local -r func="${FUNCNAME[${offset}]}"
    local -r line="${BASH_LINENO[${offset}]}"
    >&2 echo -e "${func}[${line}] ${*}"
  fi
}

######################################################################
### Segment drawing
# A few utility functions to make it easy and re-usable to draw segmented prompts


__ag_text_effect() {
  case "$1" in
    reset)      echo 0;;
    bold)       echo 1;;
    underline)  echo 4;;
  esac
}

__ag_fg_color() {
  case "$1" in
    black)          echo 30;;
    darkred)        echo 31;;
    darkgreen)      echo 32;;
    yellow)         echo 33;;
    darkblue)       echo 34;;
    darkmagenta)    echo 35;;
    darkcyan)       echo 36;;
    white)          echo 37;;
    darkgray)       echo 90;;
    red)            echo 91;;
    green)          echo 92;;
    orange)         echo 93;;
    blue)           echo 94;;
    magenta)        echo 95;;
    cyan)           echo 96\;5\;166;;
  esac
}

__ag_bg_color() {
  case "$1" in
    black)          echo 40;;
    darkred)        echo 41;;
    darkgreen)      echo 42;;
    yellow)         echo 43;;
    darkblue)       echo 44;;
    darkmagenta)    echo 45;;
    darkcyan)       echo 46;;
    white)          echo 47;;
    darkgray)       echo 100;;
    red)            echo 101;;
    green)          echo 102;;
    orange)         echo 103;;
    blue)           echo 104;;
    magenta)        echo 105;;
    cyan)           echo 106\;5\;166;;
  esac;
}

__ag_ansi() {
  local seq
  local -a codes=("${@}")
  __ag_debug "__ag_ansi: $* aka ${codes[*]}"
  seq=""
  for ((i = 0; i < ${#codes[@]}; i++)); do
      if [[ -n $seq ]]; then
          seq="${seq};"
      fi
      seq="${seq}${codes[$i]}"
  done
  __ag_debug "__ag_ansi __ag_debug:" '\\[\\033['"${seq}"'m\\]'
  echo -ne '\[\033['"${seq}"'m\]'
  # PR="$PR\[\033[${seq}m\]"
}

__ag_ansi_single() {
    echo -ne '\[\033['"${1}"'m\]'
}

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
__ag_prompt_segment() {
    local bg fg
    local -a codes
    __ag_debug "Prompting 1=${1} 2=${2} 3=${3}"
    codes=(
      "${codes[@]}"
    )

    if [[ -n $1 ]]; then
        bg=$(__ag_bg_color "${1}")
        codes=(
          "${codes[@]}"
          "${bg}"
        )
        __ag_debug "Added ${bg} as background to codes"
    fi
    if [[ -n $2 ]]; then
        fg=$(__ag_fg_color "${2}")
        codes=(
          "${codes[@]}"
          "${fg}"
        )
        __ag_debug "Added ${fg} as foreground to codes"
    fi

    __ag_debug "Codes: "

    if [[ "${CURRENT_BG}" != NONE && ${1} != "${CURRENT_BG}" ]]; then
        local -a intermediate=(
          "$(__ag_fg_color "${CURRENT_BG}")"
          "$(__ag_bg_color "${1}")"
        )
        local pre_prompt
        pre_prompt=$(__ag_ansi "${intermediate[@]}")
        __ag_debug "pre prompt ${pre_prompt}"
        PR="$PR ${pre_prompt}${SEGMENT_SEPARATOR}"
        local post_prompt
        post_prompt=$(__ag_ansi "${codes[@]}")
        __ag_debug "post prompt ${post_prompt}"
        PR="${PR}${post_prompt} "
    else
        local post_prompt
        post_prompt=$(__ag_ansi "${codes[@]}")
        __ag_debug "no current BG, codes is ${codes[*]}"
        PR="${PR}${post_prompt}"
    fi
    CURRENT_BG=${1}
    if [[ -n ${3} ]]; then
        PR="${PR}${3}"
    fi
}

# End the prompt, closing any open segments
__ag_prompt_end() {
    if [[ -n $CURRENT_BG ]]; then
        local -a codes=(
          "$(__ag_text_effect reset)"
          "$(__ag_fg_color "${CURRENT_BG}")"
        )
        PR="$PR $(__ag_ansi "${codes[@]}")$SEGMENT_SEPARATOR"
    fi
    local -a reset=(
      "$(__ag_text_effect reset)"
    )
    PR="$PR $(__ag_ansi "${reset[@]}")"
    CURRENT_BG=''
}

### virtualenv prompt
__ag_prompt_virtualenv() {
    if [[ -n $VIRTUAL_ENV ]]; then
        color=cyan
        __ag_prompt_segment "${color}" "${PRIMARY_FG}"
        __ag_prompt_segment "${color}" white "$(basename "${VIRTUAL_ENV}")"
    fi
}


### Prompt components
# Each component will draw itself, and hide itself if no information needs to be shown

# Context: user@hostname (who am I and where am I)
__ag_prompt_context() {
    local user
    user="$(whoami)"

    if [[ "${user}" != "${DEFAULT_USER}" || -n "${SSH_CLIENT}" ]]; then
        __ag_prompt_segment black default "$user@\h"
    fi
}

# prints history followed by HH:MM, useful for remembering what
# we did previously
__ag_prompt_histdt() {
	__ag_prompt_segment black default "\! (\A)"
}


__ag_git_status_dirty() {
    dirty=$(git status -s 2> /dev/null | tail -n 1)
    if [[ -n $dirty ]]; then 
      echo " ●"
    fi
}

__ag_git_stash_dirty() {
    stash=$(git stash list 2> /dev/null | tail -n 1)
    if [[ -n $stash ]]; then 
      echo " ⚑"
    fi
}

# Git: branch/detached head, dirty status
__ag_prompt_git() {
    local ref dirty
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        # ZSH_THEME_GIT_PROMPT_DIRTY='±'
        dirty=$(__ag_git_status_dirty)
        stash=$(__ag_git_stash_dirty)
        ref=$(git symbolic-ref HEAD 2> /dev/null) \
            || ref="➦ $(git describe --exact-match --tags HEAD 2> /dev/null)" \
            || ref="➦ $(git show-ref --head -s --abbrev | head -n1 2> /dev/null)"
        if [[ -n $dirty ]]; then
            __ag_prompt_segment yellow black
        else
            __ag_prompt_segment green black
        fi
        PR="$PR${ref/refs\/heads\// }$stash$dirty"
    fi
}

# Mercurial: clean, modified and uncommited files
__ag_prompt_hg() {
    local rev st branch
    if hg id >/dev/null 2>&1; then
        if hg prompt >/dev/null 2>&1; then
            if [[ $(hg prompt "{status|unknown}") = "?" ]]; then
                # if files are not added
                __ag_prompt_segment red white
                st='±'
            elif [[ -n $(hg prompt "{status|modified}") ]]; then
                # if any modification
                __ag_prompt_segment yellow black
                st='±'
            else
                # if working copy is clean
                __ag_prompt_segment green black "${CURRENT_BG}"
            fi
            PR="$PR$(hg prompt "☿ {rev}@{branch}") $st"
        else
            st=""
            rev=$(hg id -n 2>/dev/null | sed 's/[^-0-9]//g')
            branch=$(hg id -b 2>/dev/null)
            if hg st | grep -q "^\?"; then
                __ag_prompt_segment red white
                st='±'
            elif hg st | grep -q "^[MA]"; then
                __ag_prompt_segment yellow black
                st='±'
            else
                __ag_prompt_segment green black "${CURRENT_BG}"
            fi
            PR="$PR☿ $rev@$branch $st"
        fi
    fi
}


_LINE=1;

__ag_prompt_line() {
    __ag_prompt_segment black orange "║ ${_LINE} ║";
    _LINE=$((_LINE+1));
}


__ag_prompt_date() {
    __ag_prompt_segment black darkgray "$(date +%H┋%M┋%S)"
}


# Dir: current working directory
__ag_prompt_dir() {
    __ag_prompt_segment darkcyan black '\w'
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
__ag_prompt_status() {
    local symbols
    local red yellow cyan
    red=$(__ag_fg_color red)
    yellow=$(__ag_fg_color yellow)
    cyan=$(__ag_fg_color cyan)

    symbols=()
    if [[ $RETVAL -ne 0 ]]; then
      symbols+=("$(__ag_ansi_single "${red}")✘")
    fi
    if [[ $UID -eq 0 ]]; then
      symbols+=("$(__ag_ansi_single "${yellow}")⚡")
    fi
    if [[ $(jobs -l | wc -l) -gt 0 ]]; then
      symbols+=("$(__ag_ansi_single "${cyan}")⚙")
    fi
    if [[ -n "${symbols[*]}" ]]; then
      __ag_prompt_segment black default "$symbols"
    fi
    true
}

######################################################################
#
# experimental right prompt stuff
# requires setting prompt_foo to use PRIGHT vs PR
# doesn't quite work per above

__ag_right_prompt() {
    printf "%*s" "${COLUMNS}" "${PRIGHT}"
}

# quick right prompt I grabbed to test things.
__ag_command_right_prompt() {
    local times=" n=${COLUMNS} tz"
    for tz in 'ZRH:Europe/Zurich' 'PIT:US/Eastern' \
              'MTV:US/Pacific' 'TOK:Asia/Tokyo'; do
        if [[ $n -le 40 ]]; then
          break
        fi
        times="$times ${tz%%:*}\e[30;1m:\e[0;36;1m"
        times="$times$(TZ=${tz#*:} date +%H:%M)\e[0m"
        n=$(( n - 10 ))
    done
    if [[ -n "$times" ]]; then
        printf "%${n}s$times\\r" ''
    fi
}

# this doesn't wrap code in \[ \]
__ag_ansi_r() {
    local seq
    local -a codes=("${@}")

    __ag_debug "__ag_ansi:  all: ${*} aka ${codes[*]}"

    seq=""
    for ((i = 0; i < ${#codes[@]}; i++)); do
        if [[ -n $seq ]]; then
            seq="${seq};"
        fi
        seq="${seq}${codes[$i]}"
    done
    __ag_debug "__ag_ansi __ag_debug:" '\\[\\033['"${seq}"'m\\]'
    echo -ne '\033['"${seq}"'m'
    # PR="$PR\[\033[${seq}m\]"
}

# Begin a segment on the right
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
__ag_prompt_right_segment() {
    local bg fg
    local -a codes

    __ag_debug "Prompt right"
    __ag_debug "Prompting $1 $2 $3"

    local te
    te="$(__ag_text_effect reset)"
    codes=(
      "${codes[@]}"
      "${te}"
    )
    if [[ -n $1 ]]; then
        bg=$(__ag_bg_color "${1}")
        codes=(
          "${codes[@]}"
          "${bg}"
        )
        __ag_debug "Added $bg as background to codes"
    fi
    if [[ -n $2 ]]; then
        fg=$(__ag_fg_color "${2}")
        codes=(
          "${codes[@]}"
          "${fg}"
        )
        __ag_debug "Added $fg as foreground to codes"
    fi

    __ag_debug "Right Codes: "
    # declare -p codes

    # right always has a separator
    # if [[ $CURRENT_RBG != NONE && $1 != $CURRENT_RBG ]]; then
    #     $CURRENT_RBG=
    # fi
    local -a intermediate=(
      "$(__ag_fg_color "${1}")"
      "$(__ag_bg_color "${CURRENT_RBG}")"
    )
    # PRIGHT="$PRIGHT---"
    local pre_prompt
    pre_prompt=$(__ag_ansi_r "${intermediate[@]}")
    __ag_debug "pre prompt ${pre_prompt}"
    PRIGHT="${PRIGHT}${pre_prompt}${RIGHT_SEPARATOR}"
    local post_prompt
    post_prompt=$(__ag_ansi_r "${codes[@]}")
    __ag_debug "post prompt ${post_prompt}"
    PRIGHT="${PRIGHT}${post_prompt} "
    # else
    #     __ag_debug "no current BG, codes is $codes[@]"
    #     PRIGHT="$PRIGHT$(__ag_ansi codes[@]) "
    # fi
    CURRENT_RBG=$1
    if [[ -n ${3} ]]; then
      PRIGHT="${PRIGHT}${3}"
    fi
}

######################################################################
## Emacs prompt --- for dir tracking
# stick the following in your .emacs if you use this:

# (setq dirtrack-list '(".*DIR *\\([^ ]*\\) DIR" 1 nil))
# (defun dirtrack-filter-out-pwd-prompt (string)
#   "dirtrack-mode doesn't remove the PWD match from the prompt.  This does."
#   ;; TODO: support dirtrack-mode's multiline regexp.
#   (if (and (stringp string) (string-match (first dirtrack-list) string))
#       (replace-match "" t t string 0)
#     string))
# (add-hook 'shell-mode-hook
#           #'(lambda ()
#               (dirtrack-mode 1)
#               (add-hook 'comint-preoutput-filter-functions
#                         'dirtrack-filter-out-pwd-prompt t t)))

prompt_emacsdir() {
    # no color or other setting... this will be deleted per above
    PR="DIR \w DIR$PR"
}

######################################################################
## Main prompt

__ag_build_prompt() {
    __ag_prompt_line
    __ag_prompt_date
    if [[ -n "${AG_EMACS_DIR+x}" ]]; then
      prompt_emacsdir
    fi
    __ag_prompt_status
    #[[ -z ${AG_NO_HIST+x} ]] && __ag_prompt_histdt
    if [[ -z "${AG_NO_CONTEXT+x}" ]]; then
        __ag_prompt_context
    fi
    __ag_prompt_virtualenv
    __ag_prompt_dir
    __ag_prompt_git
    __ag_prompt_hg
    __ag_prompt_end
}

__ag_set_bash_prompt() {
  RETVAL=$?
  PR=""
  PRIGHT=""
  CURRENT_BG=NONE
  local te
  te="$(__ag_text_effect reset)"
  PR="$(__ag_ansi_single "${te}")"
  __ag_build_prompt


  # uncomment below to use right prompt
  # PS1='\[$(tput sc; printf "%*s" $COLUMNS "$PRIGHT"; tput rc)\]'$PR
  PS1="$PR"
}


__ag_main "${@}"
