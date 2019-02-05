function Connect-DokuServer {
    <#
	.SYNOPSIS
		Connect to a DokuWiki API endpoint

	.DESCRIPTION
		Connect to a DokuWiki API endpoint to 

	.PARAMETER ComputerName
		The server to connect to, can be an IP, FQDN or single label name. e.g. 192.168.0.1 / wiki.example.com / wiki

	.EXAMPLE
		PS C:\> Connect-DokuServer -Server wiki.example.com -Credential (Get-Credential)

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
            ValueFromPipeline = $true,
			ValueFromPipelineByPropertyName=$true,
            HelpMessage = 'The server to connect to')]
        [ValidateNotNullOrEmpty()]
        [Alias('Server')]
        [string]$ComputerName,

        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
			ValueFromPipelineByPropertyName=$true,
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
            HelpMessage = 'Force connection, even to an unencrypted endpoint')]
        [ValidateNotNullOrEmpty()]
        [switch]$Unencrypted,
        
        [Parameter(Mandatory = $false,
            Position = 5,
            HelpMessage = 'The path to the api endpoint')]
        [ValidateNotNullOrEmpty()]
        [string]$APIPath = '/lib/exe/xmlrpc.php'
    )

    begin {
        $headers = @{ "Content-Type" = "text/xml"; }
        $Protocol = if ($Unencrypted) { "http" } else { "https" }
    } # begin

    process {
        $TargetUri = ($Protocol + "://" + $ComputerName + $APIPath)
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Credential.Password)
        $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

        if ($SessionMethod -eq "HttpBasic") {
            $pair = "$($Credential.username):$($password)"
            $encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
            $headers.Add("Authorization", "Basic $encodedCreds")
        } else {
            $XMLPayload = ConvertTo-XmlRpcMethodCall -Name "dokuwiki.login" -Params @($Credential.username, $password)
            # $Websession var defined here
            $NullVar = Invoke-WebRequest -Uri $TargetUri -Method Post -Headers $headers -Body $XMLPayload -SessionVariable WebSession -ErrorAction Stop
        }

        $DokuSession = New-Object PSObject -Property @{
            Server = $ComputerName
            TargetUri = $TargetUri
            SessionMethod = $SessionMethod
            Headers = $headers
            WebSession = $WebSession
            TimeStamp = (Get-Date)
            UnencryptedEndpoint = [boolean]$Unencrypted
        } -ErrorAction Stop

        
        # Module scoped variables are defined like the below apparently
        [array]$Script:DokuServer += $DokuSession
    } # process

    end {

    } # end
}
