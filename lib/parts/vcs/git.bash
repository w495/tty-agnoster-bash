#!/usr/bin/env bash
# shellcheck enable=all

source "$(dirname "${BASH_SOURCE[0]}")/../../segment.bash"


# Git: branch/detached head, dirty status
__tty_ag_prompt_git() {
  local ref dirty line
  if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    # ZSH_THEME_GIT_PROMPT_DIRTY='±'
    dirty=$(git status -s 2> /dev/null | tail -n 1 || true)
    if [[ -n ${dirty} ]]; then
      dirty='[D]'
    fi
    stash=$(git stash list 2> /dev/null | tail -n 1 || true)
    if [[ -n ${stash} ]]; then
      stash='[S]'
    fi

    ref=$(git symbolic-ref HEAD 2> /dev/null)
    if [[ -z "${ref}" ]]; then
     ref="- $(git describe --exact-match --tags HEAD 2> /dev/null)"
    fi
    if [[ -z "${ref}" ]]; then
     ref="- $(git show-ref --head -s --abbrev | head -n1 2> /dev/null || true)"
    fi
    line="${ref/refs\/heads\//Y }${stash}"
    if [[ -n ${dirty} ]]; then
      __tty_ag_prompt_segment_left yellow black "(o_O) ${line}"
    else
      __tty_ag_prompt_segment_left green black "(^_^) ${line}"
    fi

  fi
}
