# trigger-awx

A utility to trigger (execute) Job Templates on a designated AWX server
using the [Ansible Tower CLI].

- `trigger-awx` is a simple trigger that just triggers a job that would
  normally execute based on a new fixed tag, like `stable` or `latest`
- `trigger-awx-tag` is used to provide a Job Template tag variable and value
  so that Jobs can be run to deploy an image based on a specific tag.

>   Remember that Job Templates that you expect to run on AWX must be
    executable by the user you provide.
 
>   Any AWX Job Template you execute should have the **PROMPT ON LAUNCH**
    option selected in the **EXTRA VARIABLES** section. If not, variables
    passed-in via the underlying tower-cli command will be ignored.

## Use in .travis.yml
To make a Travis build trigger a Job Template on an AWX server, do two things:

1.  Set appropriate environment variables as described in the
    embedded documentation in the `trigger-awx.sh` script.
    These can be defined in the Travis console for the project (refer to the
    [Environment Variables] documentation on Travis).
   
    You will need the AWX server URL, a job name and credentials for a user
    that can execute the chosen job.

2.  Add a `trigger awx` stage to your `.travis.yml` and then add the following:

```yaml
language: python
python:
- '3.8'

env:
  global:
  # The origin of the trigger code
  - TRIGGER_ORIGIN=https://raw.githubusercontent.com/informaticsmatters/trigger-awx/master

install:
- curl --location --retry 3 ${TRIGGER_ORIGIN}/requirements.txt --output trigger-awx-requirements.txt
- curl --location --retry 3 ${TRIGGER_ORIGIN}/trigger-awx.sh --output trigger-awx.sh
- pip install -r trigger-awx-requirements.txt
- chmod +x trigger-awx.sh

jobs:
  include:
  - stage: trigger awx
    script: ./trigger-awx.sh
```

## Use in .gitlab-ci.yml
To make a GitLab CI build trigger a Job Template on an AWX server,
do two things:

1.  Set appropriate environment variables, normally through the project's
    CI/CD variables (refer to the [GitLab Variables] documentation).
   
    You will need the AWX server URL, a job name and credentials for a user
    that can execute the chosen job.

2.  Add a `deploy` stage to your `.gitlab-ci.yml` and then add the following:

```yaml
variables:
  # The trigger repo
  TRIGGER_ORIGIN: https://raw.githubusercontent.com/informaticsmatters/trigger-awx/master

# If this is an official non-branch tag
# (i.e. something like '1.0.0' without any pre-release qualifier)
# then deploy to the production environment.
deploy_production:
  stage: deploy
  tags:
  - docker
  image: python:3.8
  script:
  - curl --location --retry 3 ${TRIGGER_ORIGIN}/requirements.txt --output trigger-awx-requirements.txt
  - curl --location --retry 3 ${TRIGGER_ORIGIN}/trigger-awx-tag.sh --output trigger-awx-tag.sh
  - pip install -r trigger-awx-requirements.txt
  - chmod +x trigger-awx-tag.sh
  - ./trigger-awx-tag.sh "${CI_COMMIT_TAG}" bother_image_tag Bother
  environment:
    name: production
  only:
  - /^([0-9]+\.){1,2}[0-9]+$/
  except:
  - branches
```

---

[ansible tower cli]: https://pypi.org/project/ansible-tower-cli/ 
[environment variables]: https://docs.travis-ci.com/user/environment-variables/
[gitlab variables]: https://docs.gitlab.com/ee/ci/variables/
