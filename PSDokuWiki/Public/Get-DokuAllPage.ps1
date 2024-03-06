function Get-DokuAllPage {
    [CmdletBinding(SupportsShouldProcess=$True, ConfirmImpact='Low')]
    [OutputType([psobject[]])]
    param()

    begin {	} #begin

    process {
        if ($PSCmdlet.ShouldProcess("Get all pages from current server: $($Script:DokuServer.TargetUri)")) {
            $APIResponse = Invoke-DokuApiCall -MethodName 'wiki.getAllPages'
            if ($APIResponse.CompletedSuccessfully -eq $true) {
                $MemberNodes = ($APIResponse.XMLPayloadResponse | Select-Xml -XPath "//struct").Node
                foreach ($node in $MemberNodes) {
					$LastModified = (($node.member)[3]).value.innertext
					$ConvertedDate = $LastModified.substring(0,4) + '-' + $LastModified.substring(4,2) + '-' + -join $LastModified[6..50]
                    $PageObject = [PSCustomObject]@{
                        FullName     = (($node.member)[0]).value.InnerText
                        Acl          = (($node.member)[1]).value.InnerText
                        Size         = (($node.member)[2]).value.InnerText
                        # LastModified = Get-Date -Date ((($node.member)[3]).value.InnerText)
                        LastModified = Get-Date -Date ($ConvertedDate)
                        LastModifiedRaw = (($node.member)[3]).value.InnerText
                        PageName        = (((($node.member)[0]).value.InnerText) -split ":")[-1]
                        ParentNamespace = (((($node.member)[0]).value.InnerText) -split ":")[-2]
                        RootNamespace   = (((($node.member)[0]).value.InnerText) -split ":")[0]
                    }
                    $PageObject.PSObject.TypeNames.Insert(0, "DokuWiki.Page")
                    $PageObject
                }
            } elseif ($null -eq $APIResponse.ExceptionMessage) {
                Write-Error "Fault code: $($APIResponse.FaultCode) - Fault string: $($APIResponse.FaultString)"
            } else {
                Write-Error "Exception: $($APIResponse.ExceptionMessage)"
            }
        } # shouldprocess
    } # process

    end { } # end
}
