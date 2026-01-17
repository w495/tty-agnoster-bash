#!/usr/bin/env bash
# shellcheck enable=all

# ---------------------------------------------------------------
#     shfmt -ci -i 2 -sr -s -bn -kp -ln bash -d
# ---------------------------------------------------------------

### Prompt components
# Each component will draw itself,
# and hide itself if no information needs to be shown
source "$(dirname "${BASH_SOURCE[0]}")/lib/parts.bash"

export DEFAULT_USER='_'
export SEGMENT_SEPARATOR='▒░'
export RIGHT_SEPARATOR='▒░'
export VERBOSE_MODE=false
export RETVAL=$?
export PS1L=""
export PS1R=""
export CURRENT_LBG=NONE
export CURRENT_RBG=NONE

__tty_ag_main() {
  local options
  local this="${BASH_SOURCE[0]}"
  options=$(
    getopt -n "${this}" \
      -o 'dvu:s:l:r:' \
      --long 'debug,verbose,user:,separator:,left:,right' \
      -- "${@}"
  )
  eval set -- "${options}"

  while [[ $# -gt 0 ]]; do
    case ${1} in
      -u | --user)
        DEFAULT_USER="${2}"
        shift 2
        ;;
      -d | --debug | -v | --verbose)
        VERBOSE_MODE=true
        shift 1
        ;;
      -l | --left | -s | --separator)
        SEGMENT_SEPARATOR="${2}"
        shift 2
        ;;
      -r | --right)
        RIGHT_SEPARATOR="${2}"
        shift 2
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

  PROMPT_COMMAND=__tty_ag_set_bash_prompt
}

__tty_ag_set_bash_prompt() {
  local RETVAL=$?
  local PS1L=""
  local PS1R=""
  local CURRENT_LBG=NONE
  local CURRENT_RBG=NONE
  local te
  te="$(__tty_ag_text_effect reset)"
  PS1L="$(__tty_ag_format_head "${te}")"
  PS1R="$(__tty_ag_format_head "${te}")"
  __tty_ag_build_prompt
  PS1="${PS1L}"
  # rename console tab
  echo >&2 -en "\0033]0;${PWD}\a"
  PS1="${PS1L}"
}

__tty_ag_main "${@}"
