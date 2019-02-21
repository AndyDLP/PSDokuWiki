function Get-DokuPageBackLinks {
<#
	.SYNOPSIS
		Returns a list of backlinks of a Wiki page

	.DESCRIPTION
		Returns a list of backlinks of a Wiki page

	.PARAMETER FullName
		The full page name for which to return the data

	.EXAMPLE
		PS C:\> $PageBackLinks = Get-DokuPageBackLinks -FullName "namespace:namespace:page"

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
			$APIResponse = Invoke-DokuApiCall -MethodName 'wiki.getBackLinks' -MethodParameters @($PageName)
			if ($APIResponse.CompletedSuccessfully -eq $true) {
				$PageArray = ($APIResponse.XMLPayloadResponse | Select-Xml -XPath "//array/data/value").Node.InnerText
				foreach ($Page in $PageArray) {
					$PageObject = New-Object PSObject -Property @{
						FullName = $PageName
						BacklinkedFullName = $Page
					}
					[array]$PageLinks = $PageLinks + $PageObject
				}
				$PageLinks
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