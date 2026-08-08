"""CLI entry points: generate-contexts and vars-grid."""

from __future__ import annotations

import argparse
import sys

from context_variables.paths import resolve_vars_dir


def _add_vars_dir_arg(parser: argparse.ArgumentParser) -> None:
    parser.add_argument(
        "--vars-dir",
        metavar="PATH",
        default=None,
        help=(
            "Directory containing variables.yaml, contexts.yaml, and contexts/ "
            "(default: CONTEXT_VARS_DIR / VARS_DIR / ./vars / .)"
        ),
    )


def main_generate(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        prog="generate-contexts",
        description="Generate context-specific configuration files from variables.yaml",
        epilog=(
            "Examples:\n"
            "  generate-contexts --vars-dir ~/repos/spark-observability/vars\n"
            "  generate-contexts --vars-dir ./vars spark-client -f\n"
            "  CONTEXT_VARS_DIR=./vars generate-contexts -v service-now\n"
        ),
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    _add_vars_dir_arg(parser)
    parser.add_argument(
        "contexts",
        nargs="*",
        help="Contexts to generate (default: all)",
    )
    parser.add_argument(
        "-f",
        "--force",
        action="store_true",
        help="Force regeneration even if outputs are up to date",
    )
    parser.add_argument(
        "-v",
        "--verbose",
        action="store_true",
        help="Verbose output",
    )
    args = parser.parse_args(argv)

    try:
        vars_dir = resolve_vars_dir(args.vars_dir)
    except FileNotFoundError as exc:
        print(f"Configuration error: {exc}", file=sys.stderr)
        return 2

    from context_variables.generate import run

    contexts = args.contexts if args.contexts else None
    return run(vars_dir, contexts=contexts, force=args.force, verbose=args.verbose)


def main_grid(argv: list[str] | None = None) -> int:
    # Pre-parse --vars-dir so the grid tool keeps its existing -v/--vars meaning.
    pre = argparse.ArgumentParser(add_help=False)
    _add_vars_dir_arg(pre)
    pre_args, rest = pre.parse_known_args(argv)

    try:
        vars_dir = resolve_vars_dir(pre_args.vars_dir)
    except FileNotFoundError as exc:
        print(f"Configuration error: {exc}", file=sys.stderr)
        return 2

    from context_variables.grid import run

    return run(vars_dir, argv=rest)


if __name__ == "__main__":
    raise SystemExit(main_generate())
