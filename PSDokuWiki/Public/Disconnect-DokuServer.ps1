function Disconnect-DokuServer {
    [CmdletBinding(SupportsShouldProcess=$True, ConfirmImpact='Low')]
    param(
        [Parameter(Mandatory = $false,
            Position = 1,
            HelpMessage = 'Bypass confirmations of calls during this connect/disconnect session')]
        [ValidateNotNullOrEmpty()]
        [switch]$BypassConfirm
    )

    begin {}

    process {
        if ($BypassConfirm -or $PSCmdlet.ShouldProcess("Disconnect from current server: $($Script:DokuServer.TargetUri)")) {
            if ($null -ne $Script:DokuServer) {
                Write-Verbose "Disconnecting DokuWiki instance: $($Script:DokuServer.TargetUri)"
                $Script:DokuServer = $null
            } else {
                Write-Verbose "No connections to any DokuWiki instances to disconnect"
            }
        } # should process
    } # process

    end {}
}
