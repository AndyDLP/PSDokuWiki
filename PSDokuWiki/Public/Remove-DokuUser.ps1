function Remove-DokuUser {
<#
	.SYNOPSIS
		Allows you to delete a user
	
	.DESCRIPTION
		Allows you to delete a user. Useful to implement GDPR right to be forgotten tools
	
	.PARAMETER DokuSession
		The DokuSession to delete the users from
	
	.PARAMETER Username
		The username(s) you want to remove
	
	.EXAMPLE
		PS C:\> Remove-DokuUser -DokuSession $DokuSession -Username 'value2'
	
	.NOTES
		AndyDLP - 2018-05-26
#>
	
	[CmdletBinding(PositionalBinding = $true)]
	[OutputType([boolean])]
	param
	(
		[Parameter(Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The DokuSession to delete the users from')]
		[ValidateNotNullOrEmpty()]
		[psobject]$DokuSession,
		[Parameter(Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'The username(s) you want to remove')]
		[ValidateNotNullOrEmpty()]
		[string[]]$Username
	)
	
	$httpResponse = Invoke-DokuApiCall -DokuSession $DokuSession -MethodName 'dokuwiki.deleteUsers' -MethodParameters @([array]$Username,$null)
	$FailReason = ([xml]$httpResponse.Content | Select-Xml -XPath "//value/boolean").Node.InnerText
	if ($FailReason -eq 0) {
		# error code generated = Fail
		throw "Error: $FailReason - Username: $Username"
	} else {
		# Do nothing = Delete successful
	}
}