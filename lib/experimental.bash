#!/usr/bin/env bash
# shellcheck enable=all

# ---------------------------------------------------------------
#     shfmt -ci -i 2 -sr -s -bn -kp -ln bash -d
# ---------------------------------------------------------------

source "$(dirname "${BASH_SOURCE[0]}")/experimental/right-prompt.bash"
source "$(dirname "${BASH_SOURCE[0]}")/experimental/right-tray.bash"
source "$(dirname "${BASH_SOURCE[0]}")/experimental/under-prompt.bash"

source "$(dirname "${BASH_SOURCE[0]}")/experimental/top-tray.bash"
source "$(dirname "${BASH_SOURCE[0]}")/experimental/bottom-tray.bash"
