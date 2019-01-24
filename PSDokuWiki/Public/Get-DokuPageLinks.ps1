function Get-DokuPageLinks {
<#
	.SYNOPSIS
		Returns an array of all links on a page

	.DESCRIPTION
		Returns an array of all links on a page

	.PARAMETER DokuSession
		The DokuSession from which to get the page links

	.PARAMETER FullName
		The full page name for which to return the data

	.EXAMPLE
		PS C:\> $PageLinks = Get-DokuPageLinks -DokuSession $DokuSession -FullName "namespace:namespace:page"

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
				   HelpMessage = 'The DokuSession from which to get the page links')]
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
			$payload = ConvertTo-XmlRpcMethodCall -Name "wiki.listLinks" -Params $PageName
			if ($DokuSession.SessionMethod -eq "HttpBasic") {
				$httpResponse = Invoke-WebRequest -Uri $DokuSession.TargetUri -Method Post -Headers $DokuSession.Headers -Body $payload -ErrorAction Stop
			} else {
				$httpResponse = Invoke-WebRequest -Uri $DokuSession.TargetUri -Method Post -Headers $DokuSession.Headers -Body $payload -ErrorAction Stop -WebSession $DokuSession.WebSession
			}
			$MemberNodes = ([xml]$httpResponse.Content | Select-Xml -XPath "//struct").Node
			foreach ($node in $MemberNodes) {
				$PageObject = New-Object PSObject -Property @{
					FullName = $PageName
					Type = (($node.member)[0]).value.string
					TargetPageName = (($node.member)[1]).value.string
					URL = (($node.member)[2]).value.string
				}
				[array]$PageLinks = $PageLinks + $PageObject
			}
			$PageLinks
		}
	} # process

	end {

	} # end
}