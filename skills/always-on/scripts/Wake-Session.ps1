[CmdletBinding()]
param([Parameter(Mandatory)][string]$Workspace)
$ErrorActionPreference='Stop'
$OutputEncoding=[Text.UTF8Encoding]::new($false)
[Console]::OutputEncoding=$OutputEncoding
$Workspace=(Resolve-Path -LiteralPath $Workspace).Path
$runtime=Join-Path $Workspace '.autonomy/runtime'
$binding=Get-Content -LiteralPath (Join-Path $runtime 'main-session.json') -Raw|ConvertFrom-Json
if($binding.workspace -ne $Workspace){throw 'Binding workspace mismatch.'}
try{$lock=[IO.File]::Open((Join-Path $runtime 'main-wake.lock'),'OpenOrCreate','ReadWrite','None')}catch [IO.IOException]{Write-Output 'WAIT: wake active';exit 0}
try{
    if(Test-Path -LiteralPath (Join-Path $runtime 'wake-suspended.json')){Write-Output 'SUSPENDED: input/recovery acceptance required';exit 0}
    $homeRoot=if($env:CODEX_HOME){$env:CODEX_HOME}else{Join-Path $env:USERPROFILE '.codex'}
    Add-Type -Path (Join-Path $PSScriptRoot 'NativeMainRpc.cs')
    $native=[NativeMainRpc]::Read((Join-Path $homeRoot 'app-server-control/app-server-control.sock'),$binding.session_id).GetAwaiter().GetResult()|ConvertFrom-Json
    if($native.error -or !$native.result.thread.status){throw 'Native main health unavailable; no wake queued.'}
    if($native.result.thread.status.type -ne 'idle'){Write-Output 'WAIT: native main is not idle';exit 0}
    $pendingPath=Join-Path $runtime 'pending-wake.json'
    $pending=if(Test-Path -LiteralPath $pendingPath){Get-Content -LiteralPath $pendingPath -Raw|ConvertFrom-Json}else{$null}
    $active=$false; $seenPending=$false; $pendingComplete=$false
    foreach($line in (Get-Content -LiteralPath $binding.transcript)){
        try{$j=$line|ConvertFrom-Json}catch{throw 'Incomplete transcript; wait for its writer before queuing.'}
        if($pending -and $j.type -eq 'response_item' -and $j.payload.type -eq 'message' -and $j.payload.role -eq 'user'){
            foreach($part in $j.payload.content){if($part.text -and $part.text.Contains($pending.marker)){$seenPending=$true}}
        }
        if($j.type -eq 'event_msg'){
            if($j.payload.type -eq 'task_started'){$active=$true}
            if($j.payload.type -in @('task_complete','turn_aborted')){$active=$false;if($seenPending){$pendingComplete=$true}}
        }
    }
    if($pending -and !$pendingComplete){Write-Output 'WAIT: previous queued wake not yet observed complete';exit 0}
    if($active){Write-Output 'WAIT: main turn active';exit 0}
    $marker='[always-on-wake:'+([guid]::NewGuid().ToString())+']'
    $prompt="$marker Continue this same main conversation latest human-authorized intent. Read private INTENT and STATE when needed; reconcile current human steering, progress pending work or explicitly authorized new source changes, verify artifacts, and report meaningful completion/failure here. Use bounded native Luna workers only when useful. No new main, inbox, framework, schedule, source scope or external authority. If nothing actionable changed, finish quietly with WAIT without rewriting state. This timer is not a new task."
    $log=Join-Path $runtime ([DateTime]::UtcNow.ToString('yyyyMMddTHHmmssfffffffZ')+'.queue.txt')
    @{marker=$marker;session_id=$binding.session_id;status='dispatching';queued_utc=[DateTime]::UtcNow.ToString('o');log=$log}|ConvertTo-Json|Set-Content -LiteralPath $pendingPath -Encoding UTF8
    $startInfo=[Diagnostics.ProcessStartInfo]::new()
    $startInfo.FileName=$binding.cli
    $startInfo.UseShellExecute=$false
    $startInfo.CreateNoWindow=$true
    $startInfo.RedirectStandardOutput=$true
    $startInfo.RedirectStandardError=$true
    foreach($argument in @('queue','--remote',$binding.remote,'--thread',$binding.session_id,'--message',$prompt)){$startInfo.ArgumentList.Add($argument)}
    $process=[Diagnostics.Process]::new()
    $process.StartInfo=$startInfo
    try{
        if(!$process.Start()){throw 'Native queue process did not start.'}
        $firstLine=$process.StandardOutput.ReadLineAsync()
        $stderr=$process.StandardError.ReadToEndAsync()
        if(!$firstLine.Wait(15000)){if(!$process.HasExited){$process.Kill()};throw 'No native queue acknowledgement. Reconcile pending marker before retry.'}
        $ack=$firstLine.Result
        $ack|Set-Content -LiteralPath $log -Encoding UTF8
        if(!$ack -or !$ack.StartsWith('Queued message ') -or !$ack.Contains($binding.session_id)){
            if(!$process.HasExited){$process.Kill()}
            if($stderr.IsCompleted){$stderr.Result|Set-Content -LiteralPath "$log.stderr.txt" -Encoding UTF8}
            throw "Native queue did not acknowledge the bound main: $log"
        }
        # The queue client may retain inherited console/transport handles after acknowledging.
        # Only end this short-lived client, never the existing server/main or its process tree.
        if(!$process.WaitForExit(2000)){$process.Kill();$null=$process.WaitForExit(1000)}
        if($stderr.IsCompleted){$stderr.Result|Set-Content -LiteralPath "$log.stderr.txt" -Encoding UTF8}
    }finally{$process.Dispose()}
    @{marker=$marker;session_id=$binding.session_id;queued_utc=[DateTime]::UtcNow.ToString('o');log=$log}|ConvertTo-Json|Set-Content -LiteralPath $pendingPath -Encoding UTF8
    Write-Output "Wake queued to existing main: $($binding.session_id)"
}catch{@{time_utc=[DateTime]::UtcNow.ToString('o');error=$_.Exception.Message}|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $runtime 'last-wake-failure.json');throw}finally{$lock.Dispose()}
