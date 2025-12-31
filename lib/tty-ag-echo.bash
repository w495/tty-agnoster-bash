#!/usr/bin/env bash
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

__tty_ag_echo() {
  __tty_ag_echo_usage() {
    # shellcheck disable=SC2312
      cat << EOF
Usage: __tty_ag_echo [OPTIONS] [TEXT]
EXAMPLES:
  > __tty_ag_echo -b -yellow -f -RED -e DEL -t 'Some waring'
  It gives you:
    $(__tty_ag_echo -b YELLOW -f RED -e DEL -t 'Some waring')
OPTIONS:
  -b — for background color in a lower or an UPPER case.
  -b — for background color in a lower or an UPPER case.

  -e — for text effect
    * bold      — $($1 -e bold bold);
    * dim       — $($1 -e dim dim);
    * italic    — $($1 -e italic italic)
                    (looks like foreground color in tty1-6);
    * underline — $($1 -e underline underline)
                    (looks like foreground color in tty1-6);
    * blink     — $($1 -e blink blink);
    * reverse   — $($1 -e reverse reverse);
    * del       — $($1 -e del del);
    * conceal   — $($1 -e conceal conceal);
    * reset     — to clean format;
    * any other interprets as empty color.
  -t — any text. Also you can use text after --.

  COLORS:
    Dark CMYK
      -cyan     — $($1 -f dc cyan);
      -magenta  — $($1 -f dm magenta);
      -yellow   — $($1 -f dy yellow);
      -black    — $($1 -f dk black);

    Dark RGB
      -red      — $($1 -f dr red);
      -green    — $($1 -f dg green);
      -blue     — $($1 -f db blue);
      -white    — $($1 -f dw white);
    Bright CMYK
      +cyan     — $($1 -f lc cyan);
      +magenta  — $($1 -f lm magenta);
      +yellow   — $($1 -f ly yellow);
      +black    — $($1 -f lk black);
    Bright RGB
      +red      — $($1 -f lr red);
      +green    — $($1 -f lg green);
      +blue     — $($1 -f lb blue);
      +white    — $($1 -f lw white);
    Any other interprets as empty color.
EOF

  }

  typeset __TTY_AG_ECHO_FMT_SEP=':'
  typeset __TTY_AG_ECHO_POS_SEP=':'
  typeset __TTY_AG_ECHO_ESC_ANSI_SEP=';'

  __tty_ag_echo_te_code() {
    typeset -l effect="${1}"
    case "${effect}" in
      0 | n |     clear |     reset)    echo 0 ;;
      1 | b |     bold)                 echo 1 ;;
      2 | d | f | dim |       faint)    echo 2 ;;
      3 | i |     italic)               echo 3 ;;
      4 | u |     underline)            echo 4 ;;
      5 | l |     blink)                echo 5 ;;
      7 | r |     reverse)              echo 7 ;;
      8 | c |     conceal)              echo 8 ;;
      9 | s | x | strike |    del)      echo 9 ;;
      '')                               echo -1 ;;
      *)                                echo -2 ;;
    esac
  }

  __tty_ag_echo_te_code_seq() {
    typeset te_name_seq="${1}"
    typeset te_code_seq=''
    OLD_IFS="${IFS}"
    IFS="${__TTY_AG_ECHO_FMT_SEP}"
    # shellcheck disable=SC2116
    for te_name in $(echo "${te_name_seq}"); do
      typeset -i te_code
      te_code=$(__tty_ag_echo_te_code "${te_name}")
      if [[ -z ${te_code} ]]; then continue; fi
      if [[ ${te_code} == '-1'   ]]; then continue; fi
      if [[ ${te_code} == '-2'   ]]; then continue; fi
      if [[ -n ${te_code_seq} ]]; then
        te_code_seq="${te_code_seq}${__TTY_AG_ECHO_FMT_SEP}"
      fi
      te_code_seq="${te_code_seq}${te_code}"
    done
    IFS="${OLD_IFS}"
    echo "${te_code_seq}"
  }

  __tty_ag_echo_color_code_case() {
    case ${1} in
      [[:lower:]]) echo "-${1}" ;;
      [[:upper:]]) echo "+${1}" ;;
      *) echo "${1}" ;;
    esac
  }

  __tty_ag_echo_rename_color() {
    typeset -l color_name="${1}"
    typeset -l cl=''
    cl="cyan|magenta|yellow|black|red|green|blue|white"
    cl="${cl}|c|m|y|k|r|g|b|w"
    patten="
      s/^((d|dark)(\W|_)?)(${cl})$/-\4/gi;
      s/^((i|l|light|br|bright)(\W|_)?)(${cl})?$/+\4/gi;
      s/^(${cl})((\W|_)?(d|dark))$/-\1/gi;
      s/^(${cl})((\W|_)?(i|l|light|b|br|bright))$/+\1/gi;
    "
    echo "${color_name}" | sed -re "${patten}"
  }

  __tty_ag_echo_color_std_name() {
    typeset -l color="${1}"
    typeset -l renamed_color
    renamed_color=$(__tty_ag_echo_rename_color "${color}")
    case "${renamed_color}" in
      -k | k | -0 | 0 | 30 | 40 | rgb-000 | -black | black)
        echo 'basic black'
        ;;
      -r | r | -1 | 1 | 31 | 41 | rgb-100 | -red | red)
        echo 'basic red'
        ;;
      -g | g | -2 | 2 | 32 | 42 | rgb-010 | -green | green)
        echo 'basic green'
        ;;
      -y | y | -3 | 3 | 33 | 43 | rgb-110 | -yellow | yellow)
        echo 'basic yellow'
        ;;
      -b | b | -4 | 4 | 34 | 44 | rgb-001 | -blue | blue)
        echo 'basic blue'
        ;;
      -m | m | -5 | 5 | 35 | 45 | rgb-101 | -magenta | magenta)
        echo 'basic magenta'
        ;;
      -c | c | -6 | 6 | 36 | 46 | rgb-011 | -cyan | cyan)
        echo 'basic cyan'
        ;;
      -w | w | -7 | 7 | 37 | 47 | rgb-111 | -white | white)
        echo 'basic white'
        ;;
      ## bright colors
      +k | +0 | 90 | 100 | rgb+000 | +black | gray)
        echo 'bright black'
        ;;
      +r | +1 | 91 | 101 | rgb+100 | +red)
        echo 'bright red'
        ;;
      +g | +2 | 92 | 102 | rgb+010 | +green)
        echo 'bright green'
        ;;
      +y | +3 | 93 | 103 | rgb+110 | +yellow)
        echo 'bright yellow'
        ;;
      +b | +4 | 94 | 104 | rgb+001 | +blue)
        echo 'bright blue'
        ;;
      +m | +5 | 95 | 105 | rgb+101 | +magenta)
        echo 'bright magenta'
        ;;
      +c | +6 | 96 | 106 | rgb+011 | +cyan)
        echo 'bright cyan'
        ;;
      +w | +7 | 97 | 107 | rgb+111 | +white)
        echo 'bright white'
        ;;
      '')
        echo 'empty color'
        ;;
      *)
        printf >&2 "\e[31mError unknown color '%s' \e[0m\n" "${color}"
        echo 'unknown color'
        ;;
    esac
  }

  __tty_ag_echo_color_code_pair() {
    typeset color_std_name="${1}"
    case "${color_std_name}" in
      'basic black')    echo 30 40  ;;
      'basic red')      echo 31 41  ;;
      'basic green')    echo 32 42  ;;
      'basic yellow')   echo 33 43  ;;
      'basic blue')     echo 34 44  ;;
      'basic magenta')  echo 35 45  ;;
      'basic cyan')     echo 36 46  ;;
      'basic white')    echo 37 47  ;;
      'bright black')   echo 90 100 ;;
      'bright red')     echo 91 101 ;;
      'bright green')   echo 92 102 ;;
      'bright yellow')  echo 93 103 ;;
      'bright blue')    echo 94 104 ;;
      'bright magenta') echo 95 105 ;;
      'bright cyan')    echo 96 106 ;;
      'bright white')   echo 97 107 ;;
      'empty color')    echo -1 -1  ;;
      'unknown color')  echo -2 -2 ;;
      *)                echo -3 -3  ;;
    esac
  }

  __tty_ag_echo_fg_code() {
    typeset code_pair
    code_pair=$(__tty_ag_echo_color_code_pair "${1}")
    typeset -i fg_code="${code_pair%\ *}"
    echo "${fg_code}"
  }

  __tty_ag_echo_bg_code() {
    typeset code_pair
    code_pair=$(__tty_ag_echo_color_code_pair "${1}")
    typeset -i bg_code="${code_pair#*\ }"
    echo "${bg_code}"
  }

  __tty_ag_echo_join_code_seq() {
    typeset code_seq="${1}"
    typeset code_str=''

    # COMPATIBILITY NOTE:
    # ---------------------------------------------------------------
    #  Dash (sh) variant:
    #    typeset pipe
    #    pipe="$(mktemp -u)"
    #    mkfifo "${pipe}"
    #    echo "${code_seq}" > "${pipe}" &
    #    while read -rd "${__TTY_AG_ECHO_FMT_SEP}" code; do
    #      if [[ -z ${code} ]]; then continue; fi
    #      if [[ "${code}" == '-1' ]]; then continue; fi
    #      if [[ "${code}" == '-2' ]]; then continue; fi
    #      if [[ -n ${code_str} ]]; then
    #        code_str="${code_str}${__TTY_AG_ECHO_ESC_ANSI_SEP}"
    #      fi
    #      code_str="${code_str}${code}"
    #    done < "${pipe}"
    #    rm "${pipe}"
    # ---------------------------------------------------------------

    OLD_IFS="${IFS}"
    IFS="${__TTY_AG_ECHO_FMT_SEP}"
    # shellcheck disable=SC2116
    #   use $(echo "${code_seq}") for zsh
    for code in $(echo "${code_seq}"); do
      if [[ -z ${code} ]]; then continue; fi
      if [[ ${code} == '-1'   ]]; then continue; fi
      if [[ ${code} == '-2'   ]]; then continue; fi
      if [[ -n ${code_str} ]]; then
        code_str="${code_str}${__TTY_AG_ECHO_ESC_ANSI_SEP}"
      fi
      code_str="${code_str}${code}"
    done
    IFS="${OLD_IFS}"

    echo "${code_str}"
  }

  __tty_ag_echo_code_str() {
    typeset fg_name="${1}"
    typeset bg_name="${2}"
    typeset te_name_seq="${3}"
    typeset -i fg_code=-1 bg_code=-1
    typeset te_code_seq=''
    if [[ -n ${fg_name} ]]; then
      typeset fg_std_name=''
      fg_std_name=$(__tty_ag_echo_color_std_name "${fg_name}")
      fg_code=$(__tty_ag_echo_fg_code "${fg_std_name}")
    fi
    if [[ -n ${bg_name} ]]; then
      typeset bg_std_name=''
      bg_std_name=$(__tty_ag_echo_color_std_name "${bg_name}")
      bg_code=$(__tty_ag_echo_bg_code "${bg_std_name}")
    fi
    if [[ -n ${te_name_seq} ]]; then
      te_code_seq=$(__tty_ag_echo_te_code_seq "${te_name_seq}")
    fi
    typeset s="${__TTY_AG_ECHO_FMT_SEP}"
    typeset code_seq="${fg_code}${s}${bg_code}${s}${te_code_seq}"
    #    code_seq=$(__tty_ag_echo_filter_code_seq "${code_seq}")
    typeset code_str
    code_str=$(__tty_ag_echo_join_code_seq "${code_seq}")
    echo "${code_str}"
  }

  __tty_ag_echo_head() {
    typeset fg_name="${1}"
    typeset bg_name="${2}"
    typeset te_name_seq="${3}"
    typeset seq=''
    seq=$(
      __tty_ag_echo_code_str "${fg_name}" "${bg_name}" "${te_name_seq}"
    )

    # COMPATIBILITY NOTE:
    # ---------------------------------------------------------------
    #   bash/zsh:
    #     ESC = \x1b = \e = \E
    #   ksh93:
    #     ESC = \0033
    # ---------------------------------------------------------------

    typeset head="\0001\0033[${seq}m\0002"
    # \[ = \1 = \x01 = \0001, do not use \001! Octal format is \0nnn.
    # \] = \2 = \x02 = \0002, do not use \002! Octal format is \0nnn.
    echo "${head}"
  }

  __tty_ag_echo_tail() {
    typeset reset_code
    reset_code=$(__tty_ag_echo_te_code reset)

    # COMPATIBILITY NOTE:
    # ---------------------------------------------------------------
    #   bash/zsh:
    #     ESC = \x1b = \e = \E
    #   ksh93:
    #     ESC = \0033
    # ---------------------------------------------------------------

    typeset tail="\0001\0033[${reset_code}m\0002"
    # \[ = \1 = \x01 = \0001, do not use \001! Octal format is \0nnn.
    # \] = \2 = \x02 = \0002, do not use \002! Octal format is \0nnn.s
    echo "${tail}"
  }

  __tty_ag_echo_parse_te_name_seq()  {
    typeset te_name_seq="${1}"
    typeset arg="${2}"
    typeset fs="${__TTY_AG_ECHO_FMT_SEP}"
    typeset std_arg

    # COMPATIBILITY NOTE:
    # ---------------------------------------------------------------
    #   bash/zsh/ksh93:
    #     std_arg="${arg//[[:punct:]]/${fs}}"
    #   posix:
    #     # shellcheck disable=SC2001
    #     std_arg=$(echo "${arg}" | sed "s/[[:punct:]]/${fs}/")
    # ---------------------------------------------------------------

    std_arg="${arg//[[:punct:]]/${fs}}"
    if [[ -n ${te_name_seq} ]]; then
      te_name_seq="${te_name_seq}${__TTY_AG_ECHO_FMT_SEP}"
    fi
    te_name_seq="${te_name_seq}${std_arg}"
    echo "${te_name_seq}"
  }

  __tty_ag_echo_parse_positional()  {
    typeset arg="${1}"
    typeset fs="${__TTY_AG_ECHO_FMT_SEP}"
    typeset fg_name
    typeset bg_name
    typeset te_name_seq

    if [[ ${arg} =~ [[:punct:]] ]]; then

      # COMPATIBILITY NOTE:
      # ---------------------------------------------------------
      #   bash/zsh/ksh93:
      #     std_arg="${arg//[[:punct:]]/${fs}}"
      #   posix:
      #     # shellcheck disable=SC2001
      #     std_arg=$(echo "${arg}" | sed "s/[[:punct:]]/${fs}/g")
      # ---------------------------------------------------------

      # shellcheck disable=SC2001
      std_arg="${arg//[[:punct:]]/${fs}}"
      fg_name="${arg%%"${fs}"*}"
                                  arg="${arg#*"${fs}"}"
      bg_name="${arg%%"${fs}"*}"
                                  arg="${arg#*"${fs}"}"
      te_name_seq="${arg}"
    else

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

      fg_name="${arg:0:1}"
      bg_name="${arg:1:1}"
      te_name_seq="${arg:2}"

      # shellcheck disable=SC2001
      #   bash=5.1.16
      #   complex substitution:
      #   split every char with ${fs}
      te_name_seq=$(echo "${te_name_seq}" | sed "s/./&${fs}/g")
    fi
    fg_name=$(__tty_ag_echo_color_code_case "${fg_name}")
    bg_name=$(__tty_ag_echo_color_code_case "${bg_name}")

    typeset ps="${__TTY_AG_ECHO_POS_SEP}"
    pos_res="${fg_name}${ps}${bg_name}${ps}${te_name_seq}"
    echo "${pos_res}"
  }

  __tty_ag_echo_main() {
    typeset options
    typeset nm='__tty_ag_echo'
    typeset sh='p:c:b:f:e:x:t:adh'
    typeset lg='pos:,bg:,fg:,te:,help,auto'
    options=$(getopt -n "${nm}" -o "${sh}" -l "${lg}" -- "${@}")
    eval set -- "${options}"
    typeset fg_name=""
    typeset bg_name=""
    typeset te_name_seq=''
    typeset text=""
    typeset detect_colors=false

    while [[ -n ${options} ]]; do
      case ${1} in
        -h)
          __tty_ag_echo_usage __tty_ag_echo
          shift 1
          ;;
        -a | --auto)
          detect_colors=true
          shift 1
          ;;
        -x | -p | --pos)
          typeset pos_arg_seq
          pos_arg_seq=$(__tty_ag_echo_parse_positional "${2}")
          fg_name="${pos_arg_seq%%"${__TTY_AG_ECHO_POS_SEP}"*}"
          # rest
          pos_arg_seq="${pos_arg_seq#*"${__TTY_AG_ECHO_POS_SEP}"}"
          bg_name="${pos_arg_seq%%"${__TTY_AG_ECHO_POS_SEP}"*}"
          # rest
          te_name_seq="${pos_arg_seq#*"${__TTY_AG_ECHO_POS_SEP}"}"
          shift 2
          ;;
        -c | -f | --fg)
          fg_name="${2}"
          shift 2
          ;;
        -b | --bg)
          bg_name="${2}"
          shift 2
          ;;
        -e | --te)
          te_name_seq=$(
            __tty_ag_echo_parse_te_name_seq "${te_name_seq}" "${2}"
          )
          shift 2
          ;;
        -t | --text)
          text="${2}"
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
    text="${text}${*}"
    typeset head
    head=$(
      __tty_ag_echo_head "${fg_name}" "${bg_name}" "${te_name_seq}"
    )
    typeset tail
    tail=$(
      __tty_ag_echo_tail "${fg_name}" "${bg_name}" "${te_name_seq}"
    )
    typeset result
    if ${detect_colors}; then
      if [[ $- =~ i ]] && [[ -t 1 ]]; then
        result="${head}${text}${tail}"
      else
        result="${text}"
      fi
    else
      result="${head}${text}${tail}"
    fi

    printf '%b\n' "${result}"
  }

  __tty_ag_echo_main "${@}"

  # grep '()' | sed -re 's/\s+(.*)\(\) \{/unset \1/gi'
  unset __tty_ag_echo_usage
  unset __tty_ag_echo_te_code_seq
  unset __tty_ag_echo_te_code
  unset __tty_ag_echo_color_code_case
  unset __tty_ag_echo_rename_color
  unset __tty_ag_echo_color_std_name
  unset __tty_ag_echo_color_code_pair
  unset __tty_ag_echo_fg_code
  unset __tty_ag_echo_bg_code
  unset __tty_ag_echo_join_code_seq
  unset __tty_ag_echo_code_str
  unset __tty_ag_echo_head
  unset __tty_ag_echo_tail
  unset __tty_ag_echo_main

}

__tty_ag_echo "${@}"

#
#if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
#  __tty_ag_echo "${@}"
#fi
