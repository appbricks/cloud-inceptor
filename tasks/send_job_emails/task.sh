#!/bin/sh
set -xeuo pipefail

for f in $(find emails -name "email_payload_*" -print); do

  iext=${f##*_}
  i=${iext%.*}

  source emails/job_info_$i
  echo -e "Sending notifiction with subject: $SUBJECT"

  cat $f | /opt/resource/out $(pwd)
done
