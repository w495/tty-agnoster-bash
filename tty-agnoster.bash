#!/usr/bin/env bash
# shellcheck enable=all

export DEFAULT_USER='_'
export SEGMENT_SEPARATOR='▒░'
export RIGHT_SEPARATOR='▒░'
export VERBOSE_MODE=false


source "$(dirname "${BASH_SOURCE[0]}")/lib/tty-ag-echo.bash"

__tty_ag_main() {
  local options
  local this="${BASH_SOURCE[0]}"
  options=$(
    getopt -n "${this}" \
    -o 'dvu:s:l:r:' \
    --long 'debug,verbose,user:,separator:,left:,right' \
    -- "${@}" \
  )
  eval set -- "${options}"

  while [[ -n ${options} ]]; do
    case ${1} in
    -u | --user)
      DEFAULT_USER="${2}"
      shift 2
      ;;
    -d | --debug |  -v | --verbose)
      VERBOSE_MODE=true
      shift 1
      ;;
    -l | --left | -s | --separator )
      SEGMENT_SEPARATOR="${2}"
      shift 2
      ;;
    -r | --right )
      RIGHT_SEPARATOR="${2}"
      shift 2
      ;;
    '--' | '')
      shift 1
      break
      ;;
    *)
      echo "Unknown parameter '${1}'." >&0
      shift 1
      ;;
    esac
  done

  PROMPT_COMMAND=__tty_ag_set_bash_prompt
}

__tty_ag_debug() {
  if [[ ${VERBOSE_MODE} == true ]]; then
    local -ir offset=1
    local -r func="${FUNCNAME[${offset}]}"
    local -r line="${BASH_LINENO[${offset}]}"

    printf -v x "%q" "${@}"
    printf "%s %s\n"  "${func}[${line}]" "${x}" >&2
  fi
}

######################################################################
### Segment drawing
# A few utility functions to make it easy and re-usable to draw segmented prompts

__tty_ag_text_effect() {
  case "$1" in
  reset)
    echo 0
    ;;
  bold)
    echo 1
    ;;
  dim)
    echo 2
    ;;
  italic)
    echo 3
    ;;
  underline)
    echo 4
    ;;
  reverse)
    echo 7
    ;;
  del)
    echo 9
    ;;
  *)
    echo
    ;;
  esac
}

__tty_ag_fg_color() {
  case "$1" in
    black)
      echo 30
      ;;
    darkred)
      echo 31
      ;;
    darkgreen)
      echo 32
      ;;
    yellow)
      echo 33
      ;;
    darkblue)
      echo 34
      ;;
    darkmagenta)
      echo 35
      ;;
    darkcyan)
      echo 36
      ;;
    white)
      echo 37
      ;;
    darkgray)
      echo 90
      ;;
    red)
      echo 91
      ;;
    green)
      echo 92
      ;;
    orange)
      echo 93
      ;;
    blue)
      echo 94
      ;;
    magenta)
      echo 95
      ;;
    cyan)
      echo 96
      ;;
    gray)
      echo 96
      ;;
    *)
      echo
      ;;
  esac
}

__tty_ag_bg_color() {
  case "$1" in
    black)
      echo 40
      ;;
    darkred)
      echo 41
      ;;
    darkgreen)
      echo 42
      ;;
    yellow)
      echo 43
      ;;
    darkblue)
      echo 44
      ;;
    darkmagenta)
      echo 45
      ;;
    darkcyan)
      echo 46
      ;;
    white)
      echo 47
      ;;
    darkgray)
      echo 100
      ;;
    red)
      echo 101
      ;;
    green)
      echo 102
      ;;
    orange)
      echo 103
      ;;
    blue)
      echo 104
      ;;
    magenta)
      echo 105
      ;;
    cyan)
      echo 106
      ;;
    gray)
      echo 107
      ;;
    *)
      echo
      ;;
  esac
}


__tty_ag_format_heads() {
  local -a codes=("${@}")
  __tty_ag_debug "format: ${codes[*]}"
  local seq=''
  for ((i = 0; i < ${#codes[@]}; i++)); do
    if [[ -n ${seq} ]]; then
      seq="${seq};"
    fi
    seq="${seq}${codes[${i}]}"
  done
  __tty_ag_debug "\\e['${seq}'m"
  echo -ne "\0001\e[${seq}m\0002"
}

__tty_ag_format_head() {
  echo -ne "\0001\e[${1}m\0002"
}

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
__tty_ag_segment() {
  local current_bg_name="${1}"
  local prompt="${2}"
  local bg_name="${3}"
  local fg_name="${4}"
  local text="${5}"

  __tty_ag_debug "Segment:"
  __tty_ag_debug "current_bg_name=${current_bg_name}"
  __tty_ag_debug "prompt=${prompt}"
  __tty_ag_debug "bg_name=${bg_name}"
  __tty_ag_debug "fg_name=${fg_name}"
  __tty_ag_debug "text=${text}"

  local -i bg_code
  local -i fg_code
  local -a codes

  codes=("$(__tty_ag_text_effect reset)")

  if [[ -n "${bg_name}" ]]; then
    bg_code=$(__tty_ag_bg_color "${bg_name}")
    codes=("${codes[@]}" "${bg_code}")
    __tty_ag_debug "Added ${bg_code} as background to codes"
  fi
  if [[ -n "${fg_name}" ]]; then
    fg_code=$(__tty_ag_fg_color "${fg_name}")
    codes=("${codes[@]}" "${fg_code}")
    __tty_ag_debug "Added ${fg_code} as foreground to codes"
  fi
  if [[ ${current_bg_name} != NONE && "${bg_name}" != "${current_bg_name}" ]]; then
    local -a intermediate=(
      "$(__tty_ag_fg_color "${current_bg_name}")"
      "$(__tty_ag_bg_color "${bg_name}")"
    )
    local pre_prompt
    pre_prompt=$(__tty_ag_format_heads "${intermediate[@]}")
    __tty_ag_debug "pre prompt ${pre_prompt}"
    prompt="${prompt}${pre_prompt}${SEGMENT_SEPARATOR}"
  else
    __tty_ag_debug "no current BG, codes is ${codes[*]}"
  fi
  local post_prompt
  post_prompt=$(__tty_ag_format_heads "${codes[@]}")
  __tty_ag_debug "post prompt ${post_prompt}"
  prompt="${prompt}${post_prompt}"
  if [[ -n ${text} ]]; then
    prompt="${prompt}${text}"
  fi
  echo -en "${prompt}"
}

__tty_ag_prompt_segment_left() {
  local bg_name="${1}"
  __tty_ag_debug "bg_name=${1} fg_name=${2} text='${3}'"
  PS1L=$(__tty_ag_segment "${CURRENT_LBG}" "${PS1L}" "${@}")
  CURRENT_LBG="${bg_name}"
}


# Begin a segment on the right
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
__tty_ag_prompt_segment_right() {
  __tty_ag_debug "bg_name=${1} fg_name=${2} text='${3}'"
  PS1R=$(__tty_ag_segment "${CURRENT_RBG}" "${PS1R}" "${@}")
  CURRENT_RBG=${bg_name}
}

# End the prompt, closing any open segments
__tty_ag_prompt_end() {
  if [[ -n ${CURRENT_LBG} ]]; then
    local -a codes=(
      "$(__tty_ag_text_effect reset)"
      "$(__tty_ag_fg_color "${CURRENT_LBG}")"
    )
    PS1L="${PS1L}$(__tty_ag_format_heads "${codes[@]}")${SEGMENT_SEPARATOR}"
  fi
  local -a reset=(
    "$(__tty_ag_text_effect reset)"
  )
  local reset_format
  reset_format=$(__tty_ag_format_heads "${reset[@]}")

  PS1L="${PS1L}${reset_format}"
  PS1R="${PS1R}${reset_format}"


  CURRENT_LBG=''
  CURRENT_RBG=''
}

### virtualenv prompt
__tty_ag_prompt_virtualenv() {
  if [[ -n ${VIRTUAL_ENV} ]]; then
    color=cyan
    __tty_ag_prompt_segment_left "${color}" default
    __tty_ag_prompt_segment_left "${color}" white "$(basename "${VIRTUAL_ENV}")"
  fi
}

### Prompt components
# Each component will draw itself,
# and hide itself if no information needs to be shown

# Context: user@hostname (who am I and where am I)
__tty_ag_prompt_context() {
  local user
  user="$(whoami)"
  if [[ ${user} != "${DEFAULT_USER}" || -n ${SSH_CLIENT} ]]; then
    __tty_ag_prompt_segment_left black default "${user}@\h"
  fi
}

__tty_ag_git_status_dirty() {
  local dirty
  dirty=$(git status -s 2>/dev/null | tail -n 1 || true)
  if [[ -n ${dirty} ]]; then
    echo ' <!>'
  fi
}

__tty_ag_git_stash_dirty() {
  local stash
  stash=$(git stash list 2>/dev/null | tail -n 1 || true)
  if [[ -n ${stash} ]]; then
    echo ' ⚑'
  fi
}


__tty_ag_prompt_arc() {
  local ref dirty
  if arc root &> /dev/null ; then
    local branch
    branch=$(arc info --json)
    branch=$(echo "${branch}" | jq -r '.branch')

    local dirty dirty_flag
    dirty=$(arc status --json | jq '.status | length')

    if [[ ${dirty} == 0 ]]; then
      dirty_flag=' <->'
      __tty_ag_prompt_segment_left green black
    else
      dirty_flag=' <+>'
      __tty_ag_prompt_segment_left yellow black
    fi
      PS1L="${PS1L} ${branch} ${dirty_flag}"
  fi
}


# Git: branch/detached head, dirty status
__tty_ag_prompt_git() {
  local ref dirty
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    # ZSH_THEME_GIT_PROMPT_DIRTY='±'
    dirty=$(__tty_ag_git_status_dirty)
    stash=$(__tty_ag_git_stash_dirty)
    ref=$(git symbolic-ref HEAD 2>/dev/null || true) ||
      ref="➦ $(git describe --exact-match --tags HEAD 2>/dev/null || true )" ||
      ref="➦ $(git show-ref --head -s --abbrev | head -n1 2>/dev/null || true)"
    if [[ -n ${dirty} ]]; then
      __tty_ag_prompt_segment_left yellow black
    else
      __tty_ag_prompt_segment_left green black
    fi
    PS1L="${PS1L}${ref/refs\/heads\// }${stash}${dirty}"
  fi
}

# Mercurial: clean, modified and uncommited files
__tty_ag_prompt_hg() {
  local rev st branch
  if hg id >/dev/null 2>&1; then
    if hg prompt >/dev/null 2>&1; then
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
        __tty_ag_prompt_segment_left green black "${CURRENT_LBG}"
      fi
      PS1L="${PS1L}$(hg prompt "☿ {rev}@{branch}") ${st}"
    else
      st=""
      rev=$(hg id -n 2>/dev/null | sed 's/[^-0-9]//g' || true)
      branch=$(hg id -b 2>/dev/null)
      if hg st | grep -q "^\?" || true ; then
        __tty_ag_prompt_segment_left red white
        st='±'
      elif hg st | grep -q "^[MA]" || true ; then
        __tty_ag_prompt_segment_left yellow black
        st='±'
      else
        __tty_ag_prompt_segment_left green black "${CURRENT_LBG}"
      fi
      PS1L="${PS1L}☿ ${rev}@${branch} ${st}"
    fi
  fi
}

__TTY_AG_LINE=1

__tty_ag_prompt_line() {
  __tty_ag_prompt_segment_left black orange "║ ${__TTY_AG_LINE} ║"
  __TTY_AG_LINE=$((__TTY_AG_LINE + 1))
}

#Capturing start time in milliseconds
__TTY_AG_SECOND="$(date '+%s%3N')"

__tty_ag_prompt_seconds() {
  local -i second
  second="$(date '+%s%3N')"
  ms_diff=$(( second - __TTY_AG_SECOND ))
  sec_diff=$(( ms_diff / 1000 ))
  ms_part=$(( ms_diff % 1000 ))
  __tty_ag_prompt_segment_left black orange "|${sec_diff}.${ms_part}|"
  __TTY_AG_SECOND="${second}"
}


# prints history followed by HH:MM, useful for remembering what
# we did previously
__tty_ag_prompt_histdt() {
  history -a
  history -c
  history -r
  __tty_ag_prompt_segment_left black default "\! (\A)"
}


__tty_ag_prompt_time() {
  local _dt
  _dt=$(date '+%H┋%M┋%S')
  __tty_ag_prompt_segment_left black darkgray "${_dt}"
}


__tty_ag_prompt_date() {
  local _dt
  _dt=$(date '+%Y-%m-%d_%H-%M-%S-%N')
  __tty_ag_prompt_segment_right black darkgray "${_dt}"
}

# Dir: current working directory
__tty_ag_prompt_dir() {
  __tty_ag_prompt_segment_left darkcyan darkgray '\w'
}


# Dir: current working directory
__tty_ag_prompt_full_pwd() {
  __tty_ag_prompt_segment_right black darkgray "#|${PWD}|"
}



# Status:
# - was there an error
# - am I root
# - are there background jobs?
__tty_ag_prompt_status() {
  local symbols
  local red yellow cyan
  red=$(__tty_ag_fg_color red)
  yellow=$(__tty_ag_fg_color yellow)
  cyan=$(__tty_ag_fg_color cyan)

  symbols=()
  if [[ ${RETVAL} -ne 0 ]]; then
    symbols+=("$(__tty_ag_format_head "${red}")✘")
  fi
  if [[ ${UID} -eq 0 ]]; then
    symbols+=("$(__tty_ag_format_head "${yellow}")⚡")
  fi
  if [[ $(jobs -l | wc -l || true) -gt 0 ]]; then
    symbols+=("$(__tty_ag_format_head "${cyan}")⚙")
  fi
  if [[ -n ${symbols[*]} ]]; then
    __tty_ag_prompt_segment_left black default "${symbols}"
  fi
  true
}

######################################################################
#
# experimental right prompt stuff
# requires setting prompt_foo to use PS1R vs PS1L
# doesn't quite work per above

__tty_ag_right_prompt() {
  tput sc;
  local ps1r="${1}"
  ps1r_flat=$(echo -en "${ps1r}" | ansi2txt | sed 's/\\\[\\\]//gi' )
  local -i len_diff=$(( ${#ps1r} - ${#ps1r_flat} ))
  local -i line_len=$((COLUMNS + len_diff))
  printf "%*s\r\n" "${line_len}" "${ps1r}"
  tput rc;
}


######################################################################
## Emacs prompt --- for dir tracking
# stick the following in your .emacs if you use this:

# (setq dirtrack-list '(".*DIR *\\([^ ]*\\) DIR" 1 nil))
# (defun dirtrack-filter-out-pwd-prompt (string)
#   "dirtrack-mode doesn't remove the PWD match from the prompt.  This does."
#   ;; TODO: support dirtrack-mode's multiline regexp.
#   (if (and (stringp string) (string-match (first dirtrack-list) string))
#       (replace-match "" t t string 0)
#     string))
# (add-hook 'shell-mode-hook
#           #'(lambda ()
#               (dirtrack-mode 1)
#               (add-hook 'comint-preoutput-filter-functions
#                         'dirtrack-filter-out-pwd-prompt t t)))

__tty_ag_prompt_emacsdir() {
  # no color or other setting... this will be deleted per above
  PS1L="DIR \w DIR${PS1L}"
}

######################################################################
## Main prompt

__tty_ag_build_prompt() {
  __tty_ag_prompt_full_pwd
  __tty_ag_prompt_date

  __tty_ag_prompt_line
  __tty_ag_prompt_seconds
  __tty_ag_prompt_time
  __tty_ag_prompt_histdt

 if [[ -n ${AG_EMACS_DIR+x} ]]; then
    __tty_ag_prompt_emacsdir
  fi
  __tty_ag_prompt_status
  #[[ -z ${AG_NO_HIST+x} ]] && __tty_ag_prompt_histdt


  if [[ -z ${AG_NO_CONTEXT+x} ]]; then
    __tty_ag_prompt_context
  fi
  __tty_ag_prompt_virtualenv
  __tty_ag_prompt_dir
  __tty_ag_prompt_arc
  __tty_ag_prompt_git
  __tty_ag_prompt_hg
  __tty_ag_prompt_end
}


__tty_ag_bottom_window () {
    tput sc
    # Create a virtual window that is two lines smaller at the bottom.
    tput csr 0 $(( LINES-4 ))
    # Move cursor to last line in your screen
    tput cup $(( LINES-2 )) 0;
    printf '~%.0s' $(seq 1 $COLUMNS); echo
    echo "${1}"
    # Move cursor to home position, back in virtual window
    tput rc
}


__tty_ag_right_window () {
    tput init
    tput sc

    local value="${1}"
    value_flat=$(echo -en "${value}" | ansi2txt )
    local -i len_diff=$(( ${#value} - ${#value_flat} ))
    local -i line_len=$((COLUMNS -  ${#value_flat}))

    row=$(__tty_ag_cursor_row)
    # Create a virtual window that is two lines smaller at the bottom.
    tput csr ${line_len} $((row - 1))
    # Move cursor to last line in your screen
    tput cup $((row - 1)) $(( line_len));
    echo -en "${value}\r\n"
    # Move cursor to home position, back in virtual window
    tput rc
}


__tty_ag_cursor_row() {
  local row col
  IFS=';' read -p $'\e[6n' -d R -rs row col \
  || echo "failed with error: $? ; ${row} ${col} "
  row="${row:2}"
  echo "${row}"
}



#
#__tty_ag_top_window () {
#    tput sc
#    local ps1r="${1}"
#    ps1r_flat=$(echo -en "${ps1r}" | ansi2txt | col -b )
#    local -i len_diff=$(( ${#ps1r} - ${#ps1r_flat} ))
#
#    local -i line_len=$((COLUMNS - ${#ps1r} ))
#    tput csr "${line_len}" 0
#    tput cup 0 "${line_len}";
#    printf "|%s|" "XXX"
#    # Move cursor to home position, back in virtual window
#    tput rc
#}


fork_spinner(){
  local -r fun="${1}"
  eval "${fun}" & 2> /dev/null
  local -r pid=$! # Process Id of the previous running command
  local -ra spin=(
    " - "
    " \ "
    " | "
    " / "
  )
  local i=0
  while kill -0 "${pid}" 2>/dev/null
  do
    i=$(( (i+1) %4 ))
    echo -en "\r${spin[${i}]}"
    sleep .1
  done
}

__tty_ag_set_bash_prompt() {
  local RETVAL=$?
  local PS1L=""
  local PS1R=""
  local CURRENT_LBG=NONE
  local CURRENT_RBG=NONE

  local te
  te="$(__tty_ag_text_effect reset)"
  PS1L="$(__tty_ag_format_head "${te}")"
  PS1R="$(__tty_ag_format_head "${te}")"

  # rename console tab
#  echo >&2 -en "\001\033]0;${PWD}\a\002\n"


  __tty_ag_build_prompt


  PS1="${PS1L}"

#  PS1="\001$(__tty_ag_right_window "${PS1R}")\002${PS1}"
#  PS1="\001[$(__tty_ag_bottom_window "${PS1R}")\002${PS1}"
#
#  __tty_ag_right_window "${PS1R}"

  # PS1='\[\e[$LINES;1H\]'$PS1






}

#__tty_ag_main "${@}"
