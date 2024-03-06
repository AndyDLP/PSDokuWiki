function Get-DokuAttachmentInfo {
    [CmdletBinding(SupportsShouldProcess=$True, ConfirmImpact='Low')]
    [OutputType([psobject])]
    param
    (
        [Parameter(Mandatory = $true,
            Position = 1,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'The full name of the file to get information from')]
        [ValidateNotNullOrEmpty()]
        [string[]]$FullName
    )

    begin {}

    process {
        foreach ($attachmentName in $FullName) {
            if ($PSCmdlet.ShouldProcess("Get info for attachment: $attachmentName")) {
                $APIResponse = Invoke-DokuApiCall -MethodName 'wiki.getAttachmentInfo' -MethodParameters @($attachmentName)
                if ($APIResponse.CompletedSuccessfully -eq $true) {
                    $ArrayValues = ($APIResponse.XMLPayloadResponse | Select-Xml -XPath "//struct").Node.Member.Value.Innertext
                    $ConvertedDate = $ArrayValues[0].substring(0,4) + '-' + $ArrayValues[0].substring(4,2) + '-' + -join $ArrayValues[0][6..50]
                    $attachmentObject = [PSCustomObject]@{
                        FullName        = $attachmentName
                        Size            = $ArrayValues[1]
                        #  LastModified    = Get-Date -Date ($ArrayValues[0])
                        LastModified    = Get-Date -Date ($ConvertedDate)
                        FileName        = ($attachmentName -split ":")[-1]
                        ParentNamespace = ($attachmentName -split ":")[-2]
                        RootNamespace   = if (($attachmentName -split ":")[0] -eq $attachmentName) {"::"} else {($attachmentName -split ":")[0]}
                    }
                    $attachmentObject.PSObject.TypeNames.Insert(0, "DokuWiki.Attachment.Info")
                    $attachmentObject            
                } elseif ($null -eq $APIResponse.ExceptionMessage) {
                    Write-Error "Fault code: $($APIResponse.FaultCode) - Fault string: $($APIResponse.FaultString)"
                } else {
                    Write-Error "Exception: $($APIResponse.ExceptionMessage)"
                }
            } # should process
        } # foreach attachment
    } # process

    end {}
}