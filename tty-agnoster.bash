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

__TTY_AG_DEFAULT_USER="${USER}"
__TTY_AG_EXPERIMENTAL_PROMPTS=false

__TTY_AG_SEGMENT_SEPARATOR_LEFT="▒░ "
__TTY_AG_SEGMENT_SEPARATOR_RIGHT="▒░"
__TTY_AG_SEGMENT_SEPARATOR_UNDER="▒░"
__TTY_AG_SEGMENT_SEPARATOR_BOTTOM="▒░"
__TTY_AG_SEGMENT_SEPARATOR_TOP=" "

__TTY_AG_LEFT_PROMPT=false
__TTY_AG_LEFT_PROMPT_COMPUTABLE=false
__TTY_AG_RIGHT_PROMPT=false
__TTY_AG_UNDER_PROMPT=false
__TTY_AG_RIGHT_TRAY=false
__TTY_AG_BOTTOM_TRAY=false
__TTY_AG_TOP_TRAY=false

__tty_ag_opts() {
 local opts
  local this="${BASH_SOURCE[0]}"
  opts=$(
    getopt -n "${this}" -a -o 'dvuU:s:lLrRbt' -l '
    debug,verbose,
    user:,separator:,
    cs:,separator:,common-separator:,
    ls:,left-separator:,
    rs:,right-separator:,
    lp,left-prompt,
    cp,computable-left-prompt,
    rp,right-prompt,
    up,under-prompt,
    rt,right-tray,
    bt,bottom-tray,
    tt,top-tray,
  ' -- "${@}"
  )
  eval set -- "${opts}"

  while [[ $# -gt 0 ]]; do
    case ${1} in
      -U | --user)
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
      -s | --cs | --separator | --common-separator)
        __TTY_AG_SEGMENT_SEPARATOR_LEFT="${2}"
        __TTY_AG_SEGMENT_SEPARATOR_RIGHT="${2}"
        __TTY_AG_SEGMENT_SEPARATOR_BOTTOM="${2}"
        __TTY_AG_SEGMENT_SEPARATOR_TOP="${2}"
        __TTY_AG_SEGMENT_SEPARATOR_UNDER="${2}"
        shift 2
        ;;
      --ls | --left-separator)
        __TTY_AG_SEGMENT_SEPARATOR_LEFT="${2}"
        shift 2
        ;;
      --rs | --right-separator)
        __TTY_AG_SEGMENT_SEPARATOR_RIGHT="${2}"
        shift 2
        ;;
      --bs | --bottom-separator)
        __TTY_AG_SEGMENT_SEPARATOR_BOTTOM="${2}"
        shift 2
        ;;
      --ts | --top-separator)
        __TTY_AG_SEGMENT_SEPARATOR_TOP="${2}"
        shift 2
        ;;
      --us | --under-separator)
        __TTY_AG_SEGMENT_SEPARATOR_UNDER="${2}"
        shift 2
        ;;
      -l | --lp | --left-prompt)
        __TTY_AG_LEFT_PROMPT=true
        shift 1
        ;;
      -L | --cp | --computable-left-prompt)
        __TTY_AG_LEFT_PROMPT=true
        __TTY_AG_LEFT_PROMPT_COMPUTABLE=true
        shift 1
        ;;
      -r | --rp | --right-prompt)
        __TTY_AG_RIGHT_PROMPT=true
        __TTY_AG_RIGHT_TRAY=false
        shift 1
        ;;
      -R | --rt | --right-tray)
        __TTY_AG_RIGHT_PROMPT=false
        __TTY_AG_RIGHT_TRAY=true
        shift 1
        ;;
      -b | --bt | --bottom-tray)
        __TTY_AG_BOTTOM_TRAY=true
        shift 1
        ;;
      -t | --tt | --top-tray)
        __TTY_AG_TOP_TRAY=true
        shift 1
        ;;
      -u | --up | --under-prompt)
        __TTY_AG_UNDER_PROMPT=true
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
  __tty_ag_opts="${opts}"
}




__tty_ag_prompt_command_under() {
  local __TTY_AG_PS1_UNDER
  __tty_ag_configure_prompt_under
  # Do not try put it into PS1.
  __tty_ag_show_prompt_under "${__TTY_AG_PS1_UNDER}"
}


__tty_ag_prompt_command_right_prompt() {
  local __TTY_AG_PS1_RIGHT
  __tty_ag_configure_prompt_right
  # Do not try put it into PS1.
  __tty_ag_right_prompt "${__TTY_AG_PS1_RIGHT}"
}


__tty_ag_prompt_command_right_tray() {
  local __TTY_AG_PS1_RIGHT
  __tty_ag_configure_prompt_right
  # Do not try put it into PS1.
  __tty_ag_right_tray "${__TTY_AG_PS1_RIGHT}"
}


__tty_ag_prompt_command_if_right() {
  if ${__TTY_AG_RIGHT_PROMPT}; then
    __tty_ag_prompt_command_right_prompt
  elif ${__TTY_AG_RIGHT_TRAY}; then
    __tty_ag_prompt_command_right_tray
  fi
}


__tty_ag_prompt_command_top() {
  local __TTY_AG_PS1_TOP
  __tty_ag_configure_tray_top
  # Do not try put it into PS1.
  __tty_ag_tray_at_top "${__TTY_AG_PS1_TOP}"
}

__tty_ag_prompt_command_bottom() {
  local __TTY_AG_PS1_BOTTOM
  __tty_ag_configure_tray_bottom
  # Do not try put it into PS1.
  __tty_ag_tray_bottom "${__TTY_AG_PS1_BOTTOM}"
}


__tty_ag_prompt_command_if_top() {
  if ${__TTY_AG_TOP_TRAY}; then
    __tty_ag_prompt_command_top
  fi
}

__tty_ag_prompt_command_if_under() {
  if ${__TTY_AG_UNDER_PROMPT}; then
    __tty_ag_prompt_command_under
  fi
}

__tty_ag_prompt_command_if_bottom() {
  if ${__TTY_AG_BOTTOM_TRAY}; then
    __tty_ag_prompt_command_bottom
  fi
}

__tty_ag_prompt_command_sync() {
  __tty_ag_prompt_command_if_under
  __tty_ag_prompt_command_if_right
}

__tty_ag_prompt_command_async() {
  printf '%b' "\0033]0;${PWD}\a"
  __tty_ag_prompt_command_if_top
  __tty_ag_prompt_command_if_bottom
}

__tty_ag_prompt_command() {
  local __TTY_AG_RETVAL=$?

  tput civis
  __tty_ag_prompt_command_async
  __tty_ag_prompt_command_sync
  tput cnorm
}


__tty_ag_main() {
  local __tty_ag_opts
  __tty_ag_opts "${@}"

  if ${__TTY_AG_VERBOSE_MODE}; then
    printf "%b" "\0033[41m# opts = ${__tty_ag_opts}\0033[0m\n"
  fi

  if ${__TTY_AG_LEFT_PROMPT}; then
    local __TTY_AG_PS1_LEFT
    __tty_ag_configure_prompt_left
    PS1="${__TTY_AG_PS1_LEFT}"
  fi

  PROMPT_COMMAND=__tty_ag_prompt_command
}



__tty_ag_main "${@}"

}
