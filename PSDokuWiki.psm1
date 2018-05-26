function Get-DokuPageList {
    <#
	.SYNOPSIS
		Gets an array of all pages from an instance of DokuWiki

	.DESCRIPTION
		Gets an array of all pages from an instance of DokuWiki

	.PARAMETER Uri
		The URI of the wiki XMLRPC api endpoint

	.PARAMETER Username
		The user that will be sending the payload

	.PARAMETER SecPassword
		The password for user that will be sending the payload

	.PARAMETER Cookies
		The array of cookies from the dokuwiki.Login function

	.EXAMPLE
		PS C:\> $AllPages = Get-DokuPageList -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -Username "adlp" -SecPassword $SecureStringPassword

    .EXAMPLE
		PS C:\> $AllPages = Get-DokuPageList -Uri "http://wiki.example.com/lib/exe/xmlrpc.php" -Cookies $LoginCookies

	.NOTES
		AndyDLP - 2018-05-26
	#>

    [CmdletBinding(DefaultParameterSetName = 'Basic')]
    [OutputType([array])]
    param
    (
        [Parameter(ParameterSetName = 'Basic',
            Mandatory = $true,
            HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
        [Parameter(ParameterSetName = 'Cookie',
            Mandatory = $true,
            HelpMessage = 'The URI of the wiki XMLRPC api endpoint')]
        [ValidateNotNullOrEmpty()]
        [string]$Uri,
        [Parameter(ParameterSetName = 'Basic',
            Mandatory = $false,
            HelpMessage = 'The user that will be requesting the pagelist')]
        [ValidateNotNullOrEmpty()]
        [string]$Username,
        [Parameter(ParameterSetName = 'Basic',
            Mandatory = $false,
            HelpMessage = 'The password for the user that will be requesting the pagelist')]
        [ValidateNotNullOrEmpty()]
        [securestring]$SecPassword,
        [Parameter(ParameterSetName = 'Cookie',
            Mandatory = $false,
            HelpMessage = 'An array of the two cookies from the dokuwiki.Login function')]
        [array]$Cookies
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
		# Use cookies provided
        $WebRequestSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
        foreach ($Cookie in $Cookies) { $WebRequestSession.Cookies.Add($Cookie) }

        try {
            # send web request
            $httpResponse = Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -ErrorAction Stop -WebSession $WebRequestSession
        } catch {
            Write-Error $PSItem
            return $null
        }
    }

    $AllDokuwikiPages = @()
    $MemberNodes = ([xml]$httpResponse.Content | Select-Xml -XPath "//struct").Node
    foreach ($node in $MemberNodes) {
        $PageObject = New-Object PSObject -Property @{
            FullName        = (($node.member)[0]).value.string
            Revision        = (($node.member)[1]).value.int
            ModifiedTime    = (($node.member)[2]).value.int
            Size            = (($node.member)[3]).value.int
            PageName        = (((($node.member)[0]).value.string) -split ":")[-1]
            ParentNamespace = (((($node.member)[0]).value.string) -split ":")[-2]
            RootNamespace   = (((($node.member)[0]).value.string) -split ":")[0]
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
    Invoke-WebRequest -Uri $Uri -Method Post -Headers $headers -Body $payload -SessionVariable WebSession | Out-Null
    $cookies = $WebSession.Cookies.GetCookies($Uri)

    # Create "login" object and return that instead?

    return $cookies
}

Export-ModuleMember -Function @("Get-DokuPageList", "Get-DokuLoginCookies")
