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
            HelpMessage = 'Connect to an unencrypted endpoint')]
        [ValidateNotNullOrEmpty()]
        [switch]$Unencrypted,
        
        [Parameter(Mandatory = $false,
            Position = 4,
            HelpMessage = 'The path to the api endpoint')]
        [ValidateNotNullOrEmpty()]
        [string]$APIPath = '/lib/exe/xmlrpc.php',
        
        [Parameter(Mandatory = $false,
            Position = 5,
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

        $XMLPayload = ConvertTo-XmlRpcMethodCall -Name "dokuwiki.login" -Params @($Credential.username, $password)
        # $Websession var defined here
        try {
            $httpResponse = Invoke-WebRequest -Uri $TargetUri -Method Post -Headers $headers -Body $XMLPayload -SessionVariable WebSession -ErrorAction Stop
            $XMLContent = [xml]($httpResponse.Content)
        }
        catch [System.Management.Automation.PSInvalidCastException] {
            Write-Verbose "Connected to API endpoint: $($Script:DokuServer.TargetUri) but did not receive valid response"
            $PSCmdlet.ThrowTerminatingError(
                [System.Management.Automation.ErrorRecord]::new(
                    ("XML payload sent to: $TargetUri but received an invalid response"),
                    'DokuWiki.Session.InvalidResponse',
                    [System.Management.Automation.ErrorCategory]::InvalidResult,
                    $TargetUri
                )
            )
        }
        catch [System.Net.WebException] {
            $PSCmdlet.ThrowTerminatingError(
                [System.Management.Automation.ErrorRecord]::new(
                    ("Failed to send POST request to $TargetUri"),
                    'DokuWiki.Session.InvalidRequest',
                    [System.Management.Automation.ErrorCategory]::InvalidOperation,
                    $TargetUri
                )
            )
        }
        catch {
            Write-Error "Unspecified error caught in Connect-DokuServer"
            throw $_
            exit
        }

        if ($null -ne ($XMLContent | Select-Xml -XPath "//fault").node) {
            # connected but API failed
            Write-Error "Connected to API endpoint: $ComputerName, but failed login. FaultCode: $(($XMLContent | Select-Xml -XPath '//struct').node.member[0].value.int) - FaultString: $(($XMLContent | Select-Xml -XPath '//struct').node.member[1].value.string)"
            $PSCmdlet.ThrowTerminatingError(
                [System.Management.Automation.ErrorRecord]::new(
                    ("FaultCode: $(($XMLContent | Select-Xml -XPath '//struct').node.member[0].value.int) - FaultString: $(($XMLContent | Select-Xml -XPath '//struct').node.member[1].value.string)"),
                    'DokuWiki.Session.FailedLogin',
                    [System.Management.Automation.ErrorCategory]::AuthenticationError,
                    $TargetUri
                )
            )
        } elseif ($null -eq ($XMLContent | Select-Xml -XPath "//methodResponse").node) {
            # not connected / invalid response
            Write-Verbose "Connected to API endpoint: $($Script:DokuServer.TargetUri) but did not receive valid response"
            $PSCmdlet.ThrowTerminatingError(
                [System.Management.Automation.ErrorRecord]::new(
                    ("XML payload sent to: $TargetUri but received an invalid response"),
                    'DokuWiki.Session.InvalidResponse',
                    [System.Management.Automation.ErrorCategory]::InvalidResult,
                    $TargetUri
                )
            )
        } else {
            # success
            Write-Verbose "Successfully connected to API server: $ComputerName"
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
        }
    } # process

    end {
        # intentionally empty
    }
}
