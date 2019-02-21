function Remove-DokuUser {
<#
	.SYNOPSIS
		Allows you to delete a user
	
	.DESCRIPTION
		Allows you to delete a user. Useful to implement GDPR right to be forgotten tools
	
	.PARAMETER Username
		The username(s) you want to remove
	
	.EXAMPLE
		PS C:\> Remove-DokuUser -Username 'value2'
	
	.NOTES
		AndyDLP - 2018-05-26
#>
	
	[CmdletBinding(PositionalBinding = $true)]
	[OutputType([boolean])]
	param
	(
		[Parameter(Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The username(s) you want to remove')]
		[ValidateNotNullOrEmpty()]
		[string[]]$Username
	)
	
	$APIResponse = Invoke-DokuApiCall -MethodName 'dokuwiki.deleteUsers' -MethodParameters @([array]$Username,$null)
	if ($APIResponse.CompletedSuccessfully -eq $true) {			
		$FailReason = ($APIResponse.XMLPayloadResponse | Select-Xml -XPath "//value/boolean").Node.InnerText
		if ($FailReason -eq 0) {
			# error code generated = Fail
			Write-Error "Error: $FailReason - Username: $Username"
		} else {
			# Do nothing = Delete successful
		}
	} elseif ($null -eq $APIResponse.ExceptionMessage) {
		Write-Error "Fault code: $($APIResponse.FaultCode) - Fault string: $($APIResponse.FaultString)"
	} else {
		Write-Error "Exception: $($APIResponse.ExceptionMessage)"
	}
}