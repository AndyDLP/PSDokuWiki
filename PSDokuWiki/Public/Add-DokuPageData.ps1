function Add-DokuPageData {
    <#
	.SYNOPSIS
		Appends wiki text to the end of a page.

	.DESCRIPTION
		Appends wiki text to the end of a page. Can create new page or namespace by referencing a (currnely non-existant) page / namespace

	.PARAMETER FullName
		The full name of the to-be-edited page, including parent namespace(s)

	.PARAMETER RawWikiText
		The raw wiki text to append to the page

	.PARAMETER PassThru
		Pass the newly created page object back out

	.PARAMETER MinorChange
		State if the change was minor or not

	.PARAMETER SummaryText
		A short summary of the change, visible in the revisions list

	.EXAMPLE
		PS C:\> Add-DokuPageData -FullName 'namespace:page' -RawWikiText 'TEST TEST TEST'

	.OUTPUTS
		System.Boolean, System.Management.Automation.PSObject

	.NOTES
		AndyDLP - 2018-05-26

	.LINK
		https://github.com/AndyDLP/PSDokuWiki
#>

    [CmdletBinding(PositionalBinding = $true)]
    [OutputType([boolean], [psobject])]
    param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
			ValueFromPipelineByPropertyName=$true,
            Position = 1,
            HelpMessage = 'The full name of the to-be-edited page, including parent namespace(s)')]
        [ValidateNotNullOrEmpty()]
        [string]$FullName,
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
    )

    begin {

    } # begin

    process {
        $Change = if ($MinorChange) {$true} else {$false}
        $APIResponse = Invoke-DokuApiCall -MethodName 'dokuwiki.appendPage' -MethodParameters @($FullName, $RawWikiText, @{ sum = $SummaryText; minor = [int]$Change })
        if ($APIResponse.CompletedSuccessfully -eq $true) {
            if ($PassThru) {
                $PageObject = New-Object PSObject -Property @{
                    FullName        = $FullName
                    AddedText       = $RawWikiText
                    MinorChange     = $MinorChange
                    SummaryText     = $SummaryText
                    PageName        = ($FullName -split ":")[-1]
                    ParentNamespace = ($FullName -split ":")[-2]
                    RootNamespace   = ($FullName -split ":")[0]
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
