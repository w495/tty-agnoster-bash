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
  local cur_bg_name_ref="__TTY_AG_CURRENT_BG_${position}"
  local fwd_sep_ref="__TTY_AG_SEGMENT_SEPARATOR_FORWARD_${position}"
  local prompt="${!prompt_ref}"
  local cur_bg_name="${!cur_bg_name_ref}"
  local fwd_sep="${!fwd_sep_ref}"

  eval "${prompt_ref}=''"
  eval "${cur_bg_name_ref}=''"
}

__tty_ag_prompt_begin_all() {
  __tty_ag_prompt_begin 'LEFT'
  __tty_ag_prompt_begin 'RIGHT'
  __tty_ag_prompt_begin 'BOTTOM'
  __tty_ag_prompt_begin 'TOP'
  __tty_ag_prompt_begin 'UNDER'
}

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
__tty_ag_segment() {
  local position="${1:-${__TTY_AG_SEGMENT_POSITION:-LEFT}}"
  local prompt_ref="__TTY_AG_PS1_${position}"
  local cur_bg_name_ref="__TTY_AG_CURRENT_BG_${position}"
  local fwd_sep_ref="__TTY_AG_SEGMENT_SEPARATOR_FORWARD_${position}"
  local rev_sep_ref="__TTY_AG_SEGMENT_SEPARATOR_REVERSE_${position}"

  local prompt="${!prompt_ref}"
  local cur_bg_name="${!cur_bg_name_ref}"
  local fwd_sep="${!fwd_sep_ref}"
  local rev_sep="${!rev_sep_ref}"


  __tty_ag_segment_debug "&prompt=${prompt_ref}"
  __tty_ag_segment_debug "&cur_bg_name=${cur_bg_name_ref}"
  __tty_ag_segment_debug "&fwd_sep=${fwd_sep_ref}"
  __tty_ag_segment_debug "&rev_sep=${rev_sep_ref}"


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

  local codes
  local -i __tty_ag_em_code
  local -i __tty_ag_fg_code
  local -i __tty_ag_bg_code

  codes="${__TTY_AG_EM_CODE_RESET}"


  if [[ -n "${cur_bg_name}" ]]; then
    if [[ "${bg_name}" != "${cur_bg_name}"  ]]; then
      __tty_ag_fg_code "${cur_bg_name}"
      __tty_ag_bg_code "${bg_name}"
      local sep_format="${__tty_ag_fg_code} ${__tty_ag_bg_code}"
      local __tty_ag_format_head
      __tty_ag_format_head "${sep_format}"
      __tty_ag_segment_debug "sep_format ${sep_format}"
      prompt="${prompt}${__tty_ag_format_head}${fwd_sep}"
    else
      __tty_ag_segment_debug "bg not changed"
    fi
  else
    __tty_ag_segment_debug "no current bg"
    if [[ -n "${bg_name}" ]]; then
      __tty_ag_segment_debug "but there new bg"
      local -i __tty_ag_fg_code
      __tty_ag_fg_code "${bg_name}"
      local sep_codes="${__TTY_AG_EM_CODE_RESET} ${__tty_ag_fg_code}"
      __tty_ag_format_head "${sep_codes}"
      prompt="${prompt}${__tty_ag_format_head}${rev_sep}"
    fi
  fi


  if [[ -n ${bg_name} ]]; then
    __tty_ag_bg_code "${bg_name}"
    codes="${codes} ${__tty_ag_bg_code}"
    __tty_ag_segment_debug "Added ${__tty_ag_bg_code} as bg to codes"
  fi
  if [[ -n ${fg_name} ]]; then
    __tty_ag_fg_code "${fg_name}"
    codes="${codes} ${__tty_ag_fg_code}"
    __tty_ag_segment_debug "Added ${__tty_ag_fg_code} as fg to codes"
  fi

  local __tty_ag_format_head
  __tty_ag_format_head "${codes}"
  __tty_ag_segment_debug "post prompt ${__tty_ag_format_head}"
  prompt="${prompt}${__tty_ag_format_head}"
  if [[ -n ${text} ]]; then
    prompt="${prompt}${text}"
  fi
  eval "${prompt_ref}='${prompt}'"
  eval "${cur_bg_name_ref}='${bg_name}'"
}

# End the prompt, closing any open segments
__tty_ag_prompt_end() {
  local position="${1:-${__TTY_AG_SEGMENT_POSITION:-LEFT}}"
  local prompt_ref="__TTY_AG_PS1_${position}"
  local cur_bg_name_ref="__TTY_AG_CURRENT_BG_${position}"
  local fwd_sep_ref="__TTY_AG_SEGMENT_SEPARATOR_FORWARD_${position}"
  local prompt="${!prompt_ref}"
  local cur_bg_name="${!cur_bg_name_ref}"
  local fwd_sep="${!fwd_sep_ref}"

  if [[ -n ${cur_bg_name} ]]; then
    local -i __tty_ag_fg_code
    __tty_ag_fg_code "${cur_bg_name}" 
    local sep_codes="${__TTY_AG_EM_CODE_RESET} ${__tty_ag_fg_code}"
    __tty_ag_format_head "${sep_codes}"
    prompt="${prompt}${__tty_ag_format_head}${fwd_sep}"
  fi
  local __tty_ag_format_tail
  __tty_ag_format_tail
  eval "${prompt_ref}='${prompt}${__tty_ag_format_tail}'"
  eval "${cur_bg_name_ref}=''"
}

__tty_ag_prompt_end_all() {
  __tty_ag_prompt_end 'LEFT'
  __tty_ag_prompt_end 'RIGHT'
  __tty_ag_prompt_end 'BOTTOM'
  __tty_ag_prompt_end 'TOP'
  __tty_ag_prompt_end 'UNDER'
}
