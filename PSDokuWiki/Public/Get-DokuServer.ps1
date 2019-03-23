function Get-DokuServer {
    [CmdletBinding()]
    param
    (
		[Parameter(Mandatory = $false,
                   Position = 1,
                   HelpMessage = 'Only return TRUE if currently connected')]
        [switch]$IsConnected
    )

    if ($null -ne $Script:DokuServer) {
        Write-Verbose "Currently connected to DokuWiki server: $($Script:DokuServer.TargetUri)"
        if ($IsConnected) {
            $true
        } else {
            $Output += $Script:DokuServer
            $Output
        }
    } else {
        Write-Verbose "Not currently connected to any DokuWiki servers"
        if ($IsConnected) {
            $false
        }
    }
}
