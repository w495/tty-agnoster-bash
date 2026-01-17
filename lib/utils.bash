#!/usr/bin/env bash
# shellcheck enable=all

# ---------------------------------------------------------------
#     shfmt -ci -i 2 -sr -s -bn -kp -ln bash -d
# ---------------------------------------------------------------

source "$(dirname "${BASH_SOURCE[0]}")/utils/text-effect.bash"
source "$(dirname "${BASH_SOURCE[0]}")/utils/fg-color.bash"
source "$(dirname "${BASH_SOURCE[0]}")/utils/bg-color.bash"
source "$(dirname "${BASH_SOURCE[0]}")/utils/format.bash"
