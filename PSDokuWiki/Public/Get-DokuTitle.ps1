function Get-DokuTitle {
	[CmdletBinding(SupportsShouldProcess=$True, ConfirmImpact='Low')]
	[OutputType([psobject])]
	param
	(
	)

	begin {

	} # begin

	process {
		if ($PSCmdlet.ShouldProcess("Query DokuServer for current DokuWiki title")) {
			$APIResponse = Invoke-DokuApiCall -MethodName 'dokuwiki.getTitle' -MethodParameters @()
			if ($APIResponse.CompletedSuccessfully -eq $true) {
				[string]$DokuTitle = ($APIResponse.XMLPayloadResponse | Select-Xml -XPath "//value/string").node.InnerText
				$TitleObject = [PSCustomObject]@{
					Server = $Script:DokuServer.Server
					Title = $DokuTitle
				}
				$TitleObject.PSObject.TypeNames.Insert(0, "DokuWiki.Server.Title")
				$TitleObject
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