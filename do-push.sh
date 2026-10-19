#!/bin/bash
if [[ $PATH_DIR != /* ]]; then
	PATH_DIR="${GITHUB_WORKSPACE}/${PATH_DIR}"
fi

cd "${PATH_DIR}" || exit 1;
echo "::group::Pushing to GIT"
# Push it (push it real good).
# One retry: GitHub answers the odd push with a transient 500.
git push || { sleep 10; git push; }
rc=$?
echo "::endgroup::"
# A swallowed failure leaves the built repo behind what was deployed, and the next consistency check reports false drift.
[ "$rc" = 0 ] || echo "::error::Pushing the build to the built repo failed (git exit $rc)."
exit "$rc"
