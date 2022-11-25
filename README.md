# Build to GIT

Use this action to push built assets to a deployable GIT repo

## Getting Started

You should be all set with these defaults.

```yml
- name: Build To GIT
  id: 'build-to-git'
  uses: saucal/action-build-to-git@v1
  with:
    from: 'source'
    path: 'pushable-repo-path'
```

This will take code that is present on the `from` folder and commit that to the repo present in `path`. NOTE: Repo in path needs to be previously cloned, otherwise things will fail.

## Full options

```yml
- uses: saucal/action-build-to-git@v1
  with:
    # Relative path to the codebase to push to the GIT repo.
    # NOTE: This does not need to be a repo, but can be
    from: ""

    # Relative path to the repository to push to.
    # NOTE: This DOES need to be a repo already
    path: ""

    # Forced .gitignore entries (appended at the end)
    # For multiline, you can do:
    #
    # force-ignore: |
    #   ignore1
    #   ignore2
    #   !not-ignore
    force-ignore: ""

    # Do not push immediately during this action call.
    # Allows to call the action later to do the actual push
    defer-push: "false"

    # Just perform the push. Set this parameter to true,
    # in case you used defer-push before and want to 
    # wrap up the procedure at this point.
    do-push: "false"
```

## Outputs

```yml
# Full list of file paths changed
# Can be empty if no change was commited
#
# Prefixed with: 
#   + (added/modified)
#   - (removed)
# Can be fed into saucal/deploy-ftp action
- ${{ steps.*.outputs.manifest }}

# Raw git diff-tree output for the commit made
# Can be empty if no change was commited
- ${{ steps.*.outputs.manifest-raw }}

# Full list of files present on the last commit
# 
# Prefixed with: 
#   + (added)
- ${{ steps.*.outputs.manifest-full }}
```
