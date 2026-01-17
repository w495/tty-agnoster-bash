#!/usr/bin/env bash
# shellcheck enable=all

# ---------------------------------------------------------------
#     shfmt -ci -i 2 -sr -s -bn -kp -ln bash -d
# ---------------------------------------------------------------

__tty_ag_bg_color() {
  case "$1" in
    black)
      echo 40
      ;;
    darkred)
      echo 41
      ;;
    darkgreen)
      echo 42
      ;;
    yellow)
      echo 43
      ;;
    darkblue)
      echo 44
      ;;
    darkmagenta)
      echo 45
      ;;
    darkcyan)
      echo 46
      ;;
    white)
      echo 47
      ;;
    darkgray)
      echo 100
      ;;
    red)
      echo 101
      ;;
    green)
      echo 102
      ;;
    orange)
      echo 103
      ;;
    blue)
      echo 104
      ;;
    magenta)
      echo 105
      ;;
    cyan)
      echo 106
      ;;
    gray)
      echo 107
      ;;
    *)
      echo
      ;;
  esac
}
