function Get-DokuServerApiVersion {
<#
	.SYNOPSIS
		Returns the DokuWiki version of the remote Wiki server

	.DESCRIPTION
		Returns the DokuWiki version of the remote Wiki server

	.EXAMPLE
		PS C:\> $Version = Get-DokuServerApiVersion

	.NOTES
		AndyDLP - 2018-05-28
#>

	[CmdletBinding()]
	[OutputType([psobject])]
	param
	(
	)

	begin {

	} # begin

	process {
		$APIResponse = Invoke-DokuApiCall -MethodName 'dokuwiki.getXMLRPCAPIVersion' -MethodParameters @()
		if ($APIResponse.CompletedSuccessfully -eq $true) {
			$APIVersion = [int]($APIResponse.XMLPayloadResponse | Select-Xml -XPath "//value/int").node.InnerText
			$VersionObject = New-Object PSObject -Property @{
				Server = $Script:DokuServer.Server
				XmlRpcVersion = $APIVersion
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