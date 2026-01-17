#!/usr/bin/env bash
# shellcheck enable=all

# ---------------------------------------------------------------
#     shfmt -ci -i 2 -sr -s -bn -kp -ln bash -d
# ---------------------------------------------------------------

__tty_ag_text_effect() {
  case "$1" in
    reset)
      echo 0
      ;;
    bold)
      echo 1
      ;;
    dim)
      echo 2
      ;;
    italic)
      echo 3
      ;;
    underline)
      echo 4
      ;;
    reverse)
      echo 7
      ;;
    del)
      echo 9
      ;;
    *)
      echo
      ;;
  esac
}
