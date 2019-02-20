function Get-DokuAllPages {
    <#
	.SYNOPSIS
		Returns a list of all Wiki pages

	.DESCRIPTION
		Returns a list of all Wiki pages from the DokuWiki API. Includes the current user's ACL status of each page

	.EXAMPLE
		PS C:\> $AllPages = Get-DokuAllPages

	.OUTPUTS
		System.Management.Automation.PSObject[]

	.NOTES
        AndyDLP - 2018-05-26
        Updated - 2019-02-20

	.LINK
		https://github.com/AndyDLP/PSDokuWiki
#>

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
                }
                [array]$AllPages = $AllPages + $PageObject
            }
            $AllPages
        } elseif ($null -eq $APIResponse.ExceptionMessage) {
            Write-Error "Fault code: $($APIResponse.FaultCode) - Fault string: $($APIResponse.FaultString)"
        } else {
            Write-Error "Exception: $($APIResponse.ExceptionMessage)"
        }
    } # process

    end {

    } # end
}
