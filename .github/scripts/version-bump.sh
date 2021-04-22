#!/bin/bash


# Get current local version
get_local_version() {
    git submodule status codeql |
    sed -E 's/.*\(([^"]+)\).*/\1/'
}

# Get current remote version
get_latest_release() {
  curl --silent "https://api.github.com/repos/github/codeql/tags?per_page=1" |
    grep '"name":' |
    sed -E 's/.*"([^"]+)".*/\1/'
}

# Check verions
CODEQL_LOCAL=$(get_local_version)
CODEQL_LATEST=$(get_latest_release)
# CODEQL_LATEST=main
 
# Validate versions
if [[ "$CODEQL_LOCAL" = "$CODEQL_LATEST" ]]; then

    echo "[+] No updates needed"
    echo "[+] Matching versions :: $CODEQL_LOCAL" 
else
    # Update CodeQL verions
    echo "[+] New version avalible :: $CODEQL_LATEST"

    # Update submodule branch
    git submodule set-branch -b $CODEQL_LATEST codeql
    git submodule set-branch -b $CODEQL_LATEST codeql-go

    git submodule update --recursive --remote

    git submodule status

fi
