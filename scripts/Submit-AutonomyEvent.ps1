[CmdletBinding()]
param(
    [string]$Workspace = (Split-Path $PSScriptRoot -Parent),
    [Parameter(Mandatory)][ValidatePattern('^[A-Za-z0-9][A-Za-z0-9_-]{0,79}$')][string]$EventId,
    [Parameter(Mandatory)][string]$Task,
    [Parameter(Mandatory)][string]$Acceptance
)
$ErrorActionPreference = 'Stop'
$Workspace = (Resolve-Path -LiteralPath $Workspace).Path
$inbox = Join-Path $Workspace '.autonomy/inbox'
New-Item -ItemType Directory -Force -Path $inbox | Out-Null
$path = Join-Path $inbox "$EventId.md"
if (Test-Path -LiteralPath $path) { throw 'Event ID already exists; inspect and update the existing event deliberately.' }
$content = "event_id: $EventId`nsource: human_local_inbox`n`n## Task`n$Task`n`n## Acceptance`n$Acceptance`n"
# A single CreateNew write prevents replacing an existing task.
$stream = [IO.File]::Open($path, 'CreateNew', 'Write', 'None')
try { $bytes = [Text.UTF8Encoding]::new($false).GetBytes($content); $stream.Write($bytes,0,$bytes.Length) }
finally { $stream.Dispose() }
Write-Output $path
