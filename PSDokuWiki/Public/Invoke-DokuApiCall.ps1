function Invoke-DokuApiCall {
<#
    .SYNOPSIS
        Invokes the 

    .DESCRIPTION
        Gets an array of all pages from an instance of DokuWiki.

    .PARAMETER DokuSession
        The DokuSession (generated by New-DokuSession) from which to get the page list.

    .PARAMETER MethodName
        The method name to invoke

    .PARAMETER MethodParameters
       The parameters for the specified method

    .EXAMPLE
        PS C:\> $httpResponse = Invoke-DokuApiCall -DokuSession $DokuSession -MethodName wiki.getAllPages

    .OUTPUTS
        Microsoft.PowerShell.Commands.HtmlWebResponseObject

    .NOTES
        AndyDLP - 2019-01-24
#>

    [CmdletBinding()]
    [OutputType([Microsoft.PowerShell.Commands.HtmlWebResponseObject])]
    param
    (
        [Parameter(Mandatory = $true,
                    Position = 1,
                    ValueFromPipeline = $true,
                    ValueFromPipelineByPropertyName = $true,
                    HelpMessage = 'The DokuSession from which to get the page list')]
        [ValidateScript({ ($null -ne $_.WebSession) -or ($_.Headers.Keys -contains "Authorization") })]
        [PSObject]$DokuSession,

        [Parameter(Mandatory = $true,
                    Position = 2,
                    ValueFromPipeline = $true,
                    ValueFromPipelineByPropertyName = $true,
                    HelpMessage = 'The method name to invoke')]
        [ValidateNotNullOrEmpty()]
        [string]$MethodName,

        [Parameter(Mandatory = $false,
                    Position = 3,
                    ValueFromPipeline = $true,
                    ValueFromPipelineByPropertyName = $true,
                    HelpMessage = 'The parameters for the specified method')]
        [array]$MethodParameters
    )

    begin {
        Write-Debug "$($MyInvocation.MyCommand.Name):: Function started"
    } # begin

    process {
        $payload = ConvertTo-XmlRpcMethodCall -Name $MethodName -Params $MethodParameters
        Write-Debug "XMLRPC payload: $payload"

        $params = @{
            Uri = $DokuSession.TargetUri
            Method = 'Post'
            Headers = $DokuSession.Headers
            Body = $payload
            ErrorAction = 'Stop'
        }
        if ($DokuSession.SessionMethod -eq "Cookie") {
            $params.Add('WebSession',$DokuSession.WebSession)
        }

        $outputObjectParams = @{
            TargetUri = $DokuSession.TargetUri
            Method = $MethodName
            MethodParameters = $MethodParameters
            XMLPayloadSent = $payload
            SessionMethod = $DokuSession.SessionMethod
        }

        try {
            $httpResponse = Invoke-WebRequest @params
            $outputObjectParams.Add('RawHttpResponse',$httpResponse)
            $XMLContent = [xml]($httpResponse.Content)
            $outputObjectParams.Add('XMLPayloadResponse',$XMLContent)
            if ($null -ne ($XMLContent | Select-Xml -XPath "//fault").node) {
                # Web request worked but failed on API side
                $outputObjectParams.Add('CompletedSuccessfully',$false)
                $outputObjectParams.Add('FaultCode',($XMLContent | Select-Xml -XPath "//struct").node.member[0].value.int)
                $outputObjectParams.Add('FaultString',($XMLContent | Select-Xml -XPath "//struct").node.member[1].value.string)
            } else {
                $outputObjectParams.Add('CompletedSuccessfully',$true)
            }
        }
        catch {
            $outputObjectParams.Add('CompletedSuccessfully',$false)
            $outputObjectParams.Add('FaultCode',(($PSItem.Exception.message) -split ' ')[1])
            $outputObjectParams.Add('FaultString',(($PSItem.Exception.message) -split 'faultString ')[1])
            $outputObjectParams.Add('ExceptionMessage',$PSItem.Exception.message)
        }
        $outputObject = [PSCustomObject]$outputObjectParams
        return $outputObject
    } # process

    end {
        Write-Debug "$($MyInvocation.MyCommand.Name):: Function ended"
    } # end
}