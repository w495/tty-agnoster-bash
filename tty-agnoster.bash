#!/usr/bin/env bash
# shellcheck enable=all

set -E -o functrace

# ---------------------------------------------------------------
#     shfmt -ci -i 2 -sr -s -bn -kp -ln bash -d
# ---------------------------------------------------------------

### Prompt components
# Each component will draw itself,
# and hide itself if no information needs to be shown
source "$(dirname "${BASH_SOURCE[0]}")/lib/parts.bash"
source "$(dirname "${BASH_SOURCE[0]}")/lib/experimental.bash"
source "$(dirname "${BASH_SOURCE[0]}")/configure.bash"

__TTY_AG_DEFAULT_USER="${USER}"
__TTY_AG_EXPERIMENTAL_PROMPTS=false

# Code page ~737
__TTY_AG_SEGMENT_SEPARATOR_FORWARD_LEFT='█▒░ ' # █▒░
__TTY_AG_SEGMENT_SEPARATOR_REVERSE_LEFT=$(
  printf '%s' "${__TTY_AG_SEGMENT_SEPARATOR_FORWARD_LEFT}" | rev
)

__TTY_AG_SEGMENT_SEPARATOR_FORWARD_RIGHT='█▒░ '
__TTY_AG_SEGMENT_SEPARATOR_REVERSE_RIGHT=$(
  printf '%s' "${__TTY_AG_SEGMENT_SEPARATOR_FORWARD_RIGHT}" | rev
)

__TTY_AG_SEGMENT_SEPARATOR_FORWARD_UNDER='█▒░ '
__TTY_AG_SEGMENT_SEPARATOR_REVERSE_UNDER=$(
  printf '%s' "${__TTY_AG_SEGMENT_SEPARATOR_FORWARD_UNDER}" | rev
)

__TTY_AG_SEGMENT_SEPARATOR_FORWARD_BOTTOM='█▒░ '
__TTY_AG_SEGMENT_SEPARATOR_REVERSE_BOTTOM=$(
  printf '%s' "${__TTY_AG_SEGMENT_SEPARATOR_REVERSE_BOTTOM}" | rev
)

__TTY_AG_SEGMENT_SEPARATOR_FORWARD_TOP='█▒░ '
__TTY_AG_SEGMENT_SEPARATOR_REVERSE_TOP=$(
  printf '%s' "${__TTY_AG_SEGMENT_SEPARATOR_FORWARD_TOP}" | rev
)

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
    cfs:,forward-separator:,common-forward-separator:,
    crs:,reverse-separator:,common-reverse-separator:,
    ls:,left-separator:,
    lfs:,left-forward-separator:,
    lrs:,left-reverse-separator:,
    rs:,right-separator:,
    rfs:,right-forward-separator:,
    rrs:,right-reverse-separator:,
    us:,under-separator:,
    ufs:,under-forward-separator:,
    urs:,under-reverse-separator:,
    bs:,bottom-separator:,
    bfs:,bottom-forward-separator:,
    brs:,bottom-reverse-separator:,
    ts:,top-separator:,
    tfs:,top-forward-separator:,
    trs:,top-reverse-separator:,
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
        local forward="${2}"
        local reverse
        reverse=$(printf '%s' "${forward}" | rev)
        __TTY_AG_SEGMENT_SEPARATOR_FORWARD_LEFT="${forward}"
        __TTY_AG_SEGMENT_SEPARATOR_REVERSE_LEFT="${reverse}"
        __TTY_AG_SEGMENT_SEPARATOR_FORWARD_RIGHT="${forward}"
        __TTY_AG_SEGMENT_SEPARATOR_REVERSE_RIGHT="${reverse}"
        __TTY_AG_SEGMENT_SEPARATOR_FORWARD_BOTTOM="${forward}"
        __TTY_AG_SEGMENT_SEPARATOR_REVERSE_BOTTOM="${reverse}"
        __TTY_AG_SEGMENT_SEPARATOR_FORWARD_TOP="${forward}"
        __TTY_AG_SEGMENT_SEPARATOR_REVERSE_TOP="${reverse}"
        __TTY_AG_SEGMENT_SEPARATOR_FORWARD_UNDER="${forward}"
        __TTY_AG_SEGMENT_SEPARATOR_REVERSE_UNDER="${reverse}"
        shift 2
        ;;
      -f | --cfs | --forward-separator | --common-forward-separator)
        local forward="${2}"
        __TTY_AG_SEGMENT_SEPARATOR_FORWARD_LEFT="${forward}"
        __TTY_AG_SEGMENT_SEPARATOR_FORWARD_RIGHT="${forward}"
        __TTY_AG_SEGMENT_SEPARATOR_FORWARD_BOTTOM="${forward}"
        __TTY_AG_SEGMENT_SEPARATOR_FORWARD_TOP="${forward}"
        __TTY_AG_SEGMENT_SEPARATOR_FORWARD_UNDER="${forward}"
        shift 2
        ;;
      -S | --crs | --reverse-separator | --common-reverse-separator)
        local reverse
        reverse=$(printf '%s' "${2}" | rev)
        __TTY_AG_SEGMENT_SEPARATOR_REVERSE_LEFT="${reverse}"
        __TTY_AG_SEGMENT_SEPARATOR_REVERSE_RIGHT="${reverse}"
        __TTY_AG_SEGMENT_SEPARATOR_REVERSE_BOTTOM="${reverse}"
        __TTY_AG_SEGMENT_SEPARATOR_REVERSE_TOP="${reverse}"
        __TTY_AG_SEGMENT_SEPARATOR_REVERSE_UNDER="${reverse}"
        shift 2
        ;;
      --ls | --left-separator)
        __TTY_AG_SEGMENT_SEPARATOR_FORWARD_LEFT="${2}"
        __TTY_AG_SEGMENT_SEPARATOR_REVERSE_LEFT=$(
          printf '%s' "${2}" | rev
        )
        shift 2
        ;;
      --rs | --right-separator)
        __TTY_AG_SEGMENT_SEPARATOR_FORWARD_RIGHT="${2}"
        __TTY_AG_SEGMENT_SEPARATOR_REVERSE_RIGHT=$(
          printf '%s' "${2}" | rev
        )
        shift 2
        ;;
      --bs | --bottom-separator)
        __TTY_AG_SEGMENT_SEPARATOR_FORWARD_BOTTOM="${2}"
        __TTY_AG_SEGMENT_SEPARATOR_REVERSE_BOTTOM=$(
          printf '%s' "${2}" | rev
        )
        shift 2
        ;;
      --ts | --top-separator)
        __TTY_AG_SEGMENT_SEPARATOR_FORWARD_TOP="${2}"
        __TTY_AG_SEGMENT_SEPARATOR_REVERSE_TOP=$(
          printf '%s' "${2}" | rev
        )
        shift 2
        ;;
      --us | --under-separator)
        __TTY_AG_SEGMENT_SEPARATOR_FORWARD_UNDER="${2}"
        __TTY_AG_SEGMENT_SEPARATOR_REVERSE_UNDER=$(
          printf '%s' "${2}" | rev
        )
        shift 2
        ;;
      --lfs | --left-forward-separator)
        __TTY_AG_SEGMENT_SEPARATOR_FORWARD_LEFT="${2}"
        shift 2
        ;;
      --rfs | --right-forward-separator)
        __TTY_AG_SEGMENT_SEPARATOR_FORWARD_RIGHT="${2}"
        shift 2
        ;;
      --bfs | --bottom-forward-separator)
        __TTY_AG_SEGMENT_SEPARATOR_FORWARD_BOTTOM="${2}"
        shift 2
        ;;
      --tfs | --top-forward-separator)
        __TTY_AG_SEGMENT_SEPARATOR_FORWARD_TOP="${2}"
        shift 2
        ;;
      --ufs | --under-forward-separator)
        __TTY_AG_SEGMENT_SEPARATOR_FORWARD_UNDER="${2}"
        shift 2
        ;;
      --lrs | --left-reverse-separator)
        __TTY_AG_SEGMENT_SEPARATOR_REVERSE_LEFT="${2}"
        shift 2
        ;;
      --rrs | --right-reverse-separator)
        __TTY_AG_SEGMENT_SEPARATOR_REVERSE_RIGHT="${2}"
        shift 2
        ;;
      --brs | --bottom-reverse-separator)
        __TTY_AG_SEGMENT_SEPARATOR_REVERSE_BOTTOM="${2}"
        shift 2
        ;;
      --trs | --top-reverse-separator)
        __TTY_AG_SEGMENT_SEPARATOR_REVERSE_TOP="${2}"
        shift 2
        ;;
      --urs | --under-reverse-separator)
        __TTY_AG_SEGMENT_SEPARATOR_REVERSE_UNDER="${2}"
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

__tty_ag_prompt_command_top() {
  local __TTY_AG_PS1_TOP
  __tty_ag_configure_tray_at_top
  # Do not try put it into PS1.
  __tty_ag_show_tray_at_top "${__TTY_AG_PS1_TOP}"
}

__tty_ag_prompt_command_left() {
  local __TTY_AG_PS1_LEFT
  __tty_ag_configure_left_prompt
  PS1="${__TTY_AG_PS1_LEFT}"
}

__tty_ag_prompt_command_under() {
  local __TTY_AG_PS1_UNDER
  __tty_ag_configure_under_prompt
  __tty_ag_show_under_prompt "${__TTY_AG_PS1_UNDER}"
}

__tty_ag_prompt_command_right_prompt() {
  local __TTY_AG_PS1_RIGHT
  __tty_ag_configure_right_prompt
  __tty_ag_show_right_prompt "${__TTY_AG_PS1_RIGHT}"
}

__tty_ag_prompt_command_right_tray() {
  local __TTY_AG_PS1_RIGHT
  __tty_ag_configure_right_prompt
  # Do not try put it into PS1.
  __tty_ag_show_tray_at_right "${__TTY_AG_PS1_RIGHT}"
}

__tty_ag_prompt_command_bottom() {
  local __TTY_AG_PS1_BOTTOM
  __tty_ag_configure_tray_at_bottom
  # Do not try put it into PS1.
  __tty_ag_show_tray_at_bottom "${__TTY_AG_PS1_BOTTOM}"
}

__tty_ag_prompt_command_if_top() {
  if ${__TTY_AG_TOP_TRAY}; then
    __tty_ag_prompt_command_top
  fi
}

__tty_ag_prompt_command_if_left() {
  if ${__TTY_AG_LEFT_PROMPT_COMPUTABLE}; then
    __tty_ag_prompt_command_left
  fi
}

__tty_ag_prompt_command_if_under() {
  if ${__TTY_AG_UNDER_PROMPT}; then
    __tty_ag_prompt_command_under
  fi
}

__tty_ag_prompt_command_if_right() {
  if ${__TTY_AG_RIGHT_PROMPT}; then
    __tty_ag_prompt_command_right_prompt
  elif ${__TTY_AG_RIGHT_TRAY}; then
    __tty_ag_prompt_command_right_tray
  fi
}

__tty_ag_prompt_command_if_bottom() {
  if ${__TTY_AG_BOTTOM_TRAY}; then
    __tty_ag_prompt_command_bottom
  fi
}

__tty_ag_prompt_command_prompts() {
  __tty_ag_prompt_command_if_left
  __tty_ag_prompt_command_if_right
  __tty_ag_prompt_command_if_under
}

__tty_ag_prompt_command_title() {
  printf '%b' "\0033]0;XX${PWD}\a"
}

__tty_ag_prompt_command_trays() {
  __tty_ag_prompt_command_if_top
  __tty_ag_prompt_command_if_bottom
}

__tty_ag_prompt_command() {
  local __TTY_AG_RETVAL=$?

  __tty_ag_prompt_command_title

  tput civis
  __tty_ag_prompt_command_prompts
  __tty_ag_prompt_command_trays
  tput cnorm
}

__tty_ag_main() {
  local __tty_ag_opts
  __tty_ag_opts "${@}"

  if ${__TTY_AG_VERBOSE_MODE}; then
    printf "%b" "\0033[41m# opts = ${__tty_ag_opts}\0033[0m\n"
  fi

  __tty_ag_prompt_command_if_left

  PROMPT_COMMAND=__tty_ag_prompt_command
}

__tty_ag_main "${@}"
