[CmdletBinding()]
param(
    [string]$Workspace = (Split-Path $PSScriptRoot -Parent),
    [string]$TaskName = 'Codex-Native-Autonomy',
    [switch]$Once
)
$ErrorActionPreference = 'Stop'
$Workspace = (Resolve-Path -LiteralPath $Workspace).Path
$runner = Join-Path $PSScriptRoot 'Invoke-Autonomy.ps1'
if ($Workspace.Contains('"') -or $runner.Contains('"')) { throw 'Unsupported quote in path.' }
if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) { throw "Task already exists: $TaskName" }
$shellCommand = Get-Command pwsh.exe -ErrorAction SilentlyContinue
if (!$shellCommand) { $shellCommand = Get-Command powershell.exe -ErrorAction Stop }
$shell = $shellCommand.Source
$action = New-ScheduledTaskAction -Execute $shell -Argument "-NoProfile -NonInteractive -File `"$runner`" -Workspace `"$Workspace`"" -WorkingDirectory $Workspace
$start = (Get-Date).AddMinutes(1)
if ($Once) { $trigger = New-ScheduledTaskTrigger -Once -At $start }
else { $trigger = New-ScheduledTaskTrigger -Once -At $start -RepetitionInterval (New-TimeSpan -Minutes 15) }
$settings = New-ScheduledTaskSettingsSet -MultipleInstances IgnoreNew -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Hours 2)
$principal = New-ScheduledTaskPrincipal -UserId ([Security.Principal.WindowsIdentity]::GetCurrent().Name) -LogonType Interactive -RunLevel Limited
Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Settings $settings -Principal $principal | Out-Null
Get-ScheduledTaskInfo -TaskName $TaskName | Select-Object TaskName,NextRunTime,LastTaskResult
