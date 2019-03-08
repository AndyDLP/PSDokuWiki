function Lock-DokuPage {
    <#
	.SYNOPSIS
		Locks a DokuWiki page for 15 min

	.DESCRIPTION
		Locks the page so it cannot be modified by users for 15 min. Also works for not yet existing pages (block create name)

	.PARAMETER FullName
		The full name of the to-be-locked page, including parent namespace(s)

	.EXAMPLE
		PS C:\> Lock-DokuPage -FullName 'namespace:page'

	.OUTPUTS
		Nothing

	.NOTES
		AndyDLP - 2019-01-27

	.LINK
		https://github.com/AndyDLP/PSDokuWiki
#>

    [CmdletBinding(PositionalBinding = $true, SupportsShouldProcess=$True, ConfirmImpact='Medium')]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName=$true,
                   Position = 1,
                   HelpMessage = 'The full name of the to-be-locked page, including parent namespace(s)')]
        [ValidateNotNullOrEmpty()]
        [string[]]$FullName
    )

    begin {}

    process {
        foreach ($page in $FullName) {
            if ($PSCmdlet.ShouldProcess("Lock page: $page")) {
                # long random name in unlock array as its unlikely to be existing (do unlock in other function)
                # xmltype converter doesn't like it to be empty?
                $APIResponse = Invoke-DokuApiCall -MethodName 'dokuwiki.setLocks' -MethodParameters @(@{ 'lock' = [array]$page; 'unlock' = @("341272da-9295-4362-939f-070baf351995341272da-9295-4362-939f-070baf351995341272da-9295-4362-939f-070baf351995") })
                if ($APIResponse.CompletedSuccessfully -eq $true) {
                    # do nothing except when locks fail
                    # $locked = ($APIResponse.XMLPayloadResponse | Select-Xml -XPath "//array").Node[0].data.value.innertext
                    $lockfail = ($APIResponse.XMLPayloadResponse | Select-Xml -XPath "//array").Node[1].data.value.innertext
                    # $unlocked = ($APIResponse.XMLPayloadResponse | Select-Xml -XPath "//array").Node[2].data.value.innertext
                    # $unlockfail = ($APIResponse.XMLPayloadResponse | Select-Xml -XPath "//array").Node[3].data.value.innertext
                    if ($null -ne $lockfail) {
                        $lockfail | ForEach-Object -Process { Write-Error "Failed to lock page: $PSItem" }
                    }
                } elseif ($null -eq $APIResponse.ExceptionMessage) {
                    Write-Error "Fault code: $($APIResponse.FaultCode) - Fault string: $($APIResponse.FaultString)"
                } else {
                    Write-Error "Exception: $($APIResponse.ExceptionMessage)"
                }
            }
        } # foreach
    } # process

    end {}
}
