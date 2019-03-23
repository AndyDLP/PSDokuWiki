function Get-DokuAllPage {
    [CmdletBinding()]
    [OutputType([psobject[]])]
    param()

    begin {

	} #begin

    process {
        $APIResponse = Invoke-DokuApiCall -MethodName 'wiki.getAllPages'
        if ($APIResponse.CompletedSuccessfully -eq $true) {
            $MemberNodes = ($APIResponse.XMLPayloadResponse | Select-Xml -XPath "//struct").Node
            foreach ($node in $MemberNodes) {
                $PageObject = New-Object PSObject -Property @{
                    FullName     = (($node.member)[0]).value.InnerText
                    Acl          = (($node.member)[1]).value.InnerText
                    Size         = (($node.member)[2]).value.InnerText
                    LastModified = Get-Date -Date ((($node.member)[3]).value.InnerText)
                    LastModifiedRaw = (($node.member)[3]).value.InnerText
                    PageName        = (((($node.member)[0]).value.InnerText) -split ":")[-1]
                    ParentNamespace = (((($node.member)[0]).value.InnerText) -split ":")[-2]
                    RootNamespace   = (((($node.member)[0]).value.InnerText) -split ":")[0]
                }
                $PageObject
            }
        } elseif ($null -eq $APIResponse.ExceptionMessage) {
            Write-Error "Fault code: $($APIResponse.FaultCode) - Fault string: $($APIResponse.FaultString)"
        } else {
            Write-Error "Exception: $($APIResponse.ExceptionMessage)"
        }
    } # process

    end {

    } # end
}
