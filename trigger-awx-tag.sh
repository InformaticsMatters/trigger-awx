#!/bin/bash

# A script to trigger an AWX Job Template given: -
#
# - a container image tag (i.e. '1.0.0'
# - the AWX Job Template variable to use for the tag (i.e. 'image_tag')
# - and a Job Template name to run (i.e. 'Bother')
#
# usage: ./trigger-awx-tag.sh <TAG> <JOB-TAG-VARIABLE> <JOB-NAME>
#
# This assumes the 'tower-cli' utility is available,
# usually installed via a requirements file prior to our execution.
#
# As this script is normally executed from wthin a CI framework
# it also uses environment variables to control the script's actions
# rather than overload the command-line. Namely: -
#
# - AWX_HOST          The server URL (i.e. https://example.com/awx)
# - AWX_USER          The name of a user that can execute the Job
# - AWX_USER_PASSWORD The user's password
#
# Note: Travis can encrypt the variables but avoid encrypting AWX_JOB_NAME
#       but make sure you use double-quotes if there are any spaces in the
#       Job name.
#
# The script disabes any input that the AWX Job Template may request and
# then waits for the Job to complete.
#
# On error or if the Job Template is not found the script exits with code 1.

set -eo pipefail

: "${AWX_HOST?Need to set AWX_HOST}"
: "${AWX_USER?Need to set AWX_USER}"
: "${AWX_USER_PASSWORD?Need to set AWX_USER_PASSWORD}"

if [[ -z "$1" ]]; then
  echo "ERROR: Missing tag"
  echo "Usage: trigger-awx-tag.sh <tag> <tag-variable> <job-name>"
  exit 1
fi

if [[ -z "$2" ]]; then
  echo "ERROR: Missing AWX tag variable"
  echo "Usage: trigger-awx-tag.sh <tag> <tag-variable> <job-name>"
  exit 1
fi

if [[ -z "$3" ]]; then
  echo "ERROR: Missing Job name"
  echo "Usage: trigger-awx-tag.sh <tag> <tag-variable> <job-name>"
  exit 1
fi

TAG=$1
TAG_VARIABLE=$2
AWX_JOB_NAME=$3

echo "Attempting to deploy image tag ${TAG_VARIABLE}=${TAG} to ${AWX_HOST} using Job Template '${AWX_JOB_NAME}'..."
# Get the AWX Job Template ID from the expected Job Template name
jtid=$(tower-cli job_template list -n "${AWX_JOB_NAME}" -f id \
  -h "$AWX_HOST" \
  -u "$AWX_USER" \
  -p "$AWX_USER_PASSWORD")

# If we have a template ID then trigger a luanch.
# Disable any input and over-ride the fs_image_tag value.
if [[ $jtid =~ ^[0-9]+$ ]]; then
  echo "Launching Job ID ${jtid} and waiting..."
  tower-cli job launch -J "$jtid" --no-input --wait \
    -h "$AWX_HOST" \
    -u "$AWX_USER" \
    -p "$AWX_USER_PASSWORD" \
    -e "${TAG_VARIABLE}=${TAG}"
else
  echo "Job Template '${AWX_JOB_NAME}' does not exist (${jtid})"
  exit 1
fi
