function Remove-DokuAttachment {
<#
	.SYNOPSIS
		Deletes an attachment
	
	.DESCRIPTION
		Deletes an attachment
	
	.PARAMETER FullName
		The full name of the attachment to delete
	
	.EXAMPLE
		PS C:\> Remove-DokuAttachment -FullName 'study:test2.jpeg'
	
	.NOTES
		AndyDLP - 2018-05-26
#>
	
	[CmdletBinding(PositionalBinding = $true)]
	param
	(
		[Parameter(Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'The full name of the attachment to delete')]
		[ValidateNotNullOrEmpty()]
		[string]$FullName
	)
	
	$APIResponse = Invoke-DokuApiCall -MethodName 'wiki.deleteAttachment' -MethodParameters @($FullName)
	if ($APIResponse.CompletedSuccessfully -eq $true) { 
		# do nothing?
	} elseif ($null -eq $APIResponse.ExceptionMessage) {
		Write-Error "Fault code: $($APIResponse.FaultCode) - Fault string: $($APIResponse.FaultString)"
	} else {
		Write-Error "Exception: $($APIResponse.ExceptionMessage)"
	}
}