[CmdletBinding()]
param([Parameter(Mandatory)][string]$Workspace,[Parameter(Mandatory)][guid]$SessionId,[switch]$NoSchedule)
$ErrorActionPreference='Stop'
$Workspace=(Resolve-Path -LiteralPath $Workspace).Path
$codexRoot=if($env:CODEX_HOME){$env:CODEX_HOME}else{Join-Path $env:USERPROFILE '.codex'}
$matches=@(Get-ChildItem -LiteralPath (Join-Path $codexRoot 'sessions') -Recurse -Filter "*$SessionId.jsonl" -File)
if($matches.Count -ne 1){throw 'Cannot uniquely identify supplied current Session UUID.'}
$meta=(Get-Content -LiteralPath $matches[0].FullName -First 1 | ConvertFrom-Json).payload
if($meta.id -ne $SessionId.ToString() -or $meta.source -notin @('cli','exec')){throw 'Binding supports verified CLI/exec sessions only; use native heartbeat for desktop.'}
if([IO.Path]::GetFullPath($meta.cwd).TrimEnd('\') -ne $Workspace.TrimEnd('\')){throw 'Session workspace mismatch.'}
$runtime=Join-Path $Workspace '.autonomy/runtime'
New-Item -ItemType Directory -Force -Path $runtime | Out-Null
$binding=Join-Path $runtime 'main-session.json'
if(Test-Path -LiteralPath $binding){$old=Get-Content -LiteralPath $binding -Raw|ConvertFrom-Json;if($old.session_id -ne $SessionId.ToString()){throw 'Another main is bound. Pause and explicitly migrate it before rebinding.'}}
foreach($name in @('INTENT','STATE','PROGRESS')){if(!(Test-Path -LiteralPath (Join-Path $Workspace ".autonomy/$name.md"))){throw "Main must initialize private $name.md first."}}
$taskName='Codex-Main-'+$SessionId.ToString()
@{session_id=$SessionId.ToString();workspace=$Workspace;transcript=$matches[0].FullName;task_name=$taskName}|ConvertTo-Json|Set-Content -LiteralPath $binding -Encoding UTF8
if(!$NoSchedule){
    if(Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue){throw 'Task exists; inspect and enable it instead of duplicating.'}
    $runner=Join-Path $PSScriptRoot 'Wake-Session.ps1'
    $shell=(Get-Command pwsh.exe -ErrorAction Stop).Source
    $action=New-ScheduledTaskAction -Execute $shell -Argument "-NoProfile -NonInteractive -WindowStyle Hidden -File `"$runner`" -Workspace `"$Workspace`"" -WorkingDirectory $Workspace
    $trigger=New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(15) -RepetitionInterval (New-TimeSpan -Minutes 15)
    $settings=New-ScheduledTaskSettingsSet -MultipleInstances IgnoreNew -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Hours 2)
    $principal=New-ScheduledTaskPrincipal -UserId ([Security.Principal.WindowsIdentity]::GetCurrent().Name) -LogonType Interactive -RunLevel Limited
    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Principal $principal|Out-Null
}
[pscustomobject]@{SessionId=$SessionId;TaskName=$taskName;Scheduled=(!$NoSchedule)}
