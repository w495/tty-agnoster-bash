#!/usr/bin/env bash
# shellcheck enable=all

# ---------------------------------------------------------------
#     shfmt -ci -i 2 -sr -s -bn -kp -ln bash -d
# ---------------------------------------------------------------

__tty_ag_bg_color() {
  # It uses global var to reduce subshells
  case "$1" in
  black)
    __tty_ag_bg_color=40
    ;;
  darkred)
    __tty_ag_bg_color=41
    ;;
  darkgreen)
    __tty_ag_bg_color=42
    ;;
  yellow)
    __tty_ag_bg_color=43
    ;;
  darkblue)
    __tty_ag_bg_color=44
    ;;
  darkmagenta)
    __tty_ag_bg_color=45
    ;;
  darkcyan)
    __tty_ag_bg_color=46
    ;;
  white)
    __tty_ag_bg_color=47
    ;;
  darkgray)
    __tty_ag_bg_color=100
    ;;
  red)
    __tty_ag_bg_color=101
    ;;
  green)
    __tty_ag_bg_color=102
    ;;
  orange)
    __tty_ag_bg_color=103
    ;;
  blue)
    __tty_ag_bg_color=104
    ;;
  magenta)
    __tty_ag_bg_color=105
    ;;
  cyan)
    __tty_ag_bg_color=106
    ;;
  gray)
    __tty_ag_bg_color=107
    ;;
  *)
    __tty_ag_bg_color=''
    ;;
  esac
  echo "${__tty_ag_bg_color}"
}
