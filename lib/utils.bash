#!/usr/bin/env bash
# shellcheck enable=all

# ---------------------------------------------------------------
#     shfmt -ci -i 2 -sr -s -bn -kp -ln bash -d
# ---------------------------------------------------------------

source "$(dirname "${BASH_SOURCE[0]}")/utils/em-code.bash"
source "$(dirname "${BASH_SOURCE[0]}")/utils/fg-code.bash"
source "$(dirname "${BASH_SOURCE[0]}")/utils/bg-code.bash"

source "$(dirname "${BASH_SOURCE[0]}")/utils/format.bash"
