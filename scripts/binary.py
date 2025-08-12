# scripts/binary.py
from __future__ import annotations

import platform
import shutil
import subprocess
import sys
from pathlib import Path
from typing import Sequence


def _run(cmd: Sequence[str]) -> None:
    """Run a command streaming output; raise on failure."""
    print(f'[build] Running: {" ".join(cmd)}')
    subprocess.run(cmd, check=True)


def run_make_binary() -> None:
    """
    Build the platform-specific mermaid-ascii binary and copy it into
    src/mermaid_ascii/ so Poetry can package it.

    - On Unix (Linux/macOS): runs scripts/binary.sh with Bash.
    - On Windows: runs scripts/binary.ps1 with PowerShell (pwsh/powershell).
    """
    scripts_dir = Path(__file__).parent

    if platform.system() == 'Windows':
        # Prefer PowerShell 7 'pwsh', fall back to Windows PowerShell.
        pwsh = (
            shutil.which('pwsh') or shutil.which('powershell') or 'powershell'
        )
        script = str(scripts_dir / 'binary.ps1')
        _run(
            [pwsh, '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', script]
        )
    else:
        bash = shutil.which('bash') or '/bin/bash'
        script = str(scripts_dir / 'binary.sh')
        _run([bash, script])


if __name__ == '__main__':
    try:
        run_make_binary()
    except subprocess.CalledProcessError as e:
        sys.stderr.write(
            f'[build] command failed with exit code {e.returncode}\n'
        )
        sys.exit(e.returncode)
