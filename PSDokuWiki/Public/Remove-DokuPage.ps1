function Remove-DokuPage {
	[CmdletBinding(PositionalBinding = $true, SupportsShouldProcess = $True, ConfirmImpact = 'High')]
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
		[Parameter(Position = 2,
			HelpMessage = 'A short summary of why the page is being deleted')]
		[string]$SummaryText
	)

	begin {}

	process {
		$RawWikiText = [string]::Empty
		foreach ($PageName in $FullName) {
			if ($PSCmdlet.ShouldProcess("Delete page: $PageName")) {
				$APIResponse = Invoke-DokuApiCall -MethodName 'wiki.putPage' -MethodParameters @($PageName, $RawWikiText, @{'sum' = $SummaryText; 'minor' = $false })
				Write-Verbose $APIResponse
				if ($APIResponse.CompletedSuccessfully -eq $true) {
					$ResultBoolean = [boolean]([int]($APIResponse.XMLPayloadResponse | Select-Xml -XPath "//value/boolean").node.InnerText)
					Write-Verbose $ResultBoolean
					if ($ResultBoolean -eq $true) {
						Write-Verbose "Successfully deleted page"
					}
					else {
						Write-Error "Failed to delete page"
					}
				}
				elseif ($null -eq $APIResponse.ExceptionMessage) {
					Write-Error "Fault code: $($APIResponse.FaultCode) - Fault string: $($APIResponse.FaultString)"
				}
				else {
					Write-Error "Exception: $($APIResponse.ExceptionMessage)"
				}
			} # should process
		} #' foreach
	} # process 

	end {}
}