function Remove-DokuUser {
	[CmdletBinding(PositionalBinding = $true, SupportsShouldProcess=$True, ConfirmImpact='High')]
	[OutputType()]
	param
	(
		[Parameter(Mandatory = $true,
				   ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName=$true,
				   Position = 1,
				   HelpMessage = 'The username(s) you want to remove')]
		[ValidateNotNullOrEmpty()]
		[string[]]$Username
	)
	begin {}

	process {
		foreach ($User in $Username) {
			if ($PSCmdlet.ShouldProcess("Delete user: $User")) {
				$APIResponse = Invoke-DokuApiCall -MethodName 'dokuwiki.deleteUsers' -MethodParameters @([array]$User,$null)
				if ($APIResponse.CompletedSuccessfully -eq $true) {			
					[bool]$Succeeded = [int]($APIResponse.XMLPayloadResponse | Select-Xml -XPath "//value/boolean").Node.InnerText
					if ($Succeeded -eq $false) {
						# error code generated = Fail
						Write-Error "Error when deleting user: $User"
					}
				} elseif ($null -eq $APIResponse.ExceptionMessage) {
					Write-Error "Fault code: $($APIResponse.FaultCode) - Fault string: $($APIResponse.FaultString)"
				} else {
					Write-Error "Exception: $($APIResponse.ExceptionMessage)"
				}
			} # should process
		} # foreach
	} # process

	end {}
}