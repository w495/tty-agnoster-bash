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
__TTY_AG_OPTIONS=''


__TTY_AG_OPTS_SHORT='dDvVolLcCrRbBtTuUs:'
__TTY_AG_OPTS_LONG='
op,opts,options,
db,debug,
nd,no-debug,
vb,verbose,
nv,no-verbose,
cp,   computable-left-prompt,
nc,   no-computable-left-prompt,
lp,   left-prompt,
nl,   no-left-prompt,
rp,   right-prompt,
nr,   no-right-prompt,
up,   under-prompt,
nu,   no-under-prompt,
bt,   bottom-tray,
nb,   no-bottom-tray,
tt,   top-tray,
nt,   no-top-tray,
me:,  user:,
cs:,  sep:,   separator:,               common-separator:,
cf:,  cfs:,   forward-separator:,       common-forward-separator:,
cr:,  crs:,   reverse-separator:,       common-reverse-separator:,
ls:,          left-separator:,
lf:,  lfs:,   left-forward-separator:,
lr:,  lrs:,   left-reverse-separator:,
rs:,          right-separator:,
rf:,  rfs:,   right-forward-separator:,
rr:,  rrs:,   right-reverse-separator:,
us:,          under-separator:,
uf:,  ufs:,   under-forward-separator:,
ur:,  urs:,   under-reverse-separator:,
bs:,          bottom-separator:,
bf:,  bfs:,   bottom-forward-separator:,
br:,  brs:,   bottom-reverse-separator:,
ts:,          top-separator:,
tf:,  tfs:,   top-forward-separator:,
tr:,  trs:,   top-reverse-separator:,
'

__tty_ag_options() {
  local opts
  local this="${BASH_SOURCE[0]}"
  opts=$(
    getopt -n "${this}" -a -o "
      ${__TTY_AG_OPTS_SHORT}
    " -l "
      ${__TTY_AG_OPTS_LONG}
    " -- "${@}"
  )
  eval set -- "${opts}"

  while [[ $# -gt 0 ]]; do
    case ${1} in
      -d | --db |--debug)
        __TTY_AG_DEBUG_MODE=true
        shift 1
        ;;
      -D | --nd | --no-debug)
        __TTY_AG_DEBUG_MODE=false
        shift 1
        ;;
      -v | --vb | --verbose)
        __TTY_AG_VERBOSE_MODE=true
        shift 1
        ;;
      -V | --nv | --no-verbose)
        __TTY_AG_VERBOSE_MODE=false
        shift 1
        ;;
      -o | --op | --opts | --options)
        printf '%s\n' "${__TTY_AG_OPTIONS}"
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
      --cf | --cfs | --forward-separator | --common-forward-separator)
        local forward="${2}"
        __TTY_AG_SEGMENT_SEPARATOR_FORWARD_LEFT="${forward}"
        __TTY_AG_SEGMENT_SEPARATOR_FORWARD_RIGHT="${forward}"
        __TTY_AG_SEGMENT_SEPARATOR_FORWARD_BOTTOM="${forward}"
        __TTY_AG_SEGMENT_SEPARATOR_FORWARD_TOP="${forward}"
        __TTY_AG_SEGMENT_SEPARATOR_FORWARD_UNDER="${forward}"
        shift 2
        ;;
      --cr | --crs | --reverse-separator | --common-reverse-separator)
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
      --lf | --lfs |--left-forward-separator)
        __TTY_AG_SEGMENT_SEPARATOR_FORWARD_LEFT="${2}"
        shift 2
        ;;
      --rf | --rfs |--right-forward-separator)
        __TTY_AG_SEGMENT_SEPARATOR_FORWARD_RIGHT="${2}"
        shift 2
        ;;
      --bf | --bfs |--bottom-forward-separator)
        __TTY_AG_SEGMENT_SEPARATOR_FORWARD_BOTTOM="${2}"
        shift 2
        ;;
      --tf | --tfs |--top-forward-separator)
        __TTY_AG_SEGMENT_SEPARATOR_FORWARD_TOP="${2}"
        shift 2
        ;;
      --uf | --ufs |--under-forward-separator)
        __TTY_AG_SEGMENT_SEPARATOR_FORWARD_UNDER="${2}"
        shift 2
        ;;
      --lr | --lrs |--left-reverse-separator)
        __TTY_AG_SEGMENT_SEPARATOR_REVERSE_LEFT="${2}"
        shift 2
        ;;
      --rr | --rrs |--right-reverse-separator)
        __TTY_AG_SEGMENT_SEPARATOR_REVERSE_RIGHT="${2}"
        shift 2
        ;;
      --br | --brs |--bottom-reverse-separator)
        __TTY_AG_SEGMENT_SEPARATOR_REVERSE_BOTTOM="${2}"
        shift 2
        ;;
      --tr | --trs |--top-reverse-separator)
        __TTY_AG_SEGMENT_SEPARATOR_REVERSE_TOP="${2}"
        shift 2
        ;;
      --ur | --urs |--under-reverse-separator)
        __TTY_AG_SEGMENT_SEPARATOR_REVERSE_UNDER="${2}"
        shift 2
        ;;
      -l | --lp | --left-prompt | --with-left-prompt )
        __TTY_AG_LEFT_PROMPT=true
        shift 1
        ;;
      -L | --nl | --no-left-prompt)
        __TTY_AG_LEFT_PROMPT=false
        shift 1
        ;;
      -c | --cp | --computable-left-prompt | --with-computable-left-prompt )
        __TTY_AG_LEFT_PROMPT_COMPUTABLE=true
        shift 1
        ;;
      -C | --nc | --no-computable-left-prompt)
        __TTY_AG_LEFT_PROMPT_COMPUTABLE=false
        shift 1
        ;;
      -r | --rp | --right-prompt)
        __TTY_AG_RIGHT_PROMPT=true
        shift 1
        ;;
      -R | --nr | --no-right-prompt)
        __TTY_AG_RIGHT_PROMPT=false
        shift 1
        ;;
      -b | --bt | --bottom-tray)
        __TTY_AG_BOTTOM_TRAY=true
        shift 1
        ;;
      -B | --nb | --no-bottom-tray)
        __TTY_AG_BOTTOM_TRAY=false
        shift 1
        ;;
      -t | --tt | --top-tray)
        __TTY_AG_TOP_TRAY=true
        shift 1
        ;;
      -T | --nt | --no-top-tray)
        __TTY_AG_TOP_TRAY=false
        shift 1
        ;;
      -u | --up | --under-prompt)
        __TTY_AG_UNDER_PROMPT=true
        shift 1
        ;;
      -U | --nu | --no-under-prompt)
        __TTY_AG_UNDER_PROMPT=false
        shift 1
        ;;
      -m | --me | --user)
        __TTY_AG_DEFAULT_USER="${2}"
        shift 2
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
  __tty_ag_options="${opts}"
  __TTY_AG_OPTIONS="${__tty_ag_options}"
  if ${__TTY_AG_VERBOSE_MODE}; then
    printf "%b" "\0033[41m# opts = ${__TTY_AG_OPTIONS}\0033[0m\n"
  fi
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
  __tty_ag_options "${@}"

  if ${__TTY_AG_LEFT_PROMPT}; then
    __tty_ag_prompt_command_left
  fi

  PROMPT_COMMAND=__tty_ag_prompt_command
}


__tty_ag_main "${@}"

flags="
  --options
  --debug
  --no-debug
  --verbose
  --no-verbose
  --computable-left-prompt
  --no-computable-left-prompt
  --left-prompt
  --no-left-prompt
  --right-prompt
  --no-right-prompt
  --under-prompt
  --no-under-prompt
  --bottom-tray
  --no-bottom-tray
  --top-tray
  --no-top-tray
"

complete -W "${flags}"  __tty_ag_options
