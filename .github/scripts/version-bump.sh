#!/bin/bash

CHANGES_NEEDED='false'


check_and_update() {
  REPO=$1

  echo "::group::Update $REPO"

  # Check verions
  CODEQL_LOCAL=$(git submodule status $REPO | awk -F" " '{print $1}')

  CODEQL_LATEST=$(curl --silent "https://api.github.com/repos/github/$REPO/tags?per_page=1")
  CODEQL_LATEST_SHA=$(echo $CODEQL_LATEST | jq -r '.[].commit.sha')
  CODEQL_LATEST_VERSION=$(echo $CODEQL_LATEST | jq -r '.[].name')

  echo "Local Version  :: $CODEQL_LOCAL"
  echo "Latest Release :: $CODEQL_LATEST_SHA ($CODEQL_LATEST_VERSION)"

  # Validate version
  if [[ "$CODEQL_LOCAL" = "$CODEQL_LATEST_SHA" ]]; then
    echo "No updates needed, matching versions"

  else
    # Update CodeQL verions
    echo "Updating to latest release..."
    CHANGES_NEEDED='true'

    # Update submodule branch
    git submodule set-branch -b $CODEQL_LATEST_VERSION $REPO
    cd $REPO; git checkout $CODEQL_LATEST_SHA; cd ..

    echo "Finished Updating"

  fi

  echo "::endgroup::"

}


check_and_update "codeql"
check_and_update "codeql-go"


if [[ "$CHANGES_NEEDED" = "true" ]]; then

  echo "Updating remote submodules"
  git submodule update --recursive --remote

  echo "New submodule status"
  git submodule status

  echo '::set-output name=CHANGES_NEEDED::true'
else
  echo "No changes"
  echo '::set-output name=CHANGES_NEEDED::false'
fi
