﻿function Get-DokuPageHtml {
<#
	.SYNOPSIS
		Returns the rendered XHTML body of a Wiki page

	.DESCRIPTION
		Returns the rendered XHTML body of a Wiki page

	.PARAMETER DokuSession
		The DokuSession (generated by New-DokuSession) from which to get the page HTML

	.PARAMETER FullName
		The full page name for which to return the data

	.PARAMETER Raw
		Return just the raw HTML instead of an object

	.EXAMPLE
		PS C:\> $PageHtml = Get-DokuPageHtml -DokuSession $DokuSession -FullName "namespace:namespace:page" -Raw

	.OUTPUTS
		System.Management.Automation.PSObject

	.NOTES
		AndyDLP - 2018-05-26
#>

	[CmdletBinding(PositionalBinding = $true)]
	[OutputType([psobject])]
	param
	(
		[Parameter(Mandatory = $true,
				   Position = 1,
				   HelpMessage = 'The DokuSession from which to get the page HTML')]
		[ValidateNotNullOrEmpty()]
		[psobject]$DokuSession,
		[Parameter(Mandatory = $true,
				   Position = 2,
				   ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
				   HelpMessage = 'The full page name for which to return the data')]
		[ValidateNotNullOrEmpty()]
		[string[]]$FullName,
		[Parameter(Mandatory = $false,
				   Position = 3,
				   HelpMessage = 'Return just the raw HTML instead of an object')]
		[switch]$Raw
	)

	begin {

	} # begin

	process {
		foreach ($PageName in $FullName) {
			$payload = (ConvertTo-XmlRpcMethodCall -Name "wiki.getPageHTML" -Params $PageName) -replace "String", "string"
			if ($DokuSession.SessionMethod -eq "HttpBasic") {
				$httpResponse = Invoke-WebRequest -Uri $DokuSession.TargetUri -Method Post -Headers $DokuSession.Headers -Body $payload -ErrorAction Stop
			} else {
				$httpResponse = Invoke-WebRequest -Uri $DokuSession.TargetUri -Method Post -Headers $DokuSession.Headers -Body $payload -ErrorAction Stop -WebSession $DokuSession.WebSession
			}

			$PageObject = New-Object PSObject -Property @{
				FullName = $PageName
				RenderedHtml = [string]([xml]$httpResponse.Content | Select-Xml -XPath "//value/string").Node.InnerText
				PageName = ($PageName -split ":")[-1]
				ParentNamespace = ($PageName -split ":")[-2]
				RootNamespace = ($PageName -split ":")[0]
			}
			if ($Raw) {
				$PageObject.RenderedHtml
			} else {
				$PageObject
			}
		} # foreach
	} # process

	end {

	} # end
}