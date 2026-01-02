#!/usr/bin/env bash
# shellcheck enable=all disable=SC2317

# COMPATIBILITY NOTE:
# ---------------------------------------------------------------
#   bash/zsh/ksh93:
#     shfmt -ci -i 2 -sr -s -bn -kp -ln bash -d
#
#   See compatibility notes below and use posix variants.
#   How to check posix:
#     shfmt -ci -i 2 -sr -s -bn -kp -ln posix -d
# ---------------------------------------------------------------

typeset __NOSTER_THEME_ZECHO_FMT_SEP=':'
typeset __NOSTER_THEME_ZECHO_TEXT_EFFECT_SEP=':'
typeset __NOSTER_THEME_ZECHO_POS_SEP=':'
typeset __NOSTER_THEME_ZECHO_ESC_ANSI_SEP=';'

__noster_theme_zecho_lib() {

  __noster_theme_zecho_usage() {
    # shellcheck disable=SC2312
    cat << EOF
Usage: __noster_theme_zecho [OPTIONS] [TEXT]

NAME:
  «Colourful Echo» —> «C. Echo» —> «cecho». It sounds like /see‑EK‑oh/
  in English. But in Latin it sounds like /tse‑kho/, that is similar to
    * German «Zeche» — /tseh‑uhn/ — colliery;
    * Russian «Цех»  — /tsekh/    — workshop.
  So we use «Z» to represent /ts/-sound.

EXAMPLES:
  > __noster_theme_zecho -b -yellow -f -RED -e DEL -t 'Some waring'
  It gives you:
    $(__noster_theme_zecho -b YELLOW -f RED -e DEL -t 'Some waring')
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

  __noster_theme_zecho_te_code() {
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

  __noster_theme_zecho_te_code_seq() {
    typeset te_name_seq="${1}"
    typeset te_sep="${__NOSTER_THEME_ZECHO_TEXT_EFFECT_SEP}"
    typeset te_code_seq=''
    te_name_seq="${te_name_seq}${te_sep}"
    while [[ ${te_name_seq#*"${te_sep}"} != "${te_name_seq}" ]]; do
      typeset te_name="${te_name_seq%%"${te_sep}"*}"
      typeset -i te_code
      te_code=$(__noster_theme_zecho_te_code "${te_name}")
      if [[ ${te_code} != '-1' ]] && [[ ${te_code} != '-2' ]]; then
        if [[ -n ${te_code_seq} ]]; then
          te_code_seq="${te_code_seq}${te_sep}"
        fi
        te_code_seq="${te_code_seq}${te_code}"
      fi
      te_name_seq="${te_name_seq#*"${te_sep}"}"
    done
    echo "${te_code_seq}"
  }

  __noster_theme_zecho_color_code_case() {
    case ${1} in
      [[:lower:]]) echo "-${1}" ;;
      [[:upper:]]) echo "+${1}" ;;
      *) echo "${1}" ;;
    esac
  }

  __noster_theme_zecho_rename_color() {
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

  __noster_theme_zecho_color_std_name() {
    typeset -l color="${1}"
    typeset -l renamed_color
    renamed_color=$(__noster_theme_zecho_rename_color "${color}")
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

  __noster_theme_zecho_color_code_pair() {
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

  __noster_theme_zecho_fg_code() {
    typeset code_pair
    code_pair=$(__noster_theme_zecho_color_code_pair "${1}")
    typeset -i fg_code="${code_pair%\ *}"
    echo "${fg_code}"
  }

  __noster_theme_zecho_bg_code() {
    typeset code_pair
    code_pair=$(__noster_theme_zecho_color_code_pair "${1}")
    typeset -i bg_code="${code_pair#*\ }"
    echo "${bg_code}"
  }

  __noster_theme_zecho_join_code_seq() {
    typeset code_seq="${1}"
    typeset ansi_sep="${__NOSTER_THEME_ZECHO_ESC_ANSI_SEP}"
    typeset fmt_sep="${__NOSTER_THEME_ZECHO_FMT_SEP}"

    typeset code_str=''
    code_seq="${code_seq}${fmt_sep}"
    while [[ ${code_seq#*"${fmt_sep}"} != "${code_seq}" ]]; do
      typeset code="${code_seq%%"${fmt_sep}"*}"
      if [[ ${code} != '-1' ]] && [[ ${code} != '-2' ]]; then
        if [[ -n ${code_str} ]]; then
          code_str="${code_str}${ansi_sep}"
        fi
        code_str="${code_str}${code}"
      fi
      code_seq="${code_seq#*"${fmt_sep}"}"
    done

    echo "${code_str}"
  }

  __noster_theme_zecho_code_str() {
    typeset fg_name="${1}"
    typeset bg_name="${2}"
    typeset te_name_seq="${3}"
    typeset fmt_sep="${__NOSTER_THEME_ZECHO_FMT_SEP}"

    typeset code_seq
    if [[ -n ${fg_name} ]]; then
      typeset fg_std_name=''
      fg_std_name=$(__noster_theme_zecho_color_std_name "${fg_name}")
      typeset -i fg_code=-1
      fg_code=$(__noster_theme_zecho_fg_code "${fg_std_name}")
      code_seq="${fg_code}"
    fi
    if [[ -n ${bg_name} ]]; then
      typeset bg_std_name=''
      bg_std_name=$(__noster_theme_zecho_color_std_name "${bg_name}")
      typeset -i bg_code=-1
      bg_code=$(__noster_theme_zecho_bg_code "${bg_std_name}")
      code_seq="${code_seq}${fmt_sep}${bg_code}"
    fi
    if [[ -n ${te_name_seq} ]]; then
      typeset te_code_seq
      te_code_seq=$(
        __noster_theme_zecho_te_code_seq "${te_name_seq}"
      )
      code_seq="${code_seq}${fmt_sep}${te_code_seq}"
    fi
    typeset code_str
    code_str=$(
      __noster_theme_zecho_join_code_seq "${code_seq}"
    )
    echo "${code_str}"
  }

  __noster_theme_zecho_head() {
    typeset fg_name="${1}"
    typeset bg_name="${2}"
    typeset te_name_seq="${3}"
    typeset seq=''
    seq=$(
      __noster_theme_zecho_code_str "${fg_name}" "${bg_name}" "${te_name_seq}"
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

  __noster_theme_zecho_tail() {
    typeset reset_code
    reset_code=$(__noster_theme_zecho_te_code reset)

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

  __noster_theme_zecho_parse_te_name_seq() {
    typeset te_name_seq="${1}"
    typeset arg="${2}"
    typeset te_sep="${__NOSTER_THEME_ZECHO_TEXT_EFFECT_SEP}"
    typeset std_arg

    # COMPATIBILITY NOTE:
    # ---------------------------------------------------------------
    #   bash/zsh/ksh93:
    #     std_arg="${arg//[[:punct:]]/${te_sep}}"
    #   posix:
    #     # shellcheck disable=SC2001
    #     std_arg=$(echo "${arg}" | sed "s/[[:punct:]]/${te_sep}/")
    # ---------------------------------------------------------------

    std_arg="${arg//[[:punct:]]/${te_sep}}"
    if [[ -n ${te_name_seq} ]]; then
      te_name_seq="${te_name_seq}${te_sep}"
    fi
    te_name_seq="${te_name_seq}${std_arg}"
    echo "${te_name_seq}"
  }

  __noster_theme_zecho_parse_positional() {
    typeset arg="${1}"
    typeset fmt_sep="${__NOSTER_THEME_ZECHO_FMT_SEP}"
    typeset pos_sep="${__NOSTER_THEME_ZECHO_POS_SEP}"
    typeset fg_name
    typeset bg_name
    typeset te_name_seq

    if [[ ${arg} =~ [[:punct:]] ]]; then

      # COMPATIBILITY NOTE:
      # ---------------------------------------------------------
      #   bash/zsh/ksh93:
      #     std_arg="${arg//[[:punct:]]/${fmt_sep}}"
      #   posix:
      #     # shellcheck disable=SC2001
      #     std_arg=$(echo "${arg}" | sed "s/[[:punct:]]/${fmt_sep}/g")
      # ---------------------------------------------------------

      # shellcheck disable=SC2001
      std_arg="${arg//[[:punct:]]/${fmt_sep}}"

      fg_name="${arg%%"${fmt_sep}"*}"
      arg="${arg#*"${fmt_sep}"}"
      bg_name="${arg%%"${fmt_sep}"*}"
      arg="${arg#*"${fmt_sep}"}"
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
      #   split every char with ${fmt_sep}
      te_name_seq=$(echo "${te_name_seq}" | sed "s/./&${fmt_sep}/g")
    fi
    fg_name=$(__noster_theme_zecho_color_code_case "${fg_name}")
    bg_name=$(__noster_theme_zecho_color_code_case "${bg_name}")

    typeset _P_="${pos_sep}"
    pos_res="${fg_name}${_P_}${bg_name}${_P_}${te_name_seq}"
    echo "${pos_res}"
  }

  __noster_theme_zecho_do() {
    typeset options
    typeset nm='__noster_theme_zecho'
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
          __noster_theme_zecho_usage __noster_theme_zecho_do
          shift 1
          ;;
        -a | --auto)
          detect_colors=true
          shift 1
          ;;
        -x | -p | --pos)
          typeset pos_arg_seq
          typeset pos_sep="${__NOSTER_THEME_ZECHO_POS_SEP}"
          pos_arg_seq=$(__noster_theme_zecho_parse_positional "${2}")
          fg_name="${pos_arg_seq%%"${pos_sep}"*}"
          # rest
          pos_arg_seq="${pos_arg_seq#*"${pos_sep}"}"
          bg_name="${pos_arg_seq%%"${pos_sep}"*}"
          # rest
          te_name_seq="${pos_arg_seq#*"${pos_sep}"}"
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
            __noster_theme_zecho_parse_te_name_seq "${te_name_seq}" "${2}"
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
      __noster_theme_zecho_head "${fg_name}" "${bg_name}" "${te_name_seq}"
    )
    typeset tail
    tail=$(
      __noster_theme_zecho_tail "${fg_name}" "${bg_name}" "${te_name_seq}"
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
}

__noster_theme_zecho() {
  __noster_theme_zecho_lib

  __noster_theme_zecho_do "${@}"

  # grep '()' | sed -re 's/\s+(.*)\(\) \{/unset \1/gi'
  unset __noster_theme_zecho_usage
  unset __noster_theme_zecho_te_code
  unset __noster_theme_zecho_te_code_seq
  unset __noster_theme_zecho_color_code_case
  unset __noster_theme_zecho_rename_color
  unset __noster_theme_zecho_color_std_name
  unset __noster_theme_zecho_color_code_pair
  unset __noster_theme_zecho_fg_code
  unset __noster_theme_zecho_bg_code
  unset __noster_theme_zecho_join_code_seq
  unset __noster_theme_zecho_code_str
  unset __noster_theme_zecho_head
  unset __noster_theme_zecho_tail
  unset __noster_theme_zecho_parse_te_name_seq
  unset __noster_theme_zecho_parse_positional
  unset __noster_theme_zecho_do

}

__noster_theme_zecho__subshell__overload_example() (
  __noster_theme_zecho_lib

  __noster_theme_zecho_usage() {
    echo "Overload example. the main function is $1"
  }

  __noster_theme_zecho_do "${@}"

)
