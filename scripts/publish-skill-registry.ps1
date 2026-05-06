$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$source = 'E:\L-One知识库\L-One知识库\具体有用的技能库\codex-video-tools-下载1-2026-05-06\07-skill-registry\skill-registry.html'
$target = Join-Path $repoRoot 'index.html'

if (-not (Test-Path -LiteralPath $source)) {
  throw "Source registry HTML was not found: $source"
}

Copy-Item -LiteralPath $source -Destination $target -Force

function Get-GitHubStars {
  param([Parameter(Mandatory = $true)][string]$Repo)

  $url = "https://github.com/$Repo"
  $response = Invoke-WebRequest -Uri $url -Headers @{ 'User-Agent' = 'Mozilla/5.0' } -UseBasicParsing -TimeoutSec 30
  $html = $response.Content
  $exact = [regex]::Match($html, 'title="([0-9,]+)"[^>]*aria-label="[0-9.,kKmM]+\s+users\s+starred')
  if ($exact.Success) {
    return [int]($exact.Groups[1].Value -replace ',', '')
  }

  $compact = [regex]::Match($html, 'aria-label="([0-9.,]+)([kKmM]?)\s+users\s+starred\s+this\s+repository"')
  if (-not $compact.Success) {
    throw "Could not parse GitHub stars for $Repo"
  }

  $number = [double]($compact.Groups[1].Value -replace ',', '')
  switch ($compact.Groups[2].Value.ToLowerInvariant()) {
    'k' { return [int]($number * 1000) }
    'm' { return [int]($number * 1000000) }
    default { return [int]$number }
  }
}

function Format-StarCount {
  param([Parameter(Mandatory = $true)][int]$Value)
  return $Value.ToString('N0', [Globalization.CultureInfo]::InvariantCulture)
}

$starRepos = @(
  'agentskills/agentskills',
  'yt-dlp/yt-dlp',
  'nilaoda/BBDown',
  'nilaoda/N_m3u8DL-RE',
  'streamlink/streamlink',
  'alexta69/metube',
  'iawia002/lux',
  'soimort/you-get',
  'FFmpeg/FFmpeg',
  'ImageMagick/ImageMagick',
  'chirlu/sox',
  'assimp/assimp',
  'electron/electron',
  'tauri-apps/tauri'
)

$stars = @{}
foreach ($repo in $starRepos) {
  $stars[$repo] = Get-GitHubStars -Repo $repo
}

$skillTotals = @{
  'open-source-to-skill-library' = $stars['agentskills/agentskills']
  'video-download-skill' = $stars['yt-dlp/yt-dlp'] + $stars['nilaoda/BBDown'] + $stars['nilaoda/N_m3u8DL-RE'] + $stars['streamlink/streamlink'] + $stars['alexta69/metube'] + $stars['iawia002/lux'] + $stars['soimort/you-get']
  'format-conversion-factory' = $stars['FFmpeg/FFmpeg'] + $stars['ImageMagick/ImageMagick'] + $stars['chirlu/sox'] + $stars['assimp/assimp']
  'web-project-to-desktop-app' = $stars['electron/electron'] + $stars['tauri-apps/tauri']
}

$content = [IO.File]::ReadAllText($target, [Text.Encoding]::UTF8)
$skillOrder = @('open-source-to-skill-library', 'video-download-skill', 'format-conversion-factory', 'web-project-to-desktop-app')
foreach ($skillId in $skillOrder) {
  $formatted = Format-StarCount -Value $skillTotals[$skillId]
  $pattern = "(id: '$([regex]::Escape($skillId))'[\s\S]*?githubStars:\s*)'[^']+'"
  $content = [regex]::Replace($content, $pattern, "`$1'$formatted'", 1)
}

foreach ($repo in $starRepos) {
  $formatted = Format-StarCount -Value $stars[$repo]
  $url = "https://github.com/$repo"
  $pattern = "('$([regex]::Escape($url))',\s*)'[^']+'"
  $content = [regex]::Replace($content, $pattern, "`$1'$formatted'", 1)
}

$content = $content.Replace("GitHub 星数待同步", "GitHub 星数已同步")
[IO.File]::WriteAllText($target, $content, [Text.UTF8Encoding]::new($false))

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
