function Get-DokuAttachmentList {
<#
	.SYNOPSIS
		Returns a list of media files in a given namespace

	.DESCRIPTION
		Returns a list of media files in a given namespace

	.PARAMETER DokuSession
		The DokuSession from which to get the attachments

	.PARAMETER Namespace
		The namespace to search for attachments

	.EXAMPLE
		PS C:\> Get-DokuAttachmentList -DokuSession $DokuSession -Namespace 'namespace'

	.OUTPUTS
		System.Management.Automation.PSObject[]

	.NOTES
		AndyDLP - 2018-05-26
#>

	[CmdletBinding()]
	[OutputType([psobject[]])]
	param
	(
		[Parameter(Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The DokuSession from which to get the attachments')]
		[ValidateNotNullOrEmpty()]
		[psobject]$DokuSession,
		[Parameter(Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'The namespace to search for attachments')]
		[ValidateNotNullOrEmpty()]
		[string]$Namespace
	)

	$payload = (ConvertTo-XmlRpcMethodCall -Name "wiki.getAttachments" -Params $FullName) -replace "String", "string"
	if ($DokuSession.SessionMethod -eq "HttpBasic") {
		$httpResponse = Invoke-WebRequest -Uri $DokuSession.TargetUri -Method Post -Headers $DokuSession.Headers -Body $payload -ErrorAction Stop
	} else {
		$httpResponse = Invoke-WebRequest -Uri $DokuSession.TargetUri -Method Post -Headers $DokuSession.Headers -Body $payload -ErrorAction Stop -WebSession $DokuSession.WebSession
	}

	$MemberNodes = ([xml]$httpResponse.Content | Select-Xml -XPath "//struct").Node
	foreach ($node in $MemberNodes) {
		$ChangeObject = New-Object PSObject -Property @{
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
		[array]$MediaChanges = $MediaChanges + $ChangeObject
	}
	return $MediaChanges
}