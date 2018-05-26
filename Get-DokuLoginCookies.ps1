function Get-DokuLoginCookies {
<#
	.SYNOPSIS
		Invoke a login to a DokuWiki instance with supplied credentials
	
	.DESCRIPTION
		Invoke a login to a DokuWiki instance with supplied credentials
	
	.PARAMETER Uri
		The URI of the wiki XMLRPC api endpoint
	
	.PARAMETER Username
		The username of the user that will be logging in
	
	.PARAMETER Password
		The password for the user
	
	.EXAMPLE
				PS C:\> $LoginCookies = Get-DokuLoginCookies -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -Username "User1" -Password "Password1"
	
	.NOTES
		Additional information about the function.
#>
	
	[CmdletBinding()]
	[OutputType([array])]
	param
	(
		[Parameter(Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[ValidateNotNullOrEmpty()]
		[string]$Uri,
		[Parameter(Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'The username of the user that will be logging in')]
		[ValidateNotNullOrEmpty()]
		[string]$Username,
		[Parameter(Mandatory = $true,
				   Position = 3,
				   HelpMessage = 'The password for the user')]
		[ValidateNotNullOrEmpty()]
		[string]$Password
	)
	
	$payload = "<?xml version='1.0'?><methodCall><methodName>dokuwiki.login</methodName><params><param><value><string>$username</string></value></param><param><value><string>$password</string></value></param></params></methodCall>"
	$headers = @{ "Content-Type" = "text/xml"; }
	$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -SessionVariable WebSession
	$cookies = $WebSession.Cookies.GetCookies($Uri)
	
    # Create "login" object and return that instead?

	return $cookies
}