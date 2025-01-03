# zfs-backup-restic

Small script to backup ZFS snapshots into a s3 bucket using restic (encrypted)


## Use case

I am using this to backup my bhyve VMs :)

## How to restore a backup

Suppose you want to restore pool/dataset/child1 from a Restic backup.

Find the snapshot
```
restic snapshots
```

Restore the Snapshot Locally:
```
restic restore 1a2b3c4d --target /tmp/restore
```
The file /tmp/restore/dataset-child1-incremental-2025-01-02.zfs is now available.


Restore only pool/dataset/child1:
```
zfs receive -F pool/dataset/child1 < /tmp/restore/dataset-child1-incremental-2025-01-02.zfs
```

Verify the Restore: Check that the dataset was restored:
```
zfs list
```

Roll Back (if needed): If the restored child dataset has multiple snapshots and you want to revert to the restored snapshot:
```
zfs rollback pool/dataset/child1@restored-snapshot
```
