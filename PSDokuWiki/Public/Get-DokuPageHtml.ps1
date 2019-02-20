function Get-DokuPageHtml {
<#
	.SYNOPSIS
		Returns the rendered XHTML body of a Wiki page

	.DESCRIPTION
		Returns the rendered XHTML body of a Wiki page

	.PARAMETER FullName
		The full page name for which to return the data

	.PARAMETER Raw
		Return just the raw HTML instead of an object

	.EXAMPLE
		PS C:\> $PageHtml = Get-DokuPageHtml -FullName "namespace:namespace:page" -Raw

	.OUTPUTS
		System.Management.Automation.PSObject

	.NOTES
		AndyDLP - 2018-05-26
#>

	[CmdletBinding(PositionalBinding = $true)]
	[OutputType([psobject])]
	param
	(
		[Parameter(Mandatory = $true,
				   Position = 2,
				   ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
				   HelpMessage = 'The full page name for which to return the data')]
		[ValidateNotNullOrEmpty()]
		[string[]]$FullName,
		[Parameter(Mandatory = $false,
				   Position = 3,
				   HelpMessage = 'Return just the raw HTML instead of an object')]
		[switch]$Raw
	)

	begin {

	} # begin

	process {
		foreach ($PageName in $FullName) {
			$APIResponse = Invoke-DokuApiCall -MethodName 'wiki.getPageHTML' -MethodParameters @($PageName)
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