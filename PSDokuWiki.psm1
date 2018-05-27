# PowerShell wrapper for the below API
# https://www.dokuwiki.org/devel:xmlrpc

function Get-DokuPageList {
<#
	.SYNOPSIS
		Gets an array of all pages from an instance of DokuWiki

	.DESCRIPTION
		Gets an array of all pages from an instance of DokuWiki

	.PARAMETER Uri
		The URI of the wiki XMLRPC api endpoint

	.PARAMETER Username
		The authorised API users username

	.PARAMETER SecPassword
		The password for user that will be sending the payload

	.PARAMETER WebSession
		The array of WebSession from the dokuwiki.Login function

	.EXAMPLE
		PS C:\> $AllPages = Get-DokuPageList -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -Username "adlp" -SecPassword $SecureStringPassword

	.EXAMPLE
		PS C:\> $AllPages = Get-DokuPageList -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -WebSession $LoginCookies

	.OUTPUTS
		System.Array

	.NOTES
		AndyDLP - 2018-05-26
#>

	[CmdletBinding(DefaultParameterSetName = 'Basic')]
	[OutputType([array])]
	param
	(
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[ValidateNotNullOrEmpty()]
		[string]$Uri,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 2,
				   HelpMessage = 'The user that will be requesting the pagelist')]
		[ValidateNotNullOrEmpty()]
		[string]$Username,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 3,
				   HelpMessage = 'The password for the user that will be requesting the pagelist')]
		[ValidateNotNullOrEmpty()]
		[securestring]$SecPassword,
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $false,
				   Position = 2,
				   HelpMessage = 'An array of the two cookies from the dokuwiki.Login function')]
		[Microsoft.PowerShell.Commands.WebRequestSession]$WebSession
	)

	# build the payload for a xmlrpc web request
	# No params for getPageList
	$payload = '<?xml version="1.0"?><methodCall><methodName>dokuwiki.getPagelist</methodName><params></params></methodCall>'
	$headers = @{ "Content-Type" = "text/xml"; }

	if ($PSCmdlet.ParameterSetName -eq "Basic") {
		# Add credentials to HTTP Basic auth header
		$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecPassword)
		$password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

		$pair = "$($username):$($password)"
		$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
		$headers.Add("Authorization", "Basic $encodedCreds")

		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop
		} catch {
			Write-Error $PSItem
			return $null
		}
	} else {
		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop -WebSession $WebSession
		} catch {
			Write-Error $PSItem
			return $null
		}
	}

	$AllDokuwikiPages = @()
	$MemberNodes = ([xml]$httpResponse.Content | Select-Xml -XPath "//struct").Node
	foreach ($node in $MemberNodes) {
		$PageObject = New-Object PSObject -Property @{
			FullName = (($node.member)[0]).value.string
			Revision = (($node.member)[1]).value.int
			ModifiedTime = (($node.member)[2]).value.int
			Size = (($node.member)[3]).value.int
			PageName = (((($node.member)[0]).value.string) -split ":")[-1]
			ParentNamespace = (((($node.member)[0]).value.string) -split ":")[-2]
			RootNamespace = (((($node.member)[0]).value.string) -split ":")[0]
		}
		$AllDokuwikiPages = $AllDokuwikiPages + $PageObject
	}
	return $AllDokuwikiPages
}

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

	.OUTPUTS
		System.Array

	.NOTES
		Shouldn't use - Use the New-DokuLoginSession function instead?
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

	# TODO: Warn / block on non-https usage?
	# TODO: Work out how to secure the password on HTTP (is it even possible with the API?)

	$payload = "<?xml version='1.0'?><methodCall><methodName>dokuwiki.login</methodName><params><param><value><string>$username</string></value></param><param><value><string>$password</string></value></param></params></methodCall>"
	$headers = @{ "Content-Type" = "text/xml"; }
	Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -SessionVariable WebSession | Out-Null
	$cookies = $WebSession.Cookies.GetCookies($Uri)

	# Create "login" object and return that instead?

	return $cookies
}

function Get-DokuTime {
<#
	.SYNOPSIS
		Returns the current time at the remote wiki server as Unix timestamp

	.DESCRIPTION
		Returns the current time at the remote wiki server as Unix timestamp

	.PARAMETER Uri
		The URI of the wiki XMLRPC api endpoint

	.PARAMETER Username
		The user that will be sending the payload

	.PARAMETER SecPassword
		The password for user that will be sending the payload

	.PARAMETER WebSession
		The Web.Session object containing the login tokens

	.PARAMETER Raw
		Output the raw response from the server in UNIX time rather than a DateTime

	.EXAMPLE
		PS C:\> $serverTime = Get-DokuTime -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -Username "adlp" -SecPassword $SecureStringPassword

	.EXAMPLE
		PS C:\> $serverTime = Get-DokuTime -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -WebSession $LoginCookies

	.OUTPUTS
		System.Array

	.NOTES
		AndyDLP - 2018-05-26
#>

	[CmdletBinding(DefaultParameterSetName = 'Basic')]
	[OutputType([array])]
	param
	(
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[ValidateNotNullOrEmpty()]
		[string]$Uri,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 3,
				   HelpMessage = 'The user that will be requesting the server time')]
		[ValidateNotNullOrEmpty()]
		[string]$Username,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 4,
				   HelpMessage = 'The password for the user that will be requesting the server time')]
		[ValidateNotNullOrEmpty()]
		[securestring]$SecPassword,
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $false,
				   Position = 3,
				   HelpMessage = 'The Web.Session object containing the login tokens')]
		[Microsoft.PowerShell.Commands.WebRequestSession]$WebSession,
		[Parameter(ParameterSetName = 'Basic',
				   Position = 2,
				   HelpMessage = 'Output the raw response from the server in UNIX time')]
		[Parameter(ParameterSetName = 'Session',
				   Position = 2,
				   HelpMessage = 'Output the raw response from the server in UNIX time')]
		[switch]$Raw
	)

	# build the payload for a xmlrpc web request
	# No params for getTime
	$payload = '<?xml version="1.0"?><methodCall><methodName>dokuwiki.getTime</methodName><params></params></methodCall>'
	$headers = @{ "Content-Type" = "text/xml"; }

	if ($PSCmdlet.ParameterSetName -eq "Basic") {
		# Add credentials to HTTP Basic auth header
		$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecPassword)
		$password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

		$pair = "$($username):$($password)"
		$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
		$headers.Add("Authorization", "Basic $encodedCreds")

		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop
		} catch {
			Write-Error $PSItem
			return $null
		}
	} else {
		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop -WebSession $WebSession
		} catch {
			Write-Error $PSItem
			return $null
		}
	}

	$RawDokuTime = [int]([xml]$httpResponse.Content | Select-Xml -XPath "//value/int").node.InnerText
	if ($Raw) {
		return $RawDokuTime
	} else {
		$DokuDateTime = Get-Date -Date $RawDokuTime
		return $DokuDateTime
	}
}

function Get-DokuVersion {
<#
	.SYNOPSIS
		Returns the DokuWiki version of the remote Wiki

	.DESCRIPTION
		Returns the DokuWiki version of the remote Wiki

	.PARAMETER Uri
		The URI of the wiki XMLRPC api endpoint

	.PARAMETER Username
		The user that will be sending the payload

	.PARAMETER SecPassword
		The password for user that will be sending the payload

	.PARAMETER WebSession
		The Web.Session object containing the login tokens

	.EXAMPLE
		PS C:\> $Version = Get-DokuVersion -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -Username "adlp" -SecPassword $SecureStringPassword

	.EXAMPLE
		PS C:\> $version = Get-DokuVersion -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -WebSession $LoginCookies

	.OUTPUTS
		System.Management.Automation.PSObject

	.NOTES
		AndyDLP - 2018-05-26
#>

	[CmdletBinding(DefaultParameterSetName = 'Basic')]
	[OutputType([psobject])]
	param
	(
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[ValidateNotNullOrEmpty()]
		[string]$Uri,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 3,
				   HelpMessage = 'The user that will be requesting the server time')]
		[ValidateNotNullOrEmpty()]
		[string]$Username,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 4,
				   HelpMessage = 'The password for the user that will be requesting the server time')]
		[ValidateNotNullOrEmpty()]
		[securestring]$SecPassword,
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $false,
				   Position = 3,
				   HelpMessage = 'The Web.Session object containing the login tokens')]
		[Microsoft.PowerShell.Commands.WebRequestSession]$WebSession
	)

	# build the payload for a xmlrpc web request
	# No params for getTime
	$payload = '<?xml version="1.0"?><methodCall><methodName>dokuwiki.getVersion</methodName><params></params></methodCall>'
	$headers = @{ "Content-Type" = "text/xml"; }

	if ($PSCmdlet.ParameterSetName -eq "Basic") {
		# Add credentials to HTTP Basic auth header
		$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecPassword)
		$password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

		$pair = "$($username):$($password)"
		$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
		$headers.Add("Authorization", "Basic $encodedCreds")

		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop
		} catch {
			Write-Error $PSItem
			return $null
		}
	} else {
		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop -WebSession $WebSession
		} catch {
			Write-Error $PSItem
			return $null
		}
	}

	$RawDokuVersion = [string]([xml]$httpResponse.Content | Select-Xml -XPath "//value/string").node.InnerText
	$CodeName = $RawDokuVersion | ForEach-Object -Process { [regex]::match($_, '(?<=")(.+)(?=")') } | Select-Object -ExpandProperty value
	$SplitVersion = $RawDokuVersion -split " "
	$VersionObject = New-Object PSObject -Property @{
		Type = $SplitVersion[0]
		ReleaseDate = $SplitVersion[1] # TODO: Convert to date time - replace letter(s)
		Codename = $CodeName
	}
	return $VersionObject
}

function Get-DokuAPIVersion {
<#
	.SYNOPSIS
		Returns the XML RPC interface version of the remote Wiki

	.DESCRIPTION
		Returns the XML RPC interface version of the remote Wiki

	.PARAMETER Uri
		The URI of the wiki XMLRPC api endpoint

	.PARAMETER Username
		The user that will be sending the payload

	.PARAMETER SecPassword
		The password for user that will be sending the payload

	.PARAMETER WebSession
		The Web.Session object containing the login tokens

	.EXAMPLE
		PS C:\> $APIVersion = Get-DokuAPIVersion -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -Username "adlp" -SecPassword $SecureStringPassword

	.EXAMPLE
		PS C:\> $APIVersion = Get-DokuAPIVersion -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -WebSession $LoginCookies

	.OUTPUTS
		System.Int32

	.NOTES
		AndyDLP - 2018-05-26
#>

	[CmdletBinding(DefaultParameterSetName = 'Basic')]
	[OutputType([int])]
	param
	(
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[ValidateNotNullOrEmpty()]
		[string]$Uri,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 3,
				   HelpMessage = 'The user that will be sending the request')]
		[ValidateNotNullOrEmpty()]
		[string]$Username,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 4,
				   HelpMessage = 'The password for the user that will be sending the request')]
		[ValidateNotNullOrEmpty()]
		[securestring]$SecPassword,
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $false,
				   Position = 3,
				   HelpMessage = 'The Web.Session object containing the login tokens')]
		[Microsoft.PowerShell.Commands.WebRequestSession]$WebSession
	)

	# build the payload for a xmlrpc web request
	# No params for getTime
	$payload = '<?xml version="1.0"?><methodCall><methodName>dokuwiki.getXMLRPCAPIVersion</methodName><params></params></methodCall>'
	$headers = @{ "Content-Type" = "text/xml"; }

	if ($PSCmdlet.ParameterSetName -eq "Basic") {
		# Add credentials to HTTP Basic auth header
		$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecPassword)
		$password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

		$pair = "$($username):$($password)"
		$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
		$headers.Add("Authorization", "Basic $encodedCreds")

		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop
		} catch {
			Write-Error $PSItem
			return $null
		}
	} else {
		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop -WebSession $WebSession
		} catch {
			Write-Error $PSItem
			return $null
		}
	}

	$APIVersion = [int]([xml]$httpResponse.Content | Select-Xml -XPath "//value/int").node.InnerText
	return $APIVersion
}

function Get-DokuRpcVersionSupported {
<#
	.SYNOPSIS
		Returns 2 with the supported RPC API version.

	.DESCRIPTION
		Returns 2 with the supported RPC API version.

	.PARAMETER Uri
		The URI of the wiki XMLRPC api endpoint

	.PARAMETER Username
		The user that will be sending the payload

	.PARAMETER SecPassword
		The password for user that will be sending the payload

	.PARAMETER WebSession
		The Web.Session object containing the login tokens

	.EXAMPLE
		PS C:\> $RPCVersionsSupported = Get-DokuRpcVersionSupported -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -Username "adlp" -SecPassword $SecureStringPassword

	.EXAMPLE
		PS C:\> $RPCVersionsSupported = Get-DokuRpcVersionSupported -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -WebSession $LoginCookies

	.OUTPUTS
		System.String

	.NOTES
		AndyDLP - 2018-05-26
#>

	[CmdletBinding(DefaultParameterSetName = 'Basic')]
	[OutputType([string])]
	param
	(
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[ValidateNotNullOrEmpty()]
		[string]$Uri,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 3,
				   HelpMessage = 'The user that will be sending the request')]
		[ValidateNotNullOrEmpty()]
		[string]$Username,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 4,
				   HelpMessage = 'The password for the user that will be sending the request')]
		[ValidateNotNullOrEmpty()]
		[securestring]$SecPassword,
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $false,
				   Position = 3,
				   HelpMessage = 'The Web.Session object containing the login tokens')]
		[Microsoft.PowerShell.Commands.WebRequestSession]$WebSession
	)

	# build the payload for a xmlrpc web request
	# No params for getTime
	$payload = '<?xml version="1.0"?><methodCall><methodName>wiki.getRPCVersionSupported</methodName><params></params></methodCall>'
	$headers = @{ "Content-Type" = "text/xml"; }

	if ($PSCmdlet.ParameterSetName -eq "Basic") {
		# Add credentials to HTTP Basic auth header
		$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecPassword)
		$password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

		$pair = "$($username):$($password)"
		$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
		$headers.Add("Authorization", "Basic $encodedCreds")

		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop
		} catch {
			Write-Error $PSItem
			return $null
		}
	} else {
		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop -WebSession $WebSession
		} catch {
			Write-Error $PSItem
			return $null
		}
	}

	[int]$RPCVersionsSupported = ([xml]$httpResponse.Content | Select-Xml -XPath "//value/int").node.InnerText
	return $RPCVersionsSupported
}

function Get-DokuTitle {
<#
	.SYNOPSIS
		Returns the title of the wiki

	.DESCRIPTION
		Returns the title of the wiki

	.PARAMETER Uri
		The URI of the wiki XMLRPC api endpoint

	.PARAMETER Username
		The user that will be sending the payload

	.PARAMETER SecPassword
		The password for user that will be sending the payload

	.PARAMETER WebSession
		The Web.Session object containing the login tokens

	.EXAMPLE
		PS C:\> $DokuTitle = Get-DokuTitle -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -Username "adlp" -SecPassword $SecureStringPassword

	.EXAMPLE
		PS C:\> $DokuTitle = Get-DokuTitle -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -WebSession $LoginCookies

	.OUTPUTS
		System.String

	.NOTES
		AndyDLP - 2018-05-26
#>

	[CmdletBinding(DefaultParameterSetName = 'Basic')]
	[OutputType([string])]
	param
	(
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[ValidateNotNullOrEmpty()]
		[string]$Uri,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 3,
				   HelpMessage = 'The user that will be sending the request')]
		[ValidateNotNullOrEmpty()]
		[string]$Username,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 4,
				   HelpMessage = 'The password for the user that will be sending the request')]
		[ValidateNotNullOrEmpty()]
		[securestring]$SecPassword,
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $false,
				   Position = 3,
				   HelpMessage = 'The Web.Session object containing the login tokens')]
		[Microsoft.PowerShell.Commands.WebRequestSession]$WebSession
	)

	# build the payload for a xmlrpc web request
	# No params for getTime
	$payload = '<?xml version="1.0"?><methodCall><methodName>dokuwiki.getTitle</methodName><params></params></methodCall>'
	$headers = @{ "Content-Type" = "text/xml"; }

	if ($PSCmdlet.ParameterSetName -eq "Basic") {
		# Add credentials to HTTP Basic auth header
		$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecPassword)
		$password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

		$pair = "$($username):$($password)"
		$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
		$headers.Add("Authorization", "Basic $encodedCreds")

		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop
		} catch {
			Write-Error $PSItem
			return $null
		}
	} else {
		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop -WebSession $WebSession
		} catch {
			Write-Error $PSItem
			return $null
		}
	}

	[string]$DokuTitle = ([xml]$httpResponse.Content | Select-Xml -XPath "//value/string").node.InnerText
	return $DokuTitle
}

function New-DokuLoginSession {
<#
	.SYNOPSIS
		Login to a DokuWiki instance with supplied credentials and create a web session

	.DESCRIPTION
		Login to a DokuWiki instance with supplied credentials and create a web session

	.PARAMETER Uri
		The URI of the wiki XMLRPC api endpoint

	.PARAMETER Username
		The username of the user that will be logging in

	.PARAMETER Password
		The password for the user

	.PARAMETER AllowUnencrypted
		Allow sending a plaintext password to an unencrypted (non-https) Uri

	.EXAMPLE
		PS C:\> $DokuSession = New-DokuLoginSession -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -Username "User1" -Password "Password1"

	.EXAMPLE
		PS C:\> $DokuSession = New-DokuLoginSession -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -Username "User1" -Password "Password1" -AllowUnencrypted

	.OUTPUTS
		Microsoft.PowerShell.Commands.WebRequestSession

	.NOTES
		Additional information about the function.
#>

	[CmdletBinding()]
	[OutputType([Microsoft.PowerShell.Commands.WebRequestSession])]
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
		[string]$Password,
		[Parameter(Position = 4,
				   HelpMessage = 'Allow sending a plaintext password to an unencrypted (non-https) Uri')]
		[switch]$AllowUnencrypted
	)
	# TODO: Work out how to secure the password on HTTP (is it even possible with the API?)

	# Block on non-https usage without 'AllowUnencrypted' switch
	if ((!$AllowUnencrypted) -and ($Uri -notmatch "https://")) {
		throw "Non-HTTPS endpoint, please set -AllowUnencrypted to ignore"
	}

	$payload = "<?xml version='1.0'?><methodCall><methodName>dokuwiki.login</methodName><params><param><value><string>$username</string></value></param><param><value><string>$password</string></value></param></params></methodCall>"
	$headers = @{ "Content-Type" = "text/xml"; }
	Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -SessionVariable WebSession | Out-Null

	return $WebSession
}

function Search-DokuWiki {
<#
	.SYNOPSIS
		Search DokuWiki instance for matching pages

	.DESCRIPTION
		Returns an associative array with matching pages similar to what is returned by Get-Pagelist, snippets are provided for the first 15 results

	.PARAMETER Uri
		The URI of the wiki XMLRPC api endpoint

	.PARAMETER Username
		The user that will be sending the payload

	.PARAMETER SecPassword
		The password for user that will be sending the payload

	.PARAMETER WebSession
		The Web.Session object containing the login tokens

	.PARAMETER SearchString
		The search string to match pages against, see 'https://www.dokuwiki.org/search' for syntax details

	.EXAMPLE
		PS C:\> $MatchingPages = Search-DokuWiki -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -Username "adlp" -SecPassword $SecureStringPassword -SearchString "study"

	.EXAMPLE
		PS C:\> $MatchingPages = Search-DokuWiki -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -WebSession $LoginCookies -SearchString "study"

	.OUTPUTS
		System.String

	.NOTES
		AndyDLP - 2018-05-26
#>

	[CmdletBinding(DefaultParameterSetName = 'Basic')]
	[OutputType([string])]
	param
	(
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[ValidateNotNullOrEmpty()]
		[string]$Uri,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 3,
				   HelpMessage = 'The user that will be sending the request')]
		[ValidateNotNullOrEmpty()]
		[string]$Username,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 4,
				   HelpMessage = 'The password for the user that will be sending the request')]
		[ValidateNotNullOrEmpty()]
		[securestring]$SecPassword,
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $false,
				   Position = 3,
				   HelpMessage = 'The Web.Session object containing the login tokens')]
		[Microsoft.PowerShell.Commands.WebRequestSession]$WebSession,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'The search string to match pages against')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'The search string to match pages against')]
		[ValidateNotNullOrEmpty()]
		[string]$SearchString
	)

	# build the payload for a xmlrpc web request
	# No params for getTime
	$payload = "<?xml version='1.0'?><methodCall><methodName>dokuwiki.search</methodName><params><value><string>$SearchString</string></value></params></methodCall>"
	$headers = @{ "Content-Type" = "text/xml"; }

	if ($PSCmdlet.ParameterSetName -eq "Basic") {
		# Add credentials to HTTP Basic auth header
		$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecPassword)
		$password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

		$pair = "$($username):$($password)"
		$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
		$headers.Add("Authorization", "Basic $encodedCreds")

		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop
		} catch {
			Write-Error $PSItem
			return $null
		}
	} else {
		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop -WebSession $WebSession
		} catch {
			Write-Error $PSItem
			return $null
		}
	}

	$AllDokuwikiPages = @()
	$MemberNodes = ([xml]$httpResponse.Content | Select-Xml -XPath "//struct").Node
	foreach ($node in $MemberNodes) {
		$PageObject = New-Object PSObject -Property @{
			FullName = (($node.member)[0]).value.string
			Score = (($node.member)[1]).value.int
			Revision = (($node.member)[2]).value.int
			ModifiedTime = (($node.member)[3]).value.int
			Size = (($node.member)[4]).value.int
			Snippet = (($node.member)[5]).value.string
			Title = (($node.member)[6]).value.string
			PageName = (((($node.member)[0]).value.string) -split ":")[-1]
			ParentNamespace = (((($node.member)[0]).value.string) -split ":")[-2]
			RootNamespace = (((($node.member)[0]).value.string) -split ":")[0]
		}
		$AllDokuwikiPages = $AllDokuwikiPages + $PageObject
	}
	return $AllDokuwikiPages
}

function Get-DokuPageAcl {
<#
	.SYNOPSIS
		Returns the permission of the given wikipage

	.DESCRIPTION
		Returns the permission of the given wikipage

	.PARAMETER Uri
		The URI of the wiki XMLRPC api endpoint

	.PARAMETER Username
		The user that will be sending the payload

	.PARAMETER SecPassword
		The password for user that will be sending the payload

	.PARAMETER WebSession
		The Web.Session object containing the login tokens

	.PARAMETER FullName
		The full page name for which to return the ACL

	.EXAMPLE
		PS C:\> $PageACL = Get-DokuPageAcl -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -Username "adlp" -SecPassword $SecureStringPassword -FullName "namespace:namespace:page"

	.EXAMPLE
		PS C:\> $PageACL = Get-DokuPageAcl -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -WebSession $LoginCookies -FullName "namespace:namespace:page"

	.OUTPUTS
		System.Management.Automation.PSObject

	.NOTES
		AndyDLP - 2018-05-26
#>

	[CmdletBinding(DefaultParameterSetName = 'Basic')]
	[OutputType([psobject])]
	param
	(
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[ValidateNotNullOrEmpty()]
		[string]$Uri,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 3,
				   HelpMessage = 'The user that will be sending the request')]
		[ValidateNotNullOrEmpty()]
		[string]$Username,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 4,
				   HelpMessage = 'The password for the user that will be sending the request')]
		[ValidateNotNullOrEmpty()]
		[securestring]$SecPassword,
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $false,
				   Position = 3,
				   HelpMessage = 'The Web.Session object containing the login tokens')]
		[Microsoft.PowerShell.Commands.WebRequestSession]$WebSession,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'The full page name for which to return the ACL')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'The full page name for which to return the ACL')]
		[ValidateNotNullOrEmpty()]
		[string]$FullName
	)

	# build the payload for a xmlrpc web request
	# No params for getTime
	$payload = "<?xml version='1.0'?><methodCall><methodName>wiki.aclCheck</methodName><params><value><string>$FullName</string></value></params></methodCall>"
	$headers = @{ "Content-Type" = "text/xml"; }

	if ($PSCmdlet.ParameterSetName -eq "Basic") {
		# Add credentials to HTTP Basic auth header
		$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecPassword)
		$password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

		$pair = "$($username):$($password)"
		$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
		$headers.Add("Authorization", "Basic $encodedCreds")

		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop
		} catch {
			Write-Error $PSItem
			return $null
		}
	} else {
		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop -WebSession $WebSession
		} catch {
			Write-Error $PSItem
			return $null
		}
	}

	$PageObject = New-Object PSObject -Property @{
		FullName = $FullName
		Acl = [int]([xml]$httpResponse.Content | Select-Xml -XPath "//value/int").Node.InnerText
		PageName = ($FullName -split ":")[-1]
		ParentNamespace = ($FullName -split ":")[-2]
		RootNamespace = ($FullName -split ":")[0]
	}
	return $PageObject
}

function Get-DokuPageVersions {
<#
	.SYNOPSIS
		Returns the available versions of a Wiki page.

	.DESCRIPTION
		Returns the available versions of a Wiki page. The number of pages in the result is controlled via the recent configuration setting. The offset can be used to list earlier versions in the history

	.PARAMETER Uri
		The URI of the wiki XMLRPC api endpoint

	.PARAMETER Username
		The user that will be sending the payload

	.PARAMETER SecPassword
		The password for user that will be sending the payload

	.PARAMETER WebSession
		The Web.Session object containing the login tokens

	.PARAMETER FullName
		The full page name for which to return the data

	.PARAMETER Offset
		used to list earlier versions in the history

	.EXAMPLE
		PS C:\> $PageVersions = Get-DokuPageVersions -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -Username "adlp" -SecPassword $SecureStringPassword -FullName "namespace:namespace:page" -Offset 0

	.EXAMPLE
		PS C:\> $PageVersions = Get-DokuPageVersions -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -WebSession $LoginCookies -FullName "namespace:namespace:page" -Offset 0

	.OUTPUTS
		System.Array

	.NOTES
		AndyDLP - 2018-05-26
#>

	[CmdletBinding(DefaultParameterSetName = 'Basic')]
	[OutputType([array])]
	param
	(
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[ValidateNotNullOrEmpty()]
		[string]$Uri,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 4,
				   HelpMessage = 'The user that will be sending the request')]
		[ValidateNotNullOrEmpty()]
		[string]$Username,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 5,
				   HelpMessage = 'The password for the user that will be sending the request')]
		[ValidateNotNullOrEmpty()]
		[securestring]$SecPassword,
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $false,
				   Position = 4,
				   HelpMessage = 'The Web.Session object containing the login tokens')]
		[Microsoft.PowerShell.Commands.WebRequestSession]$WebSession,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'The full page name for which to return the data')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'The full page name for which to return the data')]
		[ValidateNotNullOrEmpty()]
		[string]$FullName,
		[Parameter(ParameterSetName = 'Basic',
				   Position = 3,
				   HelpMessage = 'Used to list earlier versions in the history')]
		[Parameter(ParameterSetName = 'Session',
				   Position = 3,
				   HelpMessage = 'Used to list earlier versions in the history')]
		[ValidateNotNullOrEmpty()]
		[int]$Offset = 0
	)

	# build the payload for a xmlrpc web request
	# No params for getTime
	$payload = "<?xml version='1.0'?><methodCall><methodName>wiki.getPageVersions</methodName><params><param><value><string>$FullName</string></value></param><param><value><i4>$Offset</i4></value></param></params></methodCall>"
	$headers = @{ "Content-Type" = "text/xml"; }

	if ($PSCmdlet.ParameterSetName -eq "Basic") {
		# Add credentials to HTTP Basic auth header
		$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecPassword)
		$password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

		$pair = "$($username):$($password)"
		$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
		$headers.Add("Authorization", "Basic $encodedCreds")

		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop
		} catch {
			Write-Error $PSItem
			return $null
		}
	} else {
		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop -WebSession $WebSession
		} catch {
			Write-Error $PSItem
			return $null
		}
	}

	$PageVersions = @()
	$MemberNodes = ([xml]$httpResponse.Content | Select-Xml -XPath "//struct").Node
	foreach ($node in $MemberNodes) {
		$PageObject = New-Object PSObject -Property @{
			FullName = $FullName
			User = (($node.member)[0]).value.string
			IpAddress = (($node.member)[1]).value.string
			Type = (($node.member)[2]).value.string
			Summary = (($node.member)[3]).value.string
			Modified = Get-Date -Date ((($node.member)[4]).value.InnerText)
			VersionTimestamp = (($node.member)[5]).value.int
			PageName = ($FullName -split ":")[-1]
			ParentNamespace = ($FullName -split ":")[-2]
			RootNamespace = ($FullName -split ":")[0]
		}
		$PageVersions = $PageVersions + $PageObject
	}
	return $PageVersions
}

function Get-DokuPageData {
<#
	.SYNOPSIS
		Returns the raw Wiki text for a page

	.DESCRIPTION
		Returns the raw Wiki text for a page

	.PARAMETER Uri
		The URI of the wiki XMLRPC api endpoint

	.PARAMETER Username
		The user that will be sending the payload

	.PARAMETER SecPassword
		The password for user that will be sending the payload

	.PARAMETER WebSession
		The Web.Session object containing the login tokens

	.PARAMETER FullName
		The full page name for which to return the data

	.EXAMPLE
		PS C:\> $RawText = Get-DokuPageData -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -Username "adlp" -SecPassword $SecureStringPassword -FullName "namespace:namespace:page"

	.EXAMPLE
		PS C:\> $RawText = Get-DokuPageData -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -WebSession $LoginCookies -FullName "namespace:namespace:page"

	.OUTPUTS
		System.String

	.NOTES
		AndyDLP - 2018-05-26
#>

	[CmdletBinding(DefaultParameterSetName = 'Basic')]
	[OutputType([string])]
	param
	(
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[ValidateNotNullOrEmpty()]
		[string]$Uri,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 3,
				   HelpMessage = 'The user that will be sending the request')]
		[ValidateNotNullOrEmpty()]
		[string]$Username,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 4,
				   HelpMessage = 'The password for the user that will be sending the request')]
		[ValidateNotNullOrEmpty()]
		[securestring]$SecPassword,
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $false,
				   Position = 3,
				   HelpMessage = 'The Web.Session object containing the login tokens')]
		[Microsoft.PowerShell.Commands.WebRequestSession]$WebSession,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'The full page name for which to return the data')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'The full page name for which to return the data')]
		[ValidateNotNullOrEmpty()]
		[string]$FullName
	)

	# build the payload for a xmlrpc web request
	# No params for getTime
	$payload = "<?xml version='1.0'?><methodCall><methodName>wiki.getPage</methodName><params><value><string>$FullName</string></value></params></methodCall>"
	$headers = @{ "Content-Type" = "text/xml"; }

	if ($PSCmdlet.ParameterSetName -eq "Basic") {
		# Add credentials to HTTP Basic auth header
		$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecPassword)
		$password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

		$pair = "$($username):$($password)"
		$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
		$headers.Add("Authorization", "Basic $encodedCreds")

		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop
		} catch {
			Write-Error $PSItem
			return $null
		}
	} else {
		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop -WebSession $WebSession
		} catch {
			Write-Error $PSItem
			return $null
		}
	}

	$PageObject = New-Object PSObject -Property @{
		FullName = $FullName
		RawText = [string]([xml]$httpResponse.Content | Select-Xml -XPath "//value/string").Node.InnerText
		PageName = ($FullName -split ":")[-1]
		ParentNamespace = ($FullName -split ":")[-2]
		RootNamespace = ($FullName -split ":")[0]
	}
	return $PageObject
}

function Get-DokuPageVersionData {
<#
	.SYNOPSIS
		Returns the raw Wiki text for a page

	.DESCRIPTION
		Returns the raw Wiki text for a page

	.PARAMETER Uri
		The URI of the wiki XMLRPC api endpoint

	.PARAMETER Username
		The user that will be sending the payload

	.PARAMETER SecPassword
		The password for user that will be sending the payload

	.PARAMETER WebSession
		The Web.Session object containing the login tokens

	.PARAMETER FullName
		The full page name for which to return the data

	.PARAMETER VersionTimestamp
		The timestamp for which version to get the info from

	.EXAMPLE
		PS C:\> $PageData = Get-DokuPageVersionData -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -Username "adlp" -SecPassword $SecureStringPassword -FullName "namespace:namespace:page" -VersionTimestamp 1497464418

	.EXAMPLE
		PS C:\> $PageData = Get-DokuPageVersionData -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -WebSession $LoginCookies -FullName "namespace:namespace:page" -VersionTimestamp 1497464418

	.OUTPUTS
		System.Management.Automation.PSObject

	.NOTES
		AndyDLP - 2018-05-26
#>

	[CmdletBinding(DefaultParameterSetName = 'Basic')]
	[OutputType([psobject])]
	param
	(
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[ValidateNotNullOrEmpty()]
		[string]$Uri,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 4,
				   HelpMessage = 'The user that will be sending the request')]
		[ValidateNotNullOrEmpty()]
		[string]$Username,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 5,
				   HelpMessage = 'The password for the user that will be sending the request')]
		[ValidateNotNullOrEmpty()]
		[securestring]$SecPassword,
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $false,
				   Position = 4,
				   HelpMessage = 'The Web.Session object containing the login tokens')]
		[Microsoft.PowerShell.Commands.WebRequestSession]$WebSession,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'The full page name for which to return the data')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'The full page name for which to return the data')]
		[ValidateNotNullOrEmpty()]
		[string]$FullName,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 3,
				   HelpMessage = 'The timestamp for which version to get the info from')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 3,
				   HelpMessage = 'The timestamp for which version to get the info from')]
		[ValidateNotNullOrEmpty()]
		[int]$VersionTimestamp
	)

	# build the payload for a xmlrpc web request
	# No params for getTime
	$payload = "<?xml version='1.0'?><methodCall><methodName>wiki.getPageVersion</methodName><params><param><value><string>$FullName</string></value></param><param><value><i4>$VersionTimestamp</i4></value></param></params></methodCall>"
	$headers = @{ "Content-Type" = "text/xml"; }

	if ($PSCmdlet.ParameterSetName -eq "Basic") {
		# Add credentials to HTTP Basic auth header
		$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecPassword)
		$password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

		$pair = "$($username):$($password)"
		$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
		$headers.Add("Authorization", "Basic $encodedCreds")

		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop
		} catch {
			Write-Error $PSItem
			return $null
		}
	} else {
		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop -WebSession $WebSession
		} catch {
			Write-Error $PSItem
			return $null
		}
	}

	$PageObject = New-Object PSObject -Property @{
		FullName = $FullName
		VersionTimestamp = $VersionTimestamp
		RawText = [string]([xml]$httpResponse.Content | Select-Xml -XPath "//value/string").Node.InnerText
		PageName = ($FullName -split ":")[-1]
		ParentNamespace = ($FullName -split ":")[-2]
		RootNamespace = ($FullName -split ":")[0]
	}
	return $PageObject
}

function Get-DokuPageInfo {
<#
	.SYNOPSIS
		Returns information about a Wiki page

	.DESCRIPTION
		Returns information about a Wiki page

	.PARAMETER Uri
		The URI of the wiki XMLRPC api endpoint

	.PARAMETER Username
		The user that will be sending the payload

	.PARAMETER SecPassword
		The password for user that will be sending the payload

	.PARAMETER WebSession
		The Web.Session object containing the login tokens

	.PARAMETER FullName
		The full page name for which to return the data

	.EXAMPLE
		PS C:\> $PageInfo = Get-DokuPageInfo -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -Username "adlp" -SecPassword $SecureStringPassword -FullName "namespace:namespace:page"

	.EXAMPLE
		PS C:\> $PageInfo = Get-DokuPageInfo -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -WebSession $LoginCookies -FullName "namespace:namespace:page"

	.OUTPUTS
		System.Management.Automation.PSObject

	.NOTES
		AndyDLP - 2018-05-26
#>

	[CmdletBinding(DefaultParameterSetName = 'Basic')]
	[OutputType([psobject])]
	param
	(
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[ValidateNotNullOrEmpty()]
		[string]$Uri,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 3,
				   HelpMessage = 'The user that will be sending the request')]
		[ValidateNotNullOrEmpty()]
		[string]$Username,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 4,
				   HelpMessage = 'The password for the user that will be sending the request')]
		[ValidateNotNullOrEmpty()]
		[securestring]$SecPassword,
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $false,
				   Position = 3,
				   HelpMessage = 'The Web.Session object containing the login tokens')]
		[Microsoft.PowerShell.Commands.WebRequestSession]$WebSession,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'The full page name for which to return the data')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'The full page name for which to return the data')]
		[ValidateNotNullOrEmpty()]
		[string]$FullName
	)

	# build the payload for a xmlrpc web request
	# No params for getTime
	$payload = "<?xml version='1.0'?><methodCall><methodName>wiki.getPageInfo</methodName><params><value><string>$FullName</string></value></params></methodCall>"
	$headers = @{ "Content-Type" = "text/xml"; }

	if ($PSCmdlet.ParameterSetName -eq "Basic") {
		# Add credentials to HTTP Basic auth header
		$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecPassword)
		$password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

		$pair = "$($username):$($password)"
		$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
		$headers.Add("Authorization", "Basic $encodedCreds")

		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop
		} catch {
			Write-Error $PSItem
			return $null
		}
	} else {
		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop -WebSession $WebSession
		} catch {
			Write-Error $PSItem
			return $null
		}
	}

	$ArrayValues = ([xml]$httpResponse.Content | Select-Xml -XPath "//struct").Node.Member.Value.Innertext
	$PageObject = New-Object PSObject -Property @{
		FullName = $FullName
		LastModified = Get-Date -Date ($ArrayValues[1])
		Author = $ArrayValues[2]
		VersionTimestamp = $ArrayValues[3]
		PageName = ($FullName -split ":")[-1]
		ParentNamespace = ($FullName -split ":")[-2]
		RootNamespace = ($FullName -split ":")[0]
	}
	return $PageObject
}

function Get-DokuPageVersionInfo {
<#
	.SYNOPSIS
		Returns information about a specific version of a Wiki page

	.DESCRIPTION
		Returns information about a specific version of a Wiki page

	.PARAMETER Uri
		The URI of the wiki XMLRPC api endpoint

	.PARAMETER Username
		The user that will be sending the payload

	.PARAMETER SecPassword
		The password for user that will be sending the payload

	.PARAMETER WebSession
		The Web.Session object containing the login tokens

	.PARAMETER FullName
		The full page name for which to return the data

	.PARAMETER VersionTimestamp
		The timestamp for which version to get the info from

	.EXAMPLE
		PS C:\> $PageInfo = Get-DokuPageVersionInfo -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -Username "adlp" -SecPassword $SecureStringPassword -FullName "namespace:namespace:page" -VersionTimestamp 1497464418

	.EXAMPLE
		PS C:\> $PageInfo = Get-DokuPageVersionInfo -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -WebSession $LoginCookies -FullName "namespace:namespace:page" -VersionTimestamp 1497464418

	.OUTPUTS
		System.Management.Automation.PSObject

	.NOTES
		AndyDLP - 2018-05-26
#>

	[CmdletBinding(DefaultParameterSetName = 'Basic')]
	[OutputType([psobject])]
	param
	(
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[ValidateNotNullOrEmpty()]
		[string]$Uri,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 4,
				   HelpMessage = 'The user that will be sending the request')]
		[ValidateNotNullOrEmpty()]
		[string]$Username,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 5,
				   HelpMessage = 'The password for the user that will be sending the request')]
		[ValidateNotNullOrEmpty()]
		[securestring]$SecPassword,
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $false,
				   Position = 4,
				   HelpMessage = 'The Web.Session object containing the login tokens')]
		[Microsoft.PowerShell.Commands.WebRequestSession]$WebSession,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'The full page name for which to return the data')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'The full page name for which to return the data')]
		[ValidateNotNullOrEmpty()]
		[string]$FullName,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 3,
				   HelpMessage = 'The timestamp for which version to get the info from')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 3,
				   HelpMessage = 'The timestamp for which version to get the info from')]
		[ValidateNotNullOrEmpty()]
		[int]$VersionTimestamp
	)

	# build the payload for a xmlrpc web request
	# No params for getTime
	$payload = "<?xml version='1.0'?><methodCall><methodName>wiki.getPageInfoVersion</methodName><params><param><value><string>$FullName</string></value></param><param><value><i4>$VersionTimestamp</i4></value></param></params></methodCall>"
	$headers = @{ "Content-Type" = "text/xml"; }

	if ($PSCmdlet.ParameterSetName -eq "Basic") {
		# Add credentials to HTTP Basic auth header
		$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecPassword)
		$password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

		$pair = "$($username):$($password)"
		$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
		$headers.Add("Authorization", "Basic $encodedCreds")

		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop
		} catch {
			Write-Error $PSItem
			return $null
		}
	} else {
		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop -WebSession $WebSession
		} catch {
			Write-Error $PSItem
			return $null
		}
	}

	$ArrayValues = ([xml]$httpResponse.Content | Select-Xml -XPath "//struct").Node.Member.Value.Innertext
	$PageObject = New-Object PSObject -Property @{
		FullName = $FullName
		LastModified = Get-Date -Date ($ArrayValues[1])
		Author = $ArrayValues[2]
		VersionTimestamp = $ArrayValues[3]
		PageName = ($FullName -split ":")[-1]
		ParentNamespace = ($FullName -split ":")[-2]
		RootNamespace = ($FullName -split ":")[0]
	}
	return $PageObject
}

function Get-DokuPageHtml {
<#
	.SYNOPSIS
		Returns the rendered XHTML body of a Wiki page

	.DESCRIPTION
		Returns the rendered XHTML body of a Wiki page

	.PARAMETER Uri
		The URI of the wiki XMLRPC api endpoint

	.PARAMETER Username
		The user that will be sending the payload

	.PARAMETER SecPassword
		The password for user that will be sending the payload

	.PARAMETER WebSession
		The Web.Session object containing the login tokens

	.PARAMETER FullName
		The full page name for which to return the data

	.EXAMPLE
		PS C:\> $PageData = Get-DokuPageHtml -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -Username "adlp" -SecPassword $SecureStringPassword -FullName "namespace:namespace:page"

	.EXAMPLE
		PS C:\> $PageData = Get-DokuPageHtml -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -WebSession $LoginCookies -FullName "namespace:namespace:page"

	.OUTPUTS
		System.Management.Automation.PSObject

	.NOTES
		AndyDLP - 2018-05-26
#>

	[CmdletBinding(DefaultParameterSetName = 'Basic')]
	[OutputType([psobject])]
	param
	(
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[ValidateNotNullOrEmpty()]
		[string]$Uri,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 3,
				   HelpMessage = 'The user that will be sending the request')]
		[ValidateNotNullOrEmpty()]
		[string]$Username,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 4,
				   HelpMessage = 'The password for the user that will be sending the request')]
		[ValidateNotNullOrEmpty()]
		[securestring]$SecPassword,
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $false,
				   Position = 3,
				   HelpMessage = 'The Web.Session object containing the login tokens')]
		[Microsoft.PowerShell.Commands.WebRequestSession]$WebSession,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'The full page name for which to return the data')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'The full page name for which to return the data')]
		[ValidateNotNullOrEmpty()]
		[string]$FullName
	)

	# build the payload for a xmlrpc web request
	# No params for getTime
	$payload = "<?xml version='1.0'?><methodCall><methodName>wiki.getPageHTML</methodName><params><value><string>$FullName</string></value></params></methodCall>"
	$headers = @{ "Content-Type" = "text/xml"; }

	if ($PSCmdlet.ParameterSetName -eq "Basic") {
		# Add credentials to HTTP Basic auth header
		$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecPassword)
		$password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

		$pair = "$($username):$($password)"
		$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
		$headers.Add("Authorization", "Basic $encodedCreds")

		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop
		} catch {
			Write-Error $PSItem
			return $null
		}
	} else {
		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop -WebSession $WebSession
		} catch {
			Write-Error $PSItem
			return $null
		}
	}

	$PageObject = New-Object PSObject -Property @{
		FullName = $FullName
		RenderedHtml = [string]([xml]$httpResponse.Content | Select-Xml -XPath "//value/string").Node.InnerText
		PageName = ($FullName -split ":")[-1]
		ParentNamespace = ($FullName -split ":")[-2]
		RootNamespace = ($FullName -split ":")[0]
	}
	return $PageObject
}

function Get-DokuPageVersionHtml {
<#
	.SYNOPSIS
		Returns the rendered HTML for a specific version of a Wiki page

	.DESCRIPTION
		Returns the rendered HTML for a specific version of a Wiki page

	.PARAMETER Uri
		The URI of the wiki XMLRPC api endpoint

	.PARAMETER Username
		The user that will be sending the payload

	.PARAMETER SecPassword
		The password for user that will be sending the payload

	.PARAMETER WebSession
		The Web.Session object containing the login tokens

	.PARAMETER FullName
		The full page name for which to return the data

	.PARAMETER VersionTimestamp
		The timestamp for which version to get the info from

	.EXAMPLE
		PS C:\> $PageHtml = Get-DokuPageVersionHtml -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -Username "adlp" -SecPassword $SecureStringPassword -FullName "namespace:namespace:page" -VersionTimestamp 1497464418

	.EXAMPLE
		PS C:\> $PageHtml = Get-DokuPageVersionHtml -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -WebSession $LoginCookies -FullName "namespace:namespace:page" -VersionTimestamp 1497464418

	.OUTPUTS
		System.Management.Automation.PSObject

	.NOTES
		AndyDLP - 2018-05-26
#>

	[CmdletBinding(DefaultParameterSetName = 'Basic')]
	[OutputType([psobject])]
	param
	(
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[ValidateNotNullOrEmpty()]
		[string]$Uri,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 4,
				   HelpMessage = 'The user that will be sending the request')]
		[ValidateNotNullOrEmpty()]
		[string]$Username,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 5,
				   HelpMessage = 'The password for the user that will be sending the request')]
		[ValidateNotNullOrEmpty()]
		[securestring]$SecPassword,
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $false,
				   Position = 4,
				   HelpMessage = 'The Web.Session object containing the login tokens')]
		[Microsoft.PowerShell.Commands.WebRequestSession]$WebSession,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'The full page name for which to return the data')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'The full page name for which to return the data')]
		[ValidateNotNullOrEmpty()]
		[string]$FullName,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 3,
				   HelpMessage = 'The timestamp for which version to get the info from')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 3,
				   HelpMessage = 'The timestamp for which version to get the info from')]
		[ValidateNotNullOrEmpty()]
		[int]$VersionTimestamp
	)

	# build the payload for a xmlrpc web request
	# No params for getTime
	$payload = "<?xml version='1.0'?><methodCall><methodName>wiki.getPageHTMLVersion</methodName><params><param><value><string>$FullName</string></value></param><param><value><i4>$VersionTimestamp</i4></value></param></params></methodCall>"
	$headers = @{ "Content-Type" = "text/xml"; }

	if ($PSCmdlet.ParameterSetName -eq "Basic") {
		# Add credentials to HTTP Basic auth header
		$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecPassword)
		$password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

		$pair = "$($username):$($password)"
		$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
		$headers.Add("Authorization", "Basic $encodedCreds")

		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop
		} catch {
			Write-Error $PSItem
			return $null
		}
	} else {
		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop -WebSession $WebSession
		} catch {
			Write-Error $PSItem
			return $null
		}
	}

	$PageObject = New-Object PSObject -Property @{
		FullName = $FullName
		RenderedHtml = [string]([xml]$httpResponse.Content | Select-Xml -XPath "//value/string").Node.InnerText
		PageName = ($FullName -split ":")[-1]
		ParentNamespace = ($FullName -split ":")[-2]
		RootNamespace = ($FullName -split ":")[0]
	}
	return $PageObject
}

function Get-DokuPageLinks {
<#
	.SYNOPSIS
		Returns an array of all links on a page

	.DESCRIPTION
		Returns an array of all links on a page

	.PARAMETER Uri
		The URI of the wiki XMLRPC api endpoint

	.PARAMETER Username
		The user that will be sending the payload

	.PARAMETER SecPassword
		The password for user that will be sending the payload

	.PARAMETER WebSession
		The Web.Session object containing the login tokens

	.PARAMETER FullName
		The full page name for which to return the data

	.EXAMPLE
		PS C:\> $PageLinks = Get-DokuPageLinks -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -Username "adlp" -SecPassword $SecureStringPassword -FullName "namespace:namespace:page"

	.EXAMPLE
		PS C:\> $PageLinks = Get-DokuPageLinks -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -WebSession $LoginCookies -FullName "namespace:namespace:page"

	.OUTPUTS
		System.Array

	.NOTES
		AndyDLP - 2018-05-26
#>

	[CmdletBinding(DefaultParameterSetName = 'Basic')]
	[OutputType([array])]
	param
	(
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[ValidateNotNullOrEmpty()]
		[string]$Uri,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 3,
				   HelpMessage = 'The user that will be sending the request')]
		[ValidateNotNullOrEmpty()]
		[string]$Username,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 4,
				   HelpMessage = 'The password for the user that will be sending the request')]
		[ValidateNotNullOrEmpty()]
		[securestring]$SecPassword,
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $false,
				   Position = 3,
				   HelpMessage = 'The Web.Session object containing the login tokens')]
		[Microsoft.PowerShell.Commands.WebRequestSession]$WebSession,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'The full page name for which to return the data')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'The full page name for which to return the data')]
		[ValidateNotNullOrEmpty()]
		[string]$FullName
	)

	# build the payload for a xmlrpc web request
	# No params for getTime
	$payload = "<?xml version='1.0'?><methodCall><methodName>wiki.listLinks</methodName><params><param><value><string>$FullName</string></value></param></params></methodCall>"
	$headers = @{ "Content-Type" = "text/xml"; }

	if ($PSCmdlet.ParameterSetName -eq "Basic") {
		# Add credentials to HTTP Basic auth header
		$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecPassword)
		$password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

		$pair = "$($username):$($password)"
		$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
		$headers.Add("Authorization", "Basic $encodedCreds")

		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop
		} catch {
			Write-Error $PSItem
			return $null
		}
	} else {
		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop -WebSession $WebSession
		} catch {
			Write-Error $PSItem
			return $null
		}
	}

	$PageLinks = @()
	$MemberNodes = ([xml]$httpResponse.Content | Select-Xml -XPath "//struct").Node
	foreach ($node in $MemberNodes) {
		$PageObject = New-Object PSObject -Property @{
			FullName = $FullName
			Type = (($node.member)[0]).value.string
			PageName = (($node.member)[1]).value.string
			URL = (($node.member)[2]).value.string
		}
		$PageLinks = $PageLinks + $PageObject
	}
	return $PageLinks
}

function Get-DokuAllPages {
<#
	.SYNOPSIS
		Returns a list of all Wiki pages in the remote Wiki

	.DESCRIPTION
		Returns a list of all Wiki pages in the remote Wiki

	.PARAMETER Uri
		The URI of the wiki XMLRPC api endpoint

	.PARAMETER Username
		The user that will be sending the payload

	.PARAMETER SecPassword
		The password for user that will be sending the payload

	.PARAMETER WebSession
		The Web.Session object containing the login tokens

	.EXAMPLE
		PS C:\> $AllPages = Get-DokuAllPages -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -Username "adlp" -SecPassword $SecureStringPassword

	.EXAMPLE
		PS C:\> $AllPages = Get-DokuAllPages -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -WebSession $LoginCookies

	.OUTPUTS
		System.Array

	.NOTES
		AndyDLP - 2018-05-26
#>

	[CmdletBinding(DefaultParameterSetName = 'Basic')]
	[OutputType([array])]
	param
	(
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[ValidateNotNullOrEmpty()]
		[string]$Uri,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 3,
				   HelpMessage = 'The user that will be sending the request')]
		[ValidateNotNullOrEmpty()]
		[string]$Username,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 4,
				   HelpMessage = 'The password for the user that will be sending the request')]
		[ValidateNotNullOrEmpty()]
		[securestring]$SecPassword,
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $false,
				   Position = 3,
				   HelpMessage = 'The Web.Session object containing the login tokens')]
		[Microsoft.PowerShell.Commands.WebRequestSession]$WebSession
	)

	# build the payload for a xmlrpc web request
	# No params for getTime
	$payload = "<?xml version='1.0'?><methodCall><methodName>wiki.getAllPages</methodName><params></params></methodCall>"
	$headers = @{ "Content-Type" = "text/xml"; }

	if ($PSCmdlet.ParameterSetName -eq "Basic") {
		# Add credentials to HTTP Basic auth header
		$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecPassword)
		$password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

		$pair = "$($username):$($password)"
		$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
		$headers.Add("Authorization", "Basic $encodedCreds")

		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop
		} catch {
			Write-Error $PSItem
			return $null
		}
	} else {
		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop -WebSession $WebSession
		} catch {
			Write-Error $PSItem
			return $null
		}
	}

	$AllPages = @()
	$MemberNodes = ([xml]$httpResponse.Content | Select-Xml -XPath "//struct").Node
	foreach ($node in $MemberNodes) {
		$PageObject = New-Object PSObject -Property @{
			FullName = (($node.member)[0]).value.InnerText
			Acl = (($node.member)[1]).value.InnerText
			Size = (($node.member)[2]).value.InnerText
			LastModified = Get-Date -Date ((($node.member)[3]).value.InnerText)
		}
		$AllPages = $AllPages + $PageObject
	}
	return $AllPages
}

function Get-DokuPageBackLinks {
<#
	.SYNOPSIS
		Returns a list of backlinks of a Wiki page

	.DESCRIPTION
		Returns a list of backlinks of a Wiki page

	.PARAMETER Uri
		The URI of the wiki XMLRPC api endpoint

	.PARAMETER Username
		The user that will be sending the payload

	.PARAMETER SecPassword
		The password for user that will be sending the payload

	.PARAMETER WebSession
		The Web.Session object containing the login tokens

	.PARAMETER FullName
		The full page name for which to return the data

	.EXAMPLE
		PS C:\> $PageBackLinks = Get-DokuPageBackLinks -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -Username "adlp" -SecPassword $SecureStringPassword -FullName "namespace:namespace:page"

	.EXAMPLE
		PS C:\> $PageBackLinks = Get-DokuPageBackLinks -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -WebSession $LoginCookies -FullName "namespace:namespace:page"

	.OUTPUTS
		System.Array

	.NOTES
		AndyDLP - 2018-05-26
#>

	[CmdletBinding(DefaultParameterSetName = 'Basic')]
	[OutputType([array])]
	param
	(
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[ValidateNotNullOrEmpty()]
		[string]$Uri,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 3,
				   HelpMessage = 'The user that will be sending the request')]
		[ValidateNotNullOrEmpty()]
		[string]$Username,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 4,
				   HelpMessage = 'The password for the user that will be sending the request')]
		[ValidateNotNullOrEmpty()]
		[securestring]$SecPassword,
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $false,
				   Position = 3,
				   HelpMessage = 'The Web.Session object containing the login tokens')]
		[Microsoft.PowerShell.Commands.WebRequestSession]$WebSession,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'The full page name for which to return the data')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'The full page name for which to return the data')]
		[ValidateNotNullOrEmpty()]
		[string]$FullName
	)

	# build the payload for a xmlrpc web request
	# No params for getTime
	$payload = "<?xml version='1.0'?><methodCall><methodName>wiki.listLinks</methodName><params><param><value><string>$FullName</string></value></param></params></methodCall>"
	$headers = @{ "Content-Type" = "text/xml"; }

	if ($PSCmdlet.ParameterSetName -eq "Basic") {
		# Add credentials to HTTP Basic auth header
		$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecPassword)
		$password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

		$pair = "$($username):$($password)"
		$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
		$headers.Add("Authorization", "Basic $encodedCreds")

		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop
		} catch {
			Write-Error $PSItem
			return $null
		}
	} else {
		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop -WebSession $WebSession
		} catch {
			Write-Error $PSItem
			return $null
		}
	}

	$PageLinks = @()
	$MemberNodes = ([xml]$httpResponse.Content | Select-Xml -XPath "//struct").Node
	foreach ($node in $MemberNodes) {
		$PageObject = New-Object PSObject -Property @{
			FullName = $FullName
			Type = (($node.member)[0]).value.innertext
			PageName = (($node.member)[1]).value.innertext
			URL = (($node.member)[2]).value.innertext
		}
		$PageLinks = $PageLinks + $PageObject
	}
	return $PageLinks
}

function Get-DokuRecentChanges {
<#
	.SYNOPSIS
		Returns a list of recent changes since given timestamp

	.DESCRIPTION
		Returns a list of recent changes since given timestamp.
		As stated in recent_changes: Only the most recent change for each page is listed, regardless of how many times that page was changed

	.PARAMETER Uri
		The URI of the wiki XMLRPC api endpoint

	.PARAMETER Username
		The user that will be sending the payload

	.PARAMETER SecPassword
		The password for user that will be sending the payload

	.PARAMETER WebSession
		The Web.Session object containing the login tokens

	.PARAMETER VersionTimestamp
		Get all pages since this timestamp

	.EXAMPLE
		PS C:\> $RecentChanges = Get-DokuRecentChanges -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -Username "adlp" -SecPassword $SecureStringPassword -VersionTimestamp 1497464418

	.EXAMPLE
		PS C:\> $RecentChanges = Get-DokuRecentChanges -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -WebSession $LoginCookies -VersionTimestamp 1497464418

	.OUTPUTS
		System.Array

	.NOTES
		AndyDLP - 2018-05-26
#>

	[CmdletBinding(DefaultParameterSetName = 'Basic')]
	[OutputType([array])]
	param
	(
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[ValidateNotNullOrEmpty()]
		[string]$Uri,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 3,
				   HelpMessage = 'The user that will be sending the request')]
		[ValidateNotNullOrEmpty()]
		[string]$Username,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 4,
				   HelpMessage = 'The password for the user that will be sending the request')]
		[ValidateNotNullOrEmpty()]
		[securestring]$SecPassword,
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $false,
				   Position = 3,
				   HelpMessage = 'The Web.Session object containing the login tokens')]
		[Microsoft.PowerShell.Commands.WebRequestSession]$WebSession,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'Get all pages since this timestamp')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'Get all pages since this timestamp')]
		[ValidateNotNullOrEmpty()]
		[int]$VersionTimestamp
	)

	# build the payload for a xmlrpc web request
	# No params for getTime
	$payload = "<?xml version='1.0'?><methodCall><methodName>wiki.getRecentChanges</methodName><params><param><value><i4>$VersionTimestamp</i4></value></param></params></methodCall>"
	$headers = @{ "Content-Type" = "text/xml"; }

	if ($PSCmdlet.ParameterSetName -eq "Basic") {
		# Add credentials to HTTP Basic auth header
		$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecPassword)
		$password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

		$pair = "$($username):$($password)"
		$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
		$headers.Add("Authorization", "Basic $encodedCreds")

		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop
		} catch {
			Write-Error $PSItem
			return $null
		}
	} else {
		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop -WebSession $WebSession
		} catch {
			Write-Error $PSItem
			return $null
		}
	}

	$PageChanges = @()
	$MemberNodes = ([xml]$httpResponse.Content | Select-Xml -XPath "//struct").Node
	foreach ($node in $MemberNodes) {
		$ChangeObject = New-Object PSObject -Property @{
			FullName = (($node.member)[0]).value.innertext
			LastModified = Get-Date -Date ((($node.member)[1]).value.innertext)
			Author = (($node.member)[2]).value.innertext
			VersionTimestamp = (($node.member)[3]).value.innertext
		}
		$PageChanges = $PageChanges + $ChangeObject
	}
	return $PageChanges
}

function Get-DokuRecentMediaChanges {
<#
	.SYNOPSIS
		Returns a list of recently changed media since given timestamp

	.DESCRIPTION
		Returns a list of recently changed media since given timestamp

	.PARAMETER Uri
		The URI of the wiki XMLRPC api endpoint

	.PARAMETER Username
		The user that will be sending the payload

	.PARAMETER SecPassword
		The password for user that will be sending the payload

	.PARAMETER WebSession
		The Web.Session object containing the login tokens

	.PARAMETER VersionTimestamp
		Get all media / attachment changes since this timestamp

	.EXAMPLE
		PS C:\> $RecentMediaChanges = Get-DokuRecentMediaChanges -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -Username "adlp" -SecPassword $SecureStringPassword -VersionTimestamp 1497464418

	.EXAMPLE
		PS C:\> $RecentMediaChanges = Get-DokuRecentMediaChanges -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -WebSession $LoginCookies -VersionTimestamp 1497464418

	.OUTPUTS
		System.Array

	.NOTES
		AndyDLP - 2018-05-26
#>

	[CmdletBinding(DefaultParameterSetName = 'Basic')]
	[OutputType([array])]
	param
	(
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[ValidateNotNullOrEmpty()]
		[string]$Uri,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 3,
				   HelpMessage = 'The user that will be sending the request')]
		[ValidateNotNullOrEmpty()]
		[string]$Username,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 4,
				   HelpMessage = 'The password for the user that will be sending the request')]
		[ValidateNotNullOrEmpty()]
		[securestring]$SecPassword,
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $false,
				   Position = 3,
				   HelpMessage = 'The Web.Session object containing the login tokens')]
		[Microsoft.PowerShell.Commands.WebRequestSession]$WebSession,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'Get all media / attachment changes since this timestamp')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'Get all media / attachment changes since this timestamp')]
		[ValidateNotNullOrEmpty()]
		[int]$VersionTimestamp
	)

	# build the payload for a xmlrpc web request
	# No params for getTime
	$payload = "<?xml version='1.0'?><methodCall><methodName>wiki.getRecentMediaChanges</methodName><params><param><value><i4>$VersionTimestamp</i4></value></param></params></methodCall>"
	$headers = @{ "Content-Type" = "text/xml"; }

	if ($PSCmdlet.ParameterSetName -eq "Basic") {
		# Add credentials to HTTP Basic auth header
		$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecPassword)
		$password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

		$pair = "$($username):$($password)"
		$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
		$headers.Add("Authorization", "Basic $encodedCreds")

		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop
		} catch {
			Write-Error $PSItem
			return $null
		}
	} else {
		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop -WebSession $WebSession
		} catch {
			Write-Error $PSItem
			return $null
		}
	}

	$MediaChanges = @()
	$MemberNodes = ([xml]$httpResponse.Content | Select-Xml -XPath "//struct").Node
	foreach ($node in $MemberNodes) {
		$ChangeObject = New-Object PSObject -Property @{
			FullName = (($node.member)[0]).value.innertext
			LastModified = Get-Date -Date ((($node.member)[1]).value.innertext)
			Author = (($node.member)[2]).value.innertext
			VersionTimestamp = (($node.member)[3]).value.innertext
			Permissions = (($node.member)[4]).value.innertext
			Size = (($node.member)[5]).value.innertext
		}
		$MediaChanges = $MediaChanges + $ChangeObject
	}
	return $MediaChanges
}

function Get-DokuAttachmentList {
<#
	.SYNOPSIS
		Returns a list of media files in a given namespace

	.DESCRIPTION
		Returns a list of media files in a given namespace

	.PARAMETER Uri
		The URI of the wiki XMLRPC api endpoint

	.PARAMETER Username
		The user that will be sending the payload

	.PARAMETER SecPassword
		The password for user that will be sending the payload

	.PARAMETER WebSession
		The Web.Session object containing the login tokens

	.PARAMETER Namespace
		The namespace to search for attachments

	.PARAMETER Options
		Options are passed directly to the php search_media() function

	.EXAMPLE
		PS C:\> $RecentMediaChanges = Get-DokuRecentMediaChanges -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -Username "adlp" -SecPassword $SecureStringPassword -VersionTimestamp 1497464418

	.EXAMPLE
		PS C:\> $RecentMediaChanges = Get-DokuRecentMediaChanges -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -WebSession $LoginCookies -VersionTimestamp 1497464418

	.OUTPUTS
		System.Array

	.NOTES
		AndyDLP - 2018-05-26
#>

	[CmdletBinding(DefaultParameterSetName = 'Basic')]
	[OutputType([array])]
	param
	(
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[ValidateNotNullOrEmpty()]
		[string]$Uri,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 4,
				   HelpMessage = 'The user that will be sending the request')]
		[ValidateNotNullOrEmpty()]
		[string]$Username,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 5,
				   HelpMessage = 'The password for the user that will be sending the request')]
		[ValidateNotNullOrEmpty()]
		[securestring]$SecPassword,
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $false,
				   Position = 4,
				   HelpMessage = 'The Web.Session object containing the login tokens')]
		[Microsoft.PowerShell.Commands.WebRequestSession]$WebSession,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'The namespace to search for attachments')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'The namespace to search for attachments')]
		[ValidateNotNullOrEmpty()]
		[string]$Namespace,
		[Parameter(ParameterSetName = 'Basic',
				   Position = 3,
				   HelpMessage = 'Options are passed directly to the php search_media() function')]
		[Parameter(ParameterSetName = 'Session',
				   Position = 3,
				   HelpMessage = 'Options are passed directly to the php search_media() function')]
		[array]$Options = @()
	)

	# build the payload for a xmlrpc web request
	# No params for getTime
	$payload = "<?xml version='1.0'?><methodCall><methodName>wiki.getAttachments</methodName><params><param><value><string>$Namespace</string></value></param><param><value><struct>$Options</struct></value></param></params></methodCall>"
	$headers = @{ "Content-Type" = "text/xml"; }

	if ($PSCmdlet.ParameterSetName -eq "Basic") {
		# Add credentials to HTTP Basic auth header
		$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecPassword)
		$password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

		$pair = "$($username):$($password)"
		$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
		$headers.Add("Authorization", "Basic $encodedCreds")

		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop
		} catch {
			Write-Error $PSItem
			return $null
		}
	} else {
		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop -WebSession $WebSession
		} catch {
			Write-Error $PSItem
			return $null
		}
	}

	$MediaChanges = @()
	$MemberNodes = ([xml]$httpResponse.Content | Select-Xml -XPath "//struct").Node
	foreach ($node in $MemberNodes) {
		$ChangeObject = New-Object PSObject -Property @{
			FullName = ((($node.member)[0]).value.innertext)
			Name = (($node.member)[1]).value.innertext
			Size = (($node.member)[2]).value.innertext
			VersionTimestamp = (($node.member)[3]).value.innertext
			IsWritable = (($node.member)[4]).value.innertext
			IsImage = (($node.member)[5]).value.innertext
			Acl = (($node.member)[6]).value.innertext
			LastModified = (($node.member)[7]).value.innertext
			ParentNamespace = (((($node.member)[0]).value.innertext) -split ":")[-2]
			RootNamespace = (((($node.member)[0]).value.innertext) -split ":")[0]
		}
		$MediaChanges = $MediaChanges + $ChangeObject
	}
	return $MediaChanges
}

function Save-DokuAttachment {
<#
	.SYNOPSIS
		Returns the binary data of a media file

	.DESCRIPTION
		Returns the binary data of a media file

	.PARAMETER Uri
		The URI of the wiki XMLRPC api endpoint

	.PARAMETER Username
		The user that will be requesting the data

	.PARAMETER SecPassword
		The password for user that will be requesting the data

	.PARAMETER WebSession
		The Web.Session object containing the login tokens

	.PARAMETER FullName
		The full name of the file to get

	.PARAMETER OutputPath
		The folder path to save the attachment to

	.PARAMETER Force
		Force creation of output file, overwriting any existing files with the same name

	.EXAMPLE
		PS C:\> New-DokuAttachment -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -Username "user" -SecPassword $SecureStringPassword -Fullname "namespace:namespace:filename.jpg" -OutputPath "C:\DokuAttachmentsFolder"

	.EXAMPLE
		PS C:\> New-DokuAttachment -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -WebSession $LoginCookies -Fullname "study:70-412:vss-writingsteps.jpg"

	.OUTPUTS
		System.IO.FileInfo

	.NOTES
		AndyDLP - 2018-05-26
#>

	[CmdletBinding(DefaultParameterSetName = 'Basic')]
	[OutputType([System.IO.FileInfo])]
	param
	(
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[ValidateNotNullOrEmpty()]
		[string]$Uri,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 4,
				   HelpMessage = 'The user that will be requesting the server time')]
		[ValidateNotNullOrEmpty()]
		[string]$Username,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 5,
				   HelpMessage = 'The password for the user that will be requesting the data')]
		[ValidateNotNullOrEmpty()]
		[securestring]$SecPassword,
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $false,
				   Position = 4,
				   HelpMessage = 'The Web.Session object containing the login tokens')]
		[Microsoft.PowerShell.Commands.WebRequestSession]$WebSession,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'The full name of the file to get')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'The full name of the file to get')]
		[ValidateNotNullOrEmpty()]
		[string]$FullName,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 3,
				   HelpMessage = 'The folder path to save the attachment to')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 3,
				   HelpMessage = 'The folder path to save the attachment to')]
		[ValidateScript({ Test-Path -Path $_ -PathType Container })]
		[string]$OutputPath,
		[Parameter(ParameterSetName = 'Basic',
				   HelpMessage = 'Force creation of output file, overwriting any existing files')]
		[Parameter(ParameterSetName = 'Session',
				   HelpMessage = 'Force creation of output file, overwriting any existing files')]
		[switch]$Force
	)

	# build the payload for a xmlrpc web request
	# No params for getTime
	$payload = "<?xml version='1.0'?><methodCall><methodName>wiki.getAttachment</methodName><params><param><value><string>$FullName</string></value></param></params></methodCall>"
	$headers = @{ "Content-Type" = "text/xml"; }

	if ($PSCmdlet.ParameterSetName -eq "Basic") {
		# Add credentials to HTTP Basic auth header
		$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecPassword)
		$password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

		$pair = "$($username):$($password)"
		$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
		$headers.Add("Authorization", "Basic $encodedCreds")

		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop
		} catch {
			Write-Error $PSItem
			return $null
		}
	} else {
		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop -WebSession $WebSession
		} catch {
			Write-Error $PSItem
			return $null
		}
	}

	$FileName = ($FullName -split ":")[-1]
	Write-Verbose $FileName
	$FilePath = Join-Path -Path $OutputPath -ChildPath $FileName
	Write-Verbose $FilePath
	if ((Test-Path -Path $FilePath) -and (!$Force)) {
		throw "File with that name already exists at: $FilePath"
	} else {
		Remove-Item -Path $FilePath -Force -ErrorAction SilentlyContinue
		$RawFileData = [string]([xml]$httpResponse.Content | Select-Xml -XPath "//value/base64").node.InnerText
		$RawBytes = [Convert]::FromBase64String($RawFileData)
		[IO.File]::WriteAllBytes($FilePath, $RawBytes) | Out-Null
		$ItemObject = (Get-Item -Path $FilePath)
		return $ItemObject
	}
}

function Get-DokuAttachmentInfo {
<#
	.SYNOPSIS
		Returns information about a media file

	.DESCRIPTION
		Returns information about a media file

	.PARAMETER Uri
		The URI of the wiki XMLRPC api endpoint

	.PARAMETER Username
		The user that will be requesting the data

	.PARAMETER SecPassword
		The password for user that will be requesting the data

	.PARAMETER WebSession
		The Web.Session object containing the login tokens

	.PARAMETER FullName
		The full name of the file to get information from

	.EXAMPLE
		PS C:\> Get-AttachmentInfo -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -Username "user" -SecPassword $SecureStringPassword -Fullname "namespace:namespace:filename.jpg"

	.EXAMPLE
		PS C:\> Get-AttachmentInfo -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -WebSession $LoginCookies -Fullname "study:70-412:vss-writingsteps.jpg"

	.OUTPUTS
		System.Management.Automation.PSObject

	.NOTES
		AndyDLP - 2018-05-26
#>

	[CmdletBinding(DefaultParameterSetName = 'Basic')]
	[OutputType([psobject])]
	param
	(
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[ValidateNotNullOrEmpty()]
		[string]$Uri,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 4,
				   HelpMessage = 'The user that will be requesting the server time')]
		[ValidateNotNullOrEmpty()]
		[string]$Username,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 5,
				   HelpMessage = 'The password for the user that will be requesting the data')]
		[ValidateNotNullOrEmpty()]
		[securestring]$SecPassword,
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $false,
				   Position = 4,
				   HelpMessage = 'The Web.Session object containing the login tokens')]
		[Microsoft.PowerShell.Commands.WebRequestSession]$WebSession,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'The full name of the file to get information from')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'The full name of the file to get information from')]
		[ValidateNotNullOrEmpty()]
		[string]$FullName
	)

	# build the payload for a xmlrpc web request
	# No params for getTime
	$payload = "<?xml version='1.0'?><methodCall><methodName>wiki.getAttachmentInfo</methodName><params><param><value><string>$FullName</string></value></param></params></methodCall>"
	$headers = @{ "Content-Type" = "text/xml"; }

	if ($PSCmdlet.ParameterSetName -eq "Basic") {
		# Add credentials to HTTP Basic auth header
		$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecPassword)
		$password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

		$pair = "$($username):$($password)"
		$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
		$headers.Add("Authorization", "Basic $encodedCreds")

		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop
		} catch {
			Write-Error $PSItem
			return $null
		}
	} else {
		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop -WebSession $WebSession
		} catch {
			Write-Error $PSItem
			return $null
		}
	}

	$ArrayValues = ([xml]$httpResponse.Content | Select-Xml -XPath "//struct").Node.Member.Value.Innertext
	$attachmentObject = New-Object PSObject -Property @{
		FullName = $FullName
		Size = $ArrayValues[1]
		LastModified = Get-Date -Date ($ArrayValues[0])
		FileName = ($FullName -split ":")[-1]
		ParentNamespace = ($FullName -split ":")[-2]
		RootNamespace = ($FullName -split ":")[0]
	}
	return $attachmentObject
}

function New-DokuAttachment {
<#
	.SYNOPSIS
		Uploads a file as an attachment

	.DESCRIPTION
		Uploads a file as an attachment

	.PARAMETER Uri
		The URI of the wiki XMLRPC api endpoint

	.PARAMETER Username
		The user that will be requesting the data

	.PARAMETER SecPassword
		The password for user that will be requesting the data

	.PARAMETER WebSession
		The Web.Session object containing the login tokens

	.PARAMETER FullName
		The FullName of the to-be-uploaded file, including namespace(s)

	.PARAMETER FilePath
		The file path of the attachment to upload

	.PARAMETER Force
		Force upload of attachment, overwriting any existing files with the same name

	.EXAMPLE
		PS C:\> New-DokuAttachment -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -Username "user" -SecPassword $SecureStringPassword -Fullname "namespace:namespace:filename.jpg" -FilePath "C:\FolderName\filename.jpg"

	.EXAMPLE
		PS C:\> New-DokuAttachment -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -WebSession $webSession -Fullname "study:70-412:vss-writingsteps.jpg" -FilePath "C:\DokuAttachmentsFolder\vss-writingsteps.jpg"

	.OUTPUTS
		System.Management.Automation.PSObject

	.NOTES
		AndyDLP - 2018-05-26
#>

	[CmdletBinding(DefaultParameterSetName = 'Basic')]
	[OutputType([psobject])]
	param
	(
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[ValidateNotNullOrEmpty()]
		[string]$Uri,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 4,
				   HelpMessage = 'The user that will be requesting the server time')]
		[ValidateNotNullOrEmpty()]
		[string]$Username,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 5,
				   HelpMessage = 'The password for the user that will be requesting the data')]
		[ValidateNotNullOrEmpty()]
		[securestring]$SecPassword,
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $false,
				   Position = 4,
				   HelpMessage = 'The Web.Session object containing the login tokens')]
		[Microsoft.PowerShell.Commands.WebRequestSession]$WebSession,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'The FullName of the to-be-uploaded file, including namespace(s)')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'The FullName of the to-be-uploaded file, including namespace(s)')]
		[ValidateNotNullOrEmpty()]
		[string]$FullName,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 3,
				   HelpMessage = 'The file path of the attachment to upload')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 3,
				   HelpMessage = 'The file path of the attachment to upload')]
		[ValidateScript({ Test-Path -Path $_ -PathType Leaf})]
		[string]$FilePath,
		[Parameter(ParameterSetName = 'Basic',
				   HelpMessage = 'Force upload of attachment, overwriting any existing files with the same name')]
		[Parameter(ParameterSetName = 'Session',
				   HelpMessage = 'Force upload of attachment, overwriting any existing files with the same name')]
		[switch]$Force
	)

	$Forced = if ($Force) { 1 } else { 0 }
	$FileBytes = [IO.File]::ReadAllBytes($FilePath)
	$FileData = [Convert]::ToBase64String($FileBytes)

	$payload = "<?xml version='1.0'?><methodCall><methodName>wiki.putAttachment</methodName><params><param><value><string>$FullName</string></value></param><param><value><base64>$FileData</base64></value></param><param><value><struct><member><name>ow</name><value><boolean>$Forced</boolean></value></member></struct></value></param></params></methodCall>"
	$headers = @{ "Content-Type" = "text/xml"; }

	if ($PSCmdlet.ParameterSetName -eq "Basic") {
		# Add credentials to HTTP Basic auth header
		$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecPassword)
		$password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

		$pair = "$($username):$($password)"
		$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
		$headers.Add("Authorization", "Basic $encodedCreds")

		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop
		} catch {
			Write-Error $PSItem
			return $null
		}
	} else {
		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop -WebSession $WebSession
		} catch {
			Write-Error $PSItem
			return $null
		}
	}

	$FileItem = (Get-Item -Path $FilePath)
	$ResultString = [string]([xml]$httpResponse.Content | Select-Xml -XPath "//value/string").node.InnerText
	if ($ResultString -ne $FullName) {
		throw "Error: $ResultString - Fullname: $FullName"
	}

	$attachmentObject = New-Object PSObject -Property @{
		FullName = $FullName
		SourceFilePath = $FilePath
		Size = $FileItem.Length
		SourceFileLastModified = $FileItem.LastWriteTimeUtc
		FileName = ($FullName -split ":")[-1]
		ParentNamespace = ($FullName -split ":")[-2]
		RootNamespace = ($FullName -split ":")[0]
	}
	return $attachmentObject
}

function Remove-DokuAttachment {
<#
	.SYNOPSIS
		Returns information about a media file

	.DESCRIPTION
		Deletes an attachment

	.PARAMETER Uri
		The URI of the wiki XMLRPC api endpoint

	.PARAMETER Username
		The user that will be performing the action

	.PARAMETER SecPassword
		The password for user that will be performing the action

	.PARAMETER WebSession
		The Web.Session object containing the login tokens

	.PARAMETER FullName
		The full name of the attachment to delete

	.EXAMPLE
		PS C:\> Remove-DokuAttachment -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -Username "user" -SecPassword $SecureStringPassword -Fullname "namespace:namespace:filename.jpg"

	.EXAMPLE
		PS C:\> Remove-DokuAttachment -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -WebSession $LoginCookies -Fullname "study:70-412:vss-writingsteps.jpg"

	.OUTPUTS
		None

	.NOTES
		AndyDLP - 2018-05-26
#>

	[CmdletBinding(DefaultParameterSetName = 'Basic')]
	param
	(
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[ValidateNotNullOrEmpty()]
		[string]$Uri,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 4,
				   HelpMessage = 'The user that will be requesting the server time')]
		[ValidateNotNullOrEmpty()]
		[string]$Username,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 5,
				   HelpMessage = 'The password for the user that will be requesting the data')]
		[ValidateNotNullOrEmpty()]
		[securestring]$SecPassword,
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $false,
				   Position = 4,
				   HelpMessage = 'The Web.Session object containing the login tokens')]
		[Microsoft.PowerShell.Commands.WebRequestSession]$WebSession,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'The full name of the attachment to delete')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'The full name of the attachment to delete')]
		[ValidateNotNullOrEmpty()]
		[string]$FullName
	)

	# build the payload for a xmlrpc web request
	$payload = "<?xml version='1.0'?><methodCall><methodName>wiki.deleteAttachment</methodName><params><param><value><string>$FullName</string></value></param></params></methodCall>"
	$headers = @{ "Content-Type" = "text/xml"; }

	if ($PSCmdlet.ParameterSetName -eq "Basic") {
		# Add credentials to HTTP Basic auth header
		$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecPassword)
		$password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

		$pair = "$($username):$($password)"
		$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
		$headers.Add("Authorization", "Basic $encodedCreds")

		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop
		} catch {
			Write-Error $PSItem
			return $null
		}
	} else {
		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop -WebSession $WebSession
		} catch {
			Write-Error $PSItem
			return $null
		}
	}

	$FailReason = ([xml]$httpResponse.Content | Select-Xml -XPath "//value/string").Node.InnerText
	if ($FailReason) {
		# error code generated = Fail
		throw "Error: $FailReason - FullName $FullName"
	} else {
		# Do nothing = Delete successful
	}
}

# XMLRPC method "dokuwiki.deleteUsers" not on test server - Cant use Remove-DokuUser yet
function Remove-DokuUser {
<#
	.SYNOPSIS
		Allows you to delete a user

	.DESCRIPTION
		Allows you to delete a user. Useful to implement GDPR right to be forgotten tools

	.PARAMETER Uri
		The URI of the wiki XMLRPC api endpoint

	.PARAMETER Username
		The user that will be performing the action

	.PARAMETER SecPassword
		The password for user that will be performing the action

	.PARAMETER WebSession
		The Web.Session object containing the login tokens

	.PARAMETER Identity
		The username you want to remove

	.EXAMPLE
		PS C:\> Remove-DokuUser -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -Username "user" -SecPassword $SecureStringPassword -Identity testuser

	.EXAMPLE
		PS C:\> Remove-DokuUser -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -WebSession $LoginCookies -Identity testuser,testuser2

	.OUTPUTS
		System.Boolean

	.NOTES
		AndyDLP - 2018-05-26
#>

	[CmdletBinding(DefaultParameterSetName = 'Basic')]
	[OutputType([boolean])]
	param
	(
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[ValidateNotNullOrEmpty()]
		[string]$Uri,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 4,
				   HelpMessage = 'The user that will be requesting the server time')]
		[ValidateNotNullOrEmpty()]
		[string]$Username,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 5,
				   HelpMessage = 'The password for the user that will be requesting the data')]
		[ValidateNotNullOrEmpty()]
		[securestring]$SecPassword,
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $false,
				   Position = 4,
				   HelpMessage = 'The Web.Session object containing the login tokens')]
		[Microsoft.PowerShell.Commands.WebRequestSession]$WebSession,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'The username you want to remove')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'The username you want to remove')]
		[ValidateNotNullOrEmpty()]
		[string]$Identity
	)

	# build the payload for a xmlrpc web request
	$payload = "<?xml version='1.0'?><methodCall><methodName>dokuwiki.deleteUsers</methodName><params><param><value><string>$Identity</string></value></param></params></methodCall>"
	$headers = @{ "Content-Type" = "text/xml"; }

	if ($PSCmdlet.ParameterSetName -eq "Basic") {
		# Add credentials to HTTP Basic auth header
		$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecPassword)
		$password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

		$pair = "$($username):$($password)"
		$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
		$headers.Add("Authorization", "Basic $encodedCreds")

		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop
		} catch {
			Write-Error $PSItem
			return $null
		}
	} else {
		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop -WebSession $WebSession
		} catch {
			Write-Error $PSItem
			return $null
		}
	}

	$FailReason = ([xml]$httpResponse.Content | Select-Xml -XPath "//value/boolean").Node.InnerText
	if ($FailReason -eq 0) {
		# error code generated = Fail
		throw "Error: $FailReason - Identity: $Identity"
	} else {
		# Do nothing = Delete successful
	}
	#return $httpResponse
}

function Add-DokuAclRule {
<#
	.SYNOPSIS
		Allows you to delete a user

	.DESCRIPTION
		Allows you to delete a user. Useful to implement GDPR right to be forgotten tools. Use @groupname instead of user to add an ACL rule for a group.

	.PARAMETER Uri
		The URI of the wiki XMLRPC api endpoint

	.PARAMETER Username
		The user that will be performing the action

	.PARAMETER SecPassword
		The password for user that will be performing the action

	.PARAMETER WebSession
		The Web.Session object containing the login tokens

	.PARAMETER FullName
		The full name of the scope to apply to ACL to

	.PARAMETER Principal
		The username or groupname to add to the ACL

	.PARAMETER Acl
		The permission level to apply to the ACL as an integer

	.EXAMPLE
		PS C:\> Add-DokuAclRule -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -Username "user" -SecPassword $SecureStringPassword -FullName "study" -Principal testuser -Acl 0

	.EXAMPLE
		PS C:\> Add-DokuAclRule -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -WebSession $LoginCookies -FullName "study" -Principal testuser -Acl 0

	.OUTPUTS
		System.Boolean

	.NOTES
		AndyDLP - 2018-05-26
#>

	[CmdletBinding(DefaultParameterSetName = 'Basic')]
	[OutputType([boolean])]
	param
	(
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[ValidateNotNullOrEmpty()]
		[string]$Uri,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 2,
				   HelpMessage = 'The user that will be requesting the server time')]
		[ValidateNotNullOrEmpty()]
		[string]$Username,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 3,
				   HelpMessage = 'The password for the user that will be requesting the data')]
		[ValidateNotNullOrEmpty()]
		[securestring]$SecPassword,
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $false,
				   Position = 2,
				   HelpMessage = 'The Web.Session object containing the login tokens')]
		[Microsoft.PowerShell.Commands.WebRequestSession]$WebSession,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   HelpMessage = 'The full name of the scope to apply to ACL to')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   HelpMessage = 'The full name of the scope to apply to ACL to')]
		[ValidateNotNullOrEmpty()]
		[string]$FullName,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   HelpMessage = 'The username or @groupname to add to the ACL')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   HelpMessage = 'The username or @groupname to add to the ACL')]
		[ValidateNotNullOrEmpty()]
		[string]$Principal,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   HelpMessage = 'The permission level to apply to the ACL as an integer')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   HelpMessage = 'The permission level to apply to the ACL as an integer')]
		[ValidateNotNullOrEmpty()]
		[int]$Acl
	)

	# build the payload for a xmlrpc web request
	$payload = "<?xml version='1.0'?><methodCall><methodName>plugin.acl.addAcl</methodName><params><param><value><string>$FullName</string></value></param><param><value><string>$Principal</string></value></param><param><value><i4>$Acl</i4></value></param></params></methodCall>"
	$headers = @{ "Content-Type" = "text/xml"; }

	if ($PSCmdlet.ParameterSetName -eq "Basic") {
		# Add credentials to HTTP Basic auth header
		$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecPassword)
		$password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

		$pair = "$($username):$($password)"
		$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
		$headers.Add("Authorization", "Basic $encodedCreds")

		$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop
	} else {
		# send web request
		$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop -WebSession $WebSession
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

function Remove-DokuAclRule {
<#
	.SYNOPSIS
		Allows you to delete a user

	.DESCRIPTION
		Allows you to delete a user. Useful to implement GDPR right to be forgotten tools. Use @groupname instead of user to add an ACL rule for a group.

	.PARAMETER Uri
		The URI of the wiki XMLRPC api endpoint

	.PARAMETER Username
		The user that will be performing the action

	.PARAMETER SecPassword
		The password for user that will be performing the action

	.PARAMETER WebSession
		The Web.Session object containing the login tokens

	.PARAMETER FullName
		The full name of the scope to apply to ACL to

	.PARAMETER Principal
		The username or groupname to add to the ACL

	.EXAMPLE
		PS C:\> Remove-DokuAclRule -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -Username "user" -SecPassword $SecureStringPassword -FullName "study" -Principal testuser

	.EXAMPLE
		PS C:\> Remove-DokuAclRule -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -WebSession $LoginCookies -FullName "study" -Principal testuser

	.OUTPUTS
		System.Boolean

	.NOTES
		AndyDLP - 2018-05-26
#>

	[CmdletBinding(DefaultParameterSetName = 'Basic')]
	[OutputType([boolean])]
	param
	(
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[ValidateNotNullOrEmpty()]
		[string]$Uri,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 2,
				   HelpMessage = 'The user that will be performing the action')]
		[ValidateNotNullOrEmpty()]
		[string]$Username,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 3,
				   HelpMessage = 'The password for the user that will be requesting the data')]
		[ValidateNotNullOrEmpty()]
		[securestring]$SecPassword,
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $false,
				   Position = 2,
				   HelpMessage = 'The Web.Session object containing the login tokens')]
		[Microsoft.PowerShell.Commands.WebRequestSession]$WebSession,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   HelpMessage = 'The full name of the scope to apply to ACL to')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   HelpMessage = 'The full name of the scope to apply to ACL to')]
		[ValidateNotNullOrEmpty()]
		[string]$FullName,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   HelpMessage = 'The username or @groupname to add to the ACL')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   HelpMessage = 'The username or @groupname to add to the ACL')]
		[ValidateNotNullOrEmpty()]
		[string]$Principal
	)

	# build the payload for a xmlrpc web request
	$payload = "<?xml version='1.0'?><methodCall><methodName>plugin.acl.delAcl</methodName><params><param><value><string>$FullName</string></value></param><param><value><string>$Principal</string></value></param></params></methodCall>"
	$headers = @{ "Content-Type" = "text/xml"; }

	if ($PSCmdlet.ParameterSetName -eq "Basic") {
		# Add credentials to HTTP Basic auth header
		$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecPassword)
		$password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

		$pair = "$($username):$($password)"
		$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
		$headers.Add("Authorization", "Basic $encodedCreds")

		$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop
	} else {
		# send web request
		$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop -WebSession $WebSession
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

function Add-DokuPageData {
<#
	.SYNOPSIS
		Appends wiki text to the end of a page.

	.DESCRIPTION
		Appends wiki text to the end of a page. Can create new page or namespace by referencing a (currnely non-existant) page / namespace

	.PARAMETER Uri
		The URI of the wiki XMLRPC api endpoint

	.PARAMETER Username
		The user that will be requesting the data

	.PARAMETER SecPassword
		The password for user that will be requesting the data

	.PARAMETER WebSession
		The Web.Session object containing the login tokens

	.PARAMETER FullName
		The FullName of the to be edited page

	.PARAMETER RawWikiText
		The raw wiki text to append to the page

	.PARAMETER MinorChange
		State if the change was minor or not

	.PARAMETER SummaryText
		A short summary of the change, visible in the revisions list

	.EXAMPLE
		PS C:\> Add-DokuPageData -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -Username "user" -SecPassword $SecureStringPassword -Fullname "namespace:namespace:home"

	.EXAMPLE
		PS C:\> Add-DokuPageData -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -WebSession $webSession -Fullname "study:70-412:home"

	.OUTPUTS
		System.Boolean

	.NOTES
		AndyDLP - 2018-05-26
#>

	[CmdletBinding(DefaultParameterSetName = 'Basic')]
	[OutputType([boolean])]
	param
	(
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[ValidateNotNullOrEmpty()]
		[string]$Uri,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 4,
				   HelpMessage = 'The user that will be requesting the server time')]
		[ValidateNotNullOrEmpty()]
		[string]$Username,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 5,
				   HelpMessage = 'The password for the user that will be requesting the data')]
		[ValidateNotNullOrEmpty()]
		[securestring]$SecPassword,
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $false,
				   Position = 4,
				   HelpMessage = 'The Web.Session object containing the login tokens')]
		[Microsoft.PowerShell.Commands.WebRequestSession]$WebSession,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'The FullName of the to-be-uploaded file, including namespace(s)')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'The FullName of the to-be-uploaded file, including namespace(s)')]
		[ValidateNotNullOrEmpty()]
		[string]$FullName,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 3,
				   HelpMessage = 'The raw wiki text to append to the page')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 3,
				   HelpMessage = 'The raw wiki text to append to the page')]
		[ValidateNotNullOrEmpty()]
		[string]$RawWikiText,
		[Parameter(ParameterSetName = 'Basic',
				   HelpMessage = 'State if the change was minor or not')]
		[Parameter(ParameterSetName = 'Session',
				   HelpMessage = 'State if the change was minor or not')]
		[switch]$MinorChange,
		[Parameter(ParameterSetName = 'Basic',
				   HelpMessage = 'A short summary of the change')]
		[Parameter(ParameterSetName = 'Session',
				   HelpMessage = 'A short summary of the change')]
		[string]$SummaryText
	)

	# Change it to 1 / 0 for xmlrpc compat
	$MinorChanged = if ($MinorChange -eq $true) { 1 } else { 0 }
	$payload = "<?xml version='1.0'?><methodCall><methodName>dokuwiki.appendPage</methodName><params><param><value><string>$FullName</string></value></param><param><value><string>$RawWikiText</string></value></param><param><value><struct><member><name>sum</name><value><string>$SummaryText</string></value></member><member><name>minor</name><value><boolean>$MinorChanged</boolean></value></member></struct></value></param></params></methodCall>"
	$headers = @{ "Content-Type" = "text/xml"; }

	if ($PSCmdlet.ParameterSetName -eq "Basic") {
		# Add credentials to HTTP Basic auth header
		$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecPassword)
		$password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

		$pair = "$($username):$($password)"
		$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
		$headers.Add("Authorization", "Basic $encodedCreds")

		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop
		} catch {
			Write-Error $PSItem
			return $null
		}
	} else {
		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop -WebSession $WebSession
		} catch {
			Write-Error $PSItem
			return $null
		}
	}
	$ResultString = [boolean]([xml]$httpResponse.Content | Select-Xml -XPath "//value/boolean").node.InnerText

	return $ResultString
}

function Set-DokuPageData {
<#
	.SYNOPSIS
		Sets the raw wiki text of a page, will overwrite any existing page

	.DESCRIPTION
		Sets the raw wiki text of a page, will overwrite any existing page

	.PARAMETER Uri
		The URI of the wiki XMLRPC api endpoint

	.PARAMETER Username
		The user that will be requesting the data

	.PARAMETER SecPassword
		The password for user that will be requesting the data

	.PARAMETER WebSession
		The Web.Session object containing the login tokens

	.PARAMETER FullName
		The fullname of the target page

	.PARAMETER RawWikiText
		The raw wiki text to apply to the target page

	.PARAMETER MinorChange
		State if the change was minor or not

	.PARAMETER SummaryText
		A short summary of the change, visible in the revisions list

	.EXAMPLE
		PS C:\> Set-DokuPageData -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -Username "user" -SecPassword $SecureStringPassword -Fullname "namespace:namespace:home" -RawWikiText "HELLO TEST TEST TEST" -MinorChange -SummaryText "lololol"

	.EXAMPLE
		PS C:\> Set-DokuPageData -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -WebSession $webSession -Fullname "study:70-412:home" -RawWikiText "HELLO TEST TEST TEST" -MinorChange -SummaryText "lololol"

	.OUTPUTS
		System.Boolean

	.NOTES
		AndyDLP - 2018-05-26
#>

	[CmdletBinding(DefaultParameterSetName = 'Basic')]
	[OutputType([boolean])]
	param
	(
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
		[ValidateNotNullOrEmpty()]
		[string]$Uri,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 4,
				   HelpMessage = 'The user that will be requesting the server time')]
		[ValidateNotNullOrEmpty()]
		[string]$Username,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $false,
				   Position = 5,
				   HelpMessage = 'The password for the user that will be requesting the data')]
		[ValidateNotNullOrEmpty()]
		[securestring]$SecPassword,
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $false,
				   Position = 4,
				   HelpMessage = 'The Web.Session object containing the login tokens')]
		[Microsoft.PowerShell.Commands.WebRequestSession]$WebSession,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'The fullname of the target page')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'The fullname of the target page')]
		[ValidateNotNullOrEmpty()]
		[string]$FullName,
		[Parameter(ParameterSetName = 'Basic',
				   Mandatory = $true,
				   Position = 3,
				   HelpMessage = 'The raw wiki text that will be set')]
		[Parameter(ParameterSetName = 'Session',
				   Mandatory = $true,
				   Position = 3,
				   HelpMessage = 'The raw wiki text that will be set')]
		[ValidateNotNullOrEmpty()]
		[string]$RawWikiText,
		[Parameter(ParameterSetName = 'Basic',
				   HelpMessage = 'State if the change was minor or not')]
		[Parameter(ParameterSetName = 'Session',
				   HelpMessage = 'State if the change was minor or not')]
		[switch]$MinorChange,
		[Parameter(ParameterSetName = 'Basic',
				   HelpMessage = 'A short summary of the change')]
		[Parameter(ParameterSetName = 'Session',
				   HelpMessage = 'A short summary of the change')]
		[string]$SummaryText
	)

	# Change it to 1 / 0 for xmlrpc compat
	$MinorChanged = if ($MinorChange -eq $true) { 1 } else { 0 }
	$payload = "<?xml version='1.0'?><methodCall><methodName>wiki.putPage</methodName><params><param><value><string>$FullName</string></value></param><param><value><string>$RawWikiText</string></value></param><param><value><struct><member><name>sum</name><value><string>$SummaryText</string></value></member><member><name>minor</name><value><boolean>$MinorChanged</boolean></value></member></struct></value></param></params></methodCall>"
	$headers = @{ "Content-Type" = "text/xml"; }

	if ($PSCmdlet.ParameterSetName -eq "Basic") {
		# Add credentials to HTTP Basic auth header
		$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecPassword)
		$password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

		$pair = "$($username):$($password)"
		$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
		$headers.Add("Authorization", "Basic $encodedCreds")

		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop
		} catch {
			Write-Error $PSItem
			return $null
		}
	} else {
		try {
			# send web request
			$httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop -WebSession $WebSession
		} catch {
			Write-Error $PSItem
			return $null
		}
	}
	$ResultString = [boolean]([xml]$httpResponse.Content | Select-Xml -XPath "//value/boolean").node.InnerText

	return $ResultString
}

<# TODO:
	dokuwiki.setLocks
#>

Export-ModuleMember -Function @("Set-DokuPageData", "Add-DokuPageData", "Remove-DokuAclRule","Add-DokuAclRule","Remove-DokuAttachment","Get-DokuAttachmentInfo", "Save-DokuAttachment","New-DokuAttachment","Get-DokuRecentMediaChanges", "Get-DokuAttachmentList", "Get-DokuPageList", "Get-DokuLoginCookies", "Get-DokuTime", "New-DokuLoginSession", "Get-DokuVersion", "Get-DokuAPIVersion", "Get-DokuTitle", "Search-DokuWiki", "Get-DokuPageData", "Get-DokuPageAcl", "Get-DokuPageVersions", "Get-DokuPageVersionData", "Get-DokuPageInfo", "Get-DokuPageVersionInfo", "Get-DokuPageHtml", "Get-DokuPageVersionHtml", "Get-DokuPageLinks", "Get-DokuAllPages", "Get-DokuPageBackLinks", "Get-DokuRecentChanges")
