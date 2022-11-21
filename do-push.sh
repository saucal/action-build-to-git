#!/bin/bash
if [[ $SOURCE_DIR != /* ]]; then
	SOURCE_DIR="${GITHUB_WORKSPACE}/${SOURCE_DIR}"
fi

cd "${SOURCE_DIR}" || exit 1;
echo "::group::Pushing"
# Push it (push it real good).
git push
echo "::endgroup::"
