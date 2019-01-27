function Remove-DokuAclRule {
<#
	.SYNOPSIS
		Remove a principal from an ACL
	
	.DESCRIPTION
		Allows you to remove a principal from an ACL. Use @groupname instead of user to remove an ACL rule for a group.
	
	.PARAMETER DokuSession
		The DokuSession from which to remove the ACL
	
	.PARAMETER FullName
		The full name of the scope to apply to ACL to
	
	.PARAMETER Principal
		The username or groupname to add to the ACL
	
	.EXAMPLE
		PS C:\> Remove-DokuAclRule -DokuSession $DokuSession -FullName 'study' -Principal 'testuser'
	
	.OUTPUTS
		System.Boolean
	
	.NOTES
		AndyDLP - 2018-05-26
#>
	
	[CmdletBinding()]
	[OutputType([boolean])]
	param
	(
		[Parameter(Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The DokuSession from which to remove the ACL')]
		[ValidateNotNullOrEmpty()]
		[psobject]$DokuSession,
		[Parameter(Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'The full name of the scope to apply to ACL to')]
		[ValidateNotNullOrEmpty()]
		[string]$FullName,
		[Parameter(Mandatory = $true,
				   Position = 3,
				   HelpMessage = 'The username or @groupname to add to the ACL')]
		[ValidateNotNullOrEmpty()]
		[string]$Principal
	)
	
	$APIResponse = Invoke-DokuApiCall -DokuSession $DokuSession -MethodName 'plugin.acl.delAcl' -MethodParameters @($FullName,$Principal)
	if ($APIResponse.CompletedSuccessfully -eq $true) { 
		$ReturnValue = ($APIResponse.XMLPayloadResponse | Select-Xml -XPath "//value/boolean").Node.InnerText
		if ($ReturnValue -eq 0) {
			# error code generated = Fail
			Write-Error "Error: $ReturnValue - $($APIResponse.XMLPayloadResponse)"
		}
	} elseif ($null -eq $APIResponse.ExceptionMessage) {
		Write-Error "Fault code: $($APIResponse.FaultCode) - Fault string: $($APIResponse.FaultString)"
	} else {
		Write-Error "Exception: $($APIResponse.ExceptionMessage)"
	}
}