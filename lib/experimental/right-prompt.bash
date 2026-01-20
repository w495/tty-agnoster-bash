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
  prompt_flat=$(
    printf '%b' "${prompt}" | ansi2txt | sed -re 's/\o001|\o002//g'
  )
  local -i line_len=$((COLUMNS + ${#prompt} - ${#prompt_flat}))
  printf "%*s" "${line_len}" "${prompt}"
  tput rc
}
