function Unlock-DokuPage {
    [CmdletBinding(PositionalBinding = $true)]
    param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
			ValueFromPipelineByPropertyName=$true,
            Position = 1,
            HelpMessage = 'The full name of the to-be-unlocked page, including parent namespace(s)')]
        [ValidateNotNullOrEmpty()]
        [string[]]$FullName
    )

    begin {

    } # begin

    process {
        # long random name in unlock array as its unlikely to be existing (unlock in separate function to keep to logical PS standards)
        $APIResponse = Invoke-DokuApiCall -MethodName 'dokuwiki.setLocks' -MethodParameters @(@{ 'lock' = @("341272da-9295-4362-939f-070baf351995341272da-9295-4362-939f-070baf351995341272da-9295-4362-939f-070baf351995"); 'unlock' = [array]$FullName })
        if ($APIResponse.CompletedSuccessfully -eq $true) {
            # do nothing except when locks fail
            # $locked = ($APIResponse.XMLPayloadResponse | Select-Xml -XPath "//array").Node[0].data.value.innertext
            # $lockfail = ($APIResponse.XMLPayloadResponse | Select-Xml -XPath "//array").Node[1].data.value.innertext
            # $unlocked = ($APIResponse.XMLPayloadResponse | Select-Xml -XPath "//array").Node[2].data.value.innertext
            $unlockfail = ($APIResponse.XMLPayloadResponse | Select-Xml -XPath "//array").Node[3].data.value.innertext
            if ($null -ne $unlockfail) {
                $unlockfail | ForEach-Object -Process { Write-Error "Failed to unlock page: $PSItem" }
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