function Add-DokuAclRule {
<#
	.SYNOPSIS
		Add an ACL to a namespace or page
	
	.DESCRIPTION
		Add an ACL to a namespace or page. Use @groupname instead of user to add an ACL rule for a group.
	
	.PARAMETER DokuSession
		The DokuSession in which to make the ACL changes
	
	.PARAMETER FullName
		The full name of the scope to apply to ACL to
	
	.PARAMETER Principal
		The username or groupname to add to the ACL
	
	.PARAMETER Acl
		The permission level to apply to the user.
		0 = None, 1 = Read, 2 = Edit, 4 = Create, 8 = Upload, 16 = Delete
	
	.EXAMPLE
		PS C:\> Add-DokuAclRule -DokuSession $DokuSession -FullName 'study:home' -Principal 'testuser' -Acl 255
	
	.OUTPUTS
		System.Boolean
	
	.NOTES
		AndyDLP - 2018-05-26
#>
	
	[CmdletBinding(PositionalBinding = $true)]
	[OutputType([boolean])]
	param
	(
		[Parameter(Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The DokuSession in which to make the ACL changes')]
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
		[string]$Principal,
		[Parameter(Mandatory = $true,
				   Position = 4,
				   HelpMessage = 'The permission level to apply to the ACL as an integer')]
		[ValidateNotNullOrEmpty()]
		[int]$Acl
	)
	
	$payload = (ConvertTo-XmlRpcMethodCall -Name "plugin.acl.addAcl" -Params $FullName, $Principal, $Acl) -replace "String", "string"
	$payload = $payload -replace "Int32", "i4"
	if ($DokuSession.SessionMethod -eq "HttpBasic") {
		$httpResponse = Invoke-WebRequest -Uri $DokuSession.TargetUri -Method Post -Headers $DokuSession.Headers -Body $payload -ErrorAction Stop
	} else {
		$httpResponse = Invoke-WebRequest -Uri $DokuSession.TargetUri -Method Post -Headers $DokuSession.Headers -Body $payload -ErrorAction Stop -WebSession $DokuSession.WebSession
	}
	
	$ReturnValue = ([xml]$httpResponse.Content | Select-Xml -XPath "//value/boolean").Node.InnerText
	if ($ReturnValue -eq 0) {
		# error code generated = Fail
		Write-Error "Error: $ReturnValue - $($httpResponse.content)"
		return $false
	} else {
		return $true
	}
}