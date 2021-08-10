#!/bin/bash

get_latest_release() {
  # https://gist.github.com/lukechilds/a83e1d7127b78fef38c2914c4ececc3c
  curl --silent "https://api.github.com/repos/github/codeql-action/releases/latest" |
    grep '"tag_name":' |
    sed -E 's/.*"([^"]+)".*/\1/'
}

CODEQL_BIN_PATH="./bin"
CODEQL_CLI_ARCHIVE="$CODEQL_BIN_PATH/codeql.tar.gz"
CODEQL_CLI_PATH="$CODEQL_BIN_PATH/codeql"
CODEQL_QLPACK_PATH="$CODEQL_CLI_PATH/qlpacks"

# https://github.com/github/codeql-action/releases
CODEQL_CLI_LATEST=$(get_latest_release)
CODEQL_CLI_RELEASE_URL="https://github.com/github/codeql-action/releases/download/$CODEQL_CLI_LATEST/codeql-bundle-osx64.tar.gz"

echo "----------------------------------------------------"
echo "[+] CodeQL URL :: $CODEQL_CLI_RELEASE_URL"
echo "[+] CodeQL CLI Path :: $CODEQL_CLI_PATH"
echo "----------------------------------------------------"

echo "Creating directory: $CODEQL_BIN_PATH"
mkdir -p $CODEQL_BIN_PATH

echo "Downloading Archive..."
if [[ -d $CODEQL_CLI_ARCHIVE ]]; then
    rm -f $CODEQL_CLI_ARCHIVE
fi

curl -o "$CODEQL_CLI_ARCHIVE" -L $CODEQL_CLI_RELEASE_URL

echo "Extracting Archive..."
tar -xvzf $CODEQL_CLI_ARCHIVE -C $CODEQL_BIN_PATH

echo "CodeQL CLI Version"
codeql --version

echo "[+] Check QLPacks path: $CODEQL_QLPACK_PATH"
if [[ -d $CODEQL_QLPACK_PATH ]]; then
  echo "[+] Removing default QLPacks..."
  rm -r $CODEQL_QLPACK_PATH
fi

echo "CodeQL CLI SQLPack Resolve..."
codeql resolve qlpacks --additional-packs=./codeql

echo "Cleaning up..."
rm -f $CODEQL_CLI_ARCHIVE
