# scripts/binary.ps1
$ErrorActionPreference = 'Stop'

# Resolve repo paths
$PROJECT_DIR = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$SRC_DIR     = Join-Path $PROJECT_DIR 'src/mermaid_ascii'
$BUILD_DIR   = Join-Path $PROJECT_DIR 'build/mermaid_ascii'

# Clean + clone upstream
if (Test-Path $BUILD_DIR) { Remove-Item -Recurse -Force $BUILD_DIR }
git clone https://github.com/AlexanderGrooff/mermaid-ascii $BUILD_DIR

Push-Location $BUILD_DIR
try {
    # Latest tag
    $tag = (git tag --sort=-v:refname | Select-Object -First 1).Trim()
    git checkout $tag

    # Use the Go installed by actions/setup-go (on PATH in this step)
    $go = (Get-Command go).Path
    & $go version

    # Build Windows binary
    & $go build -o 'mermaid-ascii.exe'

    New-Item -ItemType Directory -Force -Path $SRC_DIR | Out-Null
    Copy-Item -Force 'mermaid-ascii.exe' (Join-Path $SRC_DIR 'mermaid-ascii.exe')
}
finally {
    Pop-Location
    if (Test-Path $BUILD_DIR) { Remove-Item -Recurse -Force $BUILD_DIR }
}
