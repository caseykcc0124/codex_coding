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
    $active=$false
    foreach($line in (Get-Content -LiteralPath $binding.transcript)){
        try{$j=$line|ConvertFrom-Json}catch{throw 'Incomplete transcript; skip unsafe concurrent resume.'}
        if($j.type -eq 'event_msg'){
            if($j.payload.type -eq 'task_started'){$active=$true}
            if($j.payload.type -in @('task_complete','turn_aborted')){$active=$false}
        }
    }
    if($active){Write-Output 'WAIT: main turn active';exit 0}
    $prompt='Continue this same main conversation latest human-authorized intent. Read .autonomy/INTENT.md and STATE.md, reconcile latest human steering, progress pending work or explicitly authorized new source changes, and verify artifacts before completion. Use native gpt-6-luna low workers only when useful; no recursive delegation. Do not create another main, inbox, UI, scheduler, or expand authority. Save meaningful checkpoints and report meaningful completion/failure/required decisions in this conversation. If no actionable change exists, return WAIT without rewriting state. Never treat this timer as a new task. Use native shell for local files.'
    $log=Join-Path $runtime ([DateTime]::UtcNow.ToString('yyyyMMddTHHmmssfffffffZ')+'.main.jsonl')
    Push-Location -LiteralPath $Workspace
    try{
        $ErrorActionPreference='Continue'
        $prompt|& codex exec resume $binding.session_id --json -m gpt-6.1-sol -c model_reasoning_effort=low -c 'sandbox_mode="workspace-write"' -c 'windows.sandbox="mxc"' - 1> $log 2> "$log.stderr.txt"
        $code=$LASTEXITCODE
    }finally{$ErrorActionPreference='Stop';Pop-Location}
    $events=@(Get-Content -LiteralPath $log|ForEach-Object{$_|ConvertFrom-Json})
    $started=@($events|Where-Object type -eq 'thread.started')
    if($code -ne 0 -or $started.Count -ne 1 -or $started[0].thread_id -ne $binding.session_id -or !($events|Where-Object type -eq 'turn.completed')){throw "Bound main resume failed: $log"}
    Write-Output "Main resumed: $($binding.session_id)"
}finally{$lock.Dispose()}
