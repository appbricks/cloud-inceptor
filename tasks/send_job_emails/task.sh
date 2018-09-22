#!/bin/sh
set -euo pipefail

wget -O mc "http://dl.minio.io/client/mc/release/linux-amd64/mc" && chmod +x mc
./mc config host add auto $AUTOS3_URL $AUTOS3_ACCESS_KEY $AUTOS3_SECRET_KEY

for f in $(find emails -name "email_payload_*" -print); do

  iext=${f##*_}
  i=${iext%.*}

  source emails/job_info_$i
  echo -e "Sending notifiction with subject: $SUBJECT"

  cat $f | /opt/resource/out $(pwd)
  ./mc rm $EMAIL_OBJECT
done
