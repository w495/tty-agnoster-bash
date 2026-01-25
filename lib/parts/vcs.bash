#!/usr/bin/env bash
# shellcheck enable=all

# ---------------------------------------------------------------
#     shfmt -ci -i 2 -sr -s -bn -kp -ln bash -d
# ---------------------------------------------------------------

source "$(dirname "${BASH_SOURCE[0]}")/vcs/git.bash"
source "$(dirname "${BASH_SOURCE[0]}")/vcs/arc.bash"
source "$(dirname "${BASH_SOURCE[0]}")/vcs/hg.bash"
