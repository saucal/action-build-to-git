#!/bin/bash
if [[ $PATH_DIR != /* ]]; then
	PATH_DIR="${GITHUB_WORKSPACE}/${PATH_DIR}"
fi

cd "${PATH_DIR}" || exit 1;
echo "::group::Pushing to GIT"
# Push it (push it real good).
git push
echo "::endgroup::"
