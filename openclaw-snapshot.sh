#!/usr/bin/env bash
#
# openclaw-snapshot.sh
#
# Description:
#   Creates a compressed snapshot of OpenClaw user state:
#       ~/.openclaw/openclaw.json
#       ~/.openclaw/credentials/
#       ~/.openclaw/workspace/
#
#   Preserves:
#       - permissions
#       - ownership
#       - ACLs
#       - extended attributes
#
#   Performs:
#       - archive creation
#       - archive integrity verification
#
#   Designed for cron/systemd timer usage.
#
# Restore Procedure:
# ------------------------------------------------------------
# 1. Stop any running OpenClaw processes.
# 2. Extract archive into $HOME:
#
#       tar -xzpf openclaw_YYYYMMDD_HHMMSS.tar.gz -C "$HOME"
#
# 3. Confirm permissions:
#
#       ls -la ~/.openclaw
#
# 4. Restart OpenClaw.
# ------------------------------------------------------------

set -Eeuo pipefail

# ----- Configuration -----
OPENCLAW_DIR="$HOME/.openclaw"
SNAPSHOT_BASE="$HOME/.snapshots"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
ARCHIVE="$SNAPSHOT_BASE/openclaw_${TIMESTAMP}.tar.gz"
LOGFILE="$SNAPSHOT_BASE/openclaw_snapshot.log"
# --------------------------

mkdir -p "$SNAPSHOT_BASE"

{
echo "[$(date '+%F %T')] Starting OpenClaw snapshot..."

# Validate required paths exist
for path in \
    "$OPENCLAW_DIR/openclaw.json" \
    "$OPENCLAW_DIR/credentials" \
    "$OPENCLAW_DIR/workspace"
do
    if [ ! -e "$path" ]; then
        echo "ERROR: Required path missing: $path"
        exit 1
    fi
done

# Create archive
tar --xattrs --acls --numeric-owner -czpf \
    "$ARCHIVE" \
    -C "$HOME" \
    .openclaw/openclaw.json \
    .openclaw/credentials \
    .openclaw/workspace

echo "Archive created: $ARCHIVE"

# Verify archive integrity
echo "Verifying archive integrity..."
if tar -tzf "$ARCHIVE" > /dev/null 2>&1; then
    echo "Verification successful."
else
    echo "ERROR: Archive verification failed."
    exit 1
fi

echo "Snapshot completed successfully."
echo
} >> "$LOGFILE" 2>&1
