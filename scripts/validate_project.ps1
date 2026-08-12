$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
$requiredFiles = @(
    "project.yml",
    "Config\Info-iOS.plist",
    "Config\Info-watchOS.plist",
    "Shared\NotificationContract.swift",
    "Shared\ReminderStateMachine.swift",
    "iOS\Services\CourseMonitor.swift",
    "iOS\Services\NotificationCoordinator.swift",
    "Watch\Services\WorkoutOpener.swift",
    "Tests\ReminderStateMachineTests.swift"
)

foreach ($relativePath in $requiredFiles) {
    $absolutePath = Join-Path $projectRoot $relativePath
    if (-not (Test-Path -LiteralPath $absolutePath)) {
        throw "Missing required file: $relativePath"
    }
}

[xml](Get-Content -Raw -LiteralPath (Join-Path $projectRoot "Config\Info-iOS.plist")) | Out-Null
[xml](Get-Content -Raw -LiteralPath (Join-Path $projectRoot "Config\Info-watchOS.plist")) | Out-Null

$sourceRoots = @("Shared", "iOS", "Watch") | ForEach-Object {
    Join-Path $projectRoot $_
}
$sourceFiles = Get-ChildItem -Path $sourceRoots -Recurse -Filter "*.swift"
$sourceText = ($sourceFiles | Get-Content -Raw) -join "`n"

$forbiddenPatterns = @(
    "HKWorkoutSession",
    "WKInterfaceDevice\s*\.\s*current",
    "URLSession",
    "NWConnection",
    "Firebase",
    "Analytics"
)

foreach ($pattern in $forbiddenPatterns) {
    if ($sourceText -match $pattern) {
        throw "Forbidden implementation pattern found: $pattern"
    }
}

$requiredActionIdentifiers = @(
    "OPEN_APPLE_WORKOUT",
    "NOT_TODAY",
    "SNOOZE_TEN_MINUTES"
)

foreach ($identifier in $requiredActionIdentifiers) {
    if ($sourceText -notmatch [regex]::Escape($identifier)) {
        throw "Missing notification action identifier: $identifier"
    }
}

if (Get-ChildItem -Path $projectRoot -Recurse -Filter "*.entitlements") {
    throw "Unexpected entitlements file found. P0 must not enable HealthKit or other entitlements."
}

Write-Output "VALIDATION_OK: structure, plists, action contract, privacy boundaries"

