#!/usr/bin/env bash
# shellcheck enable=all
### Prompt components
# Each component will draw itself,
# and hide itself if no information needs to be shown

# ---------------------------------------------------------------
#     shfmt -ci -i 2 -sr -s -bn -kp -ln bash -d
# ---------------------------------------------------------------

source "$(dirname "${BASH_SOURCE[0]}")/utils.bash"
source "$(dirname "${BASH_SOURCE[0]}")/segment.bash"

source "$(dirname "${BASH_SOURCE[0]}")/parts/vcs.bash"

__TTY_AG_DEFAULT_USER='_'
__TTY_AG_RETVAL=$?


# Context: user@hostname (who am I and where am I)
__tty_ag_prompt_context() {
  local user
  user="$(whoami)"
  if [[ ${user} != "${__TTY_AG_DEFAULT_USER}" || -n ${SSH_CLIENT} ]]; then
    __tty_ag_segment "${1}" '-black' 'default' "${user}@\h"
  fi
}

__TTY_AG_LINENO=0

__tty_ag_lineno() {
  local pos="${1}"
  local bg="${2}"
  local fg="${3}"
  local line_repr
  __TTY_AG_LINENO=$((__TTY_AG_LINENO + 1))
  printf -v line_repr '%*s' "${5:-4}" "${__TTY_AG_LINENO}"
  local text="${4//\\\#/"${line_repr}"}"
  __tty_ag_segment "${pos}" "${bg}" "${fg}" "${text}"
}

__tty_ag_prompt_command_number() {
  __tty_ag_segment "${1}" '-black' '-yellow' "║ \# ║"
}

#Capturing start time in milliseconds
__TTY_AG_SECOND="$(date '+%s%3N')"

__tty_ag_prompt_seconds() {
  local -i second
  second="$(date '+%s%3N')"
  ms_diff=$((second - __TTY_AG_SECOND))
  sec_diff=$((ms_diff / 1000))
  ms_part=$((ms_diff % 1000))
  __tty_ag_segment "${1}" '-black' '-yellow' "|${sec_diff}.${ms_part}|"
  __TTY_AG_SECOND="${second}"
}

__tty_ag_prompt_history_number() {
  __tty_ag_segment "${1}" '-black' 'default' "\!"
}

# prints history followed by HH:MM, useful for remembering what
# we did previously
__tty_ag_prompt_history_number_and_time() {
  __tty_ag_segment "${1}" '-black' 'default' " \! (\A)"
}

__tty_ag_prompt_time_24hm() {
  __tty_ag_segment "${1}" '-black' 'default' " \A"
}

__tty_ag_prompt_time_24hms() {
  __tty_ag_segment "${1}" '-black' '+black' "\t"
}

__tty_ag_prompt_time_12hms() {
  __tty_ag_segment "${1}" '-black' '+black' "\T"
}

__tty_ag_prompt_time_12hms_pm_am() {
  __tty_ag_segment "${1}" '-black' '+black' "\@"
}

__tty_ag_prompt_time() {
  local _dt
  _dt=$(date '+%H┋%M┋%S')
  __tty_ag_segment "${1}" '-black' '+black' "${_dt}"
}

__tty_ag_prompt_dt() {
  local _dt
  _dt=$(date '+%Y-%m-%d_%H-%M-%S-%N')
  __tty_ag_segment "${1}" '+green' '-black' "${_dt}"
}

__tty_ag_prompt_device() {
  __tty_ag_segment "${1}" '-blue' '-black' '\l'
}

__tty_ag_prompt_shell() {
  __tty_ag_segment "${1}" '-blue' '-black' '\s'
}

# Dir: current working directory
__tty_ag_prompt_dir() {
  __tty_ag_segment "${1}" '-blue' '-black' '\w'
}

# Dir: current working directory
__tty_ag_prompt_full_pwd() {
  __tty_ag_segment "${1}" '-green' '-black' "#${PWD}"
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
__tty_ag_prompt_status() {
  local symbols
  local __tty_ag_fg_code
  symbols=()
  if [[ ${__TTY_AG_RETVAL} -ne 0 ]]; then
    __tty_ag_fg_code -red > /dev/null
    local red="${__tty_ag_fg_code}"
    symbols+=(" $(__tty_ag_format_head "${red}")[x]")
  fi
  if [[ ${UID} -eq 0 ]]; then
    __tty_ag_fg_code -yellow > /dev/null
    local yellow="${__tty_ag_fg_code}"
    symbols+=(" $(__tty_ag_format_head "${yellow}") [z]")
  fi
  if [[ $(jobs -l | wc -l || true) -gt 0 ]]; then
    __tty_ag_fg_code -cyan > /dev/null
    local cyan="${__tty_ag_fg_code}"
    symbols+=(" $(__tty_ag_format_head "${cyan}") [\j]")
  fi
  if [[ -n ${symbols[*]} ]]; then
    __tty_ag_segment "${1}" '-black' 'default' "${symbols}"
  fi
  true
}

######################################################################
## Main prompt

__tty_ag_build_prompt() {

  history -a
  history -c
  history -r

  __tty_ag_prompt_start_all

  __tty_ag_segment    'LEFT'    'no'   'default'   ''
  __tty_ag_lineno     'LEFT'    'no'   'default'  "║ \# ║"

#  __tty_ag_segment 'LEFT'    'no'   '+green'   "║$(printf '%3s' "${LINENO}")║"
#
  __tty_ag_segment 'LEFT'    'no'   '+white'   '[\!]'
  __tty_ag_segment 'LEFT'    'no'   '+yellow'  '/\t/'

  __tty_ag_prompt_context     'LEFT'
  __tty_ag_prompt_status      'LEFT'
  __tty_ag_prompt_virtualenv  'LEFT'

  __tty_ag_segment 'LEFT'    '-blue'   '-black'    '\w '

  __tty_ag_prompt_git         'LEFT'
  __tty_ag_prompt_arc         'LEFT'
  __tty_ag_prompt_hg          'LEFT'

  __tty_ag_prompt_full_pwd    'BOTTOM'
  __tty_ag_prompt_dt          'BOTTOM'

  __tty_ag_segment 'TOP'   '-black'   '+yellow'  "${PWD}"


  __tty_ag_prompt_end_all
}
