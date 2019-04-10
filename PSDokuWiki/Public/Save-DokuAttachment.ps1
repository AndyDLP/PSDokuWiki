function Save-DokuAttachment {
	[CmdletBinding(PositionalBinding = $true, SupportsShouldProcess=$True, ConfirmImpact='Low')]
	[OutputType([System.IO.FileInfo])]
	param
	(
		[Parameter(Mandatory = $true,
				   Position = 1,
				   ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
				   HelpMessage = 'The full name of the file to get')]
		[ValidateNotNullOrEmpty()]
		[string[]]$FullName,
		[Parameter(Mandatory = $false,
				   Position = 2,
				   HelpMessage = 'The path to save the attachment to, including filename & extension')]
		[ValidateScript({ Test-Path -Path $_ -IsValid })]
		[string]$Path,
		[Parameter(Mandatory = $false,
				   Position = 3,
				   HelpMessage = 'Force creation of output file, overwriting any existing files')]
		[switch]$Force
	)

	begin {}

	process {
		foreach ($AttachmentName in $FullName) {
			if ($PSCmdlet.ShouldProcess("Save attachment: $AttachmentName to path: $Path")) {
				$APIResponse = Invoke-DokuApiCall -MethodName 'wiki.getAttachment' -MethodParameters @($AttachmentName)
				if ($APIResponse.CompletedSuccessfully -eq $true) {
					Write-Verbose $APIResponse.XMLPayloadResponse
					if ((Test-Path -Path $Path) -and (!$Force)) {
						$PSCmdlet.ThrowTerminatingError(
							[System.Management.Automation.ErrorRecord]::new(
								("File with that name already exists at: $Path"),
								'DokuWiki.Attachment.DownloadError',
								[System.Management.Automation.ErrorCategory]::WriteError,
								$Path
							)
						)
					} else {
						Remove-Item -Path $Path -Force -ErrorAction SilentlyContinue
						$RawFileData = [string]($APIResponse.XMLPayloadResponse | Select-Xml -XPath "//value/base64").node.InnerText
						$RawBytes = [Convert]::FromBase64String($RawFileData)
						[IO.File]::WriteAllBytes($Path, $RawBytes) | Out-Null
						$ItemObject = (Get-Item -Path $Path)
						$ItemObject
					}
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