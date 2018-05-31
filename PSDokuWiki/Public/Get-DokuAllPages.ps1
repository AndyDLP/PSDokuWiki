function Get-DokuAllPages {
<#
	.SYNOPSIS
		Returns a list of all Wiki pages in the remote DokuSession
	
	.DESCRIPTION
		Returns a list of all Wiki pages in the remote DokuSession
	
	.PARAMETER DokuSession
		The DokuSession from which to get the pages
	
	.EXAMPLE
		PS C:\> $AllPages = Get-DokuAllPages -DokuSession $DokuSession
	
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
				   HelpMessage = 'The DokuSession from which to get the pages')]
		[ValidateNotNullOrEmpty()]
		[psobject]$DokuSession
	)
	
	$payload = (ConvertTo-XmlRpcMethodCall -Name "wiki.getAllPages") -replace "<value></value>",""
	if ($DokuSession.SessionMethod -eq "HttpBasic") {
		$httpResponse = Invoke-WebRequest -Uri $DokuSession.TargetUri -Method Post -Headers $DokuSession.Headers -Body $payload -ErrorAction Stop
	} else {
		$httpResponse = Invoke-WebRequest -Uri $DokuSession.TargetUri -Method Post -Headers $DokuSession.Headers -Body $payload -ErrorAction Stop -WebSession $DokuSession.WebSession
	}
	
	$MemberNodes = ([xml]$httpResponse.Content | Select-Xml -XPath "//struct").Node
	foreach ($node in $MemberNodes) {
		$PageObject = New-Object PSObject -Property @{
			FullName = (($node.member)[0]).value.InnerText
			Acl = (($node.member)[1]).value.InnerText
			Size = (($node.member)[2]).value.InnerText
			LastModified = Get-Date -Date ((($node.member)[3]).value.InnerText)
		}
		[array]$AllPages = $AllPages + $PageObject
	}
	return $AllPages
}