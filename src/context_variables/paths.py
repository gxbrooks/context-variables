"""Resolve the project vars directory (data plane) for generation."""

from __future__ import annotations

import os
from pathlib import Path


def resolve_vars_dir(explicit: str | Path | None = None) -> Path:
    """
    Locate the directory that contains variables.yaml, contexts.yaml, and contexts/.

    Resolution order:
      1. explicit argument (--vars-dir)
      2. CONTEXT_VARS_DIR or VARS_DIR environment variable
      3. ./vars if it contains variables.yaml
      4. . if it contains variables.yaml
    """
    candidates: list[Path] = []
    if explicit is not None:
        candidates.append(Path(explicit).expanduser().resolve())
    for env_name in ("CONTEXT_VARS_DIR", "VARS_DIR"):
        raw = os.environ.get(env_name)
        if raw:
            candidates.append(Path(raw).expanduser().resolve())
    cwd = Path.cwd().resolve()
    candidates.append(cwd / "vars")
    candidates.append(cwd)

    seen: set[Path] = set()
    for path in candidates:
        if path in seen:
            continue
        seen.add(path)
        if (path / "variables.yaml").is_file() and (path / "contexts.yaml").is_file():
            return path

    raise FileNotFoundError(
        "Could not find a vars directory containing variables.yaml and contexts.yaml. "
        "Pass --vars-dir PATH, set CONTEXT_VARS_DIR, or run from a project that has "
        "./vars/{variables,contexts}.yaml."
    )
