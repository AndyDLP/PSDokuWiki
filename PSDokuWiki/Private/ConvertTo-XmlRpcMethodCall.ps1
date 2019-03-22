function ConvertTo-XmlRpcMethodCall {
    <#
        .SYNOPSIS
            Create a XML RPC Method Call string

        .DESCRIPTION
            Create a XML RPC Method Call string

        .INPUTS
            string
            array

        .OUTPUTS
            string

        .PARAMETER Name
            Name of the Method to be called

        .PARAMETER Params
            Parameters to be passed to the Method

        .PARAMETER CustomTypes
            Array of custom Object Types to be considered when converting

        .EXAMPLE
            ConvertTo-XmlRpcMethodCall -Name updateName -Params @('oldName', 'newName')
            ----------
            Returns (line split and indentation just for conveniance)
            <?xml version=""1.0""?>
            <methodCall>
              <methodName>updateName</methodName>
              <params>
                <param><value><string>oldName</string></value></param>
                <param><value><string>newName</string></value></param>
              </params>
            </methodCall>

        .Notes
            Author   : Oliver Lipkau <oliver@lipkau.net>
            2014-06-05 Initial release

            Sourced from Oliver Lipkau's XmlRpc module on powershellgallery
            Modified to use DokuWiki compatible type names (case sensitive etc)
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [String]$Name,

        [Parameter()]
        [Array]$Params,

        [Parameter()]
        [Array]$CustomTypes
    )

    Begin {}

    Process {
        [String]((&{
            "<?xml version=""1.0""?><methodCall><methodName>$($Name)</methodName><params>"
            if($Params)
            {
                $Params | ForEach-Object { if ($null -ne $_) { "<param>$(&{ConvertTo-XmlRpcType $_ -CustomTypes $CustomTypes})</param>" } }
            } else {
                "$(ConvertTo-XmlRpcType $NULL)"
            }
            "</params></methodCall>"
        }) -join(''))
    }

    End {}
}