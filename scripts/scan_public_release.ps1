$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
$excludedNames = @(".git", "node_modules", "dist", ".next", ".vinext", ".wrangler")
$textExtensions = @(
    ".swift", ".plist", ".yml", ".yaml", ".json", ".md", ".txt",
    ".ps1", ".tsx", ".ts", ".js", ".mjs", ".css", ".svg", ".xml"
)

$files = Get-ChildItem -LiteralPath $projectRoot -Recurse -File | Where-Object {
    $relative = $_.FullName.Substring($projectRoot.Length + 1)
    -not ($excludedNames | Where-Object { $relative -match "(^|[\\/])$([regex]::Escape($_))([\\/]|$)" }) -and
    $relative -ne "scripts\scan_public_release.ps1" -and
    $relative -ne "scripts\validate_static_site.ps1" -and
    $textExtensions -contains $_.Extension.ToLowerInvariant()
}

$forbiddenPatterns = [ordered]@{
    "Apple development team" = "\bDEVELOPMENT_TEAM\b|\bDevelopmentTeam\b"
    "Personal bundle namespace" = "com\.lewisdai"
    "Private account identifiers" = "(?i)77623915|lailailai77|ECE468"
    "Personal filesystem path" = "(?i)[A-Z]:\\Users\\|/Users/|/home/"
    "Sites project identifier" = "appgprj_|appgver_|appgdep_|chatgpt\.site"
    "Private key block" = "-----BEGIN [A-Z ]*PRIVATE KEY-----"
    "Likely GitHub token" = "gh[pousr]_[A-Za-z0-9_]{20,}"
    "Likely OpenAI key" = "sk-[A-Za-z0-9_-]{20,}"
    "Real coordinate literal" = "(?i)(latitude|longitude)\s*[:=]\s*-?\d{1,3}\.\d{4,}"
}

$violations = @()
foreach ($file in $files) {
    $content = Get-Content -Raw -LiteralPath $file.FullName
    foreach ($entry in $forbiddenPatterns.GetEnumerator()) {
        if ($content -match $entry.Value) {
            $relative = $file.FullName.Substring($projectRoot.Length + 1)
            $violations += "$($entry.Key): $relative"
        }
    }
}

$forbiddenExtensions = @(".p8", ".p12", ".cer", ".mobileprovision", ".provisionprofile", ".pem", ".key", ".mp4", ".mov")
$forbiddenFiles = Get-ChildItem -LiteralPath $projectRoot -Recurse -File | Where-Object {
    $forbiddenExtensions -contains $_.Extension.ToLowerInvariant()
}

if ($forbiddenFiles) {
    $violations += $forbiddenFiles | ForEach-Object {
        "Forbidden binary or credential type: $($_.FullName.Substring($projectRoot.Length + 1))"
    }
}

if ($violations) {
    $violations | Sort-Object -Unique | ForEach-Object { Write-Error $_ }
    throw "PUBLIC_RELEASE_SCAN_FAILED"
}

Write-Output "PUBLIC_RELEASE_SCAN_OK: no personal identifiers, signing IDs, credentials, real coordinate literals, or private hosting IDs found"
