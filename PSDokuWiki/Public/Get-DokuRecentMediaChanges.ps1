﻿function Get-DokuRecentMediaChanges {
<#
	.SYNOPSIS
		Returns a list of recently changed media since given timestamp
	
	.DESCRIPTION
		Returns a list of recently changed media since given timestamp
	
	.PARAMETER DokuSession
		The DokuSession from which to get the recent media changes
	
	.PARAMETER VersionTimestamp
		Get all media / attachment changes since this timestamp
	
	.EXAMPLE
		PS C:\> Get-DokuRecentMediaChanges -DokuSession $DokuSession -VersionTimestamp $VersionTimestamp
	
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
				   HelpMessage = 'The DokuSession from which to get the recent media changes')]
		[ValidateNotNullOrEmpty()]
		[psobject]$DokuSession,
		[Parameter(Mandatory = $true,
				   Position = 2,
				   HelpMessage = 'Get all media / attachment changes since this timestamp')]
		[ValidateNotNullOrEmpty()]
		[int]$VersionTimestamp
	)
	
	$payload = (ConvertTo-XmlRpcMethodCall -Name "wiki.getRecentMediaChanges" -Params $VersionTimestamp) -replace "Int32", "i4"
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
			Permissions = (($node.member)[4]).value.innertext
			Size = (($node.member)[5]).value.innertext
		}
		[array]$MediaChanges = $MediaChanges + $ChangeObject
	}
	return $MediaChanges
}