#!/usr/bin/env bash
# shellcheck enable=all

# ---------------------------------------------------------------
#     shfmt -ci -i 2 -sr -s -bn -kp -ln bash -d
# ---------------------------------------------------------------

__tty_ag_fg_color() {
  case "$1" in
    black)
      echo 30
      ;;
    darkred)
      echo 31
      ;;
    darkgreen)
      echo 32
      ;;
    yellow)
      echo 33
      ;;
    darkblue)
      echo 34
      ;;
    darkmagenta)
      echo 35
      ;;
    darkcyan)
      echo 36
      ;;
    white)
      echo 37
      ;;
    darkgray)
      echo 90
      ;;
    red)
      echo 91
      ;;
    green)
      echo 92
      ;;
    orange)
      echo 93
      ;;
    blue)
      echo 94
      ;;
    magenta)
      echo 95
      ;;
    cyan)
      echo 96
      ;;
    gray)
      echo 96
      ;;
    *)
      echo
      ;;
  esac
}
