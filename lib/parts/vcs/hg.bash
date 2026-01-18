#!/usr/bin/env bash
# shellcheck enable=all

# ---------------------------------------------------------------
#     shfmt -ci -i 2 -sr -s -bn -kp -ln bash -d
# ---------------------------------------------------------------

source "$(dirname "${BASH_SOURCE[0]}")/../../segment.bash"

__TTY_AG_CURRENT_LBG=NONE

# Mercurial: clean, modified and uncommited files
__tty_ag_prompt_hg() {
  local rev st branch
  if hg id > /dev/null 2>&1; then
    if hg prompt > /dev/null 2>&1; then
      if [[ $(hg prompt "{status|unknown}" || true) == "?" ]]; then
        # if files are not added
        __tty_ag_prompt_segment_left red white
        st='±'
      elif [[ -n $(hg prompt "{status|modified}" || true) ]]; then
        # if any modification
        __tty_ag_prompt_segment_left yellow black
        st='±'
      else
        # if working copy is clean
        __tty_ag_prompt_segment_left green black "${__TTY_AG_CURRENT_LBG}"
      fi
      __TTY_AG_PS1L="${__TTY_AG_PS1L}$(hg prompt "hg {rev}@{branch}") ${st}"
    else
      st=""
      rev=$(hg id -n 2> /dev/null | sed 's/[^-0-9]//g' || true)
      branch=$(hg id -b 2> /dev/null)
      if hg st | grep -q "^\?" || true; then
        __tty_ag_prompt_segment_left red white
        st='±'
      elif hg st | grep -q "^[MA]" || true; then
        __tty_ag_prompt_segment_left yellow black
        st='±'
      else
        __tty_ag_prompt_segment_left green black "${__TTY_AG_CURRENT_LBG}"
      fi
      __TTY_AG_PS1L="${__TTY_AG_PS1L}hg ${rev}@${branch} ${st}"
    fi
  fi
}
