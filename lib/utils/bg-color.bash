#!/usr/bin/env bash
# shellcheck enable=all

# ---------------------------------------------------------------
#     shfmt -ci -i 2 -sr -s -bn -kp -ln bash -d
# ---------------------------------------------------------------

__tty_ag_bg_code() {
  # It uses global var to reduce subshells
  case "$1" in
    black)
      __tty_ag_bg_code=40
      ;;
    darkred)
      __tty_ag_bg_code=41
      ;;
    darkgreen)
      __tty_ag_bg_code=42
      ;;
    yellow)
      __tty_ag_bg_code=43
      ;;
    darkblue)
      __tty_ag_bg_code=44
      ;;
    darkmagenta)
      __tty_ag_bg_code=45
      ;;
    darkcyan)
      __tty_ag_bg_code=46
      ;;
    white)
      __tty_ag_bg_code=47
      ;;
    darkgray)
      __tty_ag_bg_code=100
      ;;
    red)
      __tty_ag_bg_code=101
      ;;
    green)
      __tty_ag_bg_code=102
      ;;
    orange)
      __tty_ag_bg_code=103
      ;;
    blue)
      __tty_ag_bg_code=104
      ;;
    magenta)
      __tty_ag_bg_code=105
      ;;
    cyan)
      __tty_ag_bg_code=106
      ;;
    gray)
      __tty_ag_bg_code=107
      ;;
    *)
      __tty_ag_bg_code=''
      ;;
  esac
  echo "${__tty_ag_bg_code}"
}
