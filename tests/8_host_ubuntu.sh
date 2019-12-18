#!/bin/sh

check_8() {
  logit "\n"
  id_8="8"
  desc_8="Ubuntu security checks"
  check_8="$id_8 - $desc_8"
  info "$check_8"
  startsectionjson "$id_8" "$desc_8"
}

# 8.1
check_8_1() {
  id_8_1="8.1"
  desc_8_1="Ensure seccomp is enabled"
  check_8_1="$id_8_1  - $desc_8_1"
  starttestjson "$id_8_1" "$desc_8_1"

  totalChecks=$((totalChecks + 1))
  if egrep '^CONFIG_SECCOMP=y' /hostos/boot/config-$(uname -r) >/dev/null 2>&1; then
    pass "$check_8_1"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  else
    warn "$check_8_1"
    resulttestjson "WARN"
    currentScore=$((currentScore - 1))
  fi
}

check_8_2() {
  id_8_2="8.2"
  desc_8_2="Ensure apparmor is enabled"
  check_8_2="$id_8_2  - $desc_8_2"
  starttestjson "$id_8_2" "$desc_8_2"

  totalChecks=$((totalChecks + 1))

  aa_status=$(aa-status 2>/dev/null)
  if [ $? -eq 0 ]; then
    pass "$check_8_2"
    resulttestjson "PASS"
    info "${aa_status}"
    currentScore=$((currentScore + 1))
  else
    resulttestjson "WARN" "aa-status returned a non-zero exit code"
    currentScore=$((currentScore - 1))
  fi
}

check_8_end() {
  endsectionjson
}
