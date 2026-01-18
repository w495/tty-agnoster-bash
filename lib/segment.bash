#!/usr/bin/env bash
# shellcheck enable=all

# ---------------------------------------------------------------
#     shfmt -ci -i 2 -sr -s -bn -kp -ln bash -d
# ---------------------------------------------------------------

__TTY_AG_DEBUG_MODE=false

source "$(dirname "${BASH_SOURCE[0]}")/utils.bash"

__tty_ag_segment_debug() {
  if [[ ${__TTY_AG_DEBUG_MODE} == true ]]; then
    local -ir offset=1
    local -r func="${FUNCNAME[${offset}]}"
    local -r line="${BASH_LINENO[${offset}]}"

    printf -v x "%q" "${@}"
    printf "%s %s\n"  "${func}[${line}]" "${x}" >&2
  fi
}


# End the prompt, closing any open segments
__tty_ag_prompt_start() {
  local position="${1}"
  local prompt_ref="__TTY_AG_PS1_${position}"
  local current_bg_name_ref="__TTY_AG_CURRENT_BG_${position}"
  local segment_separator_ref="__TTY_AG_SEGMENT_SEPARATOR_${position}"
  local prompt="${!prompt_ref}"
  local current_bg_name="${!current_bg_name_ref}"
  local segment_separator="${!segment_separator_ref}"

  local __tty_ag_text_effect
  __tty_ag_text_effect reset > /dev/null

  local reset_format
  reset_format="$(__tty_ag_format_head "${__tty_ag_text_effect}")"

  eval "${prompt_ref}='${reset_format}'"
  eval "${current_bg_name_ref}='NONE'"
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
  local current_bg_name_ref="__TTY_AG_CURRENT_BG_${position}"
  local segment_separator_ref="__TTY_AG_SEGMENT_SEPARATOR_${position}"
  local prompt="${!prompt_ref}"
  local current_bg_name="${!current_bg_name_ref}"
  local segment_separator="${!segment_separator_ref}"

  __tty_ag_segment_debug "&prompt=${prompt_ref}"
  __tty_ag_segment_debug "&current_bg_name=${current_bg_name_ref}"
  __tty_ag_segment_debug "&segment_separator=${segment_separator_ref}"

  shift
  __tty_ag_segment_debug "1=${1} 2=${2} 3=${3}"

  local bg_name="${1}"
  local fg_name="${2}"
  local text="${3}"

  __tty_ag_segment_debug "Segment:"
  __tty_ag_segment_debug "current_bg_name=${current_bg_name}"
  __tty_ag_segment_debug "prompt=${prompt}"
  __tty_ag_segment_debug "bg_name=${bg_name}"
  __tty_ag_segment_debug "fg_name=${fg_name}"
  __tty_ag_segment_debug "text=${text}"

  local -i bg_code
  local -i fg_code
  local -a codes

  local __tty_ag_text_effect
  local __tty_ag_fg_color
  local __tty_ag_bg_color

  __tty_ag_text_effect reset > /dev/null
  local reset_te="${__tty_ag_text_effect}"

  codes=(
    "${reset_te}"
  )

  if [[ -n ${bg_name} ]]; then
    __tty_ag_bg_color "${bg_name}" > /dev/null
    codes=("${codes[@]}" "${__tty_ag_bg_color}")
    __tty_ag_segment_debug "Added ${bg_code} as background to codes"
  fi
  if [[ -n ${fg_name}   ]]; then
    __tty_ag_fg_color "${fg_name}" > /dev/null
    codes=("${codes[@]}" "${__tty_ag_fg_color}")
    __tty_ag_segment_debug "Added ${fg_code} as foreground to codes"
  fi
  if [[
    ${current_bg_name} != 'NONE' && ${bg_name} != "${current_bg_name}"
  ]]; then
    __tty_ag_fg_color "${current_bg_name}" > /dev/null
    __tty_ag_bg_color "${bg_name}" > /dev/null
    local -a intermediate=(
      "${__tty_ag_fg_color}"
      "${__tty_ag_bg_color}"
    )
    local pre_prompt
    pre_prompt=$(__tty_ag_format_heads "${intermediate[@]}")
    __tty_ag_segment_debug "pre prompt ${pre_prompt}"
    prompt="${prompt}${pre_prompt}${segment_separator}"
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
  eval "${current_bg_name_ref}='${bg_name}'"
}


# End the prompt, closing any open segments
__tty_ag_prompt_end() {
  local position="${1}"
  local prompt_ref="__TTY_AG_PS1_${position}"
  local current_bg_name_ref="__TTY_AG_CURRENT_BG_${position}"
  local segment_separator_ref="__TTY_AG_SEGMENT_SEPARATOR_${position}"
  local prompt="${!prompt_ref}"
  local current_bg_name="${!current_bg_name_ref}"
  local segment_separator="${!segment_separator_ref}"

  local __tty_ag_text_effect
  __tty_ag_text_effect reset > /dev/null
  local reset_te="${__tty_ag_text_effect}"

  if [[ -n ${current_bg_name} ]]; then
    local __tty_ag_fg_color
    __tty_ag_fg_color "${current_bg_name}" > /dev/null
    local -a codes=("${reset_te}" "${__tty_ag_fg_color}")
    local heads
    heads=$(__tty_ag_format_heads "${codes[@]}")
    prompt="${prompt}${heads}${segment_separator}"
  fi
  local reset_format
  reset_format="$(__tty_ag_format_head "${reset_te}")"

  eval "${prompt_ref}='${prompt}${reset_format}'"
  eval "${current_bg_name_ref}=''"
}

__tty_ag_prompt_end_all() {
  __tty_ag_prompt_end 'LEFT'
  __tty_ag_prompt_end 'RIGHT'
  __tty_ag_prompt_end 'BOTTOM'
  __tty_ag_prompt_end 'TOP'
  __tty_ag_prompt_end 'UNDER'
}
