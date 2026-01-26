#!/usr/bin/env bash
# shellcheck enable=all

# ---------------------------------------------------------------
#     shfmt -ci -i 2 -sr -s -bn -kp -ln bash -d
# ---------------------------------------------------------------

source "$(dirname "${BASH_SOURCE[0]}")/fg-code.bash"
source "$(dirname "${BASH_SOURCE[0]}")/bg-code.bash"

__TTY_AG_DEBUG_MODE=false

__tty_ag_format_debug() {
  if ${__TTY_AG_DEBUG_MODE}; then
    local -ir offset=1
    local -r func="${FUNCNAME[${offset}]}"
    local -r line="${BASH_LINENO[${offset}]}"
    printf -v x "%q" "${@}"
    printf "%s %s\n" "${func}[${line}]" "${x}" >&2
  fi
}

__tty_ag_format_fg() {
  # It uses global var to avoid subshells.
  local __tty_ag_fg_code
  local __tty_ag_format
  __tty_ag_fg_code "${1}"
  __tty_ag_format_head "${__tty_ag_fg_code}"
  __tty_ag_format_fg="${__tty_ag_format_head}"
}

__tty_ag_format_bg() {
  # It uses global var to avoid subshells.
  local __tty_ag_bg_code
  local __tty_ag_format
  __tty_ag_bg_code "${1}"
  __tty_ag_format_head "${__tty_ag_bg_code}"
  __tty_ag_format_bg="${__tty_ag_format_head}"
}

__tty_ag_format_head() {
  # It uses global var to avoid subshells.
  local code_seq="${*}"
  __tty_ag_format_debug "code_seq: ${code_seq}"
  local seq=''
  for code in ${code_seq}; do
    if [[ -n ${seq} ]]; then
      seq="${seq};"
    fi
    seq="${seq}${code}"
  done
  __tty_ag_format_debug "\\e['${seq}'m"
  printf -v __tty_ag_format_head "%b" "\0001\0033[${seq}m\0002"
}

__tty_ag_format_tail() {
  # It uses global var to avoid subshells.
  printf -v __tty_ag_format_tail "%b" "\0001\0033[0m\0002"
}

___tty_ag_format_plain() {
  # shellcheck disable=SC2312
  ansi2txt | sed -re 's/\o001|\o002//g'
}

__tty_ag_format_plain() {
  if [[ -n "${1}" ]]; then
    printf '%s' "${1}" | ___tty_ag_format_plain
  else
    ___tty_ag_format_plain
  fi
}

___tty_ag_format_chars_number() {
  # shellcheck disable=SC2312
  ___tty_ag_format_plain | wc --chars
}

__tty_ag_format_chars_number() {
  if [[ -n "${1}" ]]; then
    printf '%b' "${1}" | ___tty_ag_format_chars_number
  else
    ___tty_ag_format_chars_number
  fi
}

___tty_ag_format_bytes_number() {
  wc --bytes
}

__tty_ag_format_bytes_number() {
  if [[ -n "${1}" ]]; then
    printf '%b' "${1}" | ___tty_ag_format_bytes_number
  else
    ___tty_ag_format_bytes_number
  fi
}

__tty_ag_format_delta() {
  # It uses global var to avoid subshells.
  local -i bytes_number
  bytes_number=$(__tty_ag_format_bytes_number "${1}")
  local -i chars_number
  chars_number=$(__tty_ag_format_chars_number "${1}")
  __tty_ag_format_delta=$(("${bytes_number}" - "${chars_number}"))
}
