#!/usr/bin/env bash
# shellcheck enable=all

# ---------------------------------------------------------------
#     shfmt -ci -i 2 -sr -s -bn -kp -ln bash -d
# ---------------------------------------------------------------

source "$(dirname "${BASH_SOURCE[0]}")/../../segment.bash"

__tty_ag_prompt_arc() {
  local pos="${1}"
  local dirty
  if arc root &> /dev/null; then
    local branch
    branch=$(arc info --json)
    branch=$(echo "${branch}" | jq -r '.branch')

    local dirty
    # shellcheck disable=SC2312
    dirty=$(arc status --json | jq '.status | length')

    if [[ ${dirty} == 0 ]]; then
      __tty_ag_segment "${pos}" green black "${branch} (o_O)"
    else
      __tty_ag_segment "${pos}" yellow black "${branch} (^_^)"
    fi
  fi
}
