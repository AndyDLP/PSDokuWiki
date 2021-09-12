function Connect-DokuServer {
    [CmdletBinding(PositionalBinding = $true, SupportsShouldProcess = $True, ConfirmImpact = 'Low')]
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
        [switch]$Force,
        [Parameter(Mandatory = $false,
            Position = 6,
            HelpMessage = 'Use Basic parsing instead of IE DOM parsing')]
        [ValidateNotNullOrEmpty()]
        [switch]$UseBasicParsing
    )

    begin {}

    process {
        if ($PSCmdlet.ShouldProcess("Connect to server: $Computername")) {
            $headers = @{ 'Content-Type' = 'text/xml'; }
            $Protocol = if ($Unencrypted) { 'http' } else { 'https' }
            $TargetUri = ($Protocol + '://' + $ComputerName + $APIPath)
            # Check if already connected
            if (($null -ne $Script:DokuServer) -and (-not $Force)) {
                throw "Open connection already exists to: $($Script:DokuServer.TargetUri) - Use the -Force parameter to connect anyway"
            }
            $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Credential.Password)
            $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
            $XMLPayload = ConvertTo-XmlRpcMethodCall -Name 'dokuwiki.login' -Params @($Credential.username, $password)
            # $Websession var defined here
            try {
                $InvokeParams = @{
                    Uri             = $TargetUri
                    Method          = 'POST'
                    Headers         = $headers
                    Body            = $XMLPayload
                    SessionVariable = 'WebSession'
                    ErrorAction     = 'Stop'
                }
                if ($PSBoundParameters.ContainsKey('UseBasicParsing')) {
                    $InvokeParams.Add('UseDefaultCredentials', $true)
                }
                if ($PSBoundParameters.ContainsKey('Unencrypted')) {
                    $InvokeParams.Add('AllowUnencryptedAuthentication', $true)
                }
                $httpResponse = Invoke-WebRequest @InvokeParams
                $XMLContent = [xml]($httpResponse.Content)
            } catch [System.Management.Automation.PSInvalidCastException] {
                Write-Verbose "Connected to API endpoint: $($Script:DokuServer.TargetUri) but did not receive valid response"
                $PSCmdlet.ThrowTerminatingError(
                    [System.Management.Automation.ErrorRecord]::new(
                        ("XML payload sent to: $TargetUri but received an invalid response"),
                        'DokuWiki.Session.InvalidResponse',
                        [System.Management.Automation.ErrorCategory]::InvalidResult,
                        $TargetUri
                    )
                )
            } catch [System.Net.WebException] {
                $PSCmdlet.ThrowTerminatingError(
                    [System.Management.Automation.ErrorRecord]::new(
                        ("Failed to send POST request to $TargetUri"),
                        'DokuWiki.Session.InvalidRequest',
                        [System.Management.Automation.ErrorCategory]::InvalidOperation,
                        $TargetUri
                    )
                )
            } catch {
                Write-Error 'Unspecified error caught in Connect-DokuServer'
                throw $_
                exit
            }

            if ($null -ne ($XMLContent | Select-Xml -XPath '//fault').node) {
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
            } elseif ($null -eq ($XMLContent | Select-Xml -XPath '//methodResponse').node) {
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
            } elseif (!([bool]([int]($XMLContent | Select-Xml -XPath '//boolean').node.InnerText))) {
                Write-Verbose "Connected to API endpoint: $($Script:DokuServer.TargetUri), but failed login"
                $PSCmdlet.ThrowTerminatingError(
                    [System.Management.Automation.ErrorRecord]::new(
                        ("XML payload sent to: $TargetUri but failed login"),
                        'DokuWiki.Session.PermissionDenied',
                        [System.Management.Automation.ErrorCategory]::PermissionDenied,
                        $TargetUri
                    )
                )
            } else {
                # success
                Write-Verbose "Successfully connected to API server: $ComputerName"
                $DokuSession = [PSCustomObject]@{
                    Server              = $ComputerName
                    TargetUri           = $TargetUri
                    XMLContent          = $XMLContent
                    Headers             = $headers
                    WebSession          = $WebSession
                    TimeStamp           = (Get-Date)
                    UnencryptedEndpoint = [boolean]$Unencrypted
                    UseBasicParsing     = $UseBasicParsing
                }
                $DokuSession.PSTypeNames.Insert(0, 'DokuWiki.Session.Detail')
                # Module scoped variables are defined like the below apparently
                $Script:DokuServer = $DokuSession
            }
        }
    } # process

    end {}
}
