function Get-DokuServer {
    <#
	.SYNOPSIS
		Gets any current connection to a DokuWiki API

	.DESCRIPTION
        Gets any current connection to a DokuWiki API
        
	.EXAMPLE
		PS C:\> Get-DokuServer | Format-List -Property *

	.OUTPUTS
		DokuWiki.Session.Detail,PSCustomObject

	.NOTES
		AndyDLP - 2019

	.LINK
		https://github.com/AndyDLP/PSDokuWiki
#>
    [CmdletBinding()]
    param ()

    if ($null -ne $Script:DokuServer) {
        Write-Verbose "Currently connected to DokuWiki server: $($Script:DokuServer.TargetUri)"
        $Output += $Script:DokuServer
        return $Output
    } else {
        Write-Verbose "Not currently connected to any DokuWiki servers"
    }
}
