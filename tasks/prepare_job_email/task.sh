#!/bin/bash

set -euo pipefail

wget -O mc "http://dl.minio.io/client/mc/release/linux-amd64/mc" && chmod +x mc
./mc config host add auto $AUTOS3_URL $AUTOS3_ACCESS_KEY $AUTOS3_SECRET_KEY

wget -O fly "$CONCOURSE_URL/api/v1/cli?arch=amd64&platform=linux" && chmod +x fly
./fly -t default login -c $CONCOURSE_URL -u ''$CONCOURSE_USER'' -p ''$CONCOURSE_PASSWORD''

set -x

cat <<EOF > emails/headers
MIME-version: 1.0
Content-Type: text/html; charset="UTF-8"
EOF

i=0
emails=$(./mc find auto/$BUCKET/$EMAIL_QUEUE_PATH --name "job_email-*" --exec "echo {}" 2>/dev/null)
for email in $emails; do
  ./mc cp $email job_info
  source job_info

  set +xe
  job_output=$(./fly -t default watch -j $BUILD_PIPELINE_NAME/$BUILD_JOB_NAME -b $BUILD_NAME)
  set -xe

  echo -e "$job_output" \
    | automation/lib/inceptor/tasks/prepare_job_email/ansi2html.sh --bg=dark --palette=tango \
    > emails/email_body_$i.html

  cat <<EOF > emails/email_payload_$i.json
{
  \"params\": {
    \"headers\": \"emails/headers\"
    \"subject_text\": \"$SUBJECT\",
    \"body\": \"emails/email_body_$1.html\"
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
}
EOF

  # ./mc rm $email
  i=$(($i+1))
done
