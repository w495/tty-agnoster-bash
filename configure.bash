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


__tty_ag_configure_left_prompt() {

  history -a
  history -c
  history -r

  local pos='LEFT'
  __tty_ag_prompt_begin       "${pos}"
  __tty_ag_segment            "${pos}" null     +black   '\!'
  __tty_ag_segment            "${pos}" null     -yellow  '\t'
  __tty_ag_prompt_status      "${pos}" +black
  __tty_ag_segment            "${pos}" +black   null   '\w'
  __tty_ag_prompt_git         "${pos}"
#  __tty_ag_prompt_virtualenv  "${pos}"
  __tty_ag_prompt_end         "${pos}"

}


__tty_ag_configure_right_prompt() {
  local pos='RIGHT'
  __tty_ag_prompt_begin "${pos}"
  __tty_ag_segment      "${pos}" '+black'  '-black'  "# ${PWD}"
  __tty_ag_prompt_end   "${pos}"
}


__tty_ag_configure_under_prompt() {
  local pos='UNDER'
  __tty_ag_prompt_begin       "${pos}"
  __tty_ag_prompt_git         "${pos}"
#  __tty_ag_prompt_arc         "${pos}"
#  __tty_ag_prompt_hg          "${pos}"

  __tty_ag_prompt_end         "${pos}"
}


__tty_ag_configure_tray_at_top() {
  DT="$(date '+%Y-%m-%d_%H-%M-%S-%N')"

  local pos='TOP'
  __tty_ag_prompt_begin "${pos}"
  __tty_ag_segment      "${pos}" '-red'  '-black' "${DT}"
  __tty_ag_prompt_end   "${pos}"
}

__tty_ag_configure_tray_at_bottom() {
  DT="$(date '+%Y-%m-%d_%H-%M-%S-%N')"

  local pos='BOTTOM'
  __tty_ag_prompt_begin "${pos}"
  __tty_ag_segment      "${pos}" '-green'  '-black' "#${PWD}"
  __tty_ag_segment      "${pos}" '+blue'   '-black'
  __tty_ag_segment      "${pos}" '-green'  '-black' "${DT}"
  __tty_ag_prompt_end   "${pos}"
}
