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
            WebSession = $Script:DokuServer.WebSession
            UseBasicParsing = $Script:DokuServer.UseBasicParsing
        }
        $outputObjectParams = @{
            TargetUri = $Script:DokuServer.TargetUri
            Method = $MethodName
            MethodParameters = $MethodParameters
            XMLPayloadSent = $payload
        }

        try {
            Write-Verbose "Attempting to connect to API endpoint: $($Script:DokuServer.TargetUri)"
            $httpResponse = Invoke-WebRequest @params
            $outputObjectParams.Add('RawHttpResponse',$httpResponse)

            #$XMLContent = ConvertTo-Xml -InputObject ($httpResponse.Content) -ErrorAction Stop
            $XMLContent = [xml]($httpResponse.Content)


            $outputObjectParams.Add('XMLPayloadResponse',$XMLContent)
            if ($null -ne ($XMLContent | Select-Xml -XPath "//fault").node) {
                # Web request worked but failed on API side
                Write-Verbose "Connected to API endpoint: $($Script:DokuServer.TargetUri), but failed to execute API method $MethodName"
                $outputObjectParams.Add('CompletedSuccessfully',$false)
                $outputObjectParams.Add('FaultCode',[int]($XMLContent | Select-Xml -XPath "//struct").node.member[0].value.innertext)
                $outputObjectParams.Add('FaultString',[string]($XMLContent | Select-Xml -XPath "//struct").node.member[1].value.innertext)
            } elseif ($null -eq ($XMLContent | Select-Xml -XPath "//methodResponse").node) {
                Write-Verbose "Connected to API endpoint: $($Script:DokuServer.TargetUri) but did not receive valid response"
                $outputObjectParams.Add('CompletedSuccessfully',$false)
            } else {
                Write-Verbose "Connected to API endpoint: $($Script:DokuServer.TargetUri) and successfully executed API method $MethodName"
                $outputObjectParams.Add('CompletedSuccessfully',$true)
                Write-Verbose $XMLContent.InnerXml
            }
        }
        catch [System.Management.Automation.PSInvalidCastException] {
            Write-Verbose "API responded with data in an invalid format (not XML)"
            $outputObjectParams.Add('CompletedSuccessfully',$false)
            $outputObjectParams.Add('ExceptionMessage',$PSItem.Exception.message)
        }
        catch [System.Management.Automation.ValidationMetadataException] {
            Write-Verbose "Error: Invalid parameters possibly NULL DokuServer"
            $outputObjectParams.Add('CompletedSuccessfully',$false)
            $outputObjectParams.Add('ExceptionMessage',$PSItem.Exception.message)
        }
        catch {
            Write-Verbose "Failed to connect to API endpoint: $($Script:DokuServer.TargetUri)"
            $outputObjectParams.Add('CompletedSuccessfully',$false)
            $outputObjectParams.Add('ExceptionMessage',$PSItem.Exception.message)
        }
        $outputObject = [PSCustomObject]$outputObjectParams
        return $outputObject
    } # process

    end {
        Write-Verbose "$($MyInvocation.MyCommand.Name):: Function ended"
    } # end
}
