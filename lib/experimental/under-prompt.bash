#!/usr/bin/env bash
# shellcheck enable=all

__tty_ag_show_under_prompt() {
  tput sc
  printf "\n%s " "${1}"
  tput rc
}
