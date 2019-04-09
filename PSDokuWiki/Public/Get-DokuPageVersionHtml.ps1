function Get-DokuPageVersionHtml {
	[CmdletBinding()]
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
		[int]$VersionTimestamp,
		[Parameter(Position = 3,
				   HelpMessage = 'Return only the raw HTML, rather than an object')]
		[switch]$Raw
	)

	begin {

	} # begin

	process {
		foreach ($PageName in $FullName) {
			$APIResponse = Invoke-DokuApiCall -MethodName 'wiki.getPageHTMLVersion' -MethodParameters @($PageName,$VersionTimestamp)
			if ($APIResponse.CompletedSuccessfully -eq $true) {
				$PageObject = [PSCustomObject]@{
					FullName = $PageName
					VersionTimestamp = $VersionTimestamp
					RenderedHtml = [string]($APIResponse.XMLPayloadResponse | Select-Xml -XPath "//value/string").Node.InnerText
					PageName = ($PageName -split ":")[-1]
					ParentNamespace = ($PageName -split ":")[-2]
					RootNamespace = ($PageName -split ":")[0]
				}
				$PageObject.PSObject.TypeNames.Insert(0, "DokuWiki.Page")
				$PageObject.PSObject.TypeNames.Insert(0, "DokuWiki.Page.Version")
				$PageObject.PSObject.TypeNames.Insert(0, "DokuWiki.Page.Version.Html")
				if ($Raw) {
					$PageObject.RenderedHtml
				} else {
					$PageObject
				}
			} elseif ($null -eq $APIResponse.ExceptionMessage) {
				Write-Error "Fault code: $($APIResponse.FaultCode) - Fault string: $($APIResponse.FaultString)"
			} else {
				Write-Error "Exception: $($APIResponse.ExceptionMessage)"
			}
		} # foreach
	} # process

	end {

	} # end
}