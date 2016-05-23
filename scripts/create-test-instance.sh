#!/bin/bash
set -o nounset
set -o errexit

check-dependencies() {
  local DEPS=( tower-cli jq )
  for i in "${DEPS[@]}"
  do
    if ! which ${i} >/dev/null; then
      echo ${i} must be installed
      exit 1
    fi
  done
}

create-test-instance() {
  local GIT_COMMIT=${1}
  local OUTPUT=$(tower-cli job launch --format=json --job-template=62 --extra-vars="commit_id=${GIT_COMMIT}")
  local JOB_ID=$(echo ${OUTPUT} | jq .id)
  tower-cli job monitor ${JOB_ID} >/dev/null
  echo ${JOB_ID}
}

GIT_COMMIT=${1}
JOB_ID=$(create-test-instance ${GIT_COMMIT})
echo ${JOB_ID}
