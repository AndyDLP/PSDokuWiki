function New-DokuAttachment {
<#
	.SYNOPSIS
		Uploads a file as an attachment

	.DESCRIPTION
		Uploads a file as an attachment

	.PARAMETER DokuSession
		The DokuSession where the attachment will be uploaded

	.PARAMETER FullName
		The FullName of the to-be-uploaded file, including namespace(s)

	.PARAMETER Path
		The file path of the attachment to upload

	.PARAMETER Force
		Force upload of attachment, overwriting any existing files with the same name

	.EXAMPLE
		PS C:\> New-DokuAttachment -DokuSession $DokuSession -FullName 'value2' -FilePath 'value3'

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
				   HelpMessage = 'The DokuSession where the attachment will be uploaded')]
		[ValidateNotNullOrEmpty()]
		[psobject]$DokuSession,
		[Parameter(Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'The FullName of the to-be-uploaded file, including namespace(s)')]
		[ValidateNotNullOrEmpty()]
		[string]$FullName,
		[Parameter(Mandatory = $true,
				   Position = 3,
				   HelpMessage = 'The file path of the attachment to upload')]
		[ValidateScript({ Test-Path -Path $_ -PathType Leaf })]
		[string]$Path,
		[Parameter(HelpMessage = 'Force upload of attachment, overwriting any existing files with the same name')]
		[switch]$Force
	)

	$FileBytes = [IO.File]::ReadAllBytes($Path)
	$FileData = [Convert]::ToBase64String($FileBytes)

	$payload = ConvertTo-XmlRpcMethodCall -Name wiki.putAttachment -Params @($FullName,$FileData,@{'ow' = [bool]$Forced})

	if ($DokuSession.SessionMethod -eq "HttpBasic") {
		$httpResponse = Invoke-WebRequest -Uri $DokuSession.TargetUri -Method Post -Headers $DokuSession.Headers -Body $payload -ErrorAction Stop
	} else {
		$httpResponse = Invoke-WebRequest -Uri $DokuSession.TargetUri -Method Post -Headers $DokuSession.Headers -Body $payload -ErrorAction Stop -WebSession $DokuSession.WebSession
	}

	$FileItem = (Get-Item -Path $Path)
	$ResultString = [string]([xml]$httpResponse.Content | Select-Xml -XPath "//value/string").node.InnerText
	if ($ResultString -ne $FullName) {
		throw "Error: $ResultString - Fullname: $FullName"
	}

	$attachmentObject = New-Object PSObject -Property @{
		FullName = $FullName
		SourceFilePath = $Path
		Size = $FileItem.Length
		SourceFileLastModified = $FileItem.LastWriteTimeUtc
		FileName = ($FullName -split ":")[-1]
		ParentNamespace = ($FullName -split ":")[-2]
		RootNamespace = ($FullName -split ":")[0]
	}
	return $attachmentObject
}