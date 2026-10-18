[CmdletBinding()]
param([string]$Workspace = (Split-Path $PSScriptRoot -Parent), [string]$TaskName = 'Codex-Native-Autonomy')
$ErrorActionPreference = 'Stop'
$Workspace = (Resolve-Path -LiteralPath $Workspace).Path
$runtime = Join-Path $Workspace '.autonomy/runtime'
$checkpoint = Join-Path $runtime 'checkpoint.json'
$state = if (Test-Path -LiteralPath $checkpoint) { Get-Content -LiteralPath $checkpoint -Raw | ConvertFrom-Json } else { $null }
$task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
$info = if ($task) { Get-ScheduledTaskInfo -TaskName $TaskName } else { $null }
[pscustomobject]@{
    Workspace = $Workspace
    TaskState = if ($task) { [string]$task.State } else { 'NotRegistered' }
    NextRunTime = $info.NextRunTime
    LastRunTime = $info.LastRunTime
    LastTaskResult = $info.LastTaskResult
    SessionId = $state.session_id
    Processed = $state.processed
    Blocked = $state.blocked
    LastEvent = $state.last_event
    LastStatus = $state.last_status
    LastResult = $state.last_result
    LatestLog = (Get-ChildItem -LiteralPath $runtime -Filter '*.jsonl' -ErrorAction SilentlyContinue | Sort-Object Name | Select-Object -Last 1).FullName
}
