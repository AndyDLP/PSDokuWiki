function Add-DokuPageData {
    <#
	.SYNOPSIS
		Appends wiki text to the end of a page.

	.DESCRIPTION
		Appends wiki text to the end of a page. Can create new page or namespace by referencing a (currnely non-existant) page / namespace

	.PARAMETER FullName
		The full name of the to-be-edited page, including parent namespace(s)

	.PARAMETER DokuSession
		The DokuSession to add the page data to

	.PARAMETER RawWikiText
		The raw wiki text to append to the page

	.PARAMETER PassThru
		Pass the newly created page object back out

	.PARAMETER MinorChange
		State if the change was minor or not

	.PARAMETER SummaryText
		A short summary of the change, visible in the revisions list

	.EXAMPLE
		PS C:\> Add-DokuPageData -DokuSession $DokuSession -FullName 'namespace:page' -RawWikiText 'TEST TEST TEST'

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
            Position = 1,
            HelpMessage = 'The DokuSession to add the page data to')]
        [ValidateNotNullOrEmpty()]
        [psobject]$DokuSession,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
			ValueFromPipelineByPropertyName=$true,
            Position = 2,
            HelpMessage = 'The full name of the to-be-edited page, including parent namespace(s)')]
        [ValidateNotNullOrEmpty()]
        [string]$FullName,
        [Parameter(Mandatory = $true,
            Position = 3,
            HelpMessage = 'The raw wiki text to append to the page')]
        [ValidateNotNullOrEmpty()]
        [string]$RawWikiText,
        [Parameter(Position = 4,
            HelpMessage = 'State if the change was minor or not')]
        [switch]$MinorChange,
        [Parameter(Position = 5,
            HelpMessage = 'A short summary of the change')]
        [string]$SummaryText,
        [Parameter(Position = 6,
            HelpMessage = 'Pass the newly created object back out')]
        [switch]$PassThru
    )

    begin {

    } # begin

    process {
        # TODO: write my own xmlrpc cmdlets, this is just silly!
        $payload = (ConvertTo-XmlRpcMethodCall -Name "dokuwiki.appendPage" -Params @($FullName, $RawWikiText, @{ sum = $SummaryText; minor = $MinorChange })) -replace "String", "string"
        $payload = $payload -replace "Boolean", "boolean"
        $payload = $payload -replace "True", "1"
        $payload = $payload -replace "False", "0"

        if ($DokuSession.SessionMethod -eq "HttpBasic") {
            Invoke-WebRequest -Uri $DokuSession.TargetUri -Method Post -Headers $DokuSession.Headers -Body $payload -ErrorAction Stop | Out-Null
        } else {
            Invoke-WebRequest -Uri $DokuSession.TargetUri -Method Post -Headers $DokuSession.Headers -Body $payload -ErrorAction Stop -WebSession $DokuSession.WebSession | Out-Null
        }

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
        } else {
            # Return Nothing = more like built in cmdlets??
            # $ResultBoolean = [boolean]([xml]$httpResponse.Content | Select-Xml -XPath "//value/boolean").node.InnerText
            # $ResultBoolean
        }
    } # process

    end {

    } # end
}
