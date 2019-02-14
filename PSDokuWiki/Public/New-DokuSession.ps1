function New-DokuSession {
<#
	.SYNOPSIS
		Create a new session to a DokuWiki instance via its XMLRPC API

	.DESCRIPTION
		Create a new session to a DokuWiki instance via its XMLRPC API

	.PARAMETER Server
		The wiki server hostname, DNS name or IP address

	.PARAMETER Credential
		The PSCredential for the user that will be logging in

	.PARAMETER SessionMethod
		The authentication method that you to use with subsequent commands to the API. Can be 'HttpBasic' or 'Cookie'

	.PARAMETER Unencrypted
		Send the request to the unencrypted endpoint instead of the encrypted one

	.EXAMPLE
		PS C:\> $DokuSession = New-DokuSession -Server "192.168.10.10" -Credential (Get-Credential) -SessionMethod Cookie

	.EXAMPLE
		PS C:\> $DokuSession = New-DokuSession -Server "wiki.example.com" -Credential $UserCredentials -Unencrypted

	.OUTPUTS
		System.Management.Automation.PSObject

	.NOTES
	Updated 2018-05-28
#>

	[CmdletBinding(PositionalBinding = $true)]
	[OutputType([pscustomobject])]
	param
	(
		[Parameter(Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The wiki server name')]
		[ValidateNotNullOrEmpty()]
		[string]$Server,
		[Parameter(Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'The credentials of the user that will be logging in')]
		[ValidateNotNullOrEmpty()]
		[pscredential]$Credential,
		[Parameter(Mandatory = $false,
				   Position = 3,
				   HelpMessage = 'The authentication method that you want to use with subsequent commands to the API')]
		[ValidateSet('HttpBasic', 'Cookie', IgnoreCase = $true)]
		[string]$SessionMethod = 'Cookie',
		[Parameter(Mandatory = $false,
				   Position = 4,
				   HelpMessage = 'Send the request to the unencrypted endpoint instead')]
		[switch]$Unencrypted
	)

	$headers = @{ "Content-Type" = "text/xml"; }
	$Protocol = if ($Unencrypted) { "http" } else { "https" }
	$TargetUri = ($Protocol + '://' + $Server + "/lib/exe/xmlrpc.php")
	$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Credential.Password)
	$password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

	if ($SessionMethod -eq "HttpBasic") {
		$pair = "$($Credential.username):$($password)"
		$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
		$headers.Add("Authorization", "Basic $encodedCreds")
	} else {
		$XMLPayload = ConvertTo-XmlRpcMethodCall -Name "dokuwiki.login" -Params @($Credential.username, $password)
		# $Websession var defined here
		Invoke-WebRequest -Uri $TargetUri -Method Post -Headers $headers -Body $XMLPayload -SessionVariable WebSession -ErrorAction Stop | Out-Null
	}

	$DokuSession = New-Object PSCustomObject -Property @{
		Server = $Server
		TargetUri = $TargetUri
		SessionMethod = $SessionMethod
		Headers = $headers
		WebSession = $WebSession
		TimeStamp = (Get-Date)
		UnencryptedEndpoint = [bool]$Unencrypted
	} -ErrorAction Stop
	$DokuSession.PSTypeNames.Insert(0,'DokuWiki.Session.Detail')
	$DokuSession
}