[CmdletBinding()]
param([Parameter(Mandatory)][string]$Workspace,[Parameter(Mandatory)][guid]$SessionId,[switch]$NoSchedule,[switch]$ActivateHere)
$ErrorActionPreference='Stop'
$Workspace=(Resolve-Path -LiteralPath $Workspace).Path
$codexRoot=if($env:CODEX_HOME){$env:CODEX_HOME}else{Join-Path $env:USERPROFILE '.codex'}
$sessionFiles=@(Get-ChildItem -LiteralPath (Join-Path $codexRoot 'sessions') -Recurse -Filter "*$SessionId.jsonl" -File)
if($sessionFiles.Count -ne 1){throw 'Cannot uniquely identify supplied current Session UUID.'}
$meta=(Get-Content -LiteralPath $sessionFiles[0].FullName -First 1 | ConvertFrom-Json).payload
if($meta.id -ne $SessionId.ToString() -or $meta.source -notin @('cli','exec','vscode')){throw 'Unsupported session source; do not bind an unidentified client.'}
if([IO.Path]::GetFullPath($meta.cwd).TrimEnd('\') -ne $Workspace.TrimEnd('\')){throw 'Session workspace mismatch.'}
$runtime=Join-Path $Workspace '.autonomy/runtime'
New-Item -ItemType Directory -Force -Path $runtime | Out-Null
$binding=Join-Path $runtime 'main-session.json'
$old=$null
if(Test-Path -LiteralPath $binding){$old=Get-Content -LiteralPath $binding -Raw|ConvertFrom-Json;if($old.session_id -ne $SessionId.ToString() -and !$ActivateHere){throw 'Caller must identify explicit activation here; do not ask again when the human already invoked always-on.'}}
foreach($name in @('INTENT','STATE','PROGRESS')){if(!(Test-Path -LiteralPath (Join-Path $Workspace ".autonomy/$name.md"))){throw "Main must initialize private $name.md first."}}
$cli = if($env:CODEX_CLI_PATH -and (Test-Path -LiteralPath $env:CODEX_CLI_PATH)){$env:CODEX_CLI_PATH}else{(Get-Command codex.exe -ErrorAction Stop).Source}
$queueHelp = & $cli queue --help 2>&1
if($LASTEXITCODE -ne 0 -or ($queueHelp -join "`n") -notmatch '--thread'){throw 'This Codex lacks native queue support; update it before enabling Always-on.'}
$taskName='Codex-Main-'+$SessionId.ToString()
if($old -and $old.session_id -ne $SessionId.ToString()){
    $history=Join-Path $runtime ('binding-history/'+[DateTime]::UtcNow.ToString('yyyyMMddTHHmmssfffffffZ'))
    New-Item -ItemType Directory -Force -Path $history|Out-Null
    Copy-Item -LiteralPath $binding -Destination (Join-Path $history 'main-session.json')
    foreach($name in @($old.task_name,($old.task_name+'-Recovery'))){
        $prior=Get-ScheduledTask -TaskName $name -ErrorAction SilentlyContinue
        if($prior){
            if($prior.Actions.Count -ne 1 -or $prior.Actions[0].Arguments -notlike '*always-on*scripts*'){throw 'Old task is not a verified always-on helper.'}
            Disable-ScheduledTask -TaskName $name|Out-Null
        }
    }
    foreach($name in @('pending-wake.json','work-status.json')){$path=Join-Path $runtime $name;if(Test-Path -LiteralPath $path){Move-Item -LiteralPath $path -Destination (Join-Path $history $name)}}
}
@{session_id=$SessionId.ToString();workspace=$Workspace;transcript=$sessionFiles[0].FullName;task_name=$taskName;cli=$cli;remote='unix://'}|ConvertTo-Json|Set-Content -LiteralPath $binding -Encoding UTF8
if(!$NoSchedule){
    if(Test-Path -LiteralPath (Join-Path $runtime 'wake-suspended.json')){throw 'Prior input regression is unresolved; keep timer suspended until input/recovery acceptance passes.'}
    $runner=Join-Path $PSScriptRoot 'Wake-Session.ps1'
    $shell=(Get-Command pwsh.exe -ErrorAction Stop).Source
    $action=New-ScheduledTaskAction -Execute $shell -Argument "-NoProfile -NonInteractive -WindowStyle Hidden -File `"$runner`" -Workspace `"$Workspace`"" -WorkingDirectory $Workspace
    $trigger=New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(15) -RepetitionInterval (New-TimeSpan -Minutes 15)
    $settings=New-ScheduledTaskSettingsSet -MultipleInstances IgnoreNew -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Hours 2)
    $principal=New-ScheduledTaskPrincipal -UserId ([Security.Principal.WindowsIdentity]::GetCurrent().Name) -LogonType Interactive -RunLevel Limited
    $existing=Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
    if($existing){
        if($existing.Actions.Count -ne 1 -or $existing.Actions[0].Execute -ne $shell -or $existing.Actions[0].Arguments -ne $action.Arguments){throw 'Existing task action mismatch; do not overwrite another scheduler.'}
        Enable-ScheduledTask -TaskName $taskName|Out-Null
    }else{Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Principal $principal|Out-Null}
    try{
    $watchName=$taskName+'-Recovery'
    $watchRunner=Join-Path $PSScriptRoot 'Watch-Main.ps1'
    $watchAction=New-ScheduledTaskAction -Execute $shell -Argument "-NoProfile -NonInteractive -WindowStyle Hidden -File `"$watchRunner`" -Workspace `"$Workspace`"" -WorkingDirectory $Workspace
    $watchTrigger=New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) -RepetitionInterval (New-TimeSpan -Minutes 1)
    $watchSettings=New-ScheduledTaskSettingsSet -MultipleInstances IgnoreNew -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Minutes 2)
    $existingWatch=Get-ScheduledTask -TaskName $watchName -ErrorAction SilentlyContinue
    if($existingWatch){
        if($existingWatch.Actions.Count -ne 1 -or $existingWatch.Actions[0].Execute -ne $shell -or $existingWatch.Actions[0].Arguments -ne $watchAction.Arguments){throw 'Recovery task action mismatch.'}
        Enable-ScheduledTask -TaskName $watchName|Out-Null
    }else{Register-ScheduledTask -TaskName $watchName -Action $watchAction -Trigger $watchTrigger -Settings $watchSettings -Principal $principal|Out-Null}
    }catch{Disable-ScheduledTask -TaskName $taskName|Out-Null;throw}
}
$workStatus=Join-Path $runtime 'work-status.json'
if(!(Test-Path -LiteralPath $workStatus)){@{session_id=$SessionId.ToString();status='idle';reason='No unfinished task declared by the main conversation.'}|ConvertTo-Json|Set-Content -LiteralPath $workStatus -Encoding UTF8}
[pscustomobject]@{SessionId=$SessionId;TaskName=$taskName;Scheduled=(!$NoSchedule)}
