#!/bin/sh

# Environment Variables for Restic
export RESTIC_REPOSITORY="s3:s3.amazonaws.com/your-bucket-name"
export RESTIC_PASSWORD="your-password"
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"

# Dataset Variables
DATASET="pool/dataset"  # Parent dataset
BASE_SNAPSHOT="${DATASET}@base"
DATE=$(date +%Y-%m-%d)
INCREMENTAL_SNAPSHOT="${DATASET}@incremental-${DATE}"

# Check if the base snapshot exists
if zfs list -t snapshot | grep -q "${BASE_SNAPSHOT}"; then
    echo "Base snapshot exists. Performing incremental backup."

    # Create recursive incremental snapshot
    zfs snapshot -r "$INCREMENTAL_SNAPSHOT"

    # Send recursive incremental snapshot
    zfs send -R -i "$BASE_SNAPSHOT" "$INCREMENTAL_SNAPSHOT" | restic backup --stdin --stdin-filename "${DATASET}-incremental-${DATE}.zfs"

    # Update base snapshot
    zfs destroy -r "$BASE_SNAPSHOT"
    zfs rename -r "$INCREMENTAL_SNAPSHOT" "$BASE_SNAPSHOT"
else
    echo "No base snapshot found. Performing full backup."

    # Create recursive full snapshot
    zfs snapshot -r "$BASE_SNAPSHOT"

    # Send recursive full snapshot
    zfs send -R "$BASE_SNAPSHOT" | restic backup --stdin --stdin-filename "${DATASET}-full-${DATE}.zfs"
fi

# Optional: Prune old backups in Restic
restic forget --keep-daily 7 --keep-weekly 4 --keep-monthly 12 --prune
