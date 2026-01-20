#!/usr/bin/env bash
# shellcheck enable=all

__tty_ag_top_window() {
  tput sc
  local prompt="${1}"

  prompt_flat=$(
    printf '%b' "${prompt}" | ansi2txt | sed -re 's/\o001|\o002//g'
  )
  local -i line_len=$((COLUMNS - ${#prompt_flat} - 2))

  tput csr "${line_len}" 0
  tput cup 0 "${line_len}"
#
#  prompt_x=$(echo "${prompt_flat}" | od -An -v -to1  -c )
#
#  printf '\n\n%s\n\n' "${prompt_x}" >&2

  printf '%s' "${prompt}"

  # Move cursor to home position, back in virtual window
  tput rc
}
