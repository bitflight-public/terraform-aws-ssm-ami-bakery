#!/bin/bash

function get_contents() {
    if [ -x "$(which curl)" ]; then
        curl -s -f "$1"
    elif [ -x "$(which wget)" ]; then
        wget "$1" -O -
    else
        die "No download utility (curl, wget)"
    fi
}

readonly IDENTITY_URL="http://169.254.169.254/2016-06-30/dynamic/instance-identity/document/"
readonly TRUE_REGION=$(get_contents "$IDENTITY_URL" | awk -F\" '/region/ { print $4 }')
readonly DEFAULT_REGION="us-east-1"
readonly REGION="${TRUE_REGION:-$DEFAULT_REGION}"

readonly SCRIPT_NAME="aws-install-ssm-agent"
 SCRIPT_URL="https://aws-ssm-downloads-$REGION.s3.amazonaws.com/scripts/$SCRIPT_NAME"

if [ "$REGION" = "cn-north-1" ]; then
  SCRIPT_URL="https://aws-ssm-downloads-$REGION.s3.cn-north-1.amazonaws.com.cn/scripts/$SCRIPT_NAME"
fi

if [ "$REGION" = "us-gov-west-1" ]; then
  SCRIPT_URL="https://aws-ssm-downloads-$REGION.s3-us-gov-west-1.amazonaws.com/scripts/$SCRIPT_NAME"
fi

cd /tmp
FILE_SIZE=0
MAX_RETRY_COUNT=3
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRY_COUNT ] ; do
  echo AWS-UpdateLinuxAmi: Downloading script from $SCRIPT_URL
  get_contents "$SCRIPT_URL" > "$SCRIPT_NAME"
  FILE_SIZE=$(du -k /tmp/$SCRIPT_NAME | cut -f1)
  echo AWS-UpdateLinuxAmi: Finished downloading script, size: $FILE_SIZE
  if [ $FILE_SIZE -gt 0 ]; then
    break
  else
    if [[ $RETRY_COUNT -lt MAX_RETRY_COUNT ]]; then
      RETRY_COUNT=$((RETRY_COUNT+1));
      echo AWS-UpdateLinuxAmi: FileSize is 0, retryCount: $RETRY_COUNT
    fi
  fi 
done

if [ $FILE_SIZE -gt 0 ]; then
  chmod +x "$SCRIPT_NAME"
  echo AWS-UpdateLinuxAmi: Running UpdateSSMAgent script now ....
  ./"$SCRIPT_NAME" --region "$REGION"
else
  echo AWS-UpdateLinuxAmi: Unable to download script, quitting ....
fi