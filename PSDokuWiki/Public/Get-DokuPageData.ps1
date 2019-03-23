function Get-DokuPageData {
	[CmdletBinding()]
	[OutputType([psobject])]
	param
	(
		[Parameter(Mandatory = $true,
				   Position = 1,
				   ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
				   HelpMessage = 'The full page name for which to return the page data')]
		[ValidateNotNullOrEmpty()]
		[string[]]$FullName,
		[Parameter(Position = 2,
				   HelpMessage = 'Return only the raw wiki text, intead of an object')]
		[switch]$Raw
	)

	begin {

	} # begin

	process {
		foreach ($PageName in $FullName) {
			$APIResponse = Invoke-DokuApiCall -MethodName 'wiki.getPage' -MethodParameters @($PageName)
			if ($APIResponse.CompletedSuccessfully -eq $true) {
				$PageObject = New-Object PSObject -Property @{
					FullName = $PageName
					RawText = [string]($APIResponse.XMLPayloadResponse | Select-Xml -XPath "//value/string").Node.InnerText
					TimeChecked = (Get-Date)
					PageName = ($PageName -split ":")[-1]
					ParentNamespace = ($PageName -split ":")[-2]
					RootNamespace = ($PageName -split ":")[0]
				}
				if ($Raw) {
					$PageObject.RawText
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