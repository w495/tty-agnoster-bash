#!/usr/bin/env bash
# shellcheck enable=all
### Prompt components
# Each component will draw itself,
# and hide itself if no information needs to be shown

# ---------------------------------------------------------------
#     shfmt -ci -i 2 -sr -s -bn -kp -ln bash -d
# ---------------------------------------------------------------

source "$(dirname "${BASH_SOURCE[0]}")/utils.bash"
source "$(dirname "${BASH_SOURCE[0]}")/segment.bash"

source "$(dirname "${BASH_SOURCE[0]}")/parts/vcs.bash"
source "$(dirname "${BASH_SOURCE[0]}")/parts/virtualenv.bash"
source "$(dirname "${BASH_SOURCE[0]}")/parts/common.bash"
