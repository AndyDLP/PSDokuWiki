function Add-DokuPageData {
    [CmdletBinding(PositionalBinding = $true, SupportsShouldProcess=$True, ConfirmImpact='Medium')]
    [OutputType([boolean], [psobject])]
    param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
			ValueFromPipelineByPropertyName=$true,
            Position = 1,
            HelpMessage = 'The full name of the to-be-edited page, including parent namespace(s)')]
        [ValidateNotNullOrEmpty()]
        [string[]]$FullName,
        [Parameter(Mandatory = $true,
            Position = 2,
            HelpMessage = 'The raw wiki text to append to the page')]
        [ValidateNotNullOrEmpty()]
        [string]$RawWikiText,
        [Parameter(Position = 3,
            HelpMessage = 'State if the change was minor or not')]
        [switch]$MinorChange,
        [Parameter(Position = 4,
            HelpMessage = 'A short summary of the change')]
        [string]$SummaryText,
        [Parameter(Position = 5,
            HelpMessage = 'Pass the newly created object back out')]
        [switch]$PassThru
        [Parameter(Mandatory = $false,
            Position = 6,
            HelpMessage = 'Bypass confirmations of calls during this connect/disconnect session')]
        [ValidateNotNullOrEmpty()]
        [switch]$BypassConfirm
    )

    begin {

    } # begin

    process {
        foreach ($Page in $FullName) {
            if ($BypassConfirm -or $PSCmdlet.ShouldProcess("Add data: $RawWikiText to page: $Page")) {
                $Change = if ($MinorChange) {$true} else {$false}
                $APIResponse = Invoke-DokuApiCall -MethodName 'dokuwiki.appendPage' -MethodParameters @($Page, $RawWikiText, @{ sum = $SummaryText; minor = [int]$Change })
                if ($APIResponse.CompletedSuccessfully -eq $true) {
                    if ($PassThru) {
                        $PageObject = [PSCustomObject]@{
                            FullName        = $Page
                            AddedText       = $RawWikiText
                            MinorChange     = $MinorChange
                            SummaryText     = $SummaryText
                            PageName        = ($Page -split ":")[-1]
                            ParentNamespace = ($Page -split ":")[-2]
                            RootNamespace   = ($Page -split ":")[0]
                        }
                        $PageObject.PSObject.TypeNames.Insert(0, "DokuWiki.Page")
                        $PageObject
                    }
                } elseif ($null -eq $APIResponse.ExceptionMessage) {
                    Write-Error "Fault code: $($APIResponse.FaultCode) - Fault string: $($APIResponse.FaultString)"
                } else {
                    Write-Error "Exception: $($APIResponse.ExceptionMessage)"
                }
            } # should process
        } # foreach
    } # process

    end {

    } # end
}
