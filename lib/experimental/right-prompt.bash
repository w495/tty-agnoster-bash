#!/usr/bin/env bash
# shellcheck enable=all

######################################################################
#
# experimental right prompt stuff
# requires setting prompt_foo to use prompt vs PS1L
# doesn't quite work

source "$(dirname "${BASH_SOURCE[0]}")/../utils/format.bash"

__tty_ag_show_right_prompt() {

  local prompt="${1}"
  local __tty_ag_format_delta
  __tty_ag_format_delta "${prompt}"
  local -i line_len=$(("${COLUMNS}" + "${__tty_ag_format_delta}"))

  tput sc
  printf "%*s" "${line_len}" "${prompt}"
  tput rc
}
