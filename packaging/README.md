# Packaging

| Path | Purpose |
|------|---------|
| `build-deb.sh` | Build `dist/context-variables_<ver>_all.deb` |
| `install.sh` | Direct install under `/opt` or `PREFIX` |
| `debian/*` | Maintainer scripts |
| `usr-bin/*` | `/usr/bin` wrappers |

```bash
./packaging/build-deb.sh
sudo dpkg -i dist/context-variables_*.deb
```

Prefer `dpkg -i` for local builds under `$HOME` (avoids apt `_apt` sandbox note).
