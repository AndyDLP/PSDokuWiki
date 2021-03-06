﻿function Remove-DokuAclRule {
	[CmdletBinding(PositionalBinding = $true, SupportsShouldProcess=$True, ConfirmImpact='High')]
	[OutputType([boolean])]
	param
	(
		[Parameter(Mandatory = $true,
				   Position = 1,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName=$true,
				   HelpMessage = 'The full name of the page or namespace')]
		[ValidateNotNullOrEmpty()]
		[string[]]$FullName,
		[Parameter(Mandatory = $true,
				   Position = 2,
                   ValueFromPipelineByPropertyName=$true,
				   HelpMessage = 'The username or groupname to remove')]
		[ValidateNotNullOrEmpty()]
		[string[]]$Principal
	)

	begin {}

	process {
		foreach ($Page in $fullname) {
			foreach ($user in $Principal) {
				if ($PSCmdlet.ShouldProcess("Remove user: $user from page: $page")) {
					$APIResponse = Invoke-DokuApiCall -MethodName 'plugin.acl.delAcl' -MethodParameters @($FullName,$Principal)
					if ($APIResponse.CompletedSuccessfully -eq $true) { 
						$ReturnValue = [int](($APIResponse.XMLPayloadResponse | Select-Xml -XPath "//value/boolean").Node.InnerText)
						if ($ReturnValue -eq 0) {
							# error code generated = Fail
							Write-Error "Error removing user: $user from page: $page"
						}
					} elseif ($null -eq $APIResponse.ExceptionMessage) {
						Write-Error "Fault code: $($APIResponse.FaultCode) - Fault string: $($APIResponse.FaultString)"
					} else {
						Write-Error "Exception: $($APIResponse.ExceptionMessage)"
					}
				} # should process
			} # foreach user
		} # foreach page
	} # process

	end {}
}