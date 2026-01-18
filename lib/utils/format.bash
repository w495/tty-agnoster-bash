#!/usr/bin/env bash
# shellcheck enable=all

# ---------------------------------------------------------------
#     shfmt -ci -i 2 -sr -s -bn -kp -ln bash -d
# ---------------------------------------------------------------

__TTY_AG_DEBUG_MODE=false

__tty_ag_format_debug() {
  if [[ ${__TTY_AG_DEBUG_MODE} == true ]]; then
    local -ir offset=1
    local -r func="${FUNCNAME[${offset}]}"
    local -r line="${BASH_LINENO[${offset}]}"

    printf -v x "%q" "${@}"
    printf "%s %s\n"  "${func}[${line}]" "${x}" >&2
  fi
}

__tty_ag_format_heads() {
  local -a codes=("${@}")
  __tty_ag_format_debug "format: ${codes[*]}"
  local seq=''
  for ((i = 0; i < ${#codes[@]}; i++)); do
    if [[ -n ${seq} ]]; then
      seq="${seq};"
    fi
    seq="${seq}${codes[${i}]}"
  done
  __tty_ag_format_debug "\\e['${seq}'m"
  printf "%b" "\[\0033[${seq}m\]"
}

__tty_ag_format_head() {
  printf "%b" "\[\0033[${1}m\]"
}


__tty_ag_format_reset() {
  printf "%b" "\[\0033[0m\]"
}

__tty_ag_format_tail() {
  printf "%b" "\[\0033[0m\]"
}
