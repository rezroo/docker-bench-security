#!/bin/sh

check_1() {
  logit ""
  id_1="1"
  desc_1="Host Configuration"
  check_1="$id_1 - $desc_1"
  info "$check_1"
  startsectionjson "$id_1" "$desc_1"
}

check_1_1() {
  logit ""
  id_1_1="1.1"
  desc_1_1="General Configuration"
  check_1_1="$id_1_1 - $desc_1_1"
  info "$check_1_1"
}

# 1.1.1
check_1_1_1() {
  id_1_1_1="1.1.1"
  desc_1_1_1="Ensure the container host has been Hardened"
  check_1_1_1="$id_1_1_1  - $desc_1_1_1"
  starttestjson "$id_1_1_1" "$desc_1_1_1"

  totalChecks=$((totalChecks + 1))
  note "$check_1_1_1"
  resulttestjson "INFO"
  currentScore=$((currentScore + 0))
}

# 1.1.2
check_1_1_2() {
  id_1_1_2="1.1.2"
  desc_1_1_2="Ensure Docker is up to date"
  check_1_1_2="$id_1_1_2  - $desc_1_1_2"
  starttestjson "$id_1_1_2" "$desc_1_1_2"

  totalChecks=$((totalChecks + 1))
  docker_version=$(docker version | grep -i -A2 '^server' | grep ' Version:' \
    | awk '{print $NF; exit}' | tr -d '[:alpha:]-,')
  docker_current_version="$(date +%y.%m.0 -d @$(( $(date +%s) - 2592000)))"
  do_version_check "$docker_current_version" "$docker_version"
  if [ $? -eq 11 ]; then
    info "$check_1_1_2"
    info "       * Using $docker_version, verify is it up to date as deemed necessary"
    info "       * Your operating system vendor may provide support and security maintenance for Docker"
    resulttestjson "INFO" "Using $docker_version"
    currentScore=$((currentScore + 0))
  else
    pass "$check_1_1_2"
    info "       * Using $docker_version which is current"
    info "       * Check with your operating system vendor for support and security maintenance for Docker"
    resulttestjson "PASS" "Using $docker_version"
    currentScore=$((currentScore + 0))
  fi
}

check_1_2() {
  logit ""
  id_1_2="1.2"
  desc_1_2="Linux Hosts Specific Configuration"
  check_1_2="$id_1_2 - $desc_1_2"
  info "$check_1_2"
}

# 1.2.1
check_1_2_1() {
  id_1_2_1="1.2.1"
  desc_1_2_1="Ensure a separate partition for containers has been created"
  check_1_2_1="$id_1_2_1 - $desc_1_2_1"
  starttestjson "$id_1_2_1" "$desc_1_2_1"

  totalChecks=$((totalChecks + 1))

  if mountpoint -q -- "$(docker info -f '{{ .DockerRootDir }}')" >/dev/null 2>&1; then
    pass "$check_1_2_1"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  else
    warn "$check_1_2_1"
    resulttestjson "WARN"
    currentScore=$((currentScore - 1))
  fi
}

# 1.2.2
check_1_2_2() {
  id_1_2_2="1.2.2"
  desc_1_2_2="Ensure only trusted users are allowed to control Docker daemon"
  check_1_2_2="$id_1_2_2  - $desc_1_2_2"
  starttestjson "$id_1_2_2" "$desc_1_2_2"

  totalChecks=$((totalChecks + 1))
  docker_users=$(getent group docker)
  info "$check_1_2_2"
  for u in $docker_users; do
    info "       * $u"
  done
  resulttestjson "INFO" "users" "$docker_users"
  currentScore=$((currentScore + 0))
}

# 1.2.3
check_1_2_3() {
  id_1_2_3="1.2.3"
  desc_1_2_3="Ensure auditing is configured for the Docker daemon"
  check_1_2_3="$id_1_2_3  - $desc_1_2_3"
  starttestjson "$id_1_2_3" "$desc_1_2_3"

  totalChecks=$((totalChecks + 1))
  file="/usr/bin/dockerd"
  if command -v auditctl >/dev/null 2>&1; then
    if auditctl -l | grep "$file" >/dev/null 2>&1; then
      pass "$check_1_2_3"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check_1_2_3"
      resulttestjson "WARN"
      currentScore=$((currentScore - 1))
    fi
  elif grep -s "$file" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
    pass "$check_1_2_3"
    resulttestjson "PASS"
    currentScore=$((currentScore + 1))
  else
    warn "$check_1_2_3"
    resulttestjson "WARN"
    currentScore=$((currentScore - 1))
  fi
}

# 1.2.4
check_1_2_4() {
  id_1_2_4="1.2.4"
  desc_1_2_4="Ensure auditing is configured for Docker files and directories - /var/lib/docker"
  check_1_2_4="$id_1_2_4  - $desc_1_2_4"
  starttestjson "$id_1_2_4" "$desc_1_2_4"

  totalChecks=$((totalChecks + 1))
  directory="/var/lib/docker"
  if [ -d "$directory" ]; then
    if command -v auditctl >/dev/null 2>&1; then
      if auditctl -l | grep $directory >/dev/null 2>&1; then
        pass "$check_1_2_4"
        resulttestjson "PASS"
        currentScore=$((currentScore + 1))
      else
        warn "$check_1_2_4"
        resulttestjson "WARN"
        currentScore=$((currentScore - 1))
      fi
    elif grep -s "$directory" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
      pass "$check_1_2_4"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check_1_2_4"
      resulttestjson "WARN"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_1_2_4"
    info "     * Directory $directory not found"
    resulttestjson "INFO" "Directory $directory not found"
    currentScore=$((currentScore + 0))
  fi
}

# 1.2.5
check_1_2_5() {
  id_1_2_5="1.2.5"
  desc_1_2_5="Ensure auditing is configured for Docker files and directories - /etc/docker"
  check_1_2_5="$id_1_2_5  - $desc_1_2_5"
  starttestjson "$id_1_2_5" "$desc_1_2_5"

  totalChecks=$((totalChecks + 1))
  directory="/etc/docker"
  if [ -d "$directory" ]; then
    if command -v auditctl >/dev/null 2>&1; then
      if auditctl -l | grep $directory >/dev/null 2>&1; then
        pass "$check_1_2_5"
        resulttestjson "PASS"
        currentScore=$((currentScore + 1))
      else
        warn "$check_1_2_5"
        resulttestjson "WARN"
        currentScore=$((currentScore - 1))
      fi
    elif grep -s "$directory" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
      pass "$check_1_2_5"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check_1_2_5"
      resulttestjson "WARN"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_1_2_5"
    info "     * Directory $directory not found"
    resulttestjson "INFO" "Directory $directory not found"
    currentScore=$((currentScore + 0))
fi
}

# 1.2.6
check_1_2_6() {
  id_1_2_6="1.2.6"
  desc_1_2_6="Ensure auditing is configured for Docker files and directories - docker.service"
  check_1_2_6="$id_1_2_6  - $desc_1_2_6"
  starttestjson "$id_1_2_6" "$desc_1_2_6"

  totalChecks=$((totalChecks + 1))
  file="$(get_systemd_service_file docker.service)"
  if [ -f "$file" ]; then
    if command -v auditctl >/dev/null 2>&1; then
      if auditctl -l | grep "$file" >/dev/null 2>&1; then
        pass "$check_1_2_6"
        resulttestjson "PASS"
        currentScore=$((currentScore + 1))
      else
        warn "$check_1_2_6"
        resulttestjson "WARN"
        currentScore=$((currentScore - 1))
      fi
    elif grep -s "$file" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
      pass "$check_1_2_6"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check_1_2_6"
      resulttestjson "WARN"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_1_2_6"
    info "     * File $file not found"
    resulttestjson "INFO" "File $file not found"
    currentScore=$((currentScore + 0))
  fi
}

# 1.2.7
check_1_2_7() {
  id_1_2_7="1.2.7"
  desc_1_2_7="Ensure auditing is configured for Docker files and directories - docker.socket"
  check_1_2_7="$id_1_2_7  - $desc_1_2_7"
  starttestjson "$id_1_2_7" "$desc_1_2_7"

  totalChecks=$((totalChecks + 1))
  file="$(get_systemd_service_file docker.socket)"
  if [ -e "$file" ]; then
    if command -v auditctl >/dev/null 2>&1; then
      if auditctl -l | grep "$file" >/dev/null 2>&1; then
        pass "$check_1_2_7"
        resulttestjson "PASS"
        currentScore=$((currentScore + 1))
      else
        warn "$check_1_2_7"
        resulttestjson "WARN"
        currentScore=$((currentScore - 1))
      fi
    elif grep -s "$file" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
      pass "$check_1_2_7"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check_1_2_7"
      resulttestjson "WARN"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_1_2_7"
    info "     * File $file not found"
    resulttestjson "INFO" "File $file not found"
    currentScore=$((currentScore + 0))
  fi
}

# 1.2.8
check_1_2_8() {
  id_1_2_8="1.2.8"
  desc_1_2_8="Ensure auditing is configured for Docker files and directories - /etc/default/docker"
  check_1_2_8="$id_1_2_8  - $desc_1_2_8"
  starttestjson "$id_1_2_8" "$desc_1_2_8"

  totalChecks=$((totalChecks + 1))
  file="/etc/default/docker"
  if [ -f "$file" ]; then
    if command -v auditctl >/dev/null 2>&1; then
      if auditctl -l | grep $file >/dev/null 2>&1; then
        pass "$check_1_2_8"
        resulttestjson "PASS"
        currentScore=$((currentScore + 1))
      else
        warn "$check_1_2_8"
        resulttestjson "WARN"
        currentScore=$((currentScore - 1))
      fi
    elif grep -s "$file" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
      pass "$check_1_2_8"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check_1_2_8"
      resulttestjson "WARN"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_1_2_8"
    info "     * File $file not found"
    resulttestjson "INFO" "File $file not found"
    currentScore=$((currentScore + 0))
  fi
}

# 1.2.9
check_1_2_9() {
  id_1_2_9="1.2.9"
  desc_1_2_9="Ensure auditing is configured for Docker files and directories - /etc/sysconfig/docker"
  check_1_2_9="$id_1_2_9  - $desc_1_2_9"
  starttestjson "$id_1_2_9" "$desc_1_2_9"

  totalChecks=$((totalChecks + 1))
  file="/etc/sysconfig/docker"
  if [ -f "$file" ]; then
    if command -v auditctl >/dev/null 2>&1; then
      if auditctl -l | grep $file >/dev/null 2>&1; then
        pass "$check_1_2_9"
        resulttestjson "PASS"
        currentScore=$((currentScore + 1))
      else
        warn "$check_1_2_9"
        resulttestjson "WARN"
        currentScore=$((currentScore - 1))
      fi
    elif grep -s "$file" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
      pass "$check_1_2_9"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check_1_2_9"
      resulttestjson "WARN"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_1_2_9"
    info "       * File not found"
    resulttestjson "INFO" "File not found"
    currentScore=$((currentScore + 0))
  fi
}

# 1.2.10
check_1_2_10() {
  id_1_2_10="1.2.10"
  desc_1_2_10="Ensure auditing is configured for Docker files and directories - /etc/docker/daemon.json"
  check_1_2_10="$id_1_2_10  - $desc_1_2_10"
  starttestjson "$id_1_2_10" "$desc_1_2_10"

  totalChecks=$((totalChecks + 1))
  file="/etc/docker/daemon.json"
  if [ -f "$file" ]; then
    if command -v auditctl >/dev/null 2>&1; then
      if auditctl -l | grep $file >/dev/null 2>&1; then
        pass "$check_1_2_10"
        resulttestjson "PASS"
        currentScore=$((currentScore + 1))
      else
        warn "$check_1_2_10"
        resulttestjson "WARN"
        currentScore=$((currentScore - 1))
      fi
    elif grep -s "$file" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
      pass "$check_1_2_10"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check_1_2_10"
      resulttestjson "WARN"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_1_2_10"
    info "     * File $file not found"
    resulttestjson "INFO" "File $file not found"
    currentScore=$((currentScore + 0))
  fi
}

# 1.2.11
check_1_2_11() {
  id_1_2_11="1.2.11"
  desc_1_2_11="Ensure auditing is configured for Docker files and directories - /usr/bin/containerd"
  check_1_2_11="$id_1_2_11  - $desc_1_2_11"
  starttestjson "$id_1_2_11" "$desc_1_2_11"

  totalChecks=$((totalChecks + 1))
  file="/usr/bin/containerd"
  if [ -f "$file" ]; then
    if command -v auditctl >/dev/null 2>&1; then
      if auditctl -l | grep $file >/dev/null 2>&1; then
        pass "$check_1_2_11"
        resulttestjson "PASS"
        currentScore=$((currentScore + 1))
      else
        warn "$check_1_2_11"
        resulttestjson "WARN"
        currentScore=$((currentScore - 1))
      fi
    elif grep -s "$file" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
      pass "$check_1_2_11"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check_1_2_11"
      resulttestjson "WARN"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_1_2_11"
    info "     * File $file not found"
    resulttestjson "INFO" "File $file not found"
    currentScore=$((currentScore + 0))
  fi
}

# 1.2.12
check_1_2_12() {
  id_1_2_12="1.2.12"
  desc_1_2_12="Ensure auditing is configured for Docker files and directories - /usr/sbin/runc"
  check_1_2_12="$id_1_2_12  - $desc_1_2_12"
  starttestjson "$id_1_2_12" "$desc_1_2_12"

  totalChecks=$((totalChecks + 1))
  file="/usr/sbin/runc"
  if [ -f "$file" ]; then
    if command -v auditctl >/dev/null 2>&1; then
      if auditctl -l | grep $file >/dev/null 2>&1; then
        pass "$check_1_2_12"
        resulttestjson "PASS"
        currentScore=$((currentScore + 1))
      else
        warn "$check_1_2_12"
        resulttestjson "WARN"
        currentScore=$((currentScore - 1))
      fi
    elif grep -s "$file" "$auditrules" | grep "^[^#;]" 2>/dev/null 1>&2; then
      pass "$check_1_2_12"
      resulttestjson "PASS"
      currentScore=$((currentScore + 1))
    else
      warn "$check_1_2_12"
      resulttestjson "WARN"
      currentScore=$((currentScore - 1))
    fi
  else
    info "$check_1_2_12"
    info "     * File $file not found"
    resulttestjson "INFO" "File $file not found"
    currentScore=$((currentScore + 0))
  fi
}

check_1_end() {
  endsectionjson
}
