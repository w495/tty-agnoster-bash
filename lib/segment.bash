#!/usr/bin/env bash
# shellcheck enable=all

# ---------------------------------------------------------------
#     shfmt -ci -i 2 -sr -s -bn -kp -ln bash -d
# ---------------------------------------------------------------

__TTY_AG_DEBUG_MODE=false

source "$(dirname "${BASH_SOURCE[0]}")/utils.bash"

__tty_ag_em_code reset > /dev/null
__TTY_AG_EM_CODE_RESET="${__tty_ag_em_code}"

__tty_ag_segment_debug() {
  if [[ ${__TTY_AG_DEBUG_MODE} == true ]]; then
    local -ir offset=1
    local -r func="${FUNCNAME[${offset}]}"
    local -r line="${BASH_LINENO[${offset}]}"

    printf -v x "%q" "${@}"
    printf "%s %s\n" "${func}[${line}]" "${x}" >&2
  fi
}

__tty_ag_prompt_start() {
  local position="${1}"
  local prompt_ref="__TTY_AG_PS1_${position}"
  local cur_bg_name_ref="__TTY_AG_CURRENT_BG_${position}"
  local seg_sep_ref="__TTY_AG_SEGMENT_SEPARATOR_${position}"
  local prompt="${!prompt_ref}"
  local cur_bg_name="${!cur_bg_name_ref}"
  local seg_sep="${!seg_sep_ref}"

  local __tty_ag_em_code
  __tty_ag_em_code reset > /dev/null

  local reset_format
  reset_format="$(__tty_ag_format_head "${__tty_ag_em_code}")"

  eval "${prompt_ref}='${reset_format}'"
  eval "${cur_bg_name_ref}=''"
}

__tty_ag_prompt_start_all() {
  __tty_ag_prompt_start 'LEFT'
  __tty_ag_prompt_start 'RIGHT'
  __tty_ag_prompt_start 'BOTTOM'
  __tty_ag_prompt_start 'TOP'
  __tty_ag_prompt_start 'UNDER'
}

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
__tty_ag_segment() {
  local position="${1}"
  local prompt_ref="__TTY_AG_PS1_${position}"
  local cur_bg_name_ref="__TTY_AG_CURRENT_BG_${position}"
  local seg_sep_ref="__TTY_AG_SEGMENT_SEPARATOR_${position}"
  local prompt="${!prompt_ref}"
  local cur_bg_name="${!cur_bg_name_ref}"
  local seg_sep="${!seg_sep_ref}"

  __tty_ag_segment_debug "&prompt=${prompt_ref}"
  __tty_ag_segment_debug "&cur_bg_name=${cur_bg_name_ref}"
  __tty_ag_segment_debug "&seg_sep=${seg_sep_ref}"

  shift
  __tty_ag_segment_debug "1=${1} 2=${2} 3=${3}"

  local bg_name="${1}"
  local fg_name="${2}"
  local text="${3}"

  __tty_ag_segment_debug "Segment:"
  __tty_ag_segment_debug "cur_bg_name=${cur_bg_name}"
  __tty_ag_segment_debug "prompt=${prompt}"
  __tty_ag_segment_debug "bg_name=${bg_name}"
  __tty_ag_segment_debug "fg_name=${fg_name}"
  __tty_ag_segment_debug "text=${text}"

  local -a codes
  local -i __tty_ag_em_code
  local -i __tty_ag_fg_code
  local -i __tty_ag_bg_code

  codes=("${__TTY_AG_EM_CODE_RESET}")

  if [[ -n ${bg_name} ]]; then
    __tty_ag_bg_code "${bg_name}" > /dev/null
    codes=("${codes[@]}" "${__tty_ag_bg_code}")
    __tty_ag_segment_debug "Added ${__tty_ag_bg_code} as bg to codes"
  fi
  if [[ -n ${fg_name} ]]; then
    __tty_ag_fg_code "${fg_name}" > /dev/null
    codes=("${codes[@]}" "${__tty_ag_fg_code}")
    __tty_ag_segment_debug "Added ${__tty_ag_fg_code} as fg to codes"
  fi
  if [[ -n ${cur_bg_name}  && ${bg_name} != "${cur_bg_name}" ]]; then
    __tty_ag_fg_code "${cur_bg_name}" > /dev/null
    __tty_ag_bg_code "${bg_name}" > /dev/null
    local -a intermediate=(
      "${__tty_ag_fg_code}"
      "${__tty_ag_bg_code}"
    )
    local pre_prompt
    pre_prompt=$(__tty_ag_format_heads "${intermediate[@]}")
    __tty_ag_segment_debug "pre prompt ${pre_prompt}"
    prompt="${prompt}${pre_prompt}${seg_sep}"
  else
    __tty_ag_segment_debug "no current BG, codes is ${codes[*]}"
  fi
  local post_prompt
  post_prompt=$(__tty_ag_format_heads "${codes[@]}")
  __tty_ag_segment_debug "post prompt ${post_prompt}"
  prompt="${prompt}${post_prompt}"
  if [[ -n ${text} ]]; then
    prompt="${prompt}${text}"
  fi
  eval "${prompt_ref}='${prompt}'"
  eval "${cur_bg_name_ref}='${bg_name}'"
}

# End the prompt, closing any open segments
__tty_ag_prompt_end() {
  local position="${1}"
  local prompt_ref="__TTY_AG_PS1_${position}"
  local cur_bg_name_ref="__TTY_AG_CURRENT_BG_${position}"
  local seg_sep_ref="__TTY_AG_SEGMENT_SEPARATOR_${position}"
  local prompt="${!prompt_ref}"
  local cur_bg_name="${!cur_bg_name_ref}"
  local seg_sep="${!seg_sep_ref}"

  if [[ -n ${cur_bg_name} ]]; then
    local -i __tty_ag_fg_code
    __tty_ag_fg_code "${cur_bg_name}" > /dev/null
    local -a codes=(
      "${__TTY_AG_EM_CODE_RESET}"
      "${__tty_ag_fg_code}"
    )
    local heads
    heads=$(__tty_ag_format_heads "${codes[@]}")
    prompt="${prompt}${heads}${seg_sep}"
  fi
  local format_tail
  format_tail="$(__tty_ag_format_tail)"

  eval "${prompt_ref}='${prompt}${format_tail}'"
  eval "${cur_bg_name_ref}=''"
}

__tty_ag_prompt_end_all() {
  __tty_ag_prompt_end 'LEFT'
  __tty_ag_prompt_end 'RIGHT'
  __tty_ag_prompt_end 'BOTTOM'
  __tty_ag_prompt_end 'TOP'
  __tty_ag_prompt_end 'UNDER'
}



__tty_ag_seg() {
  local pos
  local bg_name
  local fg_name
  local em_name
  local text="${3}"

  local opts
  local this="${BASH_SOURCE[0]}"
  opts=$(
    getopt -n "${this}" -a -o 'p:b:f:e:t:' -l '
    ps:,pos:,position:,
    bg:,bag:,background:,
    fg:,fog:,foreground:,
    em:,emp:,emphasis:,
    ef:,eff:,effect:,
    tx:,txt:,text:
  ' -- "${@}"
  )
  eval set -- "${opts}"

  while [[ $# -gt 0 ]]; do
    case ${1} in
      -p | --ps | --pos | --position)
        pos="${2}"
        shift 2
        ;;
      -b | --bg | --bag | --background)
        bg_name="${2}"
        shift 2
        ;;
      -f | --fg | --fog | --foreground)
        fg_name="${2}"
        shift 2
        ;;
      -e | --em | --emp | --emphasis)
        fg_name="${2}"
        shift 2
        ;;
      -t | --tx | --txt | --text)
        text="${2}"
        shift 2
        ;;
      '--' | '')
        shift 1
        break
        ;;
      *)
        echo "Unknown parameter '${1}'." >&2
        shift 1
        ;;
    esac
  done

  __tty_ag_segment "${pos}" "${bg_name}" "${fg_name}" "${text}"
}
