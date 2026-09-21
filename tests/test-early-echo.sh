#!/bin/bash

# Checks that the trigger scripts echo their variables
# before asserting that any of them are set.
#
# A stub 'awx' is placed on the PATH so no real AWX server (or awxkit) is needed.
#
# Usage: ./tests/test-early-echo.sh

set -o pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
STUB_DIR="$(mktemp -d)"
trap 'rm -rf "${STUB_DIR}"' EXIT

cat > "${STUB_DIR}/awx" <<'EOF'
#!/bin/bash
echo "0.0.0-stub"
EOF
chmod +x "${STUB_DIR}/awx"

FAILURES=0

# Asserts the given output contains the expected text
assert_contains() {
  local name="$1" output="$2" expected="$3"
  if [[ "${output}" == *"${expected}"* ]]; then
    echo "PASS: ${name} echoes '${expected}'"
  else
    echo "FAIL: ${name} does not echo '${expected}'"
    FAILURES=$((FAILURES + 1))
  fi
}

# trigger-awx-tag.sh with command-line values but no AWX_HOST.
# The script must fail, but only after echoing everything.
OUTPUT="$(env -u AWX_HOST PATH="${STUB_DIR}:${PATH}" \
  AWX_USER=user AWX_USER_PASSWORD=secret \
  bash "${ROOT_DIR}/trigger-awx-tag.sh" 1.0.0 image_tag Bother 2>&1)"
assert_contains trigger-awx-tag.sh "${OUTPUT}" "AWX_VERSION=0.0.0-stub"
assert_contains trigger-awx-tag.sh "${OUTPUT}" "AWX_HOST="
assert_contains trigger-awx-tag.sh "${OUTPUT}" "AWX_USER=user"
assert_contains trigger-awx-tag.sh "${OUTPUT}" "AWX_USER_PASSWORD=secret"
assert_contains trigger-awx-tag.sh "${OUTPUT}" "TAG=1.0.0"
assert_contains trigger-awx-tag.sh "${OUTPUT}" "TAG_VARIABLE=image_tag"
assert_contains trigger-awx-tag.sh "${OUTPUT}" "TEMPLATE='Bother'"
assert_contains trigger-awx-tag.sh "${OUTPUT}" "Need to set AWX_HOST"

# trigger-awx.sh with no AWX_HOST.
OUTPUT="$(env -u AWX_HOST PATH="${STUB_DIR}:${PATH}" \
  AWX_JOB_NAME=Bother AWX_USER=user AWX_USER_PASSWORD=secret \
  bash "${ROOT_DIR}/trigger-awx.sh" 2>&1)"
assert_contains trigger-awx.sh "${OUTPUT}" "AWX_VERSION=0.0.0-stub"
assert_contains trigger-awx.sh "${OUTPUT}" "AWX_JOB_NAME='Bother'"
assert_contains trigger-awx.sh "${OUTPUT}" "AWX_HOST="
assert_contains trigger-awx.sh "${OUTPUT}" "AWX_USER=user"
assert_contains trigger-awx.sh "${OUTPUT}" "AWX_USER_PASSWORD=secret"
assert_contains trigger-awx.sh "${OUTPUT}" "Need to set AWX_HOST"

if [[ ${FAILURES} -gt 0 ]]; then
  echo "${FAILURES} failure(s)"
  exit 1
fi
echo "All tests passed"
