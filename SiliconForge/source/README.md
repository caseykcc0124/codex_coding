# A0 reference implementation

`A0_REFERENCE.tar.xz` includes the **exact reference/** and **tests/** sources verified locally at 25 passed / 0 failed.

SHA256: `ce9de1df5b4fcc589267f953fdd99b5d0badababb46805796db6934dd43cb450`

```bash
tar -xJf source/A0_REFERENCE.tar.xz
python -m pip install -r reference/requirements-dev.txt
python -m pytest -q tests
```

The reference A0 kernel demonstrates SQLite event routing, leases, restart, safety stopping and CRC32 golden reference. It is mock only. Do not mark B/C/D gates as passed.
