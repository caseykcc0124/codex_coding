function Test-StalledSetupTarget {
    param($Helper,$Payload,[string]$Workspace,[datetime]$PendingUtc,[datetime]$NowUtc,[int]$TimeoutSeconds,[int[]]$DaemonIds)
    if($Helper.Name -ne 'codex-windows-sandbox-setup.exe' -or $Helper.ParentProcessId -notin $DaemonIds){return $false}
    if($Helper.CreationDate.ToUniversalTime() -lt $PendingUtc){return $false}
    if(($NowUtc-$Helper.CreationDate.ToUniversalTime()).TotalSeconds -lt $TimeoutSeconds){return $false}
    if(!$Payload.refresh_only -or !$Payload.command_cwd){return $false}
    try{return [IO.Path]::GetFullPath($Payload.command_cwd).TrimEnd('\') -eq [IO.Path]::GetFullPath($Workspace).TrimEnd('\')}catch{return $false}
}
