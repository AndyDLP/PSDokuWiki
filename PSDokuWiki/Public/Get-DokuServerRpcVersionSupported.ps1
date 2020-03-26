function Get-DokuServerRpcVersionSupported {
	[CmdletBinding(SupportsShouldProcess=$True, ConfirmImpact='Low')]
	[OutputType([psobject])]
	param
	(
	)

	begin {

	} # begin

	process {
		if ($PSCmdlet.ShouldProcess("Query DokuServer for RPC Version")) {
			$APIResponse = Invoke-DokuApiCall -MethodName 'wiki.getRPCVersionSupported' -MethodParameters @()
			if ($APIResponse.CompletedSuccessfully -eq $true) {
				[int]$RPCVersionsSupported = ($APIResponse.XMLPayloadResponse | Select-Xml -XPath "//value/int").node.InnerText
				$VersionObject = [PSCustomObject]@{
					Server = $Script:DokuServer.Server
					MinimumRpcVersionSupported = $RPCVersionsSupported
				}
				$VersionObject.PSObject.TypeNames.Insert(0, "DokuWiki.Server.RpcVersion")
				$VersionObject
			} elseif ($null -eq $APIResponse.ExceptionMessage) {
				Write-Error "Fault code: $($APIResponse.FaultCode) - Fault string: $($APIResponse.FaultString)"
			} else {
				Write-Error "Exception: $($APIResponse.ExceptionMessage)"
			}
		} # should process
	} # process

	end {

	} # end
}