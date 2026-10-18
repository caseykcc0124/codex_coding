[CmdletBinding()]
param([string]$CodexRoot = $(if($env:CODEX_HOME){$env:CODEX_HOME}else{Join-Path $env:USERPROFILE '.codex'}))
$ErrorActionPreference='Stop'
$source=Join-Path (Split-Path $PSScriptRoot -Parent) 'skills/always-on'
$destination=Join-Path $CodexRoot 'skills/always-on'
$agents=Join-Path $CodexRoot 'AGENTS.md'
$backup=Join-Path $CodexRoot ('integrations/always-on/backups/'+[DateTime]::UtcNow.ToString('yyyyMMddTHHmmssfffffffZ'))
New-Item -ItemType Directory -Force -Path $backup,$destination|Out-Null
if(Test-Path -LiteralPath (Join-Path $destination 'SKILL.md')){Copy-Item -LiteralPath $destination -Destination (Join-Path $backup 'always-on') -Recurse}
Copy-Item -Path (Join-Path $source '*') -Destination $destination -Recurse -Force
$before=if(Test-Path -LiteralPath $agents){Copy-Item -LiteralPath $agents -Destination (Join-Path $backup 'AGENTS.md');[IO.File]::ReadAllText($agents)}else{''}
$block=@"
<!-- codex-always-on:begin -->
## Always-on main conversation
When the human asks to enable Always On, continue autonomously, or resume persistent work, read the installed always-on skill at $destination/SKILL.md. The current Codex conversation remains the main interface: receive tasks, execute/delegate, verify and report here. Persist intent and progress privately. Bind any authorized wake to this main using the client-supported same-thread mechanism; do not route normal tasks through an inbox, separate chat, or GitHub. For a main already activated, reconcile new human steering and continue unfinished work each turn. A new chat is not automatically the existing main: adopt/resume it only on human instruction. Preserve other instructions and all authority boundaries. Skills/rules alone do not wake exited sessions; verify actual scheduler and client support before claiming Always-on enabled.
<!-- codex-always-on:end -->
"@
$pattern='(?s)<!-- codex-always-on:begin -->.*?<!-- codex-always-on:end -->'
if([regex]::IsMatch($before,$pattern)){$after=[regex]::Replace($before,$pattern,[System.Text.RegularExpressions.MatchEvaluator]{param($m)$block})}else{$after=$before.TrimEnd()+"`n`n"+$block}
[IO.File]::WriteAllText($agents,$after.TrimEnd()+"`n",[Text.UTF8Encoding]::new($false))
[pscustomobject]@{Skill=$destination;Rules=$agents;Backup=$backup;Wake='Not created by installer; activate in the desired main conversation'}
