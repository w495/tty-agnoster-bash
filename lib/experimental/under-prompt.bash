#!/usr/bin/env bash
# shellcheck enable=all

######################################################################
#
# experimental right prompt stuff

__tty_ag_under_prompt() {
  tput sc
  printf "\n%s" "${1}"
  tput rc
}
