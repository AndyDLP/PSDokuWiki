function Get-DokuServerApiVersion {
	[CmdletBinding(SupportsShouldProcess=$True, ConfirmImpact='Low')]
	[OutputType([psobject])]
	param
	(
	)

	begin {

	} # begin

	process {
		if ($PSCmdlet.ShouldProcess("Query DokuServer for API Version")) {
			$APIResponse = Invoke-DokuApiCall -MethodName 'dokuwiki.getXMLRPCAPIVersion' -MethodParameters @()
			if ($APIResponse.CompletedSuccessfully -eq $true) {
				$APIVersion = [int]($APIResponse.XMLPayloadResponse | Select-Xml -XPath "//value/int").node.InnerText
				$VersionObject = [PSCustomObject]@{
					Server = $Script:DokuServer.Server
					XmlRpcVersion = $APIVersion
				}
				$VersionObject.PSObject.TypeNames.Insert(0, "DokuWiki.Server.ApiVersion")
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