#!/usr/bin/env bash
# shellcheck enable=all

######################################################################
#
# experimental right prompt stuff
# requires setting prompt_foo to use prompt vs PS1L
# doesn't quite work

__tty_ag_right_prompt() {
  tput sc
  local prompt="${1}"
  # shellcheck disable=SC2312
  prompt_flat=$(echo -en "${prompt}" | ansi2txt | sed 's/\\\[\\\]//gi')

  local -i line_len=$((COLUMNS + ${#prompt_flat}))
  printf "%*s\r\n" "${line_len}" "${prompt}"
  tput rc
}
