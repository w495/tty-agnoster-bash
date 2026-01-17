#!/usr/bin/env bash
# shellcheck enable=all

# ---------------------------------------------------------------
#     shfmt -ci -i 2 -sr -s -bn -kp -ln bash -d
# ---------------------------------------------------------------

VERBOSE_MODE=false
SEGMENT_SEPARATOR="|"

source "$(dirname "${BASH_SOURCE[0]}")/utils.bash"

__tty_ag_segment_debug() {
  if [[ ${VERBOSE_MODE} == true ]]; then
    local -ir offset=1
    local -r func="${FUNCNAME[${offset}]}"
    local -r line="${BASH_LINENO[${offset}]}"

    printf -v x "%q" "${@}"
    printf "%s %s\n"  "${func}[${line}]" "${x}" >&2
  fi
}

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
__tty_ag_segment() {
  local current_bg_name="${1}"
  local prompt="${2}"
  local bg_name="${3}"
  local fg_name="${4}"
  local text="${5}"

  __tty_ag_segment_debug "Segment:"
  __tty_ag_segment_debug "current_bg_name=${current_bg_name}"
  __tty_ag_segment_debug "prompt=${prompt}"
  __tty_ag_segment_debug "bg_name=${bg_name}"
  __tty_ag_segment_debug "fg_name=${fg_name}"
  __tty_ag_segment_debug "text=${text}"

  local -i bg_code
  local -i fg_code
  local -a codes

  codes=("$(__tty_ag_text_effect reset)")

  if [[ -n ${bg_name}   ]]; then
    bg_code=$(__tty_ag_bg_color "${bg_name}")
    codes=("${codes[@]}" "${bg_code}")
    __tty_ag_segment_debug "Added ${bg_code} as background to codes"
  fi
  if [[ -n ${fg_name}   ]]; then
    fg_code=$(__tty_ag_fg_color "${fg_name}")
    codes=("${codes[@]}" "${fg_code}")
    __tty_ag_segment_debug "Added ${fg_code} as foreground to codes"
  fi
  if [[ ${current_bg_name} != NONE && ${bg_name} != "${current_bg_name}"   ]]; then
    local -a intermediate=(
      "$(__tty_ag_fg_color "${current_bg_name}")"
      "$(__tty_ag_bg_color "${bg_name}")"
    )
    local pre_prompt
    pre_prompt=$(__tty_ag_format_heads "${intermediate[@]}")
    __tty_ag_segment_debug "pre prompt ${pre_prompt}"
    prompt="${prompt}${pre_prompt}${SEGMENT_SEPARATOR}"
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
  echo -en "${prompt}"
}

__tty_ag_prompt_segment_left() {
  local bg_name="${1}"
  __tty_ag_segment_debug "bg_name=${1} fg_name=${2} text='${3}'"
  PS1L=$(__tty_ag_segment "${CURRENT_LBG}" "${PS1L}" "${@}")
  CURRENT_LBG="${bg_name}"
}

# Begin a segment on the right
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
__tty_ag_prompt_segment_right() {
  __tty_ag_segment_debug "bg_name=${1} fg_name=${2} text='${3}'"
  PS1R=$(__tty_ag_segment "${CURRENT_RBG}" "${PS1R}" "${@}")
  CURRENT_RBG=${bg_name}
}

# End the prompt, closing any open segments
__tty_ag_prompt_end() {
  if [[ -n ${CURRENT_LBG} ]]; then
    local -a codes=(
      "$(__tty_ag_text_effect reset)"
      "$(__tty_ag_fg_color "${CURRENT_LBG}")"
    )
    PS1L="${PS1L}$(__tty_ag_format_heads "${codes[@]}")${SEGMENT_SEPARATOR}"
  fi
  local -a reset=(
    "$(__tty_ag_text_effect reset)"
  )
  local reset_format
  reset_format=$(__tty_ag_format_heads "${reset[@]}")

  PS1L="${PS1L}${reset_format}"
  PS1R="${PS1R}${reset_format}"

  CURRENT_LBG=''
  CURRENT_RBG=''
}
