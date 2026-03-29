#!/usr/bin/env sh
set -eu

RETENTION=${1:-7}
ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
BACKUPS_DIR="${PAPERCLIP_HOME:-$ROOT_DIR/.paperclip-home}/instances/${PAPERCLIP_INSTANCE_ID:-demo}/data/backups"
echo "Rotating backups in $BACKUPS_DIR, keeping ${RETENTION} backups"
if [ ! -d "$BACKUPS_DIR" ]; then
  echo "No backups dir found; nothing to rotate."
  exit 0
fi

set +f
IFS='
'
BACKUP_FILES=$(ls -1 "$BACKUPS_DIR" 2>/dev/null | sort || true)
IFS=' '
set -f

COUNT=0
for _file in $BACKUP_FILES; do
  COUNT=$((COUNT + 1))
done

if [ "$COUNT" -le "$RETENTION" ]; then
  echo "Backup count ($COUNT) within retention; nothing to delete."
  exit 0
fi

TO_DELETE_COUNT=$((COUNT - RETENTION))
INDEX=0
for FILE in $BACKUP_FILES; do
  if [ "$INDEX" -ge "$TO_DELETE_COUNT" ]; then
    break
  fi
  if [ -n "$FILE" ]; then
    rm -f "$BACKUPS_DIR/$FILE" || true
    echo "Deleted old backup: $FILE"
  fi
  INDEX=$((INDEX + 1))
done

echo "Retention rotation complete."
