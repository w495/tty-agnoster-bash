#!/usr/bin/env bash
# shellcheck enable=all

# ---------------------------------------------------------------
#     shfmt -ci -i 2 -sr -s -bn -kp -ln bash -d
# ---------------------------------------------------------------

### Prompt components
# Each component will draw itself,
# and hide itself if no information needs to be shown
source "$(dirname "${BASH_SOURCE[0]}")/lib/parts.bash"
source "$(dirname "${BASH_SOURCE[0]}")/lib/experimental.bash"

export __TTY_AG_DEFAULT_USER
export __TTY_AG_RETVAL
export __TTY_AG_LEFT_SEGMENT_SEPARATOR
export __TTY_AG_RIGHT_SEGMENT_SEPARATOR
export __TTY_AG_VERBOSE_MODE
export __TTY_AG_DEBUG_MODE
export __TTY_AG_RIGHT_PROMPT
export __TTY_AG_RIGHT_WINDOW
export __TTY_AG_BOTTOM_WINDOW
export __TTY_AG_TOP_WINDOW
export __TTY_AG_PS1L
export __TTY_AG_PS1R
export __TTY_AG_CURRENT_LBG=NONE
export __TTY_AG_CURRENT_RBG=NONE

__tty_ag_main() {
  local opts
  local this="${BASH_SOURCE[0]}"
  opts=$(getopt -n "${this}" -a -o 'dvu:s:S:rRbt' -l '
    debug,verbose,
    user:,separator:,
    ls:,left-separator:,
    rs:,right-separator:,
    rp,right-prompt,
    rw,right-window,
    bw,bottom-window,
    tw,top-window,
  ' -- "${@}"
  )
  eval set -- "${opts}"

  while [[ $# -gt 0 ]]; do
    case ${1} in
      -u | --user)
        __TTY_AG_DEFAULT_USER="${2}"
        shift 2
        ;;
      -d | --debug)
        __TTY_AG_DEBUG_MODE=true
        __TTY_AG_VERBOSE_MODE=true
        shift 1
        ;;
      -v | --verbose)
        __TTY_AG_VERBOSE_MODE=true
        shift 1
        ;;
      -s | --ls | --left-separator )
        __TTY_AG_SEGMENT_SEPARATOR="${2}"
        shift 2
        ;;
      -S | --rs | --right-separator)
        __TTY_AG_RIGHT_SEPARATOR="${2}"
        shift 2
        ;;
      -r | --rp | --right-prompt)
        __TTY_AG_RIGHT_PROMPT=true
        __TTY_AG_RIGHT_WINDOW=false
        shift 1
        ;;
      -R | --rw | --right-window)
        __TTY_AG_RIGHT_PROMPT=false
        __TTY_AG_RIGHT_WINDOW=true
        shift 1
        ;;
      -b | --bw | --bottom-window)
        __TTY_AG_BOTTOM_WINDOW=true
        shift 1
        ;;
      -t | --tw | --top-window)
        __TTY_AG_TOP_WINDOW=true
        shift 1
        ;;
      '--' | '')
        shift 1
        break
        ;;
      *)
        echo "Unknown parameter '${1}'." >&2
        shift 1
        ;;
    esac
  done

  if ${__TTY_AG_VERBOSE_MODE}; then
    printf "%b" "\0033[41m|options = ${opts}|\0033[0m\n"
  fi

  PROMPT_COMMAND=__tty_ag_set_bash_prompt

}



__tty_ag_set_bash_prompt() {
  local __TTY_AG_RETVAL=$?
  local __TTY_AG_PS1L=""
  local __TTY_AG_PS1R=""
  local __TTY_AG_CURRENT_LBG=NONE
  local __TTY_AG_CURRENT_RBG=NONE
  local te
  te="$(__tty_ag_text_effect reset)"
  __TTY_AG_PS1L="$(__tty_ag_format_head "${te}")"
  __TTY_AG_PS1R="$(__tty_ag_format_head "${te}")"
  __tty_ag_build_prompt
  PS1="${__TTY_AG_PS1L}"
  # rename console tab
  echo >&2 -en "\0033]0;${PWD}\a"
  PS1="${__TTY_AG_PS1L}"

  if ${__TTY_AG_RIGHT_PROMPT}; then
    PS1="${__TTY_AG_PS1L}"
  elif ${__TTY_AG_RIGHT_WINDOW}; then
    PS1="${__TTY_AG_PS1L}"
  fi;

  if ${__TTY_AG_BOTTOM_WINDOW}; then
    PS1="${__TTY_AG_PS1L}"
  fi;

  if ${__TTY_AG_TOP_WINDOW}; then
    PS1="${__TTY_AG_PS1L}"
  fi;



}

__tty_ag_main "${@}"
