$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$siteRoot = Join-Path $repoRoot "docs"
$indexPath = Join-Path $siteRoot "index.html"
$cssPath = Join-Path $siteRoot "styles.css"
$cnamePath = Join-Path $siteRoot "CNAME"

foreach ($required in @($indexPath, $cssPath, $cnamePath, (Join-Path $siteRoot "favicon.svg"), (Join-Path $siteRoot ".nojekyll"))) {
    if (-not (Test-Path -LiteralPath $required -PathType Leaf)) {
        throw "Missing required static-site file: $required"
    }
}

$html = Get-Content -LiteralPath $indexPath -Raw
$css = Get-Content -LiteralPath $cssPath -Raw
$cname = (Get-Content -LiteralPath $cnamePath -Raw).Trim()

$requiredHtml = @(
    'https://never-miss-golf.com/',
    'https://github.com/Lewisdai78/never-miss-golf-open-source',
    'Content-Security-Policy',
    'Never Miss Golf requests the handoff',
    'The prototype does not silently control Apple Workout'
)

foreach ($needle in $requiredHtml) {
    if (-not $html.Contains($needle)) {
        throw "Static site is missing required content: $needle"
    }
}

$blockedPatterns = @(
    'chatgpt\.site',
    'lailailai77',
    'localhost',
    'appgprj_',
    'appgdom_',
    'google-analytics',
    'googletagmanager',
    '<script\b'
)

foreach ($pattern in $blockedPatterns) {
    if ($html -match $pattern -or $css -match $pattern) {
        throw "Static site contains blocked public content: $pattern"
    }
}

if ($cname -cne 'never-miss-golf.com') {
    throw "CNAME must contain only never-miss-golf.com"
}

Write-Host "Static site validation passed."
