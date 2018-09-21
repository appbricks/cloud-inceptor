#!/bin/sh

set -xeuo pipefail

wget -O mc "http://dl.minio.io/client/mc/release/linux-amd64/mc" && chmod +x mc
./mc config host add auto $AUTOS3_URL $AUTOS3_ACCESS_KEY $AUTOS3_SECRET_KEY

wget -O fly "$CONCOURSE_URL/api/v1/cli?arch=amd64&platform=linux" && chmod +x fly
./fly -t default login -c $CONCOURSE_URL -u ''$CONCOURSE_USER'' -p ''$CONCOURSE_PASSWORD''

emails=$(./mc find auto/$BUCKET/$EMAIL_QUEUE_PATH --name "job_email-*" --exec "echo {}" 2>/dev/null)
for email in $emails; do
  ./mc cp $email job_info
  source job_info

  job_output=$(./fly -t default watch -j $BUILD_PIPELINE_NAME/$BUILD_JOB_NAME -b $BUILD_NAME)
  echo -e "$job_output" | ./ansi2html.sh --bg=dark --palette=tango > email_body

  echo "
  {
    \"params\": {
      \"headers\": \"automation/lib/inceptor/tasks/prepare_job_email/headers\"
      \"subject_text\": \"$SUBJECT\",
      \"body\": \"email_body\"
    },
    \"source\": {
      \"smtp\": {
          \"skip_ssl_validation\": true,
          \"host\": \"$SMTP_HOST\",
          \"port\": \"$SMTP_PORT\",
          \"anonymous\": true
      },
      \"from\": \"$EMAIL_FROM\",
      \"to\": $EMAIL_TO
    }
  }" | /opt/resource/out $(pwd)

  ./mc rm $email
done
