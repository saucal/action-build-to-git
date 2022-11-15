#!/bin/bash
TARGET_DIR="${GITHUB_WORKSPACE}/${TARGET_DIR}"
SOURCE_DIR="${GITHUB_WORKSPACE}/${SOURCE_DIR}"

cd "${SOURCE_DIR}" || exit 1;
# Remove everything on the target folder
git rm -rf . && git clean -fxd
mv ".git" ".git_backup"

shopt -s dotglob
mv "${TARGET_DIR}"/* "${SOURCE_DIR}"/
rm -rf ".git"
mv ".git_backup" ".git"

# Add changed files, delete deleted, etc, etc, you know the drill
git add -A .

if [ -z "$(git status --porcelain)" ]; then
	echo "NOTICE: No changes to deploy"
	exit 0
fi

# Commit it.
BUILD_JOB_URL="${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}"
MESSAGE=$( printf 'Build changes from %s\n\n%s' "${GITHUB_SHA}" "${BUILD_JOB_URL}" )
# Set the Author to the commit (expected to be a client dev) and the committer
# will be set to the default Git user for this system
git commit -m "${MESSAGE}"

# Push it (push it real good).
git push origin "${DEPLOY_BRANCH}"
