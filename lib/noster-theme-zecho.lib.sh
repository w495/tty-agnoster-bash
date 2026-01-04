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

__zecho_lib() {

  __zecho_usage() {
    # shellcheck disable=SC2312
    cat << EOF
Usage: __zecho [OPTIONS] [TEXT]

NAME:
«Colourful Echo» —> «C. Echo» —> «cecho». It sounds like /see‑EK‑oh/
in English. But in Latin it sounds like /tse‑kho/, that is similar to
* German «Zeche» — /tseh‑uhn/ — colliery;
* Russian «Цех»  — /tsekh/    — workshop.
So we use «Z» to represent /ts/-sound.

EXAMPLES:
> __zecho -b -yellow -f -RED -e DEL -t 'Some waring'
It gives you:
$(__zecho -b YELLOW -f RED -e DEL -t 'Some waring')
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

  __zecho_te_code() {
    case "${1}" in
      0 | n | clear |   reset)    __zecho_te_code=0 ;;
      1 | b | bold)               __zecho_te_code=1 ;;
      2 | d | f | dim | faint)    __zecho_te_code=2 ;;
      3 | i | italic)             __zecho_te_code=3 ;;
      4 | u | underline)          __zecho_te_code=4 ;;
      5 | l | blink)              __zecho_te_code=5 ;;
      7 | r | reverse)            __zecho_te_code=7 ;;
      8 | c | conceal)            __zecho_te_code=8 ;;
      9 | s | x | strike | del)   __zecho_te_code=9 ;;
      '')                         __zecho_te_code=-1 ;;
      *)                          __zecho_te_code=-2 ;;
    esac
  }

  __zecho_te_code_seq() {
    te_name_seq="${1}"
    te_sep="${__zecho_TEXT_EFFECT_SEP}"
    te_code_seq=''
    te_name_seq="${te_name_seq}${te_sep}"
    while [ "${te_name_seq#*"${te_sep}"}" != "${te_name_seq}" ]; do
      te_name="${te_name_seq%%"${te_sep}"*}"
      __zecho_te_code "${te_name}"
      te_code="${__zecho_te_code}"
      if [ "${te_code}" != '-1' ] && [ "${te_code}" != '-2' ]; then
        if [ -n "${te_code_seq}" ]; then
          te_code_seq="${te_code_seq}${te_sep}"
        fi
        te_code_seq="${te_code_seq}${te_code}"
      fi
      te_name_seq="${te_name_seq#*"${te_sep}"}"
    done
    __zecho_te_code_seq="${te_code_seq}"
  }

  __zecho_color_code_case() {
    case ${1} in
      [[:lower:]]) __zecho_color_code_case="-${1}" ;;
      [[:upper:]]) __zecho_color_code_case="+${1}" ;;
      *)           __zecho_color_code_case="${1}" ;;
    esac
  }

  __zecho_rename_color() {
    cl="cyan|magenta|yellow|black|red|green|blue|white"
    cl="${cl}|c|m|y|k|r|g|b|w"
    patten="
      s/^((d|dark)(\W|_)?)(${cl})$/-\4/gi;
      s/^((i|l|light|br|bright)(\W|_)?)(${cl})?$/+\4/gi;
      s/^(${cl})((\W|_)?(d|dark))$/-\1/gi;
      s/^(${cl})((\W|_)?(i|l|light|b|br|bright))$/+\1/gi;
      "
    __zecho_rename_color=$(echo "${1}" | sed -re "${patten}")
  }

  __zecho_color_std_name() {
    color=$(awk -vi="${1}" 'BEGIN{$0=X;print tolower(i)}')
    __zecho_rename_color "${color}"
    case "${__zecho_rename_color}" in
      -k | k | -0 | 0 | 30 | 40 | rgb-000 | -black | black)
        __zecho_color_std_name='basic black'
        ;;
      -r | r | -1 | 1 | 31 | 41 | rgb-100 | -red | red)
        __zecho_color_std_name='basic red'
        ;;
      -g | g | -2 | 2 | 32 | 42 | rgb-010 | -green | green)
        __zecho_color_std_name='basic green'
        ;;
      -y | y | -3 | 3 | 33 | 43 | rgb-110 | -yellow | yellow)
        __zecho_color_std_name='basic yellow'
        ;;
      -b | b | -4 | 4 | 34 | 44 | rgb-001 | -blue | blue)
        __zecho_color_std_name='basic blue'
        ;;
      -m | m | -5 | 5 | 35 | 45 | rgb-101 | -magenta | magenta)
        __zecho_color_std_name='basic magenta'
        ;;
      -c | c | -6 | 6 | 36 | 46 | rgb-011 | -cyan | cyan)
        __zecho_color_std_name='basic cyan'
        ;;
      -w | w | -7 | 7 | 37 | 47 | rgb-111 | -white | white)
        __zecho_color_std_name='basic white'
        ;;
      ## bright colors
      +k | +0 | 90 | 100 | rgb+000 | +black | gray)
        __zecho_color_std_name='bright black'
        ;;
      +r | +1 | 91 | 101 | rgb+100 | +red)
        __zecho_color_std_name='bright red'
        ;;
      +g | +2 | 92 | 102 | rgb+010 | +green)
        __zecho_color_std_name='bright green'
        ;;
      +y | +3 | 93 | 103 | rgb+110 | +yellow)
        __zecho_color_std_name='bright yellow'
        ;;
      +b | +4 | 94 | 104 | rgb+001 | +blue)
        __zecho_color_std_name='bright blue'
        ;;
      +m | +5 | 95 | 105 | rgb+101 | +magenta)
        __zecho_color_std_name='bright magenta'
        ;;
      +c | +6 | 96 | 106 | rgb+011 | +cyan)
        __zecho_color_std_name='bright cyan'
        ;;
      +w | +7 | 97 | 107 | rgb+111 | +white)
        __zecho_color_std_name='bright white'
        ;;
      '')
        __zecho_color_std_name='empty color'
        ;;
      *)
        printf >&2 "\e[31mError unknown color '%s' \e[0m\n" "${color}"
        __zecho_color_std_name='unknown color'
        ;;
    esac
  }

  __zecho_color_code_pair() {
    case "${1}" in
      'basic black')    __zecho_color_code_pair='30 40' ;;
      'basic red')      __zecho_color_code_pair='31 41' ;;
      'basic green')    __zecho_color_code_pair='32 42' ;;
      'basic yellow')   __zecho_color_code_pair='33 43' ;;
      'basic blue')     __zecho_color_code_pair='34 44' ;;
      'basic magenta')  __zecho_color_code_pair='35 45' ;;
      'basic cyan')     __zecho_color_code_pair='36 46' ;;
      'basic white')    __zecho_color_code_pair='37 47' ;;
      'bright black')   __zecho_color_code_pair='90 100' ;;
      'bright red')     __zecho_color_code_pair='91 101' ;;
      'bright green')   __zecho_color_code_pair='92 102' ;;
      'bright yellow')  __zecho_color_code_pair='93 103' ;;
      'bright blue')    __zecho_color_code_pair='94 104' ;;
      'bright magenta') __zecho_color_code_pair='95 105' ;;
      'bright cyan')    __zecho_color_code_pair='96 106' ;;
      'bright white')   __zecho_color_code_pair='97 107' ;;
      'empty color')    __zecho_color_code_pair='-1 -1' ;;
      'unknown color')  __zecho_color_code_pair='-2 -2' ;;
      *)                __zecho_color_code_pair='-3 -3'  ;;
    esac
  }

  __zecho_fg_code() {
    __zecho_color_code_pair "${1}"
    __zecho_fg_code="${__zecho_color_code_pair%\ *}"
  }

  __zecho_bg_code() {
    __zecho_color_code_pair "${1}"
    __zecho_bg_code="${__zecho_color_code_pair#*\ }"
  }

  __zecho_join_code_seq() {
    code_seq="${1}"
    ansi_sep="${__zecho_ESC_ANSI_SEP}"
    fmt_sep="${__zecho_FMT_SEP}"

    code_str=''
    code_seq="${code_seq}${fmt_sep}"
    while [ "${code_seq#*"${fmt_sep}"}" != "${code_seq}" ]; do
      code="${code_seq%%"${fmt_sep}"*}"
      if [ "${code}" != '-1' ] && [ "${code}" != '-2' ]; then
        if [ -n "${code_str}" ]; then
          code_str="${code_str}${ansi_sep}"
        fi
        code_str="${code_str}${code}"
      fi
      code_seq="${code_seq#*"${fmt_sep}"}"
    done
    __zecho_join_code_seq="${code_str}"
  }

  __zecho_code_str() {
    fg_name="${1}"
    bg_name="${2}"
    te_name_seq="${3}"
    fmt_sep="${__zecho_FMT_SEP}"

    if [ -n "${fg_name}" ]; then
      __zecho_color_std_name "${fg_name}"
      __zecho_fg_code "${__zecho_color_std_name}"
      code_seq="${__zecho_fg_code}"
    fi
    if [ -n "${bg_name}" ]; then
      __zecho_color_std_name "${bg_name}"
      __zecho_bg_code "${__zecho_color_std_name}"
      code_seq="${code_seq}${fmt_sep}${__zecho_fg_code}"
    fi
    if [ -n "${te_name_seq}" ]; then
      __zecho_te_code_seq "${te_name_seq}"
      code_seq="${code_seq}${fmt_sep}${__zecho_te_code_seq}"
    fi
    __zecho_join_code_seq "${code_seq}"
    __zecho_code_str="${__zecho_join_code_seq}"
  }

  __zecho_head() {
    __zecho_code_str "${1}" "${2}" "${3}"

    # COMPATIBILITY NOTE:
    # ---------------------------------------------------------------
    #   bash/zsh:
    #     ESC = \x1b = \e = \E
    #   ksh93:
    #     ESC = \0033
    # ---------------------------------------------------------------

    __zecho_head="\0001\0033[${__zecho_code_str}m\0002"
    # \[ = \1 = \x01 = \0001, do not use \001! Octal format is \0nnn.
    # \] = \2 = \x02 = \0002, do not use \002! Octal format is \0nnn.
  }

  __zecho_tail() {
    __zecho_te_code reset
    # COMPATIBILITY NOTE:
    # ---------------------------------------------------------------
    #   bash/zsh:
    #     ESC = \x1b = \e = \E
    #   ksh93:
    #     ESC = \0033
    # ---------------------------------------------------------------

    __zecho_tail="\0001\0033[${__zecho_te_code}m\0002"
    # \[ = \1 = \x01 = \0001, do not use \001! Octal format is \0nnn.
    # \] = \2 = \x02 = \0002, do not use \002! Octal format is \0nnn.s
  }

  __zecho_parse_te_name_seq() {
    te_name_seq="${1}"
    arg="${2}"
    te_sep="${__zecho_TEXT_EFFECT_SEP}"

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

    # shellcheck disable=SC2001
    std_arg=$(echo "${arg}" | sed "s/[[:punct:]]/${te_sep}/")

    if [ -n "${te_name_seq}" ]; then
      te_name_seq="${te_name_seq}${te_sep}"
    fi
    te_name_seq="${te_name_seq}${std_arg}"
    echo "${te_name_seq}"
  }

  __zecho_parse_positional() {
    pos_sep="${1}"
    arg="${2}"
    te_sep="${__zecho_TEXT_EFFECT_SEP}"
    case "${arg}" in
      *[[:punct:]]*)
        local_sep="${pos_sep}"
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
        std_arg=$(echo "${arg}" | sed "s/[[:punct:]]/${local_sep}/g")
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
        #   bash=5.1.16
        #   complex substitution:
        #   split every char with ${fmt_sep}
        te_name_seq=$(echo "${te_name_seq}" | sed "s/./&${te_sep}/g")
        ;;
    esac
    __zecho_color_code_case "${fg_name}"
    fg_name="${__zecho_color_code_case}"
    __zecho_color_code_case "${bg_name}"
    bg_name="${__zecho_color_code_case}"

    _P_="${pos_sep}"
    pos_result="${fg_name}${_P_}${bg_name}${_P_}${te_name_seq}"
    echo "${pos_result}"
  }

  __zecho_output_stream_fd() {
    stream_name="${1}"
    case "${stream_name}" in
      1 | out | stdout) __zecho_output_stream_fd=1 ;;
      2 | err | stderr) __zecho_output_stream_fd=2 ;;
      *)                __zecho_output_stream_fd=1 ;;
    esac
  }

  __zecho_apply() {
    __zecho_head "${1}" "${2}" "${3}"
    __zecho_tail "${1}" "${2}" "${3}"
    __zecho_apply="${__zecho_head}${4}${__zecho_tail}"
  }

  __zecho() {
    nm='__zecho'
    so='' # — short options
    ## MAIN SHORT OPTIONS
    so="${so}f:" # — foreground
    so="${so}b:" # — background
    so="${so}t:" # — text effect or emphasis
    so="${so}p:" # — positional form
    so="${so}h" # — help
    so="${so}v" # — version

    ## OUTPUT STREAM SHORT OPTIONS
    so="${so}s:12" # — stream

    ## ECHO COMPATIBILITY SHORT OPTIONS:
    so="${so}n" # — do not output the trailing newline.
    so="${so}e" # — enable interpretation of backslash escapes.
    so="${so}E" # — disable interpretation of backslash escapes.

    ## COREUTILS COMPATIBILITY SHORT OPTIONS:
    so="${so}c::a"
    # -c=[always|never|auto] like with diff, ls, grep and others.
    # Plain -c means -c='auto'. Another values works as for -f.
    # -a means -c='auto'.

    long_options=""
    # MAIN LONG OPTIONS
    long_options="${long_options}fg:,foreground:,foreground-color:,"
    long_options="${long_options}bg:,background:,background-color:,"
    long_options="${long_options}te:,text-effect:,em:,emphasis:,"
    long_options="${long_options}ps:,pos:,positional:,"
    long_options="${long_options}help,"
    long_options="${long_options}version,"

    ## OUTPUT STREAM LONG OPTIONS
    long_options="${long_options}st:,str:,stream:,"
    long_options="${long_options}out,err,stdout,stderr,"

    ## ECHO COMPATIBILITY LONG OPTIONS:
    long_options="${long_options}nn,nonewline,"
    long_options="${long_options}esc,escapes"
    long_options="${long_options}ne,nesc,noesc,noescapes"

    ## COREUTILS COMPATIBILITY LONG OPTIONS:
    long_options="${long_options}color::,auto,auto-color"
    # --color=[always|never|auto] like with diff, ls, grep.
    # Plain --color means --color='auto'. Another values
    # e.g (NOT 'always|never|auto)  works as for --foreground.
    # --auto and --auto-color means --color='auto'.

    options=$(getopt -n "${nm}" -o "${so}" -l "${long_options}" -- "${@}")
    eval set -- "${options}"
    fg_name=""
    bg_name=""
    te_name_seq=''
    text=""
    when_use_color='always'
    use_newline=true
    use_initial_escapes=false
    output_stream_name='stdin'

    __zecho_FMT_SEP=':'
    __zecho_TEXT_EFFECT_SEP=':'
    __zecho_POS_SEP=':'
    __zecho_ESC_ANSI_SEP=';'

    while [ -n "${options}" ]; do
      case ${1} in
        # MAIN OPTIONS
        -f | --fg | --foreground | --foreground-color)
          fg_name="${2}"
          shift 2
          ;;
        -b | --bg | --background | --background-color)
          bg_name="${2}"
          shift 2
          ;;
        -t | --te | --text-effect | --em | --emph | --emphasis)
          te_name_seq=$(
            __zecho_parse_te_name_seq "${te_name_seq}" "${2}"
          )
          shift 2
          ;;
        -p | --ps | --pos | positional)
          shift 2
          ;;
        -h | --help)
          __zecho_usage __zecho
          shift 1
          ;;
        -v | --version)
          printf '0.1767469499'
          shift 1
          ;;
        ## OUTPUT STREAM OPTIONS
        -s | --st | --str | --stream)
          te_name_seq=$(
            __zecho_parse_te_name_seq "${te_name_seq}" "${2}"
          )
          shift 2
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
            always | never | auto) when_use_color="${arg}" ;;
            *)          fg_name="${arg}" ;;
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

    ## OUTPUT STREAM OPTIONS
    __zecho_output_stream_fd "${output_stream_name}"

    # COREUTILS COMPATIBILITY
    output_type='file'
    if [ -t "${__zecho_output_stream_fd}" ]; then
      output_type='stream'
    fi
    case "${when_use_color}_${output_type}" in
      never*)   use_colors=false ;;
      always*)  use_colors=true ;;
      _stream)  use_colors=true ;;
      _file)    use_colors=false ;;
      *)        use_colors=true   ;;
    esac
    if ${use_colors}; then
      __zecho_apply "${fg_name}" "${bg_name}" "${te_name_seq}" "${text}"
      result="${__zecho_apply}"
    else
      result="${text}"
    fi

    printf '%b%b' "${result}" "${newline}" >&"${__zecho_output_stream_fd}"
  }
}

__zecho_lib
__zecho "${*}"
