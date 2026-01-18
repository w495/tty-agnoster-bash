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

export __TTY_AG_DEFAULT_USER='_'
export __TTY_AG_RETVAL=$?

# Context: user@hostname (who am I and where am I)
__tty_ag_prompt_context() {
  local user
  user="$(whoami)"
  if [[ ${user} != "${__TTY_AG_DEFAULT_USER}" || -n ${SSH_CLIENT} ]]; then
    __tty_ag_segment "${1}" black default "${user}@\h"
  fi
}

__TTY_AG_LINE=1

__tty_ag_prompt_line() {
  __tty_ag_segment "${1}" black orange "║ ${__TTY_AG_LINE} ║"
  __TTY_AG_LINE=$((__TTY_AG_LINE + 1))
}

#Capturing start time in milliseconds
__TTY_AG_SECOND="$(date '+%s%3N')"

__tty_ag_prompt_seconds() {
  local -i second
  second="$(date '+%s%3N')"
  ms_diff=$((second - __TTY_AG_SECOND))
  sec_diff=$((ms_diff / 1000))
  ms_part=$((ms_diff % 1000))
  __tty_ag_segment "${1}" black orange "|${sec_diff}.${ms_part}|"
  __TTY_AG_SECOND="${second}"
}

# prints history followed by HH:MM, useful for remembering what
# we did previously
__tty_ag_prompt_history_time() {
  history -a
  history -c
  history -r
  __tty_ag_segment "${1}" black default " \! (\A)"
}

__tty_ag_prompt_time() {
  local _dt
  _dt=$(date '+%H┋%M┋%S')
  __tty_ag_segment "${1}" black darkgray "${_dt}"
}

__tty_ag_prompt_date() {
  local _dt
  _dt=$(date '+%Y-%m-%d_%H-%M-%S-%N')
  __tty_ag_segment "${1}" black darkgray "${_dt}"
}

# Dir: current working directory
__tty_ag_prompt_dir() {
  __tty_ag_segment "${1}" darkcyan darkgray '\w'
}

# Dir: current working directory
__tty_ag_prompt_full_pwd() {
  __tty_ag_segment "${1}" black darkgray "#|${PWD}|"
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
__tty_ag_prompt_status() {
  local symbols
  local red yellow cyan
  red=$(__tty_ag_fg_color red)
  yellow=$(__tty_ag_fg_color yellow)
  cyan=$(__tty_ag_fg_color cyan)

  symbols=()
  if [[ ${__TTY_AG_RETVAL} -ne 0 ]]; then
    symbols+=("$(__tty_ag_format_head "${red}")✘")
  fi
  if [[ ${UID} -eq 0 ]]; then
    symbols+=("$(__tty_ag_format_head "${yellow}")⚡")
  fi
  if [[ $(jobs -l | wc -l || true) -gt 0 ]]; then
    symbols+=("$(__tty_ag_format_head "${cyan}")⚙")
  fi
  if [[ -n ${symbols[*]} ]]; then
    __tty_ag_segment "${1}" black default "${symbols}"
  fi
  true
}

######################################################################
## Main prompt

__tty_ag_build_prompt() {

  __tty_ag_prompt_start_all

  __tty_ag_prompt_full_pwd 'RIGHT'
  __tty_ag_prompt_date  'RIGHT'

  __tty_ag_prompt_line  'LEFT'
  __tty_ag_prompt_history_time  'LEFT'

  __tty_ag_prompt_status  'LEFT'

  if [[ -z ${AG_NO_CONTEXT+x} ]]; then
    __tty_ag_prompt_context 'LEFT'
  fi
  __tty_ag_prompt_virtualenv  'RIGHT'
  __tty_ag_prompt_dir 'LEFT'
  __tty_ag_prompt_arc 'LEFT'
  __tty_ag_prompt_git 'LEFT'
  __tty_ag_prompt_hg  'LEFT'

  __tty_ag_prompt_end_all
}
