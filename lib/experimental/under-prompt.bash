#!/usr/bin/env bash
# shellcheck enable=all

######################################################################
#
# experimental right prompt stuff
# requires setting prompt_foo to use PS1R vs PS1L
# doesn't quite work

__tty_ag_under_prompt() {
  tput sc
  local ps1r="${1}"
  # shellcheck disable=SC2312
  ps1r_flat=$(echo -en "${ps1r}" | ansi2txt | sed 's/\\\[\\\]//gi')
  local -i len_diff=$((${#ps1r} - ${#ps1r_flat}))
  local -i line_len=$((COLUMNS + len_diff))
  printf "%*s\r\n" "${line_len}" "${ps1r}"
  tput rc
}
