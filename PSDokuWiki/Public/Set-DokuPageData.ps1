function Set-DokuPageData {
<#
	.SYNOPSIS
		Sets the raw wiki text of a page, will overwrite any existing page
	
	.DESCRIPTION
		Sets the raw wiki text of a page, will overwrite any existing page
	
	.PARAMETER FullName
		The fullname of the target page
	
	.PARAMETER RawWikiText
		The raw wiki text to apply to the target page
	
	.PARAMETER MinorChange
		State if the change was minor or not
	
	.PARAMETER SummaryText
		A short summary of the change, visible in the revisions list
	
	.PARAMETER PassThru
		Pass the new page object back through
	
	.EXAMPLE
		PS C:\> Set-DokuPageData -FullName 'value2' -RawWikiText 'value3'
	
	.OUTPUTS
		System.Boolean, System.Management.Automation.PSObject
	
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
				   HelpMessage = 'The fullname of the target page')]
		[ValidateNotNullOrEmpty()]
		[string[]]$FullName,
		[Parameter(Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'The raw wiki text that will be set')]
		[ValidateNotNullOrEmpty()]
		[string]$RawWikiText,
		[Parameter(Position = 3,
				   HelpMessage = 'State if the change was minor or not')]
		[switch]$MinorChange,
		[Parameter(Position = 4,
				   HelpMessage = 'A short summary of the change')]
		[string]$SummaryText,
		[Parameter(Position = 5,
				   HelpMessage = 'Pass the new page object back through')]
		[switch]$PassThru
	)

	begin {

	}

	process {
		foreach ($PageName in $FullName) {
			$APIResponse = Invoke-DokuApiCall -MethodName 'wiki.putPage' -MethodParameters @($PageName,$RawWikiText, @{'sum' = $SummaryText; 'minor' = $MinorChange})
			Write-Verbose $APIResponse
			if ($APIResponse.CompletedSuccessfully -eq $true) {
				$ResultBoolean = [boolean]([int]($APIResponse.XMLPayloadResponse | Select-Xml -XPath "//value/boolean").node.InnerText)
				Write-Verbose $ResultBoolean
				if ($ResultBoolean -eq $true) {
					if ($PassThru) {
						$PageObject = New-Object PSObject -Property @{
							FullName = $PageName
							AddedText = $RawWikiText
							MinorChange = [bool]$MinorChange
							SummaryText = $SummaryText
							PageName = ($PageName -split ":")[-1]
							ParentNamespace = ($PageName -split ":")[-2]
							RootNamespace = ($PageName -split ":")[0]
						}
						Write-Verbose $PageObject
						$PageObject
					} else {
						Write-Verbose "Successfully set page data"
					}
				} else {
					Write-Error "Failed to set page data"
				}
			} elseif ($null -eq $APIResponse.ExceptionMessage) {
				Write-Error "Fault code: $($APIResponse.FaultCode) - Fault string: $($APIResponse.FaultString)"
			} else {
				Write-Error "Exception: $($APIResponse.ExceptionMessage)"
			}
		}
	} # process 

	end {

	}
}