#!/usr/bin/env bash
# shellcheck enable=all

# ---------------------------------------------------------------
#     shfmt -ci -i 2 -sr -s -bn -kp -ln bash -d
# ---------------------------------------------------------------

__TTY_AG_DEBUG_MODE=false

source "$(dirname "${BASH_SOURCE[0]}")/utils.bash"

__tty_ag_em_code reset 
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

__tty_ag_prompt_begin() {
  local position="${1:-${__TTY_AG_SEGMENT_POSITION:-LEFT}}"
  local prompt_ref="__TTY_AG_PS1_${position}"
  local old_bg_name_ref="__TTY_AG_OLD_BG_${position}"
  local old_fg_name_ref="__TTY_AG_OLD_FG_${position}"


  eval "${prompt_ref}=''"
  eval "${old_bg_name_ref}=''"
  eval "${old_fg_name_ref}=''"

}


# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.

__tty_ag_segment() {
  local position="${1:-${__TTY_AG_SEGMENT_POSITION:-LEFT}}"
  local prompt_ref="__TTY_AG_PS1_${position}"
  local old_bg_name_ref="__TTY_AG_OLD_BG_${position}"
  local old_fg_name_ref="__TTY_AG_OLD_FG_${position}"

  local fwd_sep_ref="__TTY_AG_SEGMENT_SEPARATOR_FORWARD_${position}"
  local rev_sep_ref="__TTY_AG_SEGMENT_SEPARATOR_REVERSE_${position}"

  local prompt="${!prompt_ref}"
  local old_bg_name="${!old_bg_name_ref}"
  local old_fg_name="${!old_fg_name_ref}"

  local fwd_sep="${!fwd_sep_ref}"
  local rev_sep="${!rev_sep_ref}"

  __tty_ag_segment_debug "&prompt=${prompt_ref}"
  __tty_ag_segment_debug "&old_bg_name=${old_bg_name_ref}"
  __tty_ag_segment_debug "&fwd_sep=${fwd_sep_ref}"
  __tty_ag_segment_debug "&rev_sep=${rev_sep_ref}"

  shift
  __tty_ag_segment_debug "1=${1} 2=${2} 3=${3}"

  local -l new_bg_name="${1}"
  local -l new_fg_name="${2}"
  local text="${3}"

  __tty_ag_segment_debug "Segment:"
  __tty_ag_segment_debug "old_bg_name=${old_bg_name}"
  __tty_ag_segment_debug "prompt=${prompt}"
  __tty_ag_segment_debug "new_bg_name=${new_bg_name}"
  __tty_ag_segment_debug "new_fg_name=${new_fg_name}"
  __tty_ag_segment_debug "text=${text}"

  local fmt_code_seq
  local -i __tty_ag_em_code
  local -i __tty_ag_fg_code
  local -i __tty_ag_bg_code
  local __tty_ag_format_head


  __tty_ag_bg_code "${old_bg_name}"
  local -i old_bg_code="${__tty_ag_bg_code}"
  __tty_ag_fg_code "${old_fg_name}"
  local -i old_fg_code="${__tty_ag_fg_code}"

  __tty_ag_bg_code "${new_bg_name}"
  local -i new_bg_code="${__tty_ag_bg_code}"
  __tty_ag_fg_code "${new_fg_name}"
  local -i new_fg_code="${__tty_ag_fg_code}"


  # -----------------------------------------------------------------
  # Show separator
  # -----------------------------------------------------------------

  if [[ "${old_bg_code}" -eq 0 ]]; then
    __tty_ag_segment_debug "No current background."
    if [[ "${new_bg_code}" -ne 0 ]]; then
      __tty_ag_segment_debug "But there is new background."
      __tty_ag_segment_debug "Set background color to foreground."
      __tty_ag_fg_code "${new_bg_name}"
      __tty_ag_format_head "${__TTY_AG_EM_CODE_RESET}" "${__tty_ag_fg_code}"
      prompt="${prompt}${__tty_ag_format_head}${rev_sep}"
    fi
  else
    if [[ "${new_bg_code}" -ne "${old_bg_code}"  ]]; then
      __tty_ag_segment_debug "Set background color to foreground."
      __tty_ag_fg_code "${old_bg_name}"
      __tty_ag_format_head "${__tty_ag_fg_code}" "${new_bg_code}"
      __tty_ag_segment_debug "fwd_sep ${__tty_ag_fg_code} ${new_bg_code}"
      prompt="${prompt}${__tty_ag_format_head}${fwd_sep}"
    else
      __tty_ag_segment_debug "bg not changed"
    fi
  fi

  # Show text
  fmt_code_seq="${__TTY_AG_EM_CODE_RESET}"
  if [[ ${new_bg_code} -ne 0 ]]; then
    fmt_code_seq="${fmt_code_seq} ${new_bg_code}"
    __tty_ag_segment_debug "Added ${__tty_ag_bg_code} as bg to fmt_code_seq"
  fi

  if [[ ${new_fg_code} -eq 0 ]]; then
    new_fg_code="${old_fg_code}"
  fi
  if [[ ${new_fg_code} -ne 0 ]]; then
    fmt_code_seq="${fmt_code_seq} ${new_fg_code}"
    __tty_ag_segment_debug "Added ${__tty_ag_fg_code} as fg to fmt_code_seq"
  fi

  __tty_ag_format_head "${fmt_code_seq}"
  prompt="${prompt}${__tty_ag_format_head}"
  if [[ -n ${text} ]]; then
    prompt="${prompt}${text}"
  fi


  eval "${prompt_ref}='${prompt}'"
  eval "${old_bg_name_ref}='${new_bg_name}'"
  eval "${old_fg_name_ref}='${new_fg_name}'"

}

# End the prompt, closing any open segments
__tty_ag_prompt_end() {
  local position="${1:-${__TTY_AG_SEGMENT_POSITION:-LEFT}}"
  local prompt_ref="__TTY_AG_PS1_${position}"
  local old_bg_name_ref="__TTY_AG_OLD_BG_${position}"
  local fwd_sep_ref="__TTY_AG_SEGMENT_SEPARATOR_FORWARD_${position}"
  local prompt="${!prompt_ref}"
  local old_bg_name="${!old_bg_name_ref}"
  local fwd_sep="${!fwd_sep_ref}"

  __tty_ag_bg_code "${old_bg_name}"
  local -i old_bg_code="${__tty_ag_bg_code}"

  if [[ "${old_bg_code}" -ne 0 ]]; then
    local -i __tty_ag_fg_code
    __tty_ag_fg_code "${old_bg_name}"
    __tty_ag_format_head "${__TTY_AG_EM_CODE_RESET}" "${__tty_ag_fg_code}"
    prompt="${prompt}${__tty_ag_format_head}${fwd_sep}"
  fi
  local __tty_ag_format_tail
  __tty_ag_format_tail
  eval "${prompt_ref}='${prompt}${__tty_ag_format_tail}'"
  eval "${old_bg_name_ref}=''"
}
