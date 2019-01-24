function Get-DokuAttachmentInfo {
    <#
	.SYNOPSIS
		Returns information about a media file

	.DESCRIPTION
		Returns information about a media file

	.PARAMETER DokuSession
		The DokuSession from which to get the attachment info

	.PARAMETER FullName
		The full name of the file to get information from

	.EXAMPLE
		PS C:\> Get-DokuAttachmentInfo -DokuSession $DokuSession -FullName 'namespace:filename.ext'

	.OUTPUTS
		System.Management.Automation.PSObject

	.NOTES
		AndyDLP - 2018-05-26
#>

    [CmdletBinding()]
    [OutputType([psobject])]
    param
    (
        [Parameter(Mandatory = $true,
            Position = 1,
            HelpMessage = 'The DokuSession from which to get the attachment info')]
        [ValidateNotNullOrEmpty()]
        [psobject]$DokuSession,
        [Parameter(Mandatory = $true,
            Position = 2,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'The full name of the file to get information from')]
        [ValidateNotNullOrEmpty()]
        [string[]]$FullName
    )

    begin {

    } # begin

    process {
        foreach ($attachmentName in $FullName) {
            $payload = ConvertTo-XmlRpcMethodCall -Name "wiki.getAttachmentInfo" -Params $attachmentName
            if ($DokuSession.SessionMethod -eq "HttpBasic") {
                $httpResponse = Invoke-WebRequest -Uri $DokuSession.TargetUri -Method Post -Headers $DokuSession.Headers -Body $payload -ErrorAction Stop
            } else {
                $httpResponse = Invoke-WebRequest -Uri $DokuSession.TargetUri -Method Post -Headers $DokuSession.Headers -Body $payload -ErrorAction Stop -WebSession $DokuSession.WebSession
            }
            $ArrayValues = ([xml]$httpResponse.Content | Select-Xml -XPath "//struct").Node.Member.Value.Innertext
            $attachmentObject = New-Object PSObject -Property @{
                FullName        = $attachmentName
                Size            = $ArrayValues[1]
                LastModified    = Get-Date -Date ($ArrayValues[0])
                FileName        = ($attachmentName -split ":")[-1]
                ParentNamespace = ($attachmentName -split ":")[-2]
                RootNamespace   = if (($attachmentName -split ":")[0] -eq $attachmentName) {"::"} else {($attachmentName -split ":")[0]}
            }
            $attachmentObject
        }
    } # process

    end {

    } # end
}