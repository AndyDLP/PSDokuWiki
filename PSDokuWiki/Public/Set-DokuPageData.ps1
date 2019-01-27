function Set-DokuPageData {
<#
	.SYNOPSIS
		Sets the raw wiki text of a page, will overwrite any existing page
	
	.DESCRIPTION
		Sets the raw wiki text of a page, will overwrite any existing page
	
	.PARAMETER FullName
		The fullname of the target page
	
	.PARAMETER DokuSession
		The DokuSession in which to overwrite the page
	
	.PARAMETER RawWikiText
		The raw wiki text to apply to the target page
	
	.PARAMETER MinorChange
		State if the change was minor or not
	
	.PARAMETER SummaryText
		A short summary of the change, visible in the revisions list
	
	.PARAMETER PassThru
		Pass the new page object back through
	
	.EXAMPLE
		PS C:\> Set-DokuPageData -DokuSession $DokuSession -FullName 'value2' -RawWikiText 'value3'
	
	.OUTPUTS
		System.Boolean, System.Management.Automation.PSObject
	
	.NOTES
		AndyDLP - 2018-05-26
#>
	
	[CmdletBinding()]
	[OutputType([boolean], [psobject])]
	param
	(
		[Parameter(Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'The fullname of the target page')]
		[ValidateNotNullOrEmpty()]
		[string]$FullName,
		[Parameter(Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The DokuSession in which to overwrite the page')]
		[ValidateNotNullOrEmpty()]
		[psobject]$DokuSession,
		[Parameter(Mandatory = $true,
				   Position = 3,
				   HelpMessage = 'The raw wiki text that will be set')]
		[ValidateNotNullOrEmpty()]
		[string]$RawWikiText,
		[Parameter(Position = 4,
				   HelpMessage = 'State if the change was minor or not')]
		[switch]$MinorChange,
		[Parameter(Position = 5,
				   HelpMessage = 'A short summary of the change')]
		[string]$SummaryText,
		[Parameter(Position = 6,
				   HelpMessage = 'Pass the new page object back through')]
		[switch]$PassThru
	)

	begin {

	}

	process {
		$APIResponse = Invoke-DokuApiCall -DokuSession $DokuSession -MethodName 'wiki.putPage' -MethodParameters @($FullName,$RawWikiText, @{'sum' = $SummaryText; 'minor' = $MinorChange})
		if ($APIResponse.CompletedSuccessfully -eq $true) {
			if ($PassThru) {
				$PageObject = New-Object PSObject -Property @{
					FullName = $FullName
					AddedText = $RawWikiText
					MinorChange = $MinorChange
					SummaryText = $SummaryText
					PageName = ($FullName -split ":")[-1]
					ParentNamespace = ($FullName -split ":")[-2]
					RootNamespace = ($FullName -split ":")[0]
				}
				$PageObject
			} else {
				$ResultBoolean = [boolean]($APIResponse.XMLPayloadResponse | Select-Xml -XPath "//value/boolean").node.InnerText
				$ResultBoolean
			}
		} elseif ($null -eq $APIResponse.ExceptionMessage) {
			Write-Error "Fault code: $($APIResponse.FaultCode) - Fault string: $($APIResponse.FaultString)"
		} else {
			Write-Error "Exception: $($APIResponse.ExceptionMessage)"
		}
	} # process 

	end {

	}
}