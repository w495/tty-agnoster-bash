#!/usr/bin/env bash
# shellcheck enable=all
### Prompt components
# Each component will draw itself,
# and hide itself if no information needs to be shown

# ---------------------------------------------------------------
#     shfmt -ci -i 2 -sr -s -bn -kp -ln bash -d
# ---------------------------------------------------------------

source "$(dirname "${BASH_SOURCE[0]}")/lib/segment.bash"
source "$(dirname "${BASH_SOURCE[0]}")/lib/parts.bash"


__tty_ag_configure_prompt_left() {

  history -a
  history -c
  history -r

  local pos='LEFT'
  __tty_ag_prompt_begin "${pos}"
  __tty_ag_segment      "${pos}" 'default' 'default'  ''
  __tty_ag_segment      "${pos}" 'default' '+black'   '\!'
  __tty_ag_segment      "${pos}" 'default' 'default'  ' '
  __tty_ag_segment      "${pos}" 'default' '-yellow'  '\t'
  __tty_ag_segment      "${pos}" '-blue'   '-black'   '\w '
  __tty_ag_prompt_end   "${pos}"
}


__tty_ag_configure_prompt_right() {
  local pos='RIGHT'
  __tty_ag_prompt_begin "${pos}"
  __tty_ag_segment      "${pos}" 'default' 'default'   ''
  __tty_ag_segment      "${pos}" '-green'  '-black'  "${PWD}"
  __tty_ag_prompt_end   "${pos}"
}


__tty_ag_configure_prompt_under() {
  local pos='UNDER'
  __tty_ag_prompt_begin       "${pos}"
  __tty_ag_prompt_git         "${pos}"
  __tty_ag_prompt_arc         "${pos}"
  __tty_ag_prompt_hg          "${pos}"
  __tty_ag_prompt_virtualenv  "${pos}"
  __tty_ag_prompt_end         "${pos}"
}



__tty_ag_configure_tray_top() {
  DT="$(date '+%Y-%m-%d_%H-%M-%S-%N')"

  local pos='TOP'
  __tty_ag_prompt_begin "${pos}"
  __tty_ag_segment      "${pos}" '-red'  '-black' "${DT}"
  __tty_ag_prompt_end   "${pos}"
}

__tty_ag_configure_tray_bottom() {
  DT="$(date '+%Y-%m-%d_%H-%M-%S-%N')"

  local pos='BOTTOM'
  __tty_ag_prompt_begin "${pos}"
  __tty_ag_segment      "${pos}" '-green'  '-black' "#${PWD}"
  __tty_ag_segment      "${pos}" '+blue'   '-black'
  __tty_ag_segment      "${pos}" '-green'  '-black' "${DT}"
  __tty_ag_prompt_end   "${pos}"
}


__tty_ag_configure_startup() {
  __tty_ag_configure_prompt_left
}

__tty_ag_configure_sync() {
  __tty_ag_configure_prompt_left
  __tty_ag_configure_prompt_right
  __tty_ag_configure_prompt_under
}

__tty_ag_configure_async() {
  __tty_ag_configure_tray_top
  __tty_ag_configure_tray_bottom
}
