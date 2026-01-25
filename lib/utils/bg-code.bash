#!/usr/bin/env bash
# shellcheck enable=all

# ---------------------------------------------------------------
#     shfmt -ci -i 2 -sr -s -bn -kp -ln bash -d
# ---------------------------------------------------------------

__tty_ag_bg_code() {
  # It uses global var to reduce subshells
  case "${1}" in
    -black)
      __tty_ag_bg_code=40
      ;;
    -red)
      __tty_ag_bg_code=41
      ;;
    -green)
      __tty_ag_bg_code=42
      ;;
    -yellow)
      __tty_ag_bg_code=43
      ;;
    -blue)
      __tty_ag_bg_code=44
      ;;
    -magenta)
      __tty_ag_bg_code=45
      ;;
    -cyan)
      __tty_ag_bg_code=46
      ;;
    -white)
      __tty_ag_bg_code=47
      ;;
    +black)
      __tty_ag_bg_code=100
      ;;
    +red)
      __tty_ag_bg_code=101
      ;;
    +green)
      __tty_ag_bg_code=102
      ;;
    +yellow)
      __tty_ag_bg_code=103
      ;;
    +blue)
      __tty_ag_bg_code=104
      ;;
    +magenta)
      __tty_ag_bg_code=105
      ;;
    +cyan)
      __tty_ag_bg_code=106
      ;;
    +white)
      __tty_ag_bg_code=107
      ;;
    *)
      __tty_ag_bg_code=0
      return 1
      ;;
  esac
}

#
#__tty_ag_bg_exists() {
#  local -l name="${1}"
#  [[ -z "${1}" ]] && return 1
#  [[ '_' == "${1}" ]] && return 1
#  [[ 'null' == "${1}" ]] && return 1
#  [[ 'none' == "${1}" ]] && return 1
#
#  return 0
#}
