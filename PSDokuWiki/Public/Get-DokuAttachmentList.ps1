function Get-DokuAttachmentList {
	[CmdletBinding(SupportsShouldProcess=$True, ConfirmImpact='Low')]
	[OutputType([psobject[]])]
	param
	(
		[Parameter(Mandatory = $true,
				   Position = 1,
				   ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
				   HelpMessage = 'The namespace to search for attachments')]
		[ValidateNotNullOrEmpty()]
		[string[]]$Namespace
	)

	begin {

	} # begin

	process {
		foreach ($curr in $Namespace) {
            if ($PSCmdlet.ShouldProcess("Get attachments in namespace: $curr")) {
				$APIResponse = Invoke-DokuApiCall -MethodName 'wiki.getAttachments' -MethodParameters @($curr)
				if ($APIResponse.CompletedSuccessfully -eq $true) {
					$MemberNodes = ($APIResponse.XMLPayloadResponse| Select-Xml -XPath "//struct").Node
					foreach ($node in $MemberNodes) {
						$MediaObject = [PSCustomObject]@{
							FullName = ((($node.member)[0]).value.innertext)
							Name = (($node.member)[1]).value.innertext
							Size = [int](($node.member)[2]).value.innertext
							VersionTimestamp = [int](($node.member)[3]).value.innertext
							IsWritable = [boolean](($node.member)[4]).value.innertext
							IsImage = [boolean](($node.member)[5]).value.innertext
							Acl = [int](($node.member)[6]).value.innertext
							LastModified = [datetime](($node.member)[7]).value.innertext
							ParentNamespace = (((($node.member)[0]).value.innertext) -split ":")[-2]
							RootNamespace = (((($node.member)[0]).value.innertext) -split ":")[0]
						}
						$MediaObject.PSObject.TypeNames.Insert(0, "DokuWiki.Attachment")
						$MediaObject
					}
				} elseif ($null -eq $APIResponse.ExceptionMessage) {
					Write-Error "Fault code: $($APIResponse.FaultCode) - Fault string: $($APIResponse.FaultString)"
				} else {
					Write-Error "Exception: $($APIResponse.ExceptionMessage)"
				}
			} # should process
		} # foreach namespace
	} # process

	end {

	} # end
}