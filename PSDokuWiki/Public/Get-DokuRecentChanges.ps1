function Get-DokuRecentChanges {
<#
	.SYNOPSIS
		Returns a list of recent changes since given timestamp

	.DESCRIPTION
		Returns a list of recent changes since given timestamp.
		As stated in recent_changes: Only the most recent change for each page is listed, regardless of how many times that page was changed

	.PARAMETER DokuSession
		The DokuSession from which to get the changes

	.PARAMETER VersionTimestamp
		Get all pages since this timestamp

	.EXAMPLE
		PS C:\> Get-DokuRecentChanges -DokuSession $DokuSession -VersionTimestamp $VersionTimestamp

	.OUTPUTS
		System.Management.Automation.PSObject[]

	.NOTES
		AndyDLP - 2018-05-26
#>

	[CmdletBinding(PositionalBinding = $true)]
	[OutputType([psobject[]])]
	param
	(
		[Parameter(Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The DokuSession from which to get the changes')]
		[ValidateNotNullOrEmpty()]
		[psobject]$DokuSession,
		[Parameter(Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'Get all pages since this timestamp')]
		[ValidateNotNullOrEmpty()]
		[int]$VersionTimestamp
	)

	$payload = (ConvertTo-XmlRpcMethodCall -Name "wiki.getRecentChanges" -Params $VersionTimestamp) -replace "Int32", "i4"
	if ($DokuSession.SessionMethod -eq "HttpBasic") {
		$httpResponse = Invoke-WebRequest -Uri $DokuSession.TargetUri -Method Post -Headers $DokuSession.Headers -Body $payload -ErrorAction Stop
	} else {
		$httpResponse = Invoke-WebRequest -Uri $DokuSession.TargetUri -Method Post -Headers $DokuSession.Headers -Body $payload -ErrorAction Stop -WebSession $DokuSession.WebSession
	}

	$MemberNodes = ([xml]$httpResponse.Content | Select-Xml -XPath "//struct").Node
	foreach ($node in $MemberNodes) {
		$ChangeObject = New-Object PSObject -Property @{
			FullName = (($node.member)[0]).value.innertext
			LastModified = Get-Date -Date ((($node.member)[1]).value.innertext)
			Author = (($node.member)[2]).value.innertext
			VersionTimestamp = (($node.member)[3]).value.innertext
		}
		[array]$PageChanges = $PageChanges + $ChangeObject
	}
	$PageChanges
}