#!/usr/bin/env bash
# shellcheck enable=all

# ---------------------------------------------------------------
#     shfmt -ci -i 2 -sr -s -bn -kp -ln bash -d
# ---------------------------------------------------------------

__tty_ag_fg_color() {
  # It uses global var to reduce subshells
  case "$1" in
    black)
      __tty_ag_fg_color=30
      ;;
    darkred)
      __tty_ag_fg_color=31
      ;;
    darkgreen)
      __tty_ag_fg_color=32
      ;;
    yellow)
      __tty_ag_fg_color=33
      ;;
    darkblue)
      __tty_ag_fg_color=34
      ;;
    darkmagenta)
      __tty_ag_fg_color=35
      ;;
    darkcyan)
      __tty_ag_fg_color=36
      ;;
    white)
      __tty_ag_fg_color=37
      ;;
    darkgray)
      __tty_ag_fg_color=90
      ;;
    red)
      __tty_ag_fg_color=91
      ;;
    green)
      __tty_ag_fg_color=92
      ;;
    orange)
      __tty_ag_fg_color=93
      ;;
    blue)
      __tty_ag_fg_color=94
      ;;
    magenta)
      __tty_ag_fg_color=95
      ;;
    cyan)
      __tty_ag_fg_color=96
      ;;
    gray)
      __tty_ag_fg_color=96
      ;;
    *)
      __tty_ag_fg_color=''
      ;;
  esac
  echo "${__tty_ag_fg_color}"
}
