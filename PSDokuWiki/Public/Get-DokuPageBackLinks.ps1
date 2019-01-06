function Get-DokuPageBackLinks {
<#
	.SYNOPSIS
		Returns a list of backlinks of a Wiki page

	.DESCRIPTION
		Returns a list of backlinks of a Wiki page

	.PARAMETER DokuSession
		The DokuSession to get the page backlinks from

	.PARAMETER FullName
		The full page name for which to return the data

	.EXAMPLE
		PS C:\> $PageBackLinks = Get-DokuPageBackLinks -DokuSession $DokuSession -FullName "namespace:namespace:page"

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
				   HelpMessage = 'The DokuSession to get the page backlinks from')]
		[ValidateNotNullOrEmpty()]
		[psobject]$DokuSession,
		[Parameter(Mandatory = $true,
				   Position = 2,
				   ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
				   HelpMessage = 'The full page name for which to return the data')]
		[ValidateNotNullOrEmpty()]
		[string[]]$FullName
	)

	begin {

	} # begin

	process {
		foreach ($PageName in $FullName) {
			$payload = (ConvertTo-XmlRpcMethodCall -Name "wiki.getBackLinks" -Params $PageName) -replace "String", "string"
			if ($DokuSession.SessionMethod -eq "HttpBasic") {
				$httpResponse = Invoke-WebRequest -Uri $DokuSession.TargetUri -Method Post -Headers $DokuSession.Headers -Body $payload -ErrorAction Stop
			} else {
				$httpResponse = Invoke-WebRequest -Uri $DokuSession.TargetUri -Method Post -Headers $DokuSession.Headers -Body $payload -ErrorAction Stop -WebSession $DokuSession.WebSession
			}
			$PageArray = ([xml]$httpResponse.Content | Select-Xml -XPath "//array/data/value").Node.InnerText
			foreach ($Page in $PageArray) {
				$PageObject = New-Object PSObject -Property @{
					FullName = $PageName
					BacklinkedFullName = $Page
				}
				[array]$PageLinks = $PageLinks + $PageObject
			}
			$PageLinks
		} # foreach
	} # process

	end {

	} # end
}