function Disconnect-DokuServer {
    [CmdletBinding()]
    param()

    if ($null -ne $Script:DokuServer) {
        Write-Verbose "Disconnecting DokuWiki instance: $($Script:DokuServer.TargetUri)"
        $Script:DokuServer = $null
    } else {
        Write-Verbose "No connections to any DokuWiki instances to disconnect"
    }
}