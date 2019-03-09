function Get-DokuPageBackLink {
<#
	.SYNOPSIS
		Returns a list of backlinks of a Wiki page

	.DESCRIPTION
		Returns a list of backlinks of a Wiki page

	.PARAMETER FullName
		The full page name for which to return the data

	.EXAMPLE
		PS C:\> $PageBackLink = Get-DokuPageBackLink -FullName "namespace:namespace:page"

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
						FullName = $Page
						PageName = ($Page -split ":")[-1]
						ParentNamespace = ($Page -split ":")[-2]
						RootNamespace = ($Page -split ":")[0]
					}
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