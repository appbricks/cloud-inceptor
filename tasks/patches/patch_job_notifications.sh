#!/bin/bash

if [[ $# < 1 ]]; then
  echo -e "\nUSAGE: /patch_job_notifications.sh <PATH_TO_PIPELINE_YML> [ <SUBJECT_HEADING> ]\n"
  exit 1
fi

if [[ -z $2 ]]; then
  subject_heading="automation job "
else
  subject_heading="$2 "
fi

set -euo pipefail

pipeline=$(cat $1)
jobs=$(echo -e "$pipeline" \
  | awk '/- task: notify on (.*) (success|failure)/{ print $5 }' \
  | uniq)

[[ -n $jobs ]] || exit 0

cat <<'EOF' > notification-patch.yml
- type: replace
  path: /resource_types?/-
  value:
    name: smuggler
    type: docker-image
    source:
      repository: redfactorlabs/concourse-smuggler-resource
      tag: alpine

- type: replace
  path: /resource_types?/-
  value:
    name: fly
    type: docker-image
    source:
      repository: troykinsella/concourse-fly-resource
      tag: latest

- type: replace
  path: /resources?/-
  value:
    name: job_info
    type: smuggler
    source:
      commands:
        check: |
          echo "$(date +%s)" > ${SMUGGLER_OUTPUT_DIR}/versions
        in: |
          cat <<EOF > $SMUGGLER_DESTINATION_DIR/job_info
          export BUILD_ID='${BUILD_ID}'
          export BUILD_NAME='${BUILD_NAME}'
          export BUILD_JOB_NAME='${BUILD_JOB_NAME}'
          export BUILD_PIPELINE_NAME='${BUILD_PIPELINE_NAME}'
          export BUILD_TEAM_NAME='${BUILD_TEAM_NAME}'
          export ATC_EXTERNAL_URL='${ATC_EXTERNAL_URL}'
          EOF

- type: replace
  path: /resources?/-
  value:
    name: notification
    type: fly
    source:
      url: ((concourse_url))
      username: ((concourse_user))
      password: ((concourse_password))
      team: main

EOF

for j in $(echo -e "$jobs"); do 

  alert_on_success=$(echo -e "$pipeline" | awk "/- task: notify on $j success/{ print \"y\" }")
  alert_on_failure=$(echo -e "$pipeline" | awk "/- task: notify on $j failure/{ print \"y\" }")

  if [[ -n $alert_on_success ]]; then

    cat <<EOF >> notification-patch.yml
- type: replace
  path: /jobs/name=$j/on_success?/do?
  value:
  - get: job_info
  - task: job_failed_alert
    file: automation/lib/inceptor/tasks/queue_job_email/task.yml
    params: 
      BUCKET: pcf
      EMAIL_QUEUE_PATH: email-queue
      AUTOS3_URL: ((autos3_url))
      AUTOS3_ACCESS_KEY: ((autos3_access_key))
      AUTOS3_SECRET_KEY: ((autos3_secret_key))
      SUBJECT_PRE: ((vpc_name)) ${subject_heading}FAILED
      JOB_STATUS: succeeded
  - put: notification
    params: 
      options: 'trigger-job -j bootstrap/notifications'

EOF

  fi

  if [[ -n $alert_on_failure ]]; then

    cat <<EOF >> notification-patch.yml
- type: replace
  path: /jobs/name=$j/on_failure?/do?
  value:
  - get: job_info
  - task: job_failed_alert
    file: automation/lib/inceptor/tasks/queue_job_email/task.yml
    params: 
      BUCKET: pcf
      EMAIL_QUEUE_PATH: email-queue
      AUTOS3_URL: ((autos3_url))
      AUTOS3_ACCESS_KEY: ((autos3_access_key))
      AUTOS3_SECRET_KEY: ((autos3_secret_key))
      SUBJECT_PRE: ((vpc_name)) ${subject_heading}SUCCEEDED
      JOB_STATUS: failed
  - put: notification
    params: 
      options: 'trigger-job -j bootstrap/notifications'

EOF

  fi

done

bosh interpolate -o notification-patch.yml $1
