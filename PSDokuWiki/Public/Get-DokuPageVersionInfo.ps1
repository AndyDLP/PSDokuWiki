function Get-DokuPageVersionInfo {
<#
	.SYNOPSIS
		Returns information about a specific version of a Wiki page

	.DESCRIPTION
		Returns information about a specific version of a Wiki page

	.PARAMETER FullName
		The full page name for which to return the data

	.PARAMETER VersionTimestamp
		The timestamp for which version to get the info from

	.EXAMPLE
		PS C:\> $PageInfo = Get-DokuPageVersionInfo -FullName "namespace:namespace:page" -VersionTimestamp 1497464418

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
		[int]$VersionTimestamp
	)

	begin {}

	process {
		foreach ($PageName in $FullName) {
			$APIResponse = Invoke-DokuApiCall -MethodName 'wiki.getPageInfoVersion' -MethodParameters @($PageName,$VersionTimestamp)
			if ($APIResponse.CompletedSuccessfully -eq $true) {
				$ArrayValues = ($APIResponse.XMLPayloadResponse | Select-Xml -XPath "//struct").Node.Member.Value.Innertext
				$PageObject = New-Object PSObject -Property @{
					FullName = $PageName
					LastModified = Get-Date -Date ($ArrayValues[1])
					Author = $ArrayValues[2]
					VersionTimestamp = $ArrayValues[3]
					PageName = ($PageName -split ":")[-1]
					ParentNamespace = ($PageName -split ":")[-2]
					RootNamespace = ($PageName -split ":")[0]
				}
				$PageObject
			} elseif ($null -eq $APIResponse.ExceptionMessage) {
				Write-Error "Fault code: $($APIResponse.FaultCode) - Fault string: $($APIResponse.FaultString)"
			} else {
				Write-Error "Exception: $($APIResponse.ExceptionMessage)"
			}
		}
	} # process

	end {}
}