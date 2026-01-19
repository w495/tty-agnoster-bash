#!/usr/bin/env bash
# shellcheck enable=all

# ---------------------------------------------------------------
#     shfmt -ci -i 2 -sr -s -bn -kp -ln bash -d
# ---------------------------------------------------------------

__tty_ag_fg_code() {
  # It uses global var to reduce subshells
  case "$1" in
    black)
      __tty_ag_fg_code=30
      ;;
    darkred)
      __tty_ag_fg_code=31
      ;;
    darkgreen)
      __tty_ag_fg_code=32
      ;;
    yellow)
      __tty_ag_fg_code=33
      ;;
    darkblue)
      __tty_ag_fg_code=34
      ;;
    darkmagenta)
      __tty_ag_fg_code=35
      ;;
    darkcyan)
      __tty_ag_fg_code=36
      ;;
    white)
      __tty_ag_fg_code=37
      ;;
    darkgray)
      __tty_ag_fg_code=90
      ;;
    red)
      __tty_ag_fg_code=91
      ;;
    green)
      __tty_ag_fg_code=92
      ;;
    orange)
      __tty_ag_fg_code=93
      ;;
    blue)
      __tty_ag_fg_code=94
      ;;
    magenta)
      __tty_ag_fg_code=95
      ;;
    cyan)
      __tty_ag_fg_code=96
      ;;
    gray)
      __tty_ag_fg_code=96
      ;;
    *)
      __tty_ag_fg_code=''
      ;;
  esac
  echo "${__tty_ag_fg_code}"
}
