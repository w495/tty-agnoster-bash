#!/usr/bin/env bash
# shellcheck enable=all

# ---------------------------------------------------------------
#     shfmt -ci -i 2 -sr -s -bn -kp -ln bash -d
# ---------------------------------------------------------------

__tty_ag_em_code() {
  # It uses global var to reduce subshells
  case "$1" in
    reset)
      __tty_ag_em_code=0
      ;;
    bold)
      __tty_ag_em_code=1
      ;;
    dim)
      __tty_ag_em_code=2
      ;;
    italic)
      __tty_ag_em_code=3
      ;;
    underline)
      __tty_ag_em_code=4
      ;;
    reverse)
      __tty_ag_em_code=7
      ;;
    del)
      __tty_ag_em_code=9
      ;;
    *)
      __tty_ag_em_code=''
      ;;
  esac
}
