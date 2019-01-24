﻿function Get-DokuPageVersionData {
<#
	.SYNOPSIS
		Returns the raw Wiki text for a specific version of a page

	.DESCRIPTION
		Returns the raw Wiki text for a specific version of a page

	.PARAMETER DokuSession
		The DokuSession (generated by New-DokuSession) from which to get the page data

	.PARAMETER FullName
		The full page name for which to return the data, including any namespaces

	.PARAMETER VersionTimestamp
		The timestamp for which version to get the info from

	.EXAMPLE
		PS C:\> $PageData = Get-DokuPageVersionData -DokuSession $DokuSession -FullName "namespace:namespace:page" -VersionTimestamp 1497464418

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
				   HelpMessage = 'The DokuSession from which to get the page data')]
		[ValidateNotNullOrEmpty()]
		[psobject]$DokuSession,
		[Parameter(Mandatory = $true,
				   Position = 2,
				   ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
				   HelpMessage = 'The full page name for which to return the data')]
		[ValidateNotNullOrEmpty()]
		[string[]]$FullName,
		[Parameter(Mandatory = $true,
				   Position = 3,
				   HelpMessage = 'The timestamp for which version to get the info from')]
		[ValidateNotNullOrEmpty()]
		[int]$VersionTimestamp
	)

	begin {

	} # begin

	process {
		foreach ($PageName in $FullName) {
			$payload = ConvertTo-XmlRpcMethodCall -Name "wiki.getPageVersion" -Params @($PageName, $VersionTimestamp)
			if ($DokuSession.SessionMethod -eq "HttpBasic") {
				$httpResponse = Invoke-WebRequest -Uri $DokuSession.TargetUri -Method Post -Headers $DokuSession.Headers -Body $payload -ErrorAction Stop
			} else {
				$httpResponse = Invoke-WebRequest -Uri $DokuSession.TargetUri -Method Post -Headers $DokuSession.Headers -Body $payload -ErrorAction Stop -WebSession $DokuSession.WebSession
			}

			$PageObject = New-Object PSObject -Property @{
				FullName = $PageName
				VersionTimestamp = $VersionTimestamp
				RawText = [string]([xml]$httpResponse.Content | Select-Xml -XPath "//value/string").Node.InnerText
				PageName = ($PageName -split ":")[-1]
				ParentNamespace = ($PageName -split ":")[-2]
				RootNamespace = ($PageName -split ":")[0]
			}
			$PageObject
		}
	} # process

	end {

	} # end
}