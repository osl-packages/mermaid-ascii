"""Mermaid-ASCII CLI wrapper."""

from __future__ import annotations

import platform
import shutil
import subprocess
import sys
from pathlib import Path
from typing import List


def _candidate_basenames() -> list[str]:
    """
    Return candidate executable basenames for this platform.

    We include both names so the same code path works in editable installs too.
    """
    if platform.system() == 'Windows':
        return ['mermaid-ascii.exe', 'mermaid-ascii']
    return ['mermaid-ascii', 'mermaid-ascii.exe']


def _find_packaged_binary() -> Path | None:
    """
    Look for the packaged binary next to this module.

    Returns the first existing candidate or None.
    """
    pkg_dir = Path(__file__).parent
    for name in _candidate_basenames():
        p = pkg_dir / name
        if p.exists():
            return p
    return None


def _resolve_binary() -> str:
    """
    Resolve the mermaid-ascii executable to run.

    Order:
      1) Packaged binary in this wheel (next to this module).
      2) System PATH lookup (useful in dev).
    """
    packaged = _find_packaged_binary()
    if packaged is not None:
        return str(packaged)

    # Fallback to PATH
    exe_name = (
        'mermaid-ascii.exe'
        if platform.system() == 'Windows'
        else 'mermaid-ascii'
    )
    found = shutil.which(exe_name)
    if found:
        return found

    raise FileNotFoundError(
        "Could not find the 'mermaid-ascii' binary. "
        'Make sure the wheel includes it (see pyproject include) '
        "or that 'mermaid-ascii' is on PATH."
    )


def run(args: List[str]) -> int:
    """
    Run the underlying mermaid-ascii binary, forwarding CLI args.

    Parameters
    ----------
    args : list[str]
        Typically sys.argv

    Returns
    -------
    int
        Process return code.
    """
    bin_path = _resolve_binary()
    cmd = [bin_path] + args[1:]
    # inherit stdout/stderr so help/output streams naturally
    completed = subprocess.run(cmd)
    return completed.returncode


def mermaid_ascii() -> None:
    """Console entry point defined in pyproject (tool.poetry.scripts)."""
    rc = run(sys.argv)
    sys.exit(rc)


if __name__ == '__main__':
    mermaid_ascii()
