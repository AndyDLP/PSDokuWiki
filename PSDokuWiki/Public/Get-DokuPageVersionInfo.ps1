function Get-DokuPageVersionInfo {
	[CmdletBinding(PositionalBinding = $true,SupportsShouldProcess=$True, ConfirmImpact='Low')]
	[OutputType([psobject])]
	param
	(
		[Parameter(Mandatory = $true,
				   Position = 1,
				   ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
				   HelpMessage = 'The full page name for which to return the data')]
		[ValidateNotNullOrEmpty()]
		[string[]]$FullName,
		[Parameter(Mandatory = $true,
				   Position = 2,
				   ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
				   HelpMessage = 'The timestamp for which version to get the info from')]
		[ValidateNotNullOrEmpty()]
		[int]$VersionTimestamp
	)

	begin {}

	process {
		foreach ($PageName in $FullName) {
			if ($PSCmdlet.ShouldProcess("Get info of page: $PageName at timestamp: $VersionTimestamp")) {
				$APIResponse = Invoke-DokuApiCall -MethodName 'wiki.getPageInfoVersion' -MethodParameters @($PageName,$VersionTimestamp)
				if ($APIResponse.CompletedSuccessfully -eq $true) {
					$ArrayValues = ($APIResponse.XMLPayloadResponse | Select-Xml -XPath "//struct").Node.Member.Value.Innertext
					$PageObject = [PSCustomObject]@{
						FullName = $PageName
						LastModified = Get-Date -Date ($ArrayValues[1])
						Author = $ArrayValues[2]
						VersionTimestamp = $ArrayValues[3]
						PageName = ($PageName -split ":")[-1]
						ParentNamespace = ($PageName -split ":")[-2]
						RootNamespace = ($PageName -split ":")[0]
					}
					$PageObject.PSObject.TypeNames.Insert(0, "DokuWiki.Page")
					$PageObject.PSObject.TypeNames.Insert(0, "DokuWiki.Page.Version")
					$PageObject.PSObject.TypeNames.Insert(0, "DokuWiki.Page.Version.Info")
					$PageObject
				} elseif ($null -eq $APIResponse.ExceptionMessage) {
					Write-Error "Fault code: $($APIResponse.FaultCode) - Fault string: $($APIResponse.FaultString)"
				} else {
					Write-Error "Exception: $($APIResponse.ExceptionMessage)"
				}
			} # should process
		} # foreach
	} # process

	end {}
}