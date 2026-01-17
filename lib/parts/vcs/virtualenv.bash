#!/usr/bin/env bash
# shellcheck enable=all

# ---------------------------------------------------------------
#     shfmt -ci -i 2 -sr -s -bn -kp -ln bash -d
# ---------------------------------------------------------------

source "$(dirname "${BASH_SOURCE[0]}")/../../segment.bash"

### virtualenv prompt
__tty_ag_prompt_virtualenv() {
  if [[ -n ${VIRTUAL_ENV} ]]; then
    color=cyan
    __tty_ag_prompt_segment_left "${color}" default
    __tty_ag_prompt_segment_left "${color}" white "$(basename "${VIRTUAL_ENV}")"
  fi
}
