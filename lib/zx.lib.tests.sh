#!/usr/bin/env sh
# shellcheck enable=all
#     shfmt -ci -i 2 -sr -s -bn -kp -ln posix -d

this_full_path="/$(lsof -p $$ | tail -n1 | cut -d '/' -f2-)"
path=$(dirname "${this_full_path}")

. "${path}/zx.lib.posix.sh"

N_CHECKS=0
N_OKS=0
N_FAILS=0

check() {
  pat="${1}"
  shift
  tval="$(__zx "${@}")"
  N_CHECKS=$((N_CHECKS + 1))
  if test "${tval}" = "$(printf '%b' "${pat}")"; then
    printf '\tOk\t%+40b %-80s\n'  "${pat}" "zx ${*}"
    N_OKS=$((N_OKS + 1))
  else
    printf '\tFail\t%s:\tzx%s\t%b\n'  "${pat}" "${*}" "${tval}"
    N_FAILS=$((N_FAILS + 1))
  fi
}

color_tests() {
  echo 'FOREGROUND FORMS'

  check '\0001\0033[31m\0002:r|g|b|w|c|m|y|k:\0001\0033[0m\0002' \
    -fr ':r|g|b|w|c|m|y|k:'
  check '\0001\0033[36m\0002:r|g|b|w|c|m|y|k:\0001\0033[0m\0002' \
    -f c ':r|g|b|w|c|m|y|k:'
  check '\0001\0033[32m\0002:red|blue|green|white|:\0001\0033[0m\0002' \
    --fg green ':red|blue|green|white|:'
  check '\0001\0033[35m\0002:|cyan|magenta|yellow|black:\0001\0033[0m\0002' \
    --foreground magenta ':|cyan|magenta|yellow|black:'

  echo 'BACKGROUND FORMS'

  check '\0001\0033[42m\0002:r|g|b|w|c|m|y|k:\0001\0033[0m\0002' \
    -bg ':r|g|b|w|c|m|y|k:'
  check '\0001\0033[43m\0002:r|g|b|w|c|m|y|k:\0001\0033[0m\0002' \
    -b y ':r|g|b|w|c|m|y|k:'
  check '\0001\0033[44m\0002:red|blue|green|white|:\0001\0033[0m\0002' \
    --bg blue ':red|blue|green|white|:'
  check '\0001\0033[46m\0002:|cyan|magenta|yellow|black:\0001\0033[0m\0002' \
    --background cyan ':|cyan|magenta|yellow|black:'

  echo 'COLOR FORMS +/-'
  check '\0001\0033[36m\0002:dark color letter:\0001\0033[0m\0002' \
    -fc- ':dark color letter:'
  check '\0001\0033[96m\0002:bright color letter:\0001\0033[0m\0002' \
    -fc+ ':bright color letter:'
  check '\0001\0033[36m\0002:dark color letter:\0001\0033[0m\0002' \
    -f-c ':dark color letter:'
  check '\0001\0033[96m\0002:bright color letter:\0001\0033[0m\0002' \
    -f+c ':bright color letter:'
  check '\0001\0033[32m\0002:dark color letter:\0001\0033[0m\0002' \
    --fg g ':dark color letter:'
  check '\0001\0033[32m\0002:dark color minus:\0001\0033[0m\0002' \
    --fg -g ':dark color minus:'
  check '\0001\0033[92m\0002:bright color plus:\0001\0033[0m\0002' \
    --fg +g ':bright color plus:'
  check '\0001\0033[31m\0002:dark color minus:\0001\0033[0m\0002' \
    -f-red ':dark color minus:'
  check '\0001\0033[91m\0002:bright color plus:\0001\0033[0m\0002' \
    -f+red ':bright color plus:'


  echo 'COLOR SHORT FORMS'
  check '\0001\0033[35m\0002:dark color letters:\0001\0033[0m\0002' \
    --fg dm ':dark color letters:'
  check '\0001\0033[35m\0002:dark color letters:\0001\0033[0m\0002' \
    --fg md ':dark color letters:'
  check '\0001\0033[95m\0002:light color letters:\0001\0033[0m\0002' \
    --fg lm ':light color letters:'
  check '\0001\0033[95m\0002:light color letters:\0001\0033[0m\0002' \
    --fg ml ':light color letters:'
  check '\0001\0033[90m\0002:light color letters:\0001\0033[0m\0002' \
    --fg ik ':light color letters:'
  check '\0001\0033[90m\0002:light color letters:\0001\0033[0m\0002' \
    --fg ki ':light color letters:'

  check '\0001\0033[31m\0002:DARK COLOR LETTER:\0001\0033[0m\0002' \
    --fg R ':DARK COLOR LETTER:'
  check '\0001\0033[31m\0002:DARK COLOR LETTERS:\0001\0033[0m\0002' \
    --fg DR ':DARK COLOR LETTERS:'
  check '\0001\0033[31m\0002:DARK COLOR LETTERS:\0001\0033[0m\0002' \
    --fg RD ':DARK COLOR LETTERS:'
  check '\0001\0033[31m\0002:lowercase color:\0001\0033[0m\0002' \
    --fg red ':lowercase color:'
  check '\0001\0033[31m\0002:UPPERCASE COLOR:\0001\0033[0m\0002' \
    --fg RED ':UPPERCASE COLOR:'

  echo 'FOREGROUND DARK COLORS'
  check '\0001\0033[30m\0002:basic black fg:\0001\0033[0m\0002' \
    --fg ba-black ':basic black fg:'
  check '\0001\0033[31m\0002:basic red fg:\0001\0033[0m\0002' \
    --fg basic-red ':basic red fg:'
  check '\0001\0033[32m\0002:basic green fg:\0001\0033[0m\0002' \
    --fg green-basic ':basic green fg:'
  check '\0001\0033[33m\0002:basic yellow fg:\0001\0033[0m\0002' \
    --fg dark-yellow ':basic yellow fg:'
  check '\0001\0033[34m\0002:basic blue fg:\0001\0033[0m\0002' \
    --fg blue-dark ':basic blue fg:'
  check '\0001\0033[35m\0002:basic magenta fg:\0001\0033[0m\0002' \
    --fg d+magenta ':basic magenta fg:'
  check '\0001\0033[36m\0002:basic cyan fg:\0001\0033[0m\0002' \
    --fg cyan-d ':basic cyan fg:'
  check '\0001\0033[37m\0002:basic white fg:\0001\0033[0m\0002' \
    --fg bawhite ':basic white fg:'

  echo 'FOREGROUND BRIGHT COLORS'
  check '\0001\0033[90m\0002:bright black fg:\0001\0033[0m\0002' \
    --fg bright+black ':bright black fg:'
  check '\0001\0033[91m\0002:bright red fg:\0001\0033[0m\0002' \
    --fg brightred ':bright red fg:'
  check '\0001\0033[92m\0002:bright green fg:\0001\0033[0m\0002' \
    --fg LightGreen ':bright green fg:'
  check '\0001\0033[93m\0002:bright yellow fg:\0001\0033[0m\0002' \
    --fg yellow_bright ':bright yellow fg:'
  check '\0001\0033[94m\0002:bright blue fg:\0001\0033[0m\0002' \
    --fg brblue ':bright blue fg:'
  check '\0001\0033[95m\0002:bright magenta fg:\0001\0033[0m\0002' \
    --fg imagenta ':bright magenta fg:'
  check '\0001\0033[96m\0002:bright cyan fg:\0001\0033[0m\0002' \
    --fg lCyan ':bright cyan fg:'
  check '\0001\0033[97m\0002:bright white fg:\0001\0033[0m\0002' \
    --fg iwhite ':bright white fg:'

  echo 'BACKGROUND DARK COLORS'
  check '\0001\0033[40m\0002:basic black bg:\0001\0033[0m\0002' \
    --bg basic-black ':basic black bg:'
  check '\0001\0033[41m\0002:basic red bg:\0001\0033[0m\0002' \
    --bg basic-red ':basic red bg:'
  check '\0001\0033[42m\0002:basic green bg:\0001\0033[0m\0002' \
    --bg basic-green ':basic green bg:'
  check '\0001\0033[43m\0002:basic yellow bg:\0001\0033[0m\0002' \
    --bg basic-yellow ':basic yellow bg:'
  check '\0001\0033[44m\0002:basic blue bg:\0001\0033[0m\0002' \
    --bg basic-blue ':basic blue bg:'
  check '\0001\0033[45m\0002:basic magenta bg:\0001\0033[0m\0002' \
    --bg basic-magenta ':basic magenta bg:'
  check '\0001\0033[46m\0002:basic cyan bg:\0001\0033[0m\0002' \
    --bg basic-cyan ':basic cyan bg:'
  check '\0001\0033[47m\0002:basic white bg:\0001\0033[0m\0002' \
    --bg basic-white ':basic white bg:'

  echo 'BACKGROUND BRIGHT COLORS:'
  check '\0001\0033[100m\0002:bright black bg:\0001\0033[0m\0002' \
    --bg bright-black ':bright black bg:'
  check '\0001\0033[101m\0002:bright red bg:\0001\0033[0m\0002' \
    --bg bright-red ':bright red bg:'
  check '\0001\0033[102m\0002:bright green bg:\0001\0033[0m\0002' \
    --bg bright-green ':bright green bg:'
  check '\0001\0033[103m\0002:bright yellow bg:\0001\0033[0m\0002' \
    --bg bright-yellow ':bright yellow bg:'
  check '\0001\0033[104m\0002:bright blue bg:\0001\0033[0m\0002' \
    --bg bright-blue ':bright blue bg:'
  check '\0001\0033[105m\0002:bright magenta bg:\0001\0033[0m\0002' \
    --bg bright-magenta ':bright magenta bg:'
  check '\0001\0033[106m\0002:bright cyan bg:\0001\0033[0m\0002' \
    --bg bright-cyan ':bright cyan bg:'
  check '\0001\0033[107m\0002:bright white bg:\0001\0033[0m\0002' \
    --bg bright-white ':bright white bg:'

  echo 'RGB FORM COLORS'
  check '\0001\0033[30m\0002:-black fg:\0001\0033[0m\0002' \
    --fg rgb-000 ':-black fg:'
  check '\0001\0033[90m\0002:+black fg:\0001\0033[0m\0002' \
    --fg rgb+000 ':+black fg:'
  check '\0001\0033[31m\0002:-red fg:\0001\0033[0m\0002' \
    --fg rgb-100 ':-red fg:'
  check '\0001\0033[91m\0002:+red fg:\0001\0033[0m\0002' \
    --fg rgb+100 ':+red fg:'
  check '\0001\0033[32m\0002:-green fg:\0001\0033[0m\0002' \
    --fg rgb-010 ':-green fg:'
  check '\0001\0033[92m\0002:+green fg:\0001\0033[0m\0002' \
    --fg rgb+010 ':+green fg:'
  check '\0001\0033[33m\0002:-yellow fg:\0001\0033[0m\0002' \
    --fg rgb-110 ':-yellow fg:'
  check '\0001\0033[93m\0002:+yellow fg:\0001\0033[0m\0002' \
    --fg rgb+110 ':+yellow fg:'
  check '\0001\0033[34m\0002:-blue fg:\0001\0033[0m\0002' \
    --fg rgb-001 ':-blue fg:'
  check '\0001\0033[94m\0002:+blue fg:\0001\0033[0m\0002' \
    --fg rgb+001 ':+blue fg:'
  check '\0001\0033[35m\0002:-magenta fg:\0001\0033[0m\0002' \
    --fg rgb-101 ':-magenta fg:'
  check '\0001\0033[95m\0002:+magenta fg:\0001\0033[0m\0002' \
    --fg rgb+101 ':+magenta fg:'
  check '\0001\0033[36m\0002:-cyan fg:\0001\0033[0m\0002' \
    --fg rgb-011 ':-cyan fg:'
  check '\0001\0033[96m\0002:+cyan fg:\0001\0033[0m\0002' \
    --fg rgb+011 ':+cyan fg:'
  check '\0001\0033[37m\0002:-white fg:\0001\0033[0m\0002' \
    --fg rgb-111 ':-white fg:'
  check '\0001\0033[97m\0002:+white fg:\0001\0033[0m\0002' \
    --fg rgb+111 ':+white fg:'

    echo 'NUMBER FORM COLORS'
    check '\0001\0033[30;100m\0002:black -fg+bg:\0001\0033[0m\0002' \
      -f-0 -b+0 ':black -fg+bg:'
    check '\0001\0033[90;40m\0002:black +fg-bg:\0001\0033[0m\0002' \
      -f+0 -b-0 ':black +fg-bg:'
    check '\0001\0033[31;101m\0002:red -fg+bg:\0001\0033[0m\0002' \
      -f-1 -b+1 ':red -fg+bg:'
    check '\0001\0033[91;41m\0002:red +fg-bg:\0001\0033[0m\0002' \
      -f+1 -b-1 ':red +fg-bg:'
    check '\0001\0033[32;102m\0002:green -fg+bg:\0001\0033[0m\0002' \
      -f-2 -b+2 ':green -fg+bg:'
    check '\0001\0033[92;42m\0002:green -fg+bg:\0001\0033[0m\0002' \
      -f+2 -b-2 ':green -fg+bg:'
    check '\0001\0033[33;103m\0002:yellow -fg+bg:\0001\0033[0m\0002' \
      -f-3 -b+3 ':yellow -fg+bg:'
    check '\0001\0033[93;43m\0002:yellow +fg-bg:\0001\0033[0m\0002' \
      -f+3 -b-3 ':yellow +fg-bg:'
    check '\0001\0033[34;104m\0002:blue -fg+bg:\0001\0033[0m\0002' \
      -f-4 -b+4 ':blue -fg+bg:'
    check '\0001\0033[94;44m\0002:blue +fg-bg:\0001\0033[0m\0002' \
      -f+4 -b-4 ':blue +fg-bg:'
    check '\0001\0033[35;105m\0002:magenta -fg+bg:\0001\0033[0m\0002' \
      -f-5 -b+5 ':magenta -fg+bg:'
    check '\0001\0033[95;45m\0002:magenta +fg-bg:\0001\0033[0m\0002' \
      -f+5 -b-5 ':magenta +fg-bg:'
    check '\0001\0033[36;106m\0002:cyan -fg+bg:\0001\0033[0m\0002' \
      -f-6 -b+6 ':cyan -fg+bg:'
    check '\0001\0033[96;46m\0002:cyan +fg-bg:\0001\0033[0m\0002' \
      -f+6 -b-6 ':cyan +fg-bg:'
    check '\0001\0033[37;107m\0002:white -fg+bg:\0001\0033[0m\0002' \
      -f-7 -b+7 ':white -fg+bg:'
    check '\0001\0033[97;47m\0002:white +fg-bg:\0001\0033[0m\0002' \
      -f+7 -b-7 ':white +fg-bg:'


  echo 'TAB TEST'
  check '\0001\0033[41m\0002\tTAB TEST\t\0001\0033[0m\0002' \
    -br -e '\tTAB TEST\t'

  printf 'Checks %5s\n' "${N_CHECKS}"
  printf 'Passed %5s\n' "${N_OKS}"
  printf 'Failed %5s\n' "${N_FAILS}"
}


color_tests
