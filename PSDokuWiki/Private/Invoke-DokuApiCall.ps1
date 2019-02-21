function Invoke-DokuApiCall {
<#
    .SYNOPSIS
        Invokes a DokuWiki API method

    .DESCRIPTION
        Invokes a DokuWiki API method using the currently connected (By Connect-DokuServer) API endpoint.

    .PARAMETER MethodName
        The method name to invoke

    .PARAMETER MethodParameters
       The parameters for the specified method

    .EXAMPLE
        PS C:\> $Response = Invoke-DokuApiCall -MethodName wiki.getAllPages

    .EXAMPLE
        PS C:\> $Response = Invoke-DokuApiCall -MethodName wiki.getPagaData -MethodParameters @('namespace:pagename')

    .OUTPUTS
        PSObject

    .NOTES
        AndyDLP - 2019
#>

    [CmdletBinding()]
    [OutputType([PSObject])]
    param
    (
        [Parameter(Mandatory = $true,
                    Position = 1,
                    ValueFromPipeline = $true,
                    ValueFromPipelineByPropertyName = $true,
                    HelpMessage = 'The method name to invoke')]
        [ValidateNotNullOrEmpty()]
        [string]$MethodName,

        [Parameter(Mandatory = $false,
                    Position = 2,
                    ValueFromPipeline = $true,
                    ValueFromPipelineByPropertyName = $true,
                    HelpMessage = 'The parameters for the specified method')]
        [array]$MethodParameters
    )

    begin {
        Write-Verbose "$($MyInvocation.MyCommand.Name):: Function started"
    } # begin

    process {
        $payload = ConvertTo-XmlRpcMethodCall -Name $MethodName -Params $MethodParameters
        Write-Verbose "XMLRPC payload: $payload"

        $params = @{
            Uri = $Script:DokuServer.TargetUri
            Method = 'Post'
            Headers = $Script:DokuServer.Headers
            Body = $payload
            ErrorAction = 'Stop'
        }
        if ($Script:DokuServer.SessionMethod -eq "Cookie") {
            $params.Add('WebSession',$Script:DokuServer.WebSession)
        }

        $outputObjectParams = @{
            TargetUri = $Script:DokuServer.TargetUri
            Method = $MethodName
            MethodParameters = $MethodParameters
            XMLPayloadSent = $payload
            SessionMethod = $Script:DokuServer.SessionMethod
        }

        try {
            Write-Verbose "Attempting to connect to API endpoint: $TargetUri"
            $httpResponse = Invoke-WebRequest @params
            $outputObjectParams.Add('RawHttpResponse',$httpResponse)
            $XMLContent = [xml]($httpResponse.Content)
            $outputObjectParams.Add('XMLPayloadResponse',$XMLContent)
            if ($null -ne ($XMLContent | Select-Xml -XPath "//fault").node) {
                # Web request worked but failed on API side
                Write-Verbose "Connected to API endpoint: $TargetUri, but failed to execute API method $MethodName"
                $outputObjectParams.Add('CompletedSuccessfully',$false)
                $outputObjectParams.Add('FaultCode',($XMLContent | Select-Xml -XPath "//struct").node.member[0].value.int)
                $outputObjectParams.Add('FaultString',($XMLContent | Select-Xml -XPath "//struct").node.member[1].value.string)
            } else {
                Write-Verbose "Connected to API endpoint: $TargetUri and successfully executed API method $MethodName"
                $outputObjectParams.Add('CompletedSuccessfully',$true)
            }
        }
        catch {
            Write-Verbose "Failed to connect to API endpoint: $TargetUri"
            $outputObjectParams.Add('CompletedSuccessfully',$false)
            $outputObjectParams.Add('FaultCode',(($PSItem.Exception.message) -split ' ')[1])
            $outputObjectParams.Add('FaultString',(($PSItem.Exception.message) -split 'faultString ')[1])
            $outputObjectParams.Add('ExceptionMessage',$PSItem.Exception.message)
        }
        $outputObject = [PSCustomObject]$outputObjectParams
        return $outputObject
    } # process

    end {
        Write-Verbose "$($MyInvocation.MyCommand.Name):: Function ended"
    } # end
}