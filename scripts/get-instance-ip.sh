#!/bin/bash
set -o nounset
set -o errexit

check-dependencies() {
  local DEPS=( curl jq shyaml )
  for i in "${DEPS[@]}"
  do
    if ! which ${i} >/dev/null; then
      echo ${i} must be installed
      exit 1
    fi
  done
}

get-instance-ip() {
  local JOB_ID=${1}
  local TOWER_HOST=$(tower-cli config host | shyaml get-value host)
  local TOWER_USERNAME=$(tower-cli config username | shyaml get-value username)
  local TOWER_PASSWORD=$(tower-cli config password | shyaml get-value password)
  local JOB_DATA=$(curl -s -k -H "Accept: application/json" \
    --user ${TOWER_USERNAME}:${TOWER_PASSWORD} \
    https://${TOWER_HOST}/api/v1/jobs/${JOB_ID}/job_events/?task__exact=instance%20ip\&event__exact=runner_on_ok)
  local IP=$(echo ${JOB_DATA} | jq .results[0].event_data.res.msg)
  echo ${IP}
}

main() {
  local JOB_ID=${1}
  check-dependencies
  get-instance-ip ${JOB_ID}
}

JOB_ID=${1}
main ${JOB_ID}
