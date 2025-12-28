#!/usr/bin/env bash
# shellcheck enable=all
# shfmt -ci -i 2 -sr -s -bn -ln posix -d



__tty_ag_echo() {
    __tty_ag_echo_usage() {
      # shellcheck disable=SC2312
      cat <<EOF
Usage: __tty_ag_echo [OPTIONS] [TEXT]
EXAMPLES:
  > __tty_ag_echo -b -yellow -f -RED -e DEL -t 'Some waring'
  It gives you:
    $(__tty_ag_echo -b YELLOW -f RED -e DEL -t 'Some waring')
OPTIONS:
  -b — for background color in a lower or an UPPER case:
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


|  $($1 -f dc cyan) | $($1 -f dm magenta) | $($1 -f dy yellow) | $($1 -f dk black) |
|------------------:|---------------------|:-------------------|-------------------|
|  $($1 -f dc cyan) | $($1 -f dm magenta) | $($1 -f dy yellow) | $($1 -f dk black) |

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

    __tty_ag_echo_te_code_seq() (
      local te_name_seq="${1}"
      for te_name in ${te_name_seq}; do
        local -i res
        res=$(__tty_ag_echo_te_code "${te_name}")
        printf '%d' "${res}"
      done
    )

    __tty_ag_echo_te_code() {
      local -l effect="${1}"
      case "${effect}" in
        0 | n | clear | reset)
          printf '%d' 0
          ;;
        1 | b | bold)
          printf '%d' 1
          ;;
        2 | d | f | dim | faint)
          printf '%d' 2
          ;;
        3 | i | italic)
          printf '%d' 3
          ;;
        4 | u | underline)
          printf '%d' 4
          ;;
        5 | l | blink )
          printf '%d' 5
          ;;
        7 | r | reverse)
          printf '%d' 7
          ;;
        8 | c | conceal)
          printf '%d'  8
          ;;
        9 | s | x | Strikethrough | strikeout | del)
          printf '%d'  9
          ;;
        '')
          printf '%d' -1
          ;;
        *)
          printf '%d' -2
          ;;
      esac
    }

    __tty_ag_echo_color_code_case() (
      case ${1} in
        ([[:lower:]]) printf '%s' "-${1}";;
        ([[:upper:]]) printf '%s' "+${1}";;
        (*) printf '%s' "${1}";;
      esac
    )

    __tty_ag_echo_rename_color() {
      local -l color_name="${1}"
      local -l cl=''
      cl="cyan|magenta|yellow|black|red|green|blue|white"
      cl="${cl}|c|m|y|k|r|g|b|w"
      patten="
          s/^((d|dark|ba|basic)(\W|_)?)(${cl})$/-\4/gi;
          s/^((i|l|light|br|bright)(\W|_)?)(${cl})?$/+\4/gi;
          s/^(${cl})((\W|_)?(d|dark|ba|basic))$/-\1/gi;
          s/^(${cl})((\W|_)?(i|l|light|b|br|bright))$/+\1/gi;
        "
      printf '%s' "${color_name}" | sed -re "${patten}"
    }

    __tty_ag_echo_color_code() {
      local -l color="${1}"
      local -l renamed_color
      renamed_color=$(__tty_ag_echo_rename_color "${color}")
      case "${renamed_color}" in
        ?(-)k | ?(-)0 | 30 | 40 | ?(-)rgb:000 | ?(-)black)
          printf '%d,%d'  30 40
          ;;
        ?(-)r | ?(-)1 | 31 | 41 | ?(-)rgb:100 | ?(-)red)
          printf '%d,%d' 31 41
          ;;
        ?(-)g | ?(-)2 | 32 | 42 | ?(-)rgb:010 | ?(-)green)
          printf '%d,%d' 32 42
          ;;
        ?(-)y | ?(-)3 | 33 | 43 | ?(-)rgb:110 | ?(-)yellow)
          printf '%d,%d'  33 43
          ;;
        ?(-)b | ?(-)4 | 34 | 44 | ?(-)rgb:001 | ?(-)blue)
          printf '%d,%d'  34 44
          ;;
        ?(-)m | ?(-)5 | 35 | 45 | ?(-)rgb:101 | ?(-)magenta)
          printf '%d,%d'  35 45
          ;;
        ?(-)c | ?(-)6 | 36 | 46 | ?(-)rgb:011 | ?(-)cyan)
          printf '%d,%d'  36 46
          ;;
        ?(-)w | ?(-)7 | 37 | 47 | ?(-)rgb:111 | ?(-)white)
          printf '%d,%d'  37 47
          ;;
        ## bright colors
        +k | +0 | 90 | 100 | +rgb:000 | +black | gray)
          # bright black
          printf '%d,%d' 90 100
          ;;
        +r | +1 | 91 | 101 | +rgb:100 | +red)
          # bright red
          printf '%d,%d' 91 101
          ;;
        +g | +2 | 92 | 102 | +rgb:010 | +green)
          # bright green
          printf '%d,%d' 92 102
          ;;
        +y | +3 | 93 | 103 | +rgb:110 | +yellow)
          # bright yellow
          printf '%d,%d' 93 103
          ;;
        +b | +4 | 94 | 104 | +rgb:001 | +blue)
          # bright blue
          printf '%d,%d' 94 104
          ;;
        +m | +5 | 95 | 105 | +rgb:101 | +magenta)
          # bright magenta
          printf '%d,%d' 95 105
          ;;
        +c | +6 | 96 | 106 | +rgb:011 | +cyan)
          # bright cyan
          printf '%d,%d' 96 106
          ;;
        +w | +7 | 97 | 107 | +rgb:111 | +white)
          # bright white
          printf '%d,%d' 97 107
          ;;
        '')
          printf '%d,%d' -1 -1
          ;;
        *)
          printf >&2 "\e[31mError unknow color '%s' \e[0m\n" "${color}"
          printf '%d,%d' -2 -2
          ;;
      esac
    }
    __tty_ag_echo_fg_code() {
      local color_code
      color_code=$(__tty_ag_echo_color_code "${1}")
      local -i fg_code="${color_code%,*}"
      echo "${fg_code}"
    }

    __tty_ag_echo_bg_code() {
      local color_code
      color_code=$(__tty_ag_echo_color_code "${1}")
      local -i bg_code="${color_code#*,}"
      echo "${bg_code}"
    }

    __tty_ag_echo_filter_code_seq() {
      local code_seq="${1}"
      for code in ${code_seq}; do
        if [[ "${code}" -le 0 ]]; then continue; fi
        if [[ -z ${code} ]]; then continue; fi
        printf '%d ' "${code}"
      done
    }

    __tty_ag_echo_join_code_seq() {
      local code_seq="${1}"
      local code_str=''
      for code in ${code_seq}; do
        if [[ -n ${code_str} ]]; then
          code_str="${code_str};";
        fi
        code_str="${code_str}${code}"
      done
      printf '%s' "${code_str}"
    }

    __tty_ag_echo_code_str() {
      local fg_name="${1}"
      local bg_name="${2}"
      local te_name_seq="${3}"
      local fg_code
      fg_code=$(__tty_ag_echo_fg_code "${fg_name}")
      local bg_code
      bg_code=$(__tty_ag_echo_bg_code "${bg_name}")
      local te_code_seq
      te_code_seq=$(__tty_ag_echo_te_code_seq "${te_name_seq}")
      local code_seq="${fg_code} ${bg_code} ${te_code_seq}"
      code_seq=$(__tty_ag_echo_filter_code_seq "${code_seq}")
      local code_str
      code_str=$(__tty_ag_echo_join_code_seq "${code_seq}")
      echo "${code_str}"
    }

    __tty_ag_echo_head() {
      local fg_name="${1}"
      local bg_name="${2}"
      local te_name_seq="${3}"
      local seq=''
      seq=$(
        __tty_ag_echo_code_str "${fg_name}" "${bg_name}" "${te_name_seq}"
      )
      local head="\x01\e[${seq}m\x02"
      echo "${head}"
    }

    __tty_ag_echo_tail() {
      local reset_code
      reset_code=$(__tty_ag_echo_te_code reset)
      local tail="\x01\e[${reset_code}m\x02"
      echo "${tail}"
    }

    __tty_ag_echo_main() {
      local options
      local nm='__tty_ag_echo'
      local sh='p:c:b:f:e:x:t:ad'
      local lg='pos:,bg:,fg:,te:,help,auto'
      options=$(getopt -n "${nm}" -o "${sh}" -l "${lg}" -- "${@}")
      eval set -- "${options}"
      local fg_name=""
      local bg_name=""
      local te_name_seq=''
      local text=""
      local detect_colors=false
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
            local arg="${2}"
            if [[ ${arg} =~ [[:punct:]]  ]]; then
              # shellcheck disable=SC2001
              # posix
              arg="$(echo "${arg}" | sed 's/[[:punct:]]/ /')"
              fg_name=$(echo "${arg}"   | cut -d' ' -f1   )
              bg_name=$(echo "${arg}"   | cut -d' ' -f2   )
              te_name_seq=$(echo "${arg}"  | cut -d' ' -f3-  )
            else
              fg_name="${arg:0:1}"
              bg_name="${arg:1:1}"
              te_name_seq="${arg:2}"
              # shellcheck disable=SC2001
              # complex substitution
              # split every char with spaces
              te_name_seq=$(echo "${te_name_seq}" | sed 's/./& /g')

            fi
            fg_name=$(__tty_ag_echo_color_code_case "${fg_name}")
            bg_name=$(__tty_ag_echo_color_code_case "${bg_name}")
            shift 2
            ;;
          -c | -f | --fg)
            fg_name="${2}"
            shift 2
            ;;
          -b | --bg )
            bg_name="${2}"
            shift 2
            ;;
          -e | --te)
            local arg="${2//[[:punct:]]/ }"
            te_name_seq="${te_name_seq} ${arg}"
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
            echo "Unknown parameter '${1}'." >& 0
            shift 1
            ;;
        esac
      done
      text="${text}${*}"


      local head
      head=$(
        __tty_ag_echo_head "${fg_name}" "${bg_name}" "${te_name_seq}"
      )

      local tail
      tail=$(
        __tty_ag_echo_tail "${fg_name}" "${bg_name}" "${te_name_seq}"
      )

      local result
      if ${detect_colors}; then
        if [[ $- =~ i  ]] && [[ -t 1  ]]; then
          result="${head}${text}${tail}"
        else
          result="${text}"
        fi
      else
        result="${head}${text}${tail}"
      fi
      printf '%b\n' "${result}"
    }

    __tty_ag_echo_main "$@"

    unset __tty_ag_echo_all
    unset __tty_ag_echo_color_code_case
    unset __tty_ag_echo_main
    unset __tty_ag_echo_te_code
    unset __tty_ag_echo_bg_code
    unset __tty_ag_echo_fg_code
    unset __tty_ag_echo_usage
}
