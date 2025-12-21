#!/usr/bin/env bash
# shellcheck enable=all
# shfmt -ci -i 2 -sr -s -bn -ln posix -d

__tty_ag_format() {
  (
    __tty_ag_format_usage() {
      # shellcheck disable=SC2312
      echo "
Usage: __tty_ag_format [OPTIONS] [TEXT]
EXAMPLES:
  > __tty_ag_format -b -yellow -f -RED -e DEL -t 'Some waring'
  It gives you:
    $(__tty_ag_format -b YELLOW -f RED -e DEL -t 'Some waring')
OPTIONS:
  -b — for background color in a lower or an UPPER case:
    Dark CMYK
      -c | c | dc | -6 | 6 | 36 | -cyan | cyan  — $($1 -b cyan cyan);
      -magenta  — $($1 -b magenta magenta);
      -yellow   — $($1 -b yellow yellow);
      -black    — $($1 -b black black);
    Dark RGB
      -red      — $($1 -b red red);
      -green    — $($1 -b green green);
      -blue     — $($1 -b blue blue);
      -white    — $($1 -b white white);
    Bright CMYK
      +cyan     — $($1 -b cyan cyan);
      +magenta  — $($1 -b magenta magenta);
      +yellow   — $($1 -b yellow yellow);
      +black    — $($1 -b black black);
    Bright RGB
      +red      — $($1 -b red red);
      +green    — $($1 -b green green);
      +blue     — $($1 -b blue blue);
      +white    — $($1 -b white white);
    Any other interprets as empty color.

    * any other interprets as empty color.

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
"
    }
    __tty_ag_format_main() {
      local options
      local nm='__tty_ag_format'
      local sh='p:c:b:f:e:x:t:h'
      local lg='pos:,bg:,fg:,te:,help'
      options=$(getopt -n "${nm}" -o "${sh}" -l "${lg}" -- "${@}")
      eval set -- "${options}"
      local fg_name=""
      local bg_name=""
      local te_names=''
      local text=""
      while [[ -n ${options} ]]; do
        case ${1} in
          -h)
            __tty_ag_format_usage __tty_ag_format
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
            fg_name=$(__tty_ag_format_color_case "${fg_name}")
            bg_name=$(__tty_ag_format_color_case "${bg_name}")
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
      local fg_code
      local bg_code
      local ef_codes
      fg_code=$(__tty_ag_format_fg_color "${fg_name}")
      bg_code=$(__tty_ag_format_bg_color "${bg_name}")
      ef_codes=$(
        __tty_ag_format_all "${te_names}" __tty_ag_format_text_effect
      )
      reset_code=$(__tty_ag_format_text_effect reset)
      local seq=''
      for code in "${fg_code}" "${bg_code}" ${ef_codes}; do
        if [[ -z ${code} ]]; then continue; fi
        if [[ -n ${seq} ]]; then seq="${seq};"; fi
        seq="${seq}${code}"
      done
      local wrap=false
      local head="\e[${seq}m"
      local tail="\e[${reset_code}m"
      if ${wrap}; then
        head="\[${head}\]"
        tail="\[${tail}\]"
      fi
      echo -e "${head}${text}${tail}"
    }

    __tty_ag_format_color_case() (
      case ${1} in
        ([[:lower:]]) echo "-${1}";;
        ([[:upper:]]) echo "+${1}";;
        (*) echo "${1}";;
      esac
    )

    __tty_ag_format_all() (
      local -l set="${1}"
      local fun="${2}"
      for en in ${set}; do
        res=$(eval "${fun}" "${en}")
        echo "${res}"
      done
    )

    __tty_ag_format_text_effect() {
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

    __tty_ag_format_fg_color() {
      local -l color="${1}"
      color=$(__tty_ag_format_rename_color "${color}")
      case "${color}" in
        -k | k | dk | -0 | 0 | 30 | -000 | -black | black)
          echo 30
          ;;
        -r | r | dr | -1 | 1 | 31 | -100 | -red | red)
          echo 31
          ;;
        -g | g | dg | -2 | 2 | 32 | -010 | -green | green)
          echo 32
          ;;
        -y | y | dy | -3 | 3 | 33 | -110 | -yellow | yellow)
          echo 33
          ;;
        -b | b | db | -4 | 4 | 34 | -001 | -blue | blue)
          echo 34
          ;;
        -m | m | dm | -5 | 5 | 35 | -101 | -magenta | magenta)
          echo 35
          ;;
        -c | c | dc | -6 | 6 | 36 | -011 | -cyan | cyan )
          echo 36
          ;;
        -w | w | dw | -7 | 7 | 37 | -111 | -white | white)
          echo 37
          ;;
        ## bright colors
        +k | bk | lk | +0 | 90 | +black | gray)
          # bright black
          echo 90
          ;;
        +r | br | lr | +1 | 91 | +red)
          # bright red
          echo 91
          ;;
        +g | bg | lg | +2 | 92 | +green)
          # bright green
          echo 92
          ;;
        +y | by | ly | +3 | 93 | +yellow)
          # bright yellow
          echo 93
          ;;
        +b | bb | lb | +4 | 94 | +blue)
          # bright blue
          echo 94
          ;;
        +m | bm | lm | +5 | 95 | +magenta)
          # bright magenta
          echo 95
          ;;
        +c | bc | lc | +6 | 96 | +cyan)
          # bright cyan
          echo 96
          ;;
        +w | bw | lw | +7 | 97 | +white)
          # bright white
          echo 97
          ;;
        *)
          echo ''
          ;;
      esac
    }

    __tty_ag_format_bg_color() {
      local -l color="${1}"
      color=$(__tty_ag_format_rename_color "${color}")
      case "${color}" in
        -k | k | dk | -0 | 0 | 40 | -black | black)
          echo 40
          ;;
        -r | r | dr | -1 | 1 | 41 |  -red | red)
          echo 41
          ;;
        -g | g | dg | -2 | 2 | 42 | -green | green)
          echo 42
          ;;
        -y | y | dy | -3 | 3 | 43 | -yellow | yellow)
          echo 43
          ;;
        -b | b | db | -4 | 4 | 44 | -blue | blue)
          echo 44
          ;;
        -m | m | dm | -5 | 5 | 45 |  -magenta | magenta)
          echo 45
          ;;
        -c | c | dc | -6 | 6 | 46 | -cyan | cyan )
          echo 46
          ;;
        -w | w | dw | -7 | 7 | 47 | -white | white)
          echo 47
          ;;
        ## bright colors
        +k | bk | lk | +0 | 100 | +black | gray)
          # bright black
          echo 100
          ;;
        +r | br | lr | +1 | 101 | +red)
          # bright red
          echo 101
          ;;
        +g | bg | lg | +2 | 102 | +green)
          # bright green
          echo 102
          ;;
        +y | by | ly | +3 | 103 | +yellow)
          # bright yellow
          echo 103
          ;;
        +b | bb | lb | +4 | 104 | +blue)
          # bright blue
          echo 104
          ;;
        +m | bm | lm | +5 | 105 | +magenta)
          # bright magenta
          echo 105
          ;;
        +c | bc | lc | +6 | 106 | +cyan)
          # bright cyan
          echo 106
          ;;
        +w | bw | lw | +7 | 107 | +white)
          # bright white
          echo 107
          ;;
        *)
          echo ''
          ;;
      esac
    }

    __tty_ag_format_rename_color() {
      local -l color="${1}"
      cl='cyan|magenta|yellow|black|red|green|blue|white'
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

    local -f __tty_ag_format_main > /dev/null
    local -f __tty_ag_format_text_effect > /dev/null
    local -f __tty_ag_format_bg_color > /dev/null
    local -f __tty_ag_format_fg_color > /dev/null
    local -f __tty_ag_format_usage > /dev/null

    __tty_ag_format_main "$@"
)
}
