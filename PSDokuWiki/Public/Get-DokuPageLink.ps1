function Get-DokuPageLink {
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
			$APIResponse = Invoke-DokuApiCall -MethodName 'wiki.listLinks' -MethodParameters @($PageName)
			if ($APIResponse.CompletedSuccessfully -eq $true) {
				$MemberNodes = ($APIResponse.XMLPayloadResponse | Select-Xml -XPath "//struct").Node
				foreach ($node in $MemberNodes) {
					$PageObject = [PSCustomObject]@{
						FullName = $PageName
						Type = (($node.member)[0]).value.string
						TargetPageName = (($node.member)[1]).value.string
						URL = (($node.member)[2]).value.string
					}
					$PageObject.PSObject.TypeNames.Insert(0, "DokuWiki.Page")
					$PageObject.PSObject.TypeNames.Insert(0, "DokuWiki.Page.Link")
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