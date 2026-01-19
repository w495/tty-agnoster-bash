#!/usr/bin/env bash
# shellcheck enable=all

######################################################################
#
# experimental right prompt stuff

__tty_ag_under_prompt() {
  tput sc
  local prompt="${1}"
  printf "\r\n%s\r\b" "${prompt}"
  tput rc
}
