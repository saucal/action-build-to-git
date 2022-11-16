#!/bin/bash
TARGET_DIR="${GITHUB_WORKSPACE}/${TARGET_DIR}"
SOURCE_DIR="${GITHUB_WORKSPACE}/${SOURCE_DIR}"

echo "::group::Syncing repos"
cd "${SOURCE_DIR}" || exit 1;
# Remove everything on the target folder
git rm -rf . && git clean -fxd
mv ".git" ".git_backup"

shopt -s dotglob
mv "${TARGET_DIR}"/* "${SOURCE_DIR}"/
rm -rf ".git"
mv ".git_backup" ".git"
echo "::endgroup::"

echo "::group::Cleanup"
# GH Actions should not be commited to built repos
rm -rf ".github"
echo "::endgroup::"

echo "::group::Handling gitignore overrides"
# To allow commiting built files in the build branch (which are typically ignored)
# -------------------
BUILD_DEPLOYIGNORE_PATH="${SOURCE_DIR}/.deployignore"
DEFAULT_DEPLOYIGNORE_PATH="${GITHUB_ACTION_PATH}/.deployignore_default"
if [ ! -f "$BUILD_DEPLOYIGNORE_PATH" ] && [ -f "$DEFAULT_DEPLOYIGNORE_PATH" ]; then
	echo "-- using default .deployignore from the action as global .gitignore"
	touch "$BUILD_DEPLOYIGNORE_PATH"
	cat "$DEFAULT_DEPLOYIGNORE_PATH" >> "$BUILD_DEPLOYIGNORE_PATH"
fi

FORCED_DEPLOYIGNORE_PATH="${GITHUB_ACTION_PATH}/.deployignore_forced"
if [ -f "$FORCED_DEPLOYIGNORE_PATH" ]; then
	echo "-- adding forced .deployignore entries from the action"
	touch "$BUILD_DEPLOYIGNORE_PATH"
	{
		echo ""
		cat "$FORCED_DEPLOYIGNORE_PATH"
	} >> "$BUILD_DEPLOYIGNORE_PATH"
fi

if [ -f "$BUILD_DEPLOYIGNORE_PATH" ]; then
	BUILD_GITIGNORE_PATH="${SOURCE_DIR}/.gitignore"

	if [ -f "$BUILD_GITIGNORE_PATH" ]; then
		rm "$BUILD_GITIGNORE_PATH"
	fi

	echo "-- found .deployignore; emptying all gitignore files"
	find "$SOURCE_DIR" -type f -name '.gitignore' | while read GITIGNORE_FILE; do
		echo "# Emptied by build-to-git; '.deployignore' exists and used as global .gitignore." > $GITIGNORE_FILE
		echo "${GITIGNORE_FILE}"
	done

	echo "-- using .deployignore as global .gitignore"
	mv "$BUILD_DEPLOYIGNORE_PATH" "$BUILD_GITIGNORE_PATH"
fi
echo "::endgroup::"

# Add changed files, delete deleted, etc, etc, you know the drill
echo "::group::Adding files"
git add -A .
echo "::endgroup::"

if [ -z "$(git status --porcelain)" ]; then
	echo "NOTICE: No changes to deploy"
	exit 0
fi

# Commit it.
echo "::group::Committing files"
BUILD_JOB_URL="${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}"
MESSAGE=$( printf 'Build changes from %s\n\n%s' "${GITHUB_SHA}" "${BUILD_JOB_URL}" )
# Set the Author to the commit (expected to be a client dev) and the committer
# will be set to the default Git user for this system
git commit -m "${MESSAGE}"
echo "::endgroup::"

echo "::group::Pushing"
# Push it (push it real good).
git push
echo "::endgroup::"

{
	echo 'manifest<<EOF_MANIFEST'
	git diff-tree HEAD --name-status --no-commit-id --no-renames -r | sed -E "s/^[AM]\t/+ /" | sed -E "s/^[D]\t/- /"
	echo 'EOF_MANIFEST'

	echo 'manifest-raw<<EOF_MANIFEST'
	git diff-tree HEAD --name-status --no-commit-id --no-renames -r
	echo 'EOF_MANIFEST'
} >> "$GITHUB_OUTPUT"
