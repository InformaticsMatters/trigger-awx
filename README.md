# trigger-awx

A utility to trigger (execute) Job Templates on a designated AWX server
using the [Ansible Tower CLI].

# Use in `.travis.yml`
To make a Travis build trigger a Job Template n an AWX server, do two things:

1.  Set appropriate environment variables as described in the
    embedded documentation in the `trigger-awx.sh` script.
    These can be defined in the Travis console for the project (refer to the
    [Environment Variables] documentation on Travis).
   
    You will need the AWX server URL, a job name and credentials for a user
    that can execute the chosen job.

2.  Add a `trigger awx` stage to your `.travis.yml` and then add the following:

```
language: python
python:
- '3.8'

env:
  global:
  # The origin of the trigger code
  - TRIGGER_ORIGIN=https://raw.githubusercontent.com/informaticsmatters/trigger-awx/master

install:
- curl --location --retry 3 ${TRIGGER_ORIGIN}/requirements.txt --output trigger-awx-requirements.txt
- curl --location --retry 3 ${TRIGGER_ORIGIN}/trigger-travis.py --output trigger-awx.py
- pip install -r trigger-awx-requirements.txt
- chmod +x trigger-awx.sh

jobs:
  include:
  - stage: trigger awx
    script: ./trigger-awx.sh
```

---

[ansible tower cli]: https://pypi.org/project/ansible-tower-cli/ 
[environment variables]: https://docs.travis-ci.com/user/environment-variables/
