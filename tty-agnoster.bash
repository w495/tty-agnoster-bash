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
__TTY_AG_RIGHT_PROMPT="${__TTY_AG_EXPERIMENTAL_PROMPTS}"
__TTY_AG_UNDER_PROMPT="${__TTY_AG_EXPERIMENTAL_PROMPTS}"
__TTY_AG_RIGHT_WINDOW="${__TTY_AG_EXPERIMENTAL_PROMPTS}"
__TTY_AG_BOTTOM_WINDOW="${__TTY_AG_EXPERIMENTAL_PROMPTS}"
__TTY_AG_TOP_WINDOW="${__TTY_AG_EXPERIMENTAL_PROMPTS}"

__tty_ag_main() {
  local opts
  local this="${BASH_SOURCE[0]}"
  opts=$(
    getopt -n "${this}" -a -o 'dvuU:s:lrRbt' -l '
    debug,verbose,
    user:,separator:,
    cs:,separator:,common-separator:,
    ls:,left-separator:,
    rs:,right-separator:,
    lp,left-prompt,
    rp,right-prompt,
    up,under-prompt,
    rw,right-window,
    bw,bottom-window,
    tw,top-window,
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

  if ${__TTY_AG_VERBOSE_MODE}; then
    printf "%b" "\0033[41m# options = ${opts}|\0033[0m\n"
  fi

  PROMPT_COMMAND=__tty_ag_prompt_command

}

__tty_ag_prompt_command() {
  local __TTY_AG_RETVAL=$?

  local __TTY_AG_PS1_LEFT
  local __TTY_AG_PS1_RIGHT
  local __TTY_AG_PS1_BOTTOM
  local __TTY_AG_PS1_TOP
  local __TTY_AG_PS1_UNDER

  # rename console tab
  (
    printf '%b' "\0033]0;${PWD}\a" &
  )

  __tty_ag_build_prompt

  if ${__TTY_AG_LEFT_PROMPT}; then
    PS1="${__TTY_AG_PS1_LEFT}"
  fi
  (
    (
      if ${__TTY_AG_TOP_WINDOW}; then
          __tty_ag_top_window "${__TTY_AG_PS1_TOP}" &
      fi
      if ${__TTY_AG_UNDER_PROMPT}; then
        # Do not try put it into PS1.
        __tty_ag_under_prompt "${__TTY_AG_PS1_UNDER}" &
      fi
      if ${__TTY_AG_RIGHT_PROMPT}; then
          # Do not try put it into PS1.
          __tty_ag_right_prompt "${__TTY_AG_PS1_RIGHT}" &
      elif ${__TTY_AG_RIGHT_WINDOW}; then
          # Do not try put it into PS1.
          __tty_ag_right_window "${__TTY_AG_PS1_RIGHT}" &
      fi
      if ${__TTY_AG_BOTTOM_WINDOW}; then
          # Do not try put it into PS1.
          __tty_ag_bottom_window "${__TTY_AG_PS1_BOTTOM}" &
      fi
    ) &
  )


}

__tty_ag_main "${@}"
