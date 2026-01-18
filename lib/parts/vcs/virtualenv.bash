#!/usr/bin/env bash
# shellcheck enable=all

# ---------------------------------------------------------------
#     shfmt -ci -i 2 -sr -s -bn -kp -ln bash -d
# ---------------------------------------------------------------

source "$(dirname "${BASH_SOURCE[0]}")/../../segment.bash"

### virtualenv prompt
__tty_ag_prompt_virtualenv() {
  local pos="${1}"
  if [[ -n ${VIRTUAL_ENV} ]]; then
    color=cyan
    __tty_ag_segment "${pos}" "${color}" default
    local path
    path=$(basename "${VIRTUAL_ENV}")
    __tty_ag_segment "${pos}" "${color}" white "${path}"
  fi
}
