function Set-DokuPageData {
	[CmdletBinding(PositionalBinding = $true, SupportsShouldProcess=$True, ConfirmImpact='High')]
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
        	[Parameter(Mandatory = $false,
        	    Position = 6,
        	    HelpMessage = 'Bypass confirmations of calls during this connect/disconnect session')]
        	[ValidateNotNullOrEmpty()]
        	[switch]$BypassConfirm
	)

	begin {}

	process {
		foreach ($PageName in $FullName) {
            if ($BypassConfirm -or $PSCmdlet.ShouldProcess("Set data: $RawWikiText for page: $PageName")) {
				$APIResponse = Invoke-DokuApiCall -MethodName 'wiki.putPage' -MethodParameters @($PageName,$RawWikiText, @{'sum' = $SummaryText; 'minor' = $MinorChange})
				Write-Verbose $APIResponse
				if ($APIResponse.CompletedSuccessfully -eq $true) {
					$ResultBoolean = [boolean]([int]($APIResponse.XMLPayloadResponse | Select-Xml -XPath "//value/boolean").node.InnerText)
					Write-Verbose $ResultBoolean
					if ($ResultBoolean -eq $true) {
						if ($PassThru) {
							$PageObject = [PSCustomObject]@{
								FullName = $PageName
								AddedText = $RawWikiText
								MinorChange = [bool]$MinorChange
								SummaryText = $SummaryText
								PageName = ($PageName -split ":")[-1]
								ParentNamespace = ($PageName -split ":")[-2]
								RootNamespace = ($PageName -split ":")[0]
							}
							$PageObject.PSObject.TypeNames.Insert(0, "DokuWiki.Page")
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
			} # should process
		} #' foreach
	} # process 

	end {}
}
