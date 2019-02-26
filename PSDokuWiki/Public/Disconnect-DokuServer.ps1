function Disconnect-DokuServer {
    <#
	.SYNOPSIS
		Disconnect any open connections to a DokuWiki API endpoint

	.DESCRIPTION
		Disconnect any open connections to a DokuWiki API endpoint

	.EXAMPLE
		PS C:\> Disconnect-DokuServer

	.OUTPUTS
		Nothing

	.NOTES
		AndyDLP - 2019

	.LINK
		https://github.com/AndyDLP/PSDokuWiki
#>

    [CmdletBinding()]
    param()

    if ($null -ne $Script:DokuServer) {
        Write-Verbose "Disconnecting DokuWiki instance: $($Script:DokuServer.TargetUri)"
        $Script:DokuServer = $null
    } else {
        Write-Verbose "No connections to any DokuWiki instances to disconnect"
    }
}