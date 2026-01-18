#!/usr/bin/env bash
# shellcheck enable=all

# ---------------------------------------------------------------
#     shfmt -ci -i 2 -sr -s -bn -kp -ln bash -d
# ---------------------------------------------------------------

__tty_ag_text_effect() {
  # It uses global var to reduce subshells
  case "$1" in
  reset)
    __tty_ag_text_effect=0
    ;;
  bold)
    __tty_ag_text_effect=1
    ;;
  dim)
    __tty_ag_text_effect=2
    ;;
  italic)
    __tty_ag_text_effect=3
    ;;
  underline)
    __tty_ag_text_effect=4
    ;;
  reverse)
    __tty_ag_text_effect=7
    ;;
  del)
    __tty_ag_text_effect=9
    ;;
  *)
    __tty_ag_text_effect=''
    ;;
  esac
  echo "${__tty_ag_text_effect}"
}
