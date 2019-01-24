﻿function Get-DokuServerApiVersion {
<#
	.SYNOPSIS
		Returns the DokuWiki version of the remote Wiki server

	.DESCRIPTION
		Returns the DokuWiki version of the remote Wiki server

	.PARAMETER DokuSession
		The DokuSession (generated by New-DokuSession) from which to get the page list.

	.EXAMPLE
		PS C:\> $Version = Get-DokuServerApiVersion -DokuSession $DokuSession

	.EXAMPLE
		PS C:\> $version = Get-DokuServerApiVersion -DokuSession $DokuSession

	.NOTES
		AndyDLP - 2018-05-28
#>

	[CmdletBinding()]
	[OutputType([psobject])]
	param
	(
		[Parameter(Mandatory = $true,
				   Position = 1,
				   ValueFromPipeline = $true,
				   HelpMessage = 'The DokuSession from which to get the page list.')]
		[ValidateScript({ ($null -ne $_.WebSession) -or ($_.Headers.Keys -contains "Authorization") })]
		[psobject]$DokuSession
	)

	begin {

	} # begin

	process {
		$payload = ConvertTo-XmlRpcMethodCall -Name "dokuwiki.getXMLRPCAPIVersion"
		if ($DokuSession.SessionMethod -eq "HttpBasic") {
			$httpResponse = Invoke-WebRequest -Uri $DokuSession.TargetUri -Method Post -Headers $DokuSession.Headers -Body $payload -ErrorAction Stop
		} else {
			$httpResponse = Invoke-WebRequest -Uri $DokuSession.TargetUri -Method Post -Headers $DokuSession.Headers -Body $payload -ErrorAction Stop -WebSession $DokuSession.WebSession
		}
		$APIVersion = [int]([xml]$httpResponse.Content | Select-Xml -XPath "//value/int").node.InnerText
		$VersionObject = New-Object PSObject -Property @{
			Server = $DokuSession.Server
			XmlRpcVersion = $APIVersion
		}
		$VersionObject
	} # process

	end {

	} # end
}