function New-DokuAttachment {
	[CmdletBinding(PositionalBinding = $true, SupportsShouldProcess=$True, ConfirmImpact='Medium')]
	[OutputType([psobject])]
	param
	(
		[Parameter(Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The file path of the attachment to upload')]
		[ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
		[string]$Path,
		[Parameter(Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'The FullName of the to-be-uploaded file, including namespace(s)')]
		[ValidateNotNullOrEmpty()]
		[string]$FullName,
		[Parameter(Mandatory = $false,
				   Position = 3,
				   HelpMessage = 'Force upload of attachment, overwriting any existing files with the same name')]
		[switch]$Force,
		[Parameter(Mandatory = $false,
				   Position = 4,
				   HelpMessage = 'Pass the newly created attachment object out')]
		[switch]$PassThru
	)

	if ($PSCmdlet.ShouldProcess("Upload attachment at path: $Path to location: $Fullname")) {

		# add a check size before uploading??
		Write-Verbose "Reading all bytes from file: $Path"
		$FileBytes = [IO.File]::ReadAllBytes($Path)

		# Moved conversion to Base64 to inside the function0.
		$APIResponse = Invoke-DokuApiCall -MethodName 'wiki.putAttachment' -MethodParameters @($FullName,$FileBytes,@{'ow' = [bool]$Force})
		if ($APIResponse.CompletedSuccessfully -eq $true) {
			Write-Verbose $APIResponse.XMLPayloadResponse
			$FileItem = (Get-Item -Path $Path)
			$ResultString = [string]($APIResponse.XMLPayloadResponse | Select-Xml -XPath "//value/string").node.InnerText
			if ($ResultString -eq $FullName) {
				Write-Verbose "File uploaded successfully"
				if ($PassThru) {
					$attachmentObject = [PSCustomObject]@{
						FullName = $FullName
						SourceFilePath = $Path
						Size = $FileItem.Length
						SourceFileLastModified = $FileItem.LastWriteTimeUtc
						FileName = ($FullName -split ":")[-1]
						ParentNamespace = ($FullName -split ":")[-2]
						RootNamespace = ($FullName -split ":")[0]
					}
					$attachmentObject.PSObject.TypeNames.Insert(0, "DokuWiki.Attachment")
					$attachmentObject
				}
			} else {
				Write-Error "Error: $ResultString - Fullname: $FullName"
			}
		} elseif ($null -eq $APIResponse.ExceptionMessage) {
			Write-Error "Fault code: $($APIResponse.FaultCode) - Fault string: $($APIResponse.FaultString)"
		} else {
			Write-Error "Exception: $($APIResponse.ExceptionMessage)"
		}
	} # should process
}