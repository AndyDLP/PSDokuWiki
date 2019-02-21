function Get-DokuPageLinks {
<#
	.SYNOPSIS
		Returns an array of all links on a page

	.DESCRIPTION
		Returns an array of all links on a page

	.PARAMETER FullName
		The full page name for which to return the data

	.EXAMPLE
		PS C:\> $PageLinks = Get-DokuPageLinks -FullName "namespace:namespace:page"

	.OUTPUTS
		System.Management.Automation.PSObject[]

	.NOTES
		AndyDLP - 2018-05-26
#>

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
					$PageObject = New-Object PSObject -Property @{
						FullName = $PageName
						Type = (($node.member)[0]).value.string
						TargetPageName = (($node.member)[1]).value.string
						URL = (($node.member)[2]).value.string
					}
					[array]$PageLinks = $PageLinks + $PageObject
				}
				$PageLinks
			} elseif ($null -eq $APIResponse.ExceptionMessage) {
				Write-Error "API Fault code: $($APIResponse.FaultCode) - API Fault string: $($APIResponse.FaultString)"
			} else {
				Write-Error "Exception: $($APIResponse.ExceptionMessage)"
			}
		} # foreach page
	} # process

	end {

	} # end
}