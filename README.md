# context-variables

Generate **context-specific configuration files** from a project’s
`variables.yaml` + `contexts.yaml` (optional `secrets.yaml`).

Extracted from `spark-observability/vars/` so the generator can be installed
once and reused. Consuming projects keep their YAML data and generated
`contexts/` locally.

## Layout

```
context-variables/
  src/context_variables/   # library + CLI
  docs/                    # architecture, TPG, usage (man-page style)
  examples/                # sample YAML (not live project data)
  packaging/               # build-deb.sh, install.sh
```

## Quick start

```bash
python3 -m venv .venv && . .venv/bin/activate
pip install -e .

generate-contexts --vars-dir ~/repos/spark-observability/vars -f
vars-grid --vars-dir ~/repos/spark-observability/vars --summary
```

Or after Debian install (`generate-contexts` / `vars-grid` on `PATH`):

```bash
generate-contexts --vars-dir /path/to/project/vars
```

## Documentation

| Doc | Purpose |
|-----|---------|
| [docs/usage.md](docs/usage.md) | Operator / man-page style reference |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Design and data flow |
| [docs/IMPLEMENTATION.md](docs/IMPLEMENTATION.md) | Formats and consumers |
| [docs/Context_Variable_Best_Practice.md](docs/Context_Variable_Best_Practice.md) | TPG |
| [docs/SECRETS_MANAGEMENT.md](docs/SECRETS_MANAGEMENT.md) | Secrets handling |

## Install (Linux)

```bash
./packaging/build-deb.sh
sudo dpkg -i dist/context-variables_*.deb
```

See [packaging/README.md](packaging/README.md).
