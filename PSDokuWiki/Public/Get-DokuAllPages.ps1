function Get-DokuAllPages {
    <#
	.SYNOPSIS
		Returns a list of all Wiki pages in the remote DokuSession

	.DESCRIPTION
		Returns a list of all Wiki pages in the remote DokuSession

	.PARAMETER DokuSession
		The DokuSession from which to get the pages

	.EXAMPLE
		PS C:\> $AllPages = Get-DokuAllPages -DokuSession $DokuSession

	.OUTPUTS
		System.Management.Automation.PSObject[]

	.NOTES
		AndyDLP - 2018-05-26

	.LINK
		https://github.com/AndyDLP/PSDokuWiki
#>

    [CmdletBinding()]
    [OutputType([psobject[]])]
    param
    (
        [Parameter(Mandatory = $true,
            Position = 1,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'The DokuSession from which to get the pages')]
        [ValidateNotNullOrEmpty()]
        [psobject]$DokuSession
    )

    begin {

	} #begin

    process {
        $APIResponse = Invoke-DokuApiCall -DokuSession $DokuSession -MethodName 'wiki.getAllPages'
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
