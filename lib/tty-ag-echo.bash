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

    __tty_ag_echo_all() (
      local -l set="${1}"
      local fun="${2}"
      for en in ${set}; do
        res=$(eval "${fun}" "${en}")
        echo "${res}"
      done
    )

    __tty_ag_echo_text_effect() {
      local -l effect="${1}"
      case "${effect}" in
        0 | n | clear | reset)
          echo 0
          ;;
        1 | b | bold)
          echo 1
          ;;
        2 | d | f | dim | faint)
          echo 2
          ;;
        3 | i | italic)
          echo 3
          ;;
        4 | u | underline)
          echo 4
          ;;
        5 | l | blink )
          echo 5
          ;;
        7 | r | reverse)
          echo 7
          ;;
        8 | c | conceal)
          echo 8
          ;;
        9 | s | x | Strikethrough | strikeout | del)
          echo 9
          ;;
        *)
          echo ''
          ;;
      esac
    }

    __tty_ag_echo_color_case() (
      case ${1} in
        ([[:lower:]]) echo "-${1}";;
        ([[:upper:]]) echo "+${1}";;
        (*) echo "${1}";;
      esac
    )

    __tty_ag_echo_rename_color() {
      local -l color="${1}"
      local -l cl=''
      cl="cyan|magenta|yellow|black|red|green|blue|white"
      cl="${cl}|c|m|y|k|r|g|b|w"
      patten="
          s/^((d|dark)(\W|_)?)(${cl})$/-\4/gi;
          s/^((b|bright)(\W|_)?)(${cl})?$/+\4/gi;
          s/^((l|light)(\W|_)?)(${cl})?$/+\4/gi;
          s/^(${cl})((\W|_)?(d|dark))$/-\1/gi;
          s/^(${cl})((\W|_)?(b|bright))$/+\1/gi;
          s/^(${cl})((\W|_)?(l|light))$/+\1/gi;
        "
      echo "${color}" | sed -re "${patten}"
    }

    __tty_ag_echo_color() {
      local -l color="${1}"
      color=$(__tty_ag_echo_rename_color "${color}")
      case "${color}" in
        -k | k | -0 | 0 | 30 | 40 | -000 | -black | black)
          echo 30:40
          ;;
        -r | r | -1 | 1 | 31 | 41 | -100 | -red | red)
          echo 31:41
          ;;
        -g | g | -2 | 2 | 32 | 42 | -010 | -green | green)
          echo 32:42
          ;;
        -y | y | -3 | 3 | 33 | 43 | -110 | -yellow | yellow)
          echo 33:43
          ;;
        -b | b | -4 | 4 | 34 | 44 | -001 | -blue | blue)
          echo 34:44
          ;;
        -m | m | -5 | 5 | 35 | 45 | -101 | -magenta | magenta)
          echo 35:45
          ;;
        -c | c | -6 | 6 | 36 | 46 | -011 | -cyan | cyan )
          echo 36:46
          ;;
        -w | w | -7 | 7 | 37 | 47 | -111 | -white | white)
          echo 37:47
          ;;
        ## bright colors
        +k | +0 | 90 | +black | gray)
          # bright black
          echo 90:100
          ;;
        +r | +1 | 91 | +red)
          # bright red
          echo 91:101
          ;;
        +g | +2 | 92 | +green)
          # bright green
          echo 92:102
          ;;
        +y | +3 | 93 | +yellow)
          # bright yellow
          echo 93:103
          ;;
        +b | +4 | 94 | +blue)
          # bright blue
          echo 94:104
          ;;
        +m | +5 | 95 | +magenta)
          # bright magenta
          echo 95:105
          ;;
        +c | +6 | 96 | +cyan)
          # bright cyan
          echo 96:106
          ;;
        +w | +7 | 97 | +white)
          # bright white
          echo 97:107
          ;;
        *)
          echo "${color}:${color}"
          ;;
      esac
    }
    __tty_ag_echo_fg() {
      local -l color="${1}"
      color=$(__tty_ag_echo_color "${1}")
      color="${color%:*}"
      echo "${color}"
    }

    __tty_ag_echo_bg() {
      local -l color="${1}"
      color=$(__tty_ag_echo_color "${1}")
      color="${color#*:}"
      echo "${color}"
    }

    __tty_ag_echo_iter_codes() {
      local fg_code="${1}"
      local bg_code="${2}"
      local ef_codes="${3}"
      local seq=''
      for code in "${fg_code}" "${bg_code}" ${ef_codes}; do
        if [[ -z ${code} ]]; then continue; fi
        if [[ -n ${seq} ]]; then seq="${seq};"; fi
        seq="${seq}${code}"
      done
      echo "${seq}"
    }

    __tty_ag_echo_codes() {
      local fg_name="${1}"
      local bg_name="${1}"
      local te_names="${2}"
      local fg_code
      local bg_code
      local ef_codes
      fg_code=$(__tty_ag_echo_fg "${fg_name}")
      bg_code=$(__tty_ag_echo_bg "${bg_name}")
      ef_codes=$(
        __tty_ag_echo_all "${te_names}" __tty_ag_echo_text_effect
      )
      local seq=''
      seq=$(
        __tty_ag_echo_iter_codes "${fg_code}" "${bg_code}" "${ef_codes}"
      )
    }

    __tty_ag_echo_head() {
      local fg_name="${1}"
      local bg_name="${1}"
      local te_names="${2}"
      local seq=''
      seq=$(
        __tty_ag_echo_codes "${fg_name}" "${bg_name}" "${te_names}"
      )
      local head="\x01\e[${seq}m\x02"
      echo "${head}"
    }

    __tty_ag_echo_tail() {
      local reset_code
      reset_code=$(__tty_ag_echo_text_effect reset)
      local tail="\x01\e[${reset_code}m\x02"
      echo "${tail}"
    }

    __tty_ag_echo_main() {
      local options
      local nm='__tty_ag_echo'
      local sh='p:c:b:f:e:x:t:a'
      local lg='pos:,bg:,fg:,te:,help,auto'
      options=$(getopt -n "${nm}" -o "${sh}" -l "${lg}" -- "${@}")
      eval set -- "${options}"
      local fg_name=""
      local bg_name=""
      local te_names=''
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
              arg="${arg//[[:punct:]]/ }"
              fg_name=$(echo "${arg}"   | cut -d' ' -f1   )
              bg_name=$(echo "${arg}"   | cut -d' ' -f2   )
              te_names=$(echo "${arg}"  | cut -d' ' -f3-  )
            else
              fg_name="${arg:0:1}"
              bg_name="${arg:1:1}"
              te_names="${arg:2}"
              # shellcheck disable=SC2001
              te_names=$(echo "${te_names}" | sed 's/./& /g')
            fi
            fg_name=$(__tty_ag_echo_color_case "${fg_name}")
            bg_name=$(__tty_ag_echo_color_case "${bg_name}")
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
            te_names="${te_names} ${arg}"
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
        __tty_ag_echo_head "${fg_name}" "${bg_name}" "${te_names}"
      )

      local tail
      tail=$(
        __tty_ag_echo_tail "${fg_name}" "${bg_name}" "${te_names}"
      )

      local result
      if ${detect_colors}; then
        if [[ $- =~ i  ]] && [[ -t 1  ]]; then
          result="${head}${text}${tail}"
        esle
          result="${text}"
        fi
      else
        result="${head}${text}${tail}"
      fi
      echo "${result}"
    }


    __tty_ag_echo_main "$@"

    unset __tty_ag_echo_all
    unset __tty_ag_echo_color_case
    unset __tty_ag_echo_main
    unset __tty_ag_echo_text_effect
    unset __tty_ag_echo_bg
    unset __tty_ag_echo_fg
    unset __tty_ag_echo_usage
}
