function Save-DokuAttachment {
<#
	.SYNOPSIS
		Returns the binary data of a media file
	
	.DESCRIPTION
		Returns the binary data of a media file
	
	.PARAMETER DokuSession
		The DokuSession from which to get the attachment
	
	.PARAMETER FullName
		The full name of the file to get
	
	.PARAMETER Path
		The path to save the attachment to, including filename & extension
	
	.PARAMETER Force
		Force creation of output file, overwriting any existing files with the same name
	
	.EXAMPLE
		PS C:\> Save-DokuAttachment -DokuSession $DokuSession -FullName 'value2' -Path 'value3'
	
	.OUTPUTS
		System.IO.FileInfo
	
	.NOTES
		AndyDLP - 2018-05-26
#>
	
	[CmdletBinding(PositionalBinding = $true)]
	[OutputType([System.IO.FileInfo])]
	param
	(
		[Parameter(Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The DokuSession from which to get the attachment')]
		[ValidateNotNullOrEmpty()]
		[psobject]$DokuSession,
		[Parameter(Mandatory = $true,
				   Position = 2,
				   ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
				   HelpMessage = 'The full name of the file to get')]
		[ValidateNotNullOrEmpty()]
		[string[]]$FullName,
		[Parameter(Mandatory = $false,
				   Position = 3,
				   HelpMessage = 'The path to save the attachment to, including filename & extension')]
		[ValidateScript({ Test-Path -Path $_ -IsValid })]
		[string]$Path,
		[Parameter(HelpMessage = 'Force creation of output file, overwriting any existing files')]
		[switch]$Force
	)

	begin {
		
	} # begin

	process {
		foreach ($AttachmentName in $FullName) {
			$httpResponse = Invoke-DokuApiCall -DokuSession $DokuSession -MethodName 'wiki.getAttachment' -MethodParameters @($AttachmentName)
			if ((Test-Path -Path $Path) -and (!$Force)) {
				throw "File with that name already exists at: $Path"
			} else {
				Remove-Item -Path $Path -Force -ErrorAction Stop
				$RawFileData = [string]([xml]$httpResponse.Content | Select-Xml -XPath "//value/base64").node.InnerText
				$RawBytes = [Convert]::FromBase64String($RawFileData)
				[IO.File]::WriteAllBytes($Path, $RawBytes) | Out-Null
				$ItemObject = (Get-Item -Path $Path)
				$ItemObject
			}
		}
	} # process

	end {

	} # end
}