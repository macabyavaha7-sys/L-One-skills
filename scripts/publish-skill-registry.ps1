$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$source = 'E:\L-One知识库\L-One知识库\具体有用的技能库\codex-video-tools-下载1-2026-05-06\07-skill-registry\skill-registry.html'
$target = Join-Path $repoRoot 'index.html'

if (-not (Test-Path -LiteralPath $source)) {
  throw "Source registry HTML was not found: $source"
}

Copy-Item -LiteralPath $source -Destination $target -Force

Push-Location $repoRoot
try {
  git status -sb
  git add index.html README.md .nojekyll scripts/publish-skill-registry.ps1

  $pending = git diff --cached --name-only
  if (-not $pending) {
    Write-Host 'No registry changes to publish.'
    exit 0
  }

  $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
  git commit -m "Update skill registry site $timestamp"
  git push origin main
}
finally {
  Pop-Location
}
