#!/usr/bin/env bash
# shellcheck enable=all

# COMPATIBILITY NOTE:
# ---------------------------------------------------------------
#   bash/zsh/ksh93:
#     shfmt -ci -i 2 -sr -s -bn -kp -ln bash -d
#
#   See compatibility notes below and use posix variants.
#   How to check posix:
#     shfmt -ci -i 2 -sr -s -bn -kp -ln posix -d
# ---------------------------------------------------------------


__tty_ag_echo_lib() (
  source ./tty-ag-echo.lib.bash
  __tty_ag_echo "${@}"

  # grep '()' | sed -re 's/\s+(.*)\(\) \{/unset \1/gi'
  #  unset __tty_ag_echo_usage
  #  unset __tty_ag_echo_te_code_seq
  #  unset __tty_ag_echo_te_code
  #  unset __tty_ag_echo_color_code_case
  #  unset __tty_ag_echo_rename_color
  #  unset __tty_ag_echo_color_std_name
  #  unset __tty_ag_echo_color_code_pair
  #  unset __tty_ag_echo_fg_code
  #  unset __tty_ag_echo_bg_code
  #  unset __tty_ag_echo_join_code_seq
  #  unset __tty_ag_echo_code_str
  #  unset __tty_ag_echo_head
  #  unset __tty_ag_echo_tail
  #  unset __tty_ag_echo_main

)
