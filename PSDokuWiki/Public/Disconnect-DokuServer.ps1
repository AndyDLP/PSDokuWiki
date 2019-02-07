function Disconnect-DokuServer {
    <#
	.SYNOPSIS
		Disconnect a DokuWiki API endpoint

	.DESCRIPTION
		Disconnect a DokuWiki API endpoint

	.PARAMETER ComputerName
		The server to disconnect can be an IP, FQDN or single label name. e.g. 192.168.0.1 / wiki.example.com / wiki

	.EXAMPLE
		PS C:\> Disconnect-DokuServer -Server wiki.example.com

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
        [string]$ComputerName
    )

    begin {
        
    } # begin

    process {
        # Module scoped variables are defined like the below apparently
        $Script:DokuServer

    } # process

    end {

    } # end
}
