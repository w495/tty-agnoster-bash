#!/usr/bin/env sh
# shellcheck enable=all

# COMPATIBILITY NOTE:
# ---------------------------------------------------------------
#   bash/zsh/ksh93:
#     shfmt -ci -i 2 -sr -s -bn -kp -ln bash -d
#
#   See compatibility notes below and use posix variants.
#   How to check posix:
#     shfmt -ci -i 2 -sr -s -bn -kp -ln posix -d
# ---------------------------------------------------------------


__zx__usage() {
  # shellcheck disable=SC2312
  printf 'Usage: __zx [OPTIONS] [TEXT]\n'
  printf 'NAME:
  «Colourful Echo» —> «C. Echo» —> «cecho». It _sounds like /see‑EK‑oh/
  in English. But in Latin it _sounds like /tse‑kho/, that is similar to
  * German «Zeche» — /tseh‑uhn/ — colliery;
  * Russian «Цех»  — /tsekh/    — workshop.
  so we use «Z» to represent /ts/-_sound.
  \n'

  printf 'EXAMPLES:
    > __zx -f +RED -b -yellow -e DEL -t some waring
    \v'
  __zx -b -yellow -f -RED -t del some waring
  printf '\n'


  printf 'OPTIONS:
    :-f:--fg — for foreground color in a lower or an UPPER case.
    :-b:--bg — for background color in a lower or an UPPER case.
    :-t:--te — for text effect"
  \n' | column -t -s '.:|'


  { printf 'COLORS:\n'
    __zx      -- '  : -k | k | -0 | 0 | rgb-000 | -black   | black'
    __zx -f-r -- '  : -r | r | -1 | 1 | rgb-100 | -red     | red'
    __zx -f-g -- '  : -g | g | -2 | 2 | rgb-010 | -green   | green'
    __zx -f-y -- '  : -y | y | -3 | 3 | rgb-110 | -yellow  | yellow'
    __zx -f-b -- '  : -b | b | -4 | 4 | rgb-001 | -blue    | blue'
    __zx -f-m -- '  : -m | m | -5 | 5 | rgb-101 | -magenta | magenta'
    __zx -f-c -- '  : -c | c | -6 | 6 | rgb-011 | -cyan    | cyan'
    __zx -f-w -- '  : -w | w | -7 | 7 | rgb-111 | -white   | white'
    __zx -f+k -- '  : +k |   . +0 |   . rgb+000 | +black   | gray'
    __zx -f+r -- '  : +r |   . +1 |   . rgb+100 | +red'
    __zx -f+g -- '  : +g |   . +2 |   . rgb+010 | +green'
    __zx -f+y -- '  : +y |   . +3 |   . rgb+110 | +yellow'
    __zx -f+b -- '  : +b |   . +4 |   . rgb+001 | +blue'
    __zx -f+m -- '  : +m |   . +5 |   . rgb+101 | +magenta'
    __zx -f+c -- '  : +c |   . +6 |   . rgb+011 | +cyan'
    __zx -f+w -- '  : +w |   . +7 |   . rgb+111 | +white'
  } | column -t -s '.:|'


  { printf 'EFFECTS:\n'
    printf '  :'
    __zx -tn -- '0 | n |   : cl | clear | reset '
    printf '  :bold:'
    __zx -tb -- '1 | b |   : bd | bb | bold | bl '
    printf '  :faint:'
    __zx -td -- '2 | d | f | fa | di | dim  | faint'
    printf '  :italic:'
    __zx -ti -- '3 | i | e | it | em | italic'
    printf '  :underline:'
    __zx -tu -- '4 | u | _ | un | ln | underline'
    printf '  :blink:'
    __zx -tl -- '5 | l |   : bl | ll | blink'
    printf '  :reverse:'
    __zx -tr -- '7 | r |   : re | rv  | reverse'
    printf '  :conceal:'
    __zx -tc -- '8 | c |   : co | con | conceal'
    printf '  :strike:'
    __zx -tx -- '9 | s | x |  st |strike | del'
    printf '  :'
  } | column -t -s ':|'

}

__zx_punct_to_sep() {
    # COMPATIBILITY NOTE:
    # ---------------------------------------------------------------
    #   bash/zsh/ksh93:
    #     res="${1//[[:punct:]]/${2}}"
    #   posix:
    #     # shellcheck disable=SC2001
    #     res=$(echo "${1}" | sed "s/[[:punct:]]/${2}/")
    #     OR
    #     awk_prog='BEGIN{$0=v;gsub(/[[:punct:]]/,s);print}'
    #     res=$(awk -vv="${1}" -vs="${2}" "${awk_prog}")
    # ---------------------------------------------------------------

    # shellcheck disable=SC2001
    __zx_punct_to_sep__=$(
      echo "${1}" | sed "s/[[:punct:]|[:space:]]/${2}/g"
    )
    eval set -- '' "${__zx_punct_to_sep__}"
}

{ # __zx__text_effect__*
  __zx__text_effect__code() {
    case "${1}" in
    0 | n | clear | reset)
      __zx__text_effect__code__=0
      ;;
    1 | b | bold)
      __zx__text_effect__code__=1
      ;;
    2 | d | f | dim | faint)
      __zx__text_effect__code__=2
      ;;
    3 | i | italic)
      __zx__text_effect__code__=3
      ;;
    4 | u | underline)
      __zx__text_effect__code__=4
      ;;
    5 | l | blink)
      __zx__text_effect__code__=5
      ;;
    7 | r | reverse)
      __zx__text_effect__code__=7
      ;;
    8 | c | conceal)
      __zx__text_effect__code__=8
      ;;
    9 | s | x | strike | del)
      __zx__text_effect__code__=9
      ;;
    '')
      __zx__text_effect__code__=-1
      ;;
    *)
      __zx__text_effect__code__=-2
      ;;
    esac
  }
  __zx__text_effect__code_seq() {
    te_name_seq="${1}"
    te_sep="${2:-${__zx__FMT_SEP}}"
    te_code_seq=''


    # COMPATIBILITY NOTE:
    # ---------------------------------------------------------------
    #   bash/zsh/ksh93:
    #     std_arg="${arg//[[:punct:]]/${te_sep}}"
    #   posix:
    #     # shellcheck disable=SC2001
    #     std_arg=$(echo "${arg}" | sed "s/[[:punct:]]/${te_sep}/")
    #     OR
    #     awk_prog='BEGIN{$0=v;gsub(/[[:punct:]]/,s);print}'
    #     std_arg=$(awk -vv="${arg}" -vs="${te_sep}" "${awk_prog}")
    # ---------------------------------------------------------------

    __zx_punct_to_sep "${te_name_seq}" "${te_sep}"
    te_name_seq="${__zx_punct_to_sep__}"

    te_name_seq="${te_name_seq}${te_sep}"
    while test "${te_name_seq#*"${te_sep}"}" != "${te_name_seq}"; do
      te_name="${te_name_seq%%"${te_sep}"*}"
      if test -n "${te_name}"; then
        __zx__text_effect__code "${te_name}"
        if test "${__zx__text_effect__code__}" -gt 0; then
          if test -n "${te_code_seq}"; then
            te_code_seq="${te_code_seq}${te_sep}"
          fi
          te_code_seq="${te_code_seq}${__zx__text_effect__code__}"
        elif test "${__zx__text_effect__code__}" -eq -2; then
          te_name_seq=$(
            echo "${te_name_seq}" | sed "s/./${te_sep}&/g"
          )
        fi
      fi
      te_name_seq="${te_name_seq#*"${te_sep}"}"
    done
    __zx__text_effect__code_seq__="${te_code_seq}"

    unset -v __zx__text_effect__code__
    unset -v __zx_punct_to_sep__

    unset -v te_name_seq
    unset -v te_sep
    unset -v te_code_seq
    unset -v te_name
  }
}

{ # __zx__color__*
  __zx__color__code_case() {
    case ${1} in
    [[:lower:]])
      __zx__color__code_case__="-${1}"
      ;;
    [[:upper:]])
      __zx__color__code_case__="+${1}"
      ;;
    *)
      __zx__color__code_case__="${1}"
      ;;
    esac
  }

  __zx__color__rename() {
    colors="cyan|magenta|yellow|black|red|green|blue|white"
    colors="${colors}|c|m|y|k|r|g|b|w"
    patten="
      s/^((d|dark|ba|basic)(\W|_)?)(${colors})$/-\4/gi;
      s/^((i|l|light|br|bright)(\W|_)?)(${colors})?$/+\4/gi;
      s/^(${colors})((\W|_)?(\-|d|dark|ba|basic))$/-\1/gi;
      s/^(${colors})((\W|_)?(\+|i|l|light|b|br|bright))$/+\1/gi;
      "
    __zx__color__rename__=$(
      echo "${1}" | sed -re "${patten}"
    )
    unset colors patten
  }

  __zx__color__std_name() {
    color=$(awk -vi="${1}" 'BEGIN{$0=X;print tolower(i)}')
    __zx__color__rename "${color}"
    case "${__zx__color__rename__}" in
    -k | k | -0 | 0 | 30 | 40 | rgb-000 | -black | black)
      __zx__color__std_name__='basic black'
      ;;
    -r | r | -1 | 1 | 31 | 41 | rgb-100 | -red | red)
      __zx__color__std_name__='basic red'
      ;;
    -g | g | -2 | 2 | 32 | 42 | rgb-010 | -green | green)
      __zx__color__std_name__='basic green'
      ;;
    -y | y | -3 | 3 | 33 | 43 | rgb-110 | -yellow | yellow)
      __zx__color__std_name__='basic yellow'
      ;;
    -b | b | -4 | 4 | 34 | 44 | rgb-001 | -blue | blue)
      __zx__color__std_name__='basic blue'
      ;;
    -m | m | -5 | 5 | 35 | 45 | rgb-101 | -magenta | magenta)
      __zx__color__std_name__='basic magenta'
      ;;
    -c | c | -6 | 6 | 36 | 46 | rgb-011 | -cyan | cyan)
      __zx__color__std_name__='basic cyan'
      ;;
    -w | w | -7 | 7 | 37 | 47 | rgb-111 | -white | white)
      __zx__color__std_name__='basic white'
      ;;
    ## bright colors
    +k | +0 | 90 | 100 | rgb+000 | +black | gray)
      __zx__color__std_name__='bright black'
      ;;
    +r | +1 | 91 | 101 | rgb+100 | +red)
      __zx__color__std_name__='bright red'
      ;;
    +g | +2 | 92 | 102 | rgb+010 | +green)
      __zx__color__std_name__='bright green'
      ;;
    +y | +3 | 93 | 103 | rgb+110 | +yellow)
      __zx__color__std_name__='bright yellow'
      ;;
    +b | +4 | 94 | 104 | rgb+001 | +blue)
      __zx__color__std_name__='bright blue'
      ;;
    +m | +5 | 95 | 105 | rgb+101 | +magenta)
      __zx__color__std_name__='bright magenta'
      ;;
    +c | +6 | 96 | 106 | rgb+011 | +cyan)
      __zx__color__std_name__='bright cyan'
      ;;
    +w | +7 | 97 | 107 | rgb+111 | +white)
      __zx__color__std_name__='bright white'
      ;;
    '')
      __zx__color__std_name__='empty color'
      ;;
    *)
      printf >&2 "\e[31mError unknown color '%s' \e[0m\n" "${color}"
      __zx__color__std_name__='unknown color'
      ;;
    esac
  }

  __zx__color__code_pair() {
    case "${1}" in
    'basic black')
      __zx__color__code_pair__='30 40'
      ;;
    'basic red')
      __zx__color__code_pair__='31 41'
      ;;
    'basic green')
      __zx__color__code_pair__='32 42'
      ;;
    'basic yellow')
      __zx__color__code_pair__='33 43'
      ;;
    'basic blue')
      __zx__color__code_pair__='34 44'
      ;;
    'basic magenta')
      __zx__color__code_pair__='35 45'
      ;;
    'basic cyan')
      __zx__color__code_pair__='36 46'
      ;;
    'basic white')
      __zx__color__code_pair__='37 47'
      ;;
    'bright black')
      __zx__color__code_pair__='90 100'
      ;;
    'bright red')
      __zx__color__code_pair__='91 101'
      ;;
    'bright green')
      __zx__color__code_pair__='92 102'
      ;;
    'bright yellow')
      __zx__color__code_pair__='93 103'
      ;;
    'bright blue')
      __zx__color__code_pair__='94 104'
      ;;
    'bright magenta')
      __zx__color__code_pair__='95 105'
      ;;
    'bright cyan')
      __zx__color__code_pair__='96 106'
      ;;
    'bright white')
      __zx__color__code_pair__='97 107'
      ;;
    'empty color')
      __zx__color__code_pair__='-1 -1'
      ;;
    'unknown color')
      __zx__color__code_pair__='-2 -2'
      ;;
    *)
      __zx__color__code_pair__='-3 -3'
      ;;
    esac
  }

  __zx__color__fg_code() {
    __zx__color__code_pair "${1}"
    __zx__color__fg_code__="${__zx__color__code_pair__%\ *}"
  }

  __zx__color__bg_code() {
    __zx__color__code_pair "${1}"
    __zx__color__bg_code__="${__zx__color__code_pair__#*\ }"
  }
}

__zx__join_code_seq() {
  code_seq="${1}"
  fmt_sep="${2:-${__zx__FMT_SEP}}"
  ansi_sep="${3:-${__zx__ESC_ANSI_SEP}}"

  code_str=''
  code_seq="${code_seq}${fmt_sep}"
  while test "${code_seq#*"${fmt_sep}"}" != "${code_seq}"; do
    code="${code_seq%%"${fmt_sep}"*}"
    if test -n "${code}"; then
      if test "${code}" -gt 0; then
        if test -n "${code_str}"; then
          code_str="${code_str}${ansi_sep}"
        fi
        code_str="${code_str}${code}"
      fi
    fi
    code_seq="${code_seq#*"${fmt_sep}"}"
  done
  __zx__join_code_seq="${code_str}"
}

__zx__code_str() {
  fg_name="${1}"
  bg_name="${2}"
  te_name_seq="${3}"
  fmt_sep="${4:-${__zx__FMT_SEP}}"
  ansi_sep="${5:-${__zx__ESC_ANSI_SEP}}"

  if test -n "${fg_name}"; then
    __zx__color__std_name "${fg_name}"
    __zx__color__fg_code "${__zx__color__std_name__}"
    code_seq="${__zx__color__fg_code__}"
  fi
  if test -n "${bg_name}"; then
    __zx__color__std_name "${bg_name}"
    __zx__color__bg_code "${__zx__color__std_name__}"
    code_seq="${code_seq}${fmt_sep}${__zx__color__bg_code__}"
  fi
  if test -n "${te_name_seq}"; then
    __zx__text_effect__code_seq "${te_name_seq}" "${fmt_sep}"
    code_seq="${code_seq}${fmt_sep}${__zx__text_effect__code_seq__}"
  fi
  __zx__join_code_seq "${code_seq}" "${fmt_sep}" "${ansi_sep}"
  __zx__code_str="${__zx__join_code_seq}"
}

__zx__head() {
  __zx__code_str "${@}"

  # COMPATIBILITY NOTE:
  # ---------------------------------------------------------------
  #   bash/zsh:
  #     ESC = \x1b = \e = \E
  #   ksh93:
  #     ESC = \0033
  # ---------------------------------------------------------------

  __zx__head="\0001\0033[${__zx__code_str}m\0002"
  # \[ = \1 = \x01 = \0001, do not use \001! Octal format is \0nnn.
  # \] = \2 = \x02 = \0002, do not use \002! Octal format is \0nnn.
}

__zx__tail() {
  __zx__text_effect__code reset
  # COMPATIBILITY NOTE:
  # ---------------------------------------------------------------
  #   bash/zsh:
  #     ESC = \x1b = \e = \E
  #   ksh93:
  #     ESC = \0033
  # ---------------------------------------------------------------

  __zx__tail="\0001\0033[${__zx__text_effect__code__}m\0002"
  # \[ = \1 = \x01 = \0001, do not use \001! Octal format is \0nnn.
  # \] = \2 = \x02 = \0002, do not use \002! Octal format is \0nnn.s
}

__zx__pos() {
  arg="${1}"
  te_sep="${2:-${__zx__FMT_SEP}}"
  pos_sep="${3}"
  case "${arg}" in
  *[[:punct:]]*)
    local_sep="${te_sep}"
    # COMPATIBILITY NOTE:
    # ---------------------------------------------------------
    #   bash/zsh/ksh93:
    #     std_arg="${arg//[[:punct:]]/${local_sep}}"
    #   posix:
    #     # shellcheck disable=SC2001
    #     std_arg=$(echo "${arg}" | sed "s/[[:punct:]]/${local_sep}/g")
    #     OR
    #     std_arg=$(echo "${arg}" | awk -v X="${local_sep}" '{gsub(/[[:punct:]]/,X); print}'
    # ---------------------------------------------------------
    # shellcheck disable=SC2001
    arg=$(
      echo "${arg}" | sed "s/[[:punct:]|[:space:]]/${local_sep}/g"
    )
    fg_name="${arg%%"${local_sep}"*}"
    arg="${arg#*"${local_sep}"}"
    bg_name="${arg%%"${local_sep}"*}"
    arg="${arg#*"${local_sep}"}"
    te_name_seq="${arg}"
    ;;
  *)
    # COMPATIBILITY NOTE:
    # ---------------------------------------------------------
    #   bash/zsh/ksh93:
    #     fg_name="${arg:0:1}"
    #     bg_name="${arg:1:1}"
    #     te_name_seq="${arg:2}"
    #   posix:
    #     fg_name=$(echo "${arg}" | cut -c1)
    #     bg_name=$(echo "${arg}" | cut -c2)
    #     te_name_seq=$(echo "${arg}" | cut -c3-)
    # ---------------------------------------------------------

    fg_name=$(echo "${arg}" | cut -c1)
    bg_name=$(echo "${arg}" | cut -c2)
    te_name_seq=$(echo "${arg}" | cut -c3-)

    # shellcheck disable=SC2001
    #   bash==5.1.16
    #   complex substitution:
    #   split every char with ${te_sep}
    te_name_seq=$(echo "${te_name_seq}" | sed "s/./&${te_sep}/g")
    ;;
  esac
  __zx__color__code_case "${fg_name}"
  __zx__pos__fg_name="${__zx__color__code_case__}"
  __zx__color__code_case "${bg_name}"
  __zx__pos__bg_name="${__zx__color__code_case__}"
  __zx__pos__te_name_seq="${te_name_seq}"

  if test -n "${pos_sep}"; then
    __zx__pos="${fg_name}${pos_sep}${bg_name}${pos_sep}${te_name_seq}"
  fi
}

__zx__output_stream_fd() {
  stream_name="${1}"
  case "${stream_name}" in
  1 | out | stdout) __zx__output_stream_fd=1 ;;
  2 | err | stderr) __zx__output_stream_fd=2 ;;
  *) __zx__output_stream_fd=1 ;;
  esac
}

__zx__apply() {
  text=${1}
  shift
  __zx__head "${@}"
  __zx__tail "${@}"
  __zx__apply="${__zx__head}${text}${__zx__tail}"
}

__zx() {
  nm='__zx'
  so='' # — short opt_seq
  ## MAIN SHORT opt_seq
  so="${so}f:" # — foreground
  so="${so}b:" # — background
  so="${so}t:" # — text effect or emphasis
  so="${so}p:" # — positional form
  so="${so}h"  # — help
  so="${so}v"  # — version

  ## ECHO COMPATIBILITY SHORT opt_seq:
  so="${so}n" # — do not output the trailing newline.
  so="${so}e" # — enable interpretation of backslash escapes.
  so="${so}E" # — disable interpretation of backslash escapes.

  ## COREUTILS COMPATIBILITY SHORT opt_seq:
  so="${so}c::a"
  # -c=[always|never|auto] like with diff, ls, grep and others.
  # Plain -c means -c='auto'. Another values works as for -f.
  # -a means -c='auto'.

  lo=""
  # MAIN LONG opt_seq
  lo="${lo}fg:,foreground:,foreground-color:,"
  lo="${lo}bg:,background:,background-color:,"
  lo="${lo}te:,text-effect:,em:,emphasis:,"
  lo="${lo}ps:,pos:,positional:,"
  lo="${lo}help,"
  lo="${lo}version,"

  ## ECHO COMPATIBILITY LONG opt_seq:
  lo="${lo}nn,nonewline,"
  lo="${lo}esc,escapes"
  lo="${lo}ne,nesc,noesc,noescapes"

  ## COREUTILS COMPATIBILITY LONG opt_seq:
  lo="${lo}color::,auto,auto-color"
  # --color=[always|never|auto] like with diff, ls, grep.
  # Plain --color means --color='auto'. Another values
  # e.g (NOT 'always|never|auto)  works as for --foreground.
  # --auto and --auto-color means --color='auto'.

  opt_seq=$(getopt -n "${nm}" -o "${so}" -l "${lo}" -- "${@}")
  eval set -- "${opt_seq}"
  unset nm so lo

  fg_name=''
  bg_name=''
  te_name_seq=''
  text=''
  pos_args_seq=''

  when_use_color='always'
  use_newline=true
  use_initial_escapes=false

  ## OUTPUT STREAM opt_seq
  __zx__OUTPUT_STREAM_FD=1

  while test -n "${opt_seq}"; do
    case ${1} in
    # MAIN opt_seq
    -f | --fg | --foreground | --foreground-color)
      fg_name="${2}"
      shift 2
      ;;
    -b | --bg | --background | --background-color)
      bg_name="${2}"
      shift 2
      ;;
    -t | --te | --text-effect | --em | --emph | --emphasis)
      te_name_seq="${te_name_seq} ${2}"
      shift 2
      ;;
    -p | --ps | --pos | positional)
      pos_args_seq="${2}"
      shift 2
      ;;
    -h | --help)
      __zx__usage
      shift 1
      ;;
    -v | --version)
      printf '0.1767469499'
      shift 1
      ;;
    # ECHO COMPATIBILITY
    -n | --nn | --nonewline)
      # Echo compatibility.
      use_newline=false
      shift 1
      ;;
    -e | --esc | --escapes)
      # Echo compatibility.
      use_initial_escapes=true
      shift 1
      ;;
    -E | --ne | --nesc | --noesc | --noescapes)
      # Echo compatibility.
      use_initial_escapes=false
      shift 1
      ;;
    # COREUTILS COMPATIBILITY
    -c | --color)
      ## Coreutils compatibility.
      arg="${2:-auto}"
      case "${arg}" in
      always | never | auto)
        when_use_color="${arg}"
        ;;
      *)
        fg_name="${arg}"
        ;;
      esac

      shift 2
      ;;
    -a | --auto | --auto-color)
      ## Coreutils compatibility.
      when_use_color='auto'
      shift 1
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
  text="${*}"

  # ECHO COMPATIBILITY
  newline=''
  if ${use_newline}; then
    newline='\n'
  fi
  if ${use_initial_escapes}; then
    text=$(printf "%b" "${text}")
  else
    text=$(printf "%s" "${text}")
  fi

  # COREUTILS COMPATIBILITY
  output_type='file'
  if test -t "${__zx__OUTPUT_STREAM_FD}"; then
    output_type='stream'
  fi
  case "${when_use_color}_${output_type}" in
  never*)
    use_colors=false
    ;;
  always*)
    use_colors=true
    ;;
  _stream)
    use_colors=true
    ;;
  _file)
    use_colors=false
    ;;
  *)
    use_colors=true
    ;;
  esac

  __zx__FMT_SEP=':'
  __zx__ESC_ANSI_SEP=';'

  fmt_sep="${__zx__FMT_SEP}"

  if test -n "${pos_args_seq}"; then
    __zx__pos "${pos_args_seq}" "${fmt_sep}"
    fg_name="${__zx__pos__fg_name}"
    bg_name="${__zx__pos__bg_name}"
    te_name_seq="${__zx__pos__te_name_seq}"
  fi

  if ${use_colors}; then
    __zx__apply "${text}" "${fg_name}" "${bg_name}" "${te_name_seq}"
    result="${__zx__apply}"
  else
    result="${text}"
  fi

  printf '%b%b' "${result}" "${newline}"
}


__zx__clean() {
  unset ansi_sep
  unset arg
  unset awk_prog
  unset bg_name
  unset cl
  unset code
  unset code_seq
  unset code_str
  unset color
  unset disable
  unset enable
  unset fg_name
  unset fmt_sep
  unset lo
  unset local_sep
  unset newline
  unset nm
  unset opt_seq
  unset output_type
  unset patten
  unset pos_args_seq
  unset pos_sep
  unset result
  unset so
  unset std_arg
  unset stream_name
  unset te_code_seq
  unset te_name
  unset te_name_seq
  unset te_sep
  unset text
  unset use_colors
  unset use_initial_escapes
  unset use_newline
  unset when_use_color
  unset X
  unset __zx__apply
  unset __zx__color__bg_code
  unset __zx__code_str
  unset __zx__color__code_case
  unset __zx__color__code_pair
  unset __zx__color__std_name
  unset __zx__ESC_ANSI_SEP
  unset __zx__color__fg_code
  unset __zx__FMT_SEP
  unset __zx__head
  unset __zx__join_code_seq
  unset __zx__output_stream_fd
  unset __zx__OUTPUT_STREAM_FD
  unset __zx__pos
  unset __zx__pos__bg_name
  unset __zx__pos__fg_name
  unset __zx__pos__te_name_seq
  unset __zx__color__rename
  unset __zx__tail
  unset __zx__text_effect__code__
  unset __zx__text_effect__code_seq
}
