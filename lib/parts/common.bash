#!/usr/bin/env bash
# shellcheck enable=all

# ---------------------------------------------------------------
#     shfmt -ci -i 2 -sr -s -bn -kp -ln bash -d
# ---------------------------------------------------------------

source "$(dirname "${BASH_SOURCE[0]}")/../segment.bash"


__TTY_AG_DEFAULT_USER='_'
__TTY_AG_RETVAL=$?

# Context: user@hostname (who am I and where am I)
__tty_ag_prompt_context() {
  local user
  user="$(whoami)"
  if [[ ${user} != "${__TTY_AG_DEFAULT_USER}" || -n ${SSH_CLIENT} ]]; then
    __tty_ag_segment "${1}" "${2}" "${3}"  "${user}@\h"
  fi
}

__TTY_AG_LINENO=0

__tty_ag_lineno() {
  local line_repr
  __TTY_AG_LINENO=$((__TTY_AG_LINENO + 1))
  printf -v line_repr '%*s' "${5:-4}" "${__TTY_AG_LINENO}"
  local text="${4//\\\#/"${line_repr}"}"
  __tty_ag_segment "${1}" "${2}" "${3}"  "${text}"
}

__tty_ag_prompt_command_number() {
  __tty_ag_segment "${1}" "${2}" "${3}"  "║ \# ║"
}

#Capturing start time in milliseconds
__TTY_AG_SECOND="$(date '+%s%3N')"

__tty_ag_prompt_seconds() {
  local -i second
  second="$(date '+%s%3N')"
  ms_diff=$((second - __TTY_AG_SECOND))
  sec_diff=$((ms_diff / 1000))
  ms_part=$((ms_diff % 1000))
  __tty_ag_segment "${1}" "${2}" "${3}"  "|${sec_diff}.${ms_part}|"
  __TTY_AG_SECOND="${second}"
}

__tty_ag_prompt_history_number() {
  __tty_ag_segment "${1}" "${2}" "${3}"  "\!"
}

# prints history followed by HH:MM, useful for remembering what
# we did previously
__tty_ag_prompt_history_number_and_time() {
  __tty_ag_segment "${1}" "${2}" "${3}"  ' \! (\A)'
}

__tty_ag_prompt_time_24hm() {
  __tty_ag_segment  "${1}" "${2}" "${3}" '\A'
}

__tty_ag_prompt_time_24hms() {
  __tty_ag_segment  "${1}" "${2}" "${3}"  '\t'
}

__tty_ag_prompt_time_12hms() {
  __tty_ag_segment  "${1}" "${2}" "${3}" '\T'
}

__tty_ag_prompt_time_12hms_pm_am() {
  __tty_ag_segment  "${1}" "${2}" "${3}"  '\@'
}

__tty_ag_prompt_time() {
  local _dt
  _dt=$(date '+%H┋%M┋%S')
  __tty_ag_segment  "${1}" "${2}" "${3}"  "${_dt}"
}

__tty_ag_prompt_dt() {
  local _dt
  _dt=$(date '+%Y-%m-%d_%H-%M-%S-%N')
  __tty_ag_segment "${1}" "${2}" "${3}" "${_dt}"
}

__tty_ag_prompt_device() {
  __tty_ag_segment  "${1}" "${2}" "${3}" '\l'
}

__tty_ag_prompt_shell() {
  __tty_ag_segment  "${1}" "${2}" "${3}" '\s'
}

# Dir: current working directory
__tty_ag_prompt_dir() {
  __tty_ag_segment  "${1}" "${2}" "${3}" '\w'
}

# Dir: current working directory
__tty_ag_prompt_full_pwd() {
  __tty_ag_segment  "${1}" "${2}" "${3}" "#${PWD}"
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
__tty_ag_prompt_status() {
  local symbols
  local __tty_ag_fg_code
  if [[ ${__TTY_AG_RETVAL} -ne 0 ]]; then
    __tty_ag_fg_code -red > /dev/null
    local red="${__tty_ag_fg_code}"
    symbols="${symbols}$(__tty_ag_format_head "${red}")[x]"
  fi
  if [[ ${UID} -eq 0 ]]; then
    __tty_ag_fg_code -yellow > /dev/null
    local yellow="${__tty_ag_fg_code}"
    symbols="${symbols}$(__tty_ag_format_head "${yellow}")[z]"
  fi
  if [[ $(jobs -l | wc -l || true) -gt 0 ]]; then
    __tty_ag_fg_code -cyan > /dev/null
    local cyan="${__tty_ag_fg_code}"
    symbols="${symbols}$(__tty_ag_format_head "${cyan}")[\j]"
  fi
  if [[ -n ${symbols} ]]; then
    __tty_ag_segment "${1}" "${2}" "${3}" "${symbols}"
  fi
  true
}
