function Get-DokuServerRpcVersionSupported {
<#
	.SYNOPSIS
		Returns the servers minimum supported RPC API version.

	.DESCRIPTION
		Returns the servers minimum supported RPC API version.

	.EXAMPLE
		PS C:\> $RPCVersionsSupported = Get-DokuServerRpcVersionSupported

	.OUTPUTS
		System.Management.Automation.PSObject

	.NOTES
		AndyDLP - 2018-05-26
#>

	[CmdletBinding(PositionalBinding = $true)]
	[OutputType([psobject])]
	param
	(
	)

	begin {

	} # begin

	process {
		$APIResponse = Invoke-DokuApiCall -MethodName 'wiki.getRPCVersionSupported' -MethodParameters @()
		if ($APIResponse.CompletedSuccessfully -eq $true) {
			[int]$RPCVersionsSupported = ($APIResponse.XMLPayloadResponse | Select-Xml -XPath "//value/int").node.InnerText
			$VersionObject = New-Object PSObject -Property @{
				Server = $Script:DokuServer.Server
				MinimumRpcVersionSupported = $RPCVersionsSupported
			}
			$VersionObject
		} elseif ($null -eq $APIResponse.ExceptionMessage) {
			Write-Error "Fault code: $($APIResponse.FaultCode) - Fault string: $($APIResponse.FaultString)"
		} else {
			Write-Error "Exception: $($APIResponse.ExceptionMessage)"
		}
	} # process

	end {

	} # end
}