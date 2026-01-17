#!/usr/bin/env bash
# shellcheck enable=all

source "$(dirname "${BASH_SOURCE[0]}")/../../segment.bash"

__tty_ag_git_status_dirty() {
  local dirty
  dirty=$(git status -s 2> /dev/null | tail -n 1 || true)
  if [[ -n ${dirty} ]]; then
    echo '[!]'
  fi
}

__tty_ag_git_stash_dirty() {
  local stash
  stash=$(git stash list 2> /dev/null | tail -n 1 || true)
  if [[ -n ${stash} ]]; then
    echo '[F]'
  fi
}

# Git: branch/detached head, dirty status
__tty_ag_prompt_git() {
  local ref dirty
  if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    # ZSH_THEME_GIT_PROMPT_DIRTY='±'
    dirty=$(__tty_ag_git_status_dirty)
    stash=$(__tty_ag_git_stash_dirty)
    ref=$(git symbolic-ref HEAD 2> /dev/null || true) \
                                                     || ref="- $(git describe --exact-match --tags HEAD 2> /dev/null || true)" \
                                                                             || ref="- $(git show-ref --head -s --abbrev | head -n1 2> /dev/null || true)"
    if [[ -n ${dirty} ]]; then
      __tty_ag_prompt_segment_left yellow black
    else
      __tty_ag_prompt_segment_left green black
    fi
    PS1L="${PS1L}${ref/refs\/heads\// }${stash}${dirty}"
  fi
}
