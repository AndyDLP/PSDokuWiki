function Get-DokuPageVersionHtml {
<#
	.SYNOPSIS
		Returns the rendered HTML for a specific version of a Wiki page

	.DESCRIPTION
		Returns the rendered HTML for a specific version of a Wiki page

	.PARAMETER FullName
		The full page name for which to return the data

	.PARAMETER VersionTimestamp
		The timestamp for which version to get the info from

	.PARAMETER Raw
		Return only the raw HTML, rather than an object

	.EXAMPLE
		PS C:\> $RawPageHtml = Get-DokuPageVersionHtml -FullName "namespace:namespace:page" -VersionTimestamp 1497464418 -Raw

	.OUTPUTS
		System.Management.Automation.PSObject

	.NOTES
		AndyDLP - 2018-05-26
#>

	[CmdletBinding()]
	[OutputType([psobject])]
	param
	(
		[Parameter(Position = 4,
				   HelpMessage = 'Return only the raw HTML, rather than an object')]
		[switch]$Raw,
		[Parameter(Mandatory = $true,
				   Position = 2,
				   ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
				   HelpMessage = 'The full page name for which to return the data')]
		[ValidateNotNullOrEmpty()]
		[string[]]$FullName,
		[Parameter(Mandatory = $true,
				   Position = 3,
				   HelpMessage = 'The timestamp for which version to get the info from')]
		[ValidateNotNullOrEmpty()]
		[int]$VersionTimestamp
	)

	begin {

	} # begin

	process {
		foreach ($PageName in $FullName) {
			$APIResponse = Invoke-DokuApiCall -MethodName 'wiki.getPageHTMLVersion' -MethodParameters @($PageName,$VersionTimestamp)
			if ($APIResponse.CompletedSuccessfully -eq $true) {
				$PageObject = New-Object PSObject -Property @{
					FullName = $PageName
					RenderedHtml = [string]($APIResponse.XMLPayloadResponse | Select-Xml -XPath "//value/string").Node.InnerText
					PageName = ($PageName -split ":")[-1]
					ParentNamespace = ($PageName -split ":")[-2]
					RootNamespace = ($PageName -split ":")[0]
				}
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