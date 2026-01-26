#!/usr/bin/env bash
# shellcheck enable=all

# ---------------------------------------------------------------
#     shfmt -ci -i 2 -sr -s -bn -kp -ln bash -d
# ---------------------------------------------------------------

__tty_ag_fg_code() {
  # It uses global var to avoid subshells
  local -l color_name="${1}"
  case "${color_name}" in
    -black)
      __tty_ag_fg_code=30
      ;;
    -red)
      __tty_ag_fg_code=31
      ;;
    -green)
      __tty_ag_fg_code=32
      ;;
    -yellow)
      __tty_ag_fg_code=33
      ;;
    -blue)
      __tty_ag_fg_code=34
      ;;
    -magenta)
      __tty_ag_fg_code=35
      ;;
    -cyan)
      __tty_ag_fg_code=36
      ;;
    -white)
      __tty_ag_fg_code=37
      ;;
    +black)
      __tty_ag_fg_code=90
      ;;
    +red)
      __tty_ag_fg_code=91
      ;;
    +green)
      __tty_ag_fg_code=92
      ;;
    +yellow)
      __tty_ag_fg_code=93
      ;;
    +blue)
      __tty_ag_fg_code=94
      ;;
    +magenta)
      __tty_ag_fg_code=95
      ;;
    +cyan)
      __tty_ag_fg_code=96
      ;;
    +white)
      __tty_ag_fg_code=97
      ;;
    *)
      __tty_ag_fg_code=0
      ;;
  esac
}
