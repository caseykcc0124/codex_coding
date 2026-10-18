[CmdletBinding()]
param([Parameter(Mandatory)][string]$Workspace,[int]$SetupTimeoutSeconds=120)
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'Recovery-Policy.ps1')
$Workspace=(Resolve-Path -LiteralPath $Workspace).Path
$runtime=Join-Path $Workspace '.autonomy/runtime'
$binding=Get-Content -LiteralPath (Join-Path $runtime 'main-session.json') -Raw|ConvertFrom-Json
$task=Get-ScheduledTask -TaskName $binding.task_name -ErrorAction Stop
if($task.State -eq 'Disabled'){Write-Output 'PAUSED';exit 0}
$pendingPath=Join-Path $runtime 'pending-wake.json'
if(!(Test-Path -LiteralPath $pendingPath)){Write-Output 'NO_AUTOMATIC_TURN';exit 0}
$pending=Get-Content -LiteralPath $pendingPath -Raw|ConvertFrom-Json
$homeRoot=if($env:CODEX_HOME){$env:CODEX_HOME}else{Join-Path $env:USERPROFILE '.codex'}
$socket=Join-Path $homeRoot 'app-server-control/app-server-control.sock'
Add-Type -Path (Join-Path $PSScriptRoot 'NativeMainRpc.cs')
$response=[NativeMainRpc]::Read($socket,$binding.session_id).GetAwaiter().GetResult()|ConvertFrom-Json
if($response.error){throw 'Cannot verify native main status; recovery refused.'}
$thread=$response.result.thread
if($thread.status.type -eq 'idle'){
    $priorPath=Join-Path $runtime 'recovery.json'
    if(Test-Path -LiteralPath $priorPath){$prior=Get-Content -LiteralPath $priorPath -Raw|ConvertFrom-Json;if($prior.requires_native_idle_confirmation){$prior.requires_native_idle_confirmation=$false;$prior|Add-Member -NotePropertyName native_idle_confirmed_utc -NotePropertyValue ([DateTime]::UtcNow.ToString('o')) -Force;$prior|ConvertTo-Json|Set-Content -LiteralPath $priorPath -Encoding UTF8}}
    Write-Output 'HEALTHY_IDLE';exit 0
}
$latest=@($thread.turns)|Select-Object -Last 1
$userText=(@($latest.items|Where-Object type -eq 'userMessage'|ForEach-Object {$_.content}|ForEach-Object {$_.text}) -join '')
if(!$userText.Contains($pending.marker)){Write-Output 'HUMAN_OR_OTHER_TURN: recovery refused';exit 0}
$recoveryPath=Join-Path $runtime 'recovery.json'
$attempts=0
if(Test-Path -LiteralPath $recoveryPath){$previous=Get-Content -LiteralPath $recoveryPath -Raw|ConvertFrom-Json;if($previous.marker -eq $pending.marker){$attempts=[int]$previous.attempts}}
if($attempts -ge 2){Disable-ScheduledTask -TaskName $binding.task_name|Out-Null;throw 'Repeated automatic recovery failed; wakes suspended.'}
$pendingTime=if($pending.queued_utc -is [datetime]){$pending.queued_utc.ToUniversalTime()}elseif($pending.queued_utc -is [datetimeoffset]){$pending.queued_utc.UtcDateTime}else{[DateTimeOffset]::Parse([string]$pending.queued_utc).UtcDateTime}
$parents=@{}
Get-CimInstance Win32_Process -Filter "name='codex.exe'"|ForEach-Object {if($_.CommandLine -like '*app-server*--managed-daemon*'){$parents[$_.ProcessId]=$true}}
$recovered=@()
foreach($helper in (Get-CimInstance Win32_Process -Filter "name='codex-windows-sandbox-setup.exe'")){
    # Match only idempotent setup refresh for this workspace, never user commands or servers.
    $encoded=($helper.CommandLine.Trim() -split '\s+')[-1].Trim('"')
    try{$payload=[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($encoded))|ConvertFrom-Json}catch{continue}
    if(!(Test-StalledSetupTarget -Helper $helper -Payload $payload -Workspace $Workspace -PendingUtc $pendingTime -NowUtc ([datetime]::UtcNow) -TimeoutSeconds $SetupTimeoutSeconds -DaemonIds @($parents.Keys))){continue}
    # Recheck identity to avoid PID reuse before ending this temporary helper only.
    $current=Get-CimInstance Win32_Process -Filter "ProcessId=$($helper.ProcessId)"
    if($current.CreationDate -ne $helper.CreationDate -or $current.ParentProcessId -ne $helper.ParentProcessId){continue}
    Stop-Process -Id $helper.ProcessId -ErrorAction Stop
    $recovered+=$helper.ProcessId
}
if($recovered.Count){
    @{marker=$pending.marker;attempts=($attempts+1);time_utc=[DateTime]::UtcNow.ToString('o');action='stop_stalled_setup_refresh_only';helper_pids=$recovered;requires_native_idle_confirmation=$true}|ConvertTo-Json|Set-Content -LiteralPath $recoveryPath -Encoding UTF8
    Write-Output 'RECOVERY_REQUESTED: verify native idle on next check'
}else{Write-Output 'NO_VERIFIED_RECOVERY_TARGET'}
