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
	
	$payload = ConvertTo-XmlRpcMethodCall -Name "wiki.deleteAttachment" -Params $FullName
	if ($DokuSession.SessionMethod -eq "HttpBasic") {
		$httpResponse = Invoke-WebRequest -Uri $DokuSession.TargetUri -Method Post -Headers $DokuSession.Headers -Body $payload -ErrorAction Stop
	} else {
		$httpResponse = Invoke-WebRequest -Uri $DokuSession.TargetUri -Method Post -Headers $DokuSession.Headers -Body $payload -ErrorAction Stop -WebSession $DokuSession.WebSession
	}
	
	$FailReason = ([xml]$httpResponse.Content | Select-Xml -XPath "//value/string").Node.InnerText
	if ($FailReason) {
		# error code generated = Fail
		throw "Error: $FailReason - FullName $FullName"
	} else {
		# Do nothing = Delete successful
	}
}