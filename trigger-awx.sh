#!/bin/bash

# A script to trigger an AWX Job Template.
#
# This assumes the 'awxkit' utility is available,
# usually installed via a requirements file prior to our execution.
#
# usage: ./trigger-awx.sh
#
# As this script is normally executed from within a Travis VM
# it uses environment variables to control the script's actions. Namely: -
#
# - AWX_JOB_NAME      The name of the Job Template to execute
# - AWX_HOST          The server URL (i.e. https://example.com/awx)
# - AWX_USER          The name of a user that can execute the Job
# - AWX_USER_PASSWORD The user's password
#
# Note: Travis can encrypt the variables but avoid encrypting AWX_JOB_NAME
#       and make sure you use double-quotes if there are any spaces in the
#       Job name.
#
# The script disables any input that the AWX Job Template may request and
# then waits for the Job to complete.
#
# If the Job Template is not found the script exits with code 1.

set -eo pipefail

: "${AWX_JOB_NAME?Need to set AWX_JOB_NAME}"
: "${AWX_HOST?Need to set AWX_HOST}"
: "${AWX_USER?Need to set AWX_USER}"
: "${AWX_USER_PASSWORD?Need to set AWX_USER_PASSWORD}"

export CONTROLLER_HOST=${AWX_HOST}
export CONTROLLER_USERNAME=${AWX_USER}
export CONTROLLER_PASSWORD=${AWX_USER_PASSWORD}

echo "Launching Job Template ${AWX_JOB_NAME} and monitoring..."
awx job_templates launch --monitor "${AWX_JOB_NAME}"
