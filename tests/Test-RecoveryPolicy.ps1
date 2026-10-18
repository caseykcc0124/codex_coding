$ErrorActionPreference='Stop'
. (Join-Path (Split-Path $PSScriptRoot -Parent) 'skills/always-on/scripts/Recovery-Policy.ps1')
$now=[datetime]::UtcNow
$helper=[pscustomobject]@{Name='codex-windows-sandbox-setup.exe';ParentProcessId=101;CreationDate=$now.AddSeconds(-150)}
$payload=[pscustomobject]@{refresh_only=$true;command_cwd='C:/authorized'}
$arguments=@{Helper=$helper;Payload=$payload;Workspace='C:/authorized';PendingUtc=$now.AddSeconds(-180);NowUtc=$now;TimeoutSeconds=120;DaemonIds=@(101)}
if(!(Test-StalledSetupTarget @arguments)){throw 'Verified stale refresh rejected'}
$payload.command_cwd='C:/unrelated'
if(Test-StalledSetupTarget @arguments){throw 'Unrelated workspace allowed'}
$payload.command_cwd='C:/authorized';$payload.refresh_only=$false
if(Test-StalledSetupTarget @arguments){throw 'Non-refresh operation allowed'}
$payload.refresh_only=$true;$helper.ParentProcessId=999
if(Test-StalledSetupTarget @arguments){throw 'Unrelated parent allowed'}
$helper.ParentProcessId=101;$helper.CreationDate=$now.AddSeconds(-30)
if(Test-StalledSetupTarget @arguments){throw 'Healthy recent setup allowed'}
$helper.CreationDate=$now.AddSeconds(-200)
if(Test-StalledSetupTarget @arguments){throw 'Older unrelated setup allowed'}
Write-Output 'RECOVERY_TARGET_BOUNDARIES_OK'
