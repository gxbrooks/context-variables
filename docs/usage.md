# context-variables(1) — generate context-specific configuration files

## NAME

`generate-contexts`, `vars-grid` — transform a project `variables.yaml` +
`contexts.yaml` into context-specific output files under `vars/contexts/`.

## SYNOPSIS

```text
generate-contexts [--vars-dir PATH] [-f] [-v] [CONTEXT ...]
vars-grid         [--vars-dir PATH] [GRID OPTIONS]
```

## DESCRIPTION

**context-variables** is a reusable generator formerly embedded under
`spark-observability/vars/`. Consuming projects keep their **data**
(`variables.yaml`, `contexts.yaml`, `secrets.yaml`, generated `contexts/`)
in-tree; this package provides only the **code** and documentation.

Each context in `contexts.yaml` names an output format (`docker-env`,
`shell_env`, `systemd_env`, `toml`, `configmap`, `ansible_vars`) and a
filename written under `<vars-dir>/contexts/`.

## OPTIONS

### Common

| Flag | Environment | Description |
|------|-------------|-------------|
| `--vars-dir PATH` | `CONTEXT_VARS_DIR` or `VARS_DIR` | Directory containing `variables.yaml` and `contexts.yaml` |

If `--vars-dir` is omitted, the tool looks for `./vars` then `.` (cwd) that
contain both YAML files.

### generate-contexts

| Flag | Description |
|------|-------------|
| `CONTEXT ...` | Limit generation to named contexts (default: all) |
| `-f`, `--force` | Regenerate even when outputs are newer than sources |
| `-v`, `--verbose` | Verbose logging |

### vars-grid

Analysis grid of variables × contexts. See `vars-grid --help` for
`--missing`, `--summary`, `-c`, `-ov`, `-oc`, `-v PATTERN`.

## FILES (in a consuming project)

| Path | Role |
|------|------|
| `vars/variables.yaml` | Source of truth for values and context tags |
| `vars/contexts.yaml` | Output formats and filenames |
| `vars/secrets.yaml` | Optional secrets (gitignored); env vars override |
| `vars/contexts/*` | Generated outputs (gitignored) |

Examples shipped with this package: `/opt/context-variables/examples/` or
`examples/` in a checkout.

## EXAMPLES

```bash
# From a project that has ./vars/variables.yaml
generate-contexts -f
generate-contexts --vars-dir ~/repos/spark-observability/vars service-now -v

# Analysis
vars-grid --vars-dir ~/repos/spark-observability/vars --summary
```

Ansible (spark-observability) calls the installed CLI:

```yaml
ansible.builtin.command:
  argv: ["generate-contexts", "--vars-dir", "{{ regenerate_contexts_vars_dir }}", "-f"]
```

## INSTALL

Debian package (preferred):

```bash
./packaging/build-deb.sh
sudo dpkg -i dist/context-variables_*.deb
```

Direct install:

```bash
sudo ./packaging/install.sh
```

Depends on `python3-yaml` (deb) or PyYAML (pip).

## EXIT STATUS

| Code | Meaning |
|------|---------|
| `0` | Success |
| `1` | Generation / analysis error |
| `2` | Configuration error (vars dir not found) |

## SEE ALSO

`docs/ARCHITECTURE.md`, `docs/IMPLEMENTATION.md`,
`docs/Context_Variable_Best_Practice.md`, `docs/SECRETS_MANAGEMENT.md`
