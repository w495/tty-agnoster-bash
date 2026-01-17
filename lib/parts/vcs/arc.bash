#!/usr/bin/env bash
# shellcheck enable=all

# ---------------------------------------------------------------
#     shfmt -ci -i 2 -sr -s -bn -kp -ln bash -d
# ---------------------------------------------------------------

source "$(dirname "${BASH_SOURCE[0]}")/../../segment.bash"

__tty_ag_prompt_arc() {
  local dirty
  if arc root &> /dev/null; then
    local branch
    branch=$(arc info --json)
    branch=$(echo "${branch}" | jq -r '.branch')

    local dirty dirty_flag
    dirty=$(arc status --json | jq '.status | length')

    if [[ ${dirty} == 0 ]]; then
      dirty_flag='<->'
      __tty_ag_prompt_segment_left green black
    else
      dirty_flag='<+>'
      __tty_ag_prompt_segment_left yellow black
    fi
      PS1L="${PS1L} ${branch} ${dirty_flag}"
  fi
}
