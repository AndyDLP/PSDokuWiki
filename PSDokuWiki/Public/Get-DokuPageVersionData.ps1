function Get-DokuPageVersionData {
<#
	.SYNOPSIS
		Returns the raw Wiki text for a specific version of a page

	.DESCRIPTION
		Returns the raw Wiki text for a specific version of a page

	.PARAMETER FullName
		The full page name for which to return the data, including any namespaces

	.PARAMETER VersionTimestamp
		The timestamp for which version to get the info from

	.PARAMETER Raw
		Return only the raw data, rather than an object

	.EXAMPLE
		PS C:\> $PageData = Get-DokuPageVersionData -FullName "namespace:namespace:page" -VersionTimestamp 1497464418

	.OUTPUTS
		System.Management.Automation.PSObject

	.NOTES
		AndyDLP - 2018-05-26
#>

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
				   HelpMessage = 'Return only the raw Data, rather than an object')]
		[switch]$Raw
	)

	begin {

	} # begin

	process {
		foreach ($PageName in $FullName) {
			$APIResponse = Invoke-DokuApiCall -MethodName 'wiki.getPageVersion' -MethodParameters @($PageName,$VersionTimestamp)
			if ($APIResponse.CompletedSuccessfully -eq $true) {
				if ($Raw) {
					$RawText = [string]($APIResponse.XMLPayloadResponse  | Select-Xml -XPath "//value/string").Node.InnerText
					$RawText
				} else {
					$PageObject = New-Object PSObject -Property @{
						FullName = $PageName
						VersionTimestamp = $VersionTimestamp
						RawText = [string]($APIResponse.XMLPayloadResponse  | Select-Xml -XPath "//value/string").Node.InnerText
						PageName = ($PageName -split ":")[-1]
						ParentNamespace = ($PageName -split ":")[-2]
						RootNamespace = ($PageName -split ":")[0]
					}
					$PageObject
				}
			} elseif ($null -eq $APIResponse.ExceptionMessage) {
				Write-Error "Fault code: $($APIResponse.FaultCode) - Fault string: $($APIResponse.FaultString)"
			} else {
				Write-Error "Exception: $($APIResponse.ExceptionMessage)"
			}
		}
	} # process

	end {

	} # end
}