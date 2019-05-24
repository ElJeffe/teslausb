#!/bin/bash -eu

FILE_PATH="$1"

echo "INSTALL_DIR=\"$INSTALL_DIR\"" > "$FILE_PATH"
echo "user=$RSYNC_USER" > "$FILE_PATH"
echo "server=$RSYNC_SERVER" >> "$FILE_PATH"
echo "path=$RSYNC_PATH" >> "$FILE_PATH"