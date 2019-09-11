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

if [[ -z $jobs ]]; then
  echo -e "$pipeline"
  exit 0
fi

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

  cat <<EOF >> notification-patch.yml

- type: replace
  path: /resources?/-
  value:
    name: $j-job-info
    type: smuggler
    source:
      smuggler_debug: true
      commands:
        check: |
          echo "\${BUILD_JOB_NAME}-\${BUILD_NAME}-\${BUILD_ID}" > \${SMUGGLER_OUTPUT_DIR}/versions
        in: |
          cat <<EOF > \${SMUGGLER_DESTINATION_DIR}/job_info
          export BUILD_ID='\${BUILD_ID}'
          export BUILD_NAME='\${BUILD_NAME}'
          export BUILD_JOB_NAME='\${BUILD_JOB_NAME}'
          export BUILD_PIPELINE_NAME='\${BUILD_PIPELINE_NAME}'
          export BUILD_TEAM_NAME='\${BUILD_TEAM_NAME}'
          export ATC_EXTERNAL_URL='\${ATC_EXTERNAL_URL}'
          EOF

- type: replace
  path: /jobs/name=$j/plan/0:before
  value:
    get: $j-job-info
EOF

  if [[ -n $alert_on_success ]]; then

    cat <<EOF >> notification-patch.yml

- type: remove
  path: /jobs/name=$j/on_success/do/task=notify on $j success

- type: replace
  path: /jobs/name=$j/on_success?/do?/-
  value:
    task: job_succeeded_alert
    file: ((pipeline_automation_path))/tasks/queue_job_email/task.yml
    input_mapping: {job-info: $j-job-info}
    params: 
      AUTOS3_URL: ((autos3_url))
      AUTOS3_ACCESS_KEY: ((autos3_access_key))
      AUTOS3_SECRET_KEY: ((autos3_secret_key))
      SUBJECT_PRE: ((vpc_name)) ${subject_heading}SUCCEEDED
      JOB_STATUS: succeeded

- type: replace
  path: /jobs/name=$j/on_success?/do?/-
  value:
    put: notification
    params: 
      options: 'trigger-job -j bootstrap/notifications'
EOF

  fi

  if [[ -n $alert_on_failure ]]; then

    cat <<EOF >> notification-patch.yml
    
- type: remove
  path: /jobs/name=$j/on_failure/do/task=notify on $j failure

- type: replace
  path: /jobs/name=$j/on_failure?/do?/-
  value:
    task: job_failed_alert
    file: ((pipeline_automation_path))/tasks/queue_job_email/task.yml
    input_mapping: {job-info: $j-job-info}
    params: 
      AUTOS3_URL: ((autos3_url))
      AUTOS3_ACCESS_KEY: ((autos3_access_key))
      AUTOS3_SECRET_KEY: ((autos3_secret_key))
      SUBJECT_PRE: ((vpc_name)) ${subject_heading}FAILED
      JOB_STATUS: failed

- type: replace
  path: /jobs/name=$j/on_failure?/do?/-
  value:
    put: notification
    params: 
      options: 'trigger-job -j bootstrap/notifications'
EOF

  fi

done

set +e
which bosh 2>&1 > /dev/null
if [ $? -ne 0 ]; then
    which bosh-cli 2>&1 > /dev/null
    if [ $? -ne 0 ]; then
        echo "ERROR! Unable to find bosh cli."
        exit 1
    fi
    set -e
    bosh-cli interpolate -o notification-patch.yml $1
else
    set -e
    bosh interpolate -o notification-patch.yml $1
fi
