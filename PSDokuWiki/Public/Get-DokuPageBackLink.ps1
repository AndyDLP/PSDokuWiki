function Get-DokuPageBackLink {
	[CmdletBinding()]
	[OutputType([psobject[]])]
	param
	(
		[Parameter(Mandatory = $true,
				   Position = 1,
				   ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
				   HelpMessage = 'The full page name for which to return the data')]
		[ValidateNotNullOrEmpty()]
		[string[]]$FullName
	)

	begin {

	} # begin

	process {
		foreach ($PageName in $FullName) {
			$APIResponse = Invoke-DokuApiCall -MethodName 'wiki.getBackLinks' -MethodParameters @($PageName)
			if ($APIResponse.CompletedSuccessfully -eq $true) {
				$PageArray = ($APIResponse.XMLPayloadResponse | Select-Xml -XPath "//array/data/value").Node.InnerText
				foreach ($Page in $PageArray) {
					$PageObject = [PSCustomObject]@{
						FullName = $Page
						PageName = ($Page -split ":")[-1]
						ParentNamespace = ($Page -split ":")[-2]
						RootNamespace = ($Page -split ":")[0]
					}
					$PageObject.PSObject.TypeNames.Insert(0, "DokuWiki.Page")
					$PageObject.PSObject.TypeNames.Insert(0, "DokuWiki.Page.Backlink")
					$PageObject
				}
			} elseif ($null -eq $APIResponse.ExceptionMessage) {
				Write-Error "Fault code: $($APIResponse.FaultCode) - Fault string: $($APIResponse.FaultString)"
			} else {
				Write-Error "Exception: $($APIResponse.ExceptionMessage)"
			}
		} # foreach page
	} # process

	end {

	} # end
}