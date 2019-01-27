function Remove-DokuAttachment {
<#
	.SYNOPSIS
		Returns information about a media file
	
	.DESCRIPTION
		Deletes an attachment
	
	.PARAMETER DokuSession
		The DokuSession from which to delete the attachment
	
	.PARAMETER FullName
		The full name of the attachment to delete
	
	.EXAMPLE
		PS C:\> Remove-DokuAttachment -DokuSession $DokuSession -FullName 'study:test2.jpeg'
	
	.NOTES
		AndyDLP - 2018-05-26
#>
	
	[CmdletBinding(PositionalBinding = $true)]
	param
	(
		[Parameter(Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The DokuSession from which to delete the attachment')]
		[ValidateNotNullOrEmpty()]
		[psobject]$DokuSession,
		[Parameter(Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'The full name of the attachment to delete')]
		[ValidateNotNullOrEmpty()]
		[string]$FullName
	)
	
	$APIResponse = Invoke-DokuApiCall -DokuSession $DokuSession -MethodName 'wiki.deleteAttachment' -MethodParameters @($FullName)
	if ($APIResponse.CompletedSuccessfully -eq $true) { 
		# do nothing?
	} elseif ($null -eq $APIResponse.ExceptionMessage) {
		Write-Error "Fault code: $($APIResponse.FaultCode) - Fault string: $($APIResponse.FaultString)"
	} else {
		Write-Error "Exception: $($APIResponse.ExceptionMessage)"
	}
}