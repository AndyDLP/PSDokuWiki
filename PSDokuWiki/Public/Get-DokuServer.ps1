function Get-DokuServer {
    <#
	.SYNOPSIS
		Gets any current connection to a DokuWiki API

	.DESCRIPTION
        Gets any current connection to a DokuWiki API

	.PARAMETER IsConnected
		Only return TRUE if currently connected and FALSE if not

	.EXAMPLE
		PS C:\> Get-DokuServer | Format-List -Property *

	.OUTPUTS
		DokuWiki.Session.Detail,Boolean

	.NOTES
		AndyDLP - 2019

	.LINK
		https://github.com/AndyDLP/PSDokuWiki
#>
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
