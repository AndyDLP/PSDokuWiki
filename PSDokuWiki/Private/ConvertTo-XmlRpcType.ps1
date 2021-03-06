function ConvertTo-XmlRpcType {
    <#
        .SYNOPSIS
            Convert Data into XML declared datatype string

        .DESCRIPTION
            Convert Data into XML declared datatype string

        .OUTPUTS
            string

        .PARAMETER InputObject
            Object to be converted to XML string

        .PARAMETER CustomTypes
            Array of custom Object Types to be considered when converting

        .EXAMPLE
            ConvertTo-XmlRpcType "Hello World"
            --------
            Returns
            <value><string>Hello World</string></value>

        .EXAMPLE
            ConvertTo-XmlRpcType 42
            --------
            Returns
            <value><int32>42</int32></value>

        .Notes
            Author   : Oliver Lipkau <oliver@lipkau.net>
            2014-06-05 Initial release

            Sourced from Oliver Lipkau's XmlRpc module on powershellgallery
            Modified to use DokuWiki compatible type names (case sensitive etc)
    #>
    [CmdletBinding()]
    [OutputType([String])]
    param(
        [AllowNull()]
        [Parameter(
            Position=1,
            Mandatory=$true
        )]
        $InputObject,

        [Parameter()]
        [Array]$CustomTypes
    )

    Begin
    {
        $Objects = @('Object','PSCustomObject')
        $objects += $CustomTypes
    }

    Process
    {
        if ($null -ne $inputObject) {
            [string]$Type=$inputObject.GetType().Name
            # [string]$BaseType=$inputObject.GetType().BaseType
        } else {
            return ""
        }

        # DokuWiki doesn't like capital letters
        $Type = $Type.ToLower()

        # Return simple Types
        if (('double','false') -contains $Type)
        {
            return "<value><$($Type)>$($inputObject)</$($Type)></value>"
        }

        if ($Type -eq 'boolean')
        {
            return "<value><$($Type)>$([int]$inputObject)</$($Type)></value>"
        }

        if ($Type -eq 'byte[]')
        {
	        $FileData = [Convert]::ToBase64String($InputObject)
            return "<value><base64>$FileData</base64></value>"
        }

        if ($Type -eq 'string')
        {
            return "<value><$Type>$([System.Web.HttpUtility]::HtmlEncode($inputObject))</$Type></value>"
        }

        # Int16 must be casted as Int
        if ($Type -eq 'int16')
        {
            return "<value><int>$inputObject</int></value>"
        }

        # Int32 must be casted as i4
        if ($Type -eq 'int32')
        {
            return "<value><i4>$inputObject</i4></value>"
        }

        if ($Type -eq "SwitchParameter")
        {
            return "<value><boolean>$([int]$inputObject.IsPresent)</boolean></value>"
        }

        # Return In64 as Double
        if (('Int64') -contains $Type)
        {
            return "<value><double>$inputObject</double></value>"
        }

        # DateTime
        if('dateTime' -eq $Type)
        {
            return "<value><dateTime.iso8601>$($inputObject.ToString(
            'yyyyMMddTHH:mm:ss'))</dateTime.iso8601></value>"
        }

        # Loop though Array
        if(($inputObject -is [Array]) -or ($Type -eq "List``1"))
        {
            try
            {
                return "<value><array><data>$(
                    [string]::Join(
                        '',
                        ($inputObject | ForEach-Object  {
                            if ($null -ne $_) {
                                ConvertTo-XmlRpcType $_ -CustomTypes $CustomTypes
                            } else {}
                        } )
                    )
                )</data></array></value>"
            }
            catch
            {
                throw
            }
        }

        # Loop though HashTable Keys
        if('hashtable' -eq $Type)
        {
            return "<value><struct>$(
                [string]::Join(
                    '',
                    ($inputObject.Keys|  Foreach-Object {
                        "<member><name>$($_)</name>$(
                            if ($null -ne $inputObject[$_]) {
                                ConvertTo-XmlRpcType $inputObject[$_] -CustomTypes $CustomTypes
                            } else {
                                ConvertTo-XmlRpcType $null
                            })</member>"
                    } )
                )
            )</struct></value>"
        }

        # Loop though Object Properties
        if(($Objects -contains $Type) -and ($inputObject))
        {
            return "<value><struct>$(
                [string]::Join(
                    '',
                    (
                        ($inputObject | Get-Member -MemberType Properties).Name | Foreach-Object {
                            if ($null -ne $inputObject.$_) {
                                "<member><name>$($_)</name>$(
                                    ConvertTo-XmlRpcType $inputObject.$_ -CustomTypes $CustomTypes
                                )</member>"
                            }
                        }
                    )
                )
            )</struct></value>"
        }

        # XML
        if ('xmlelement','xmldocument' -contains $Type)
        {
            # data types listed as System.String rather than string....
            return $inputObject.InnerXml.ToString()
        }

        # XML
        if ($inputObject -match "<([^<>]+)>([^<>]+)</\\1>" -or $inputObject)
        {
            return $inputObject
        }
    } # process

    End {

    } # end
}
