function Connect-DokuServer {
    <#
	.SYNOPSIS
		Connect to a DokuWiki API endpoint

	.DESCRIPTION
		Connect to a DokuWiki API endpoint to enable subsequent DokuWiki commands from the same PowerShell session

	.PARAMETER ComputerName
		The computer name (single label or FQDN) / IP to connect to

	.PARAMETER Credential
		The credentials used to authenticate to the API endpoint

	.PARAMETER SessionMethod
		The session method to use for the connection. Options are Cookie or HttpBasic

	.PARAMETER Unencrypted
		Specify that the APi endpoint is at a http rather than https address. Recommended for development only!!

	.PARAMETER ApiPath
		The web path that the api executable is at. DokuWiki default is /lib/exe/xmlrpc.php

    .PARAMETER Force
        Force a connection even if one is already established to the same endpoint

	.EXAMPLE
		PS C:\> Connect-DokuServer -ComputerName wiki.example.com -Credential (Get-Credential)

	.OUTPUTS
		Nothing

	.NOTES
		AndyDLP - 2019

	.LINK
		https://github.com/AndyDLP/PSDokuWiki
#>

    [CmdletBinding(PositionalBinding = $true)]
    param
    (
        [Parameter(Mandatory = $true,
            Position = 1,
            HelpMessage = 'The server to connect to')]
        [ValidateNotNullOrEmpty()]
        [Alias('Server')]
        [string]$ComputerName,

        [Parameter(Mandatory = $true,
            Position = 2,
            HelpMessage = 'The credentials to use to connect')]
        [ValidateNotNullOrEmpty()]
        [pscredential]$Credential,
        
        [Parameter(Mandatory = $false,
            Position = 3,
            HelpMessage = 'The session method to use')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Cookie','HttpBasic',IgnoreCase = $true)]
        [string]$SessionMethod = 'Cookie',
        
        [Parameter(Mandatory = $false,
            Position = 4,
            HelpMessage = 'Connect to an unencrypted endpoint')]
        [ValidateNotNullOrEmpty()]
        [switch]$Unencrypted,
        
        [Parameter(Mandatory = $false,
            Position = 5,
            HelpMessage = 'The path to the api endpoint')]
        [ValidateNotNullOrEmpty()]
        [string]$APIPath = '/lib/exe/xmlrpc.php',
        
        [Parameter(Mandatory = $false,
            Position = 6,
            HelpMessage = 'Force a re-connection')]
        [ValidateNotNullOrEmpty()]
        [switch]$Force
    )

    begin {
        # intentionally empty
    }

    process {
        $headers = @{ "Content-Type" = "text/xml"; }
        $Protocol = if ($Unencrypted) { "http" } else { "https" }

        $TargetUri = ($Protocol + "://" + $ComputerName + $APIPath)

        # Check if already connected
        if (($null -ne $Script:DokuServer) -and (-not $Force)) {
            throw "Open connection already exists to: $($Script:DokuServer.TargetUri) - Use the -Force parameter to connect anyway"
        }

        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Credential.Password)
        $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

        if ($SessionMethod -eq "HttpBasic") {
            $pair = "$($Credential.username):$($password)"
            $encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
            $headers.Add("Authorization", "Basic $encodedCreds")
        } else {
            $XMLPayload = ConvertTo-XmlRpcMethodCall -Name "dokuwiki.login" -Params @($Credential.username, $password)
            # $Websession var defined here
            try {
                $NullVar = Invoke-WebRequest -Uri $TargetUri -Method Post -Headers $headers -Body $XMLPayload -SessionVariable WebSession -ErrorAction Stop
                Write-Verbose $NullVar
            }
            catch {
                throw $_
                exit
            }
        }

        $DokuSession = New-Object PSObject -Property @{
            Server = $ComputerName
            TargetUri = $TargetUri
            SessionMethod = $SessionMethod
            Headers = $headers
            WebSession = $WebSession
            TimeStamp = (Get-Date)
            UnencryptedEndpoint = [boolean]$Unencrypted
        }
        $DokuSession.PSTypeNames.Insert(0,'DokuWiki.Session.Detail')
        
        # Module scoped variables are defined like the below apparently
        $Script:DokuServer = $DokuSession
    } # process

    end {
        # intentionally empty
    }
}
