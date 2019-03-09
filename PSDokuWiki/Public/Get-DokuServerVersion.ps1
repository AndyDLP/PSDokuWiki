function Get-DokuServerVersion {
<#
	.SYNOPSIS
		Returns the DokuWiki version of the remote Wiki server

	.DESCRIPTION
		Returns the DokuWiki version of the remote Wiki server

	.EXAMPLE
		PS C:\> $Version = Get-DokuServerVersion

	.OUTPUTS
		System.Management.Automation.PSObject

	.NOTES
		AndyDLP - 2018-05-28
#>

	[CmdletBinding()]
	[OutputType([psobject])]
	param
	(
	)

	begin {

	} # begin

	process {
		$APIResponse = Invoke-DokuApiCall -MethodName 'dokuwiki.getVersion' -MethodParameters @()
		if ($APIResponse.CompletedSuccessfully -eq $true) {
			$RawDokuVersion = [string]($APIResponse.XMLPayloadResponse | Select-Xml -XPath "//value/string").node.InnerText
			$CodeName = $RawDokuVersion | ForEach-Object -Process { [regex]::match($_, '(?<=")(.+)(?=")') } | Select-Object -ExpandProperty value
			$SplitVersion = $RawDokuVersion -split " "
			$VersionObject = New-Object PSObject -Property @{
				Server = $Script:DokuServer.Server
				Type = $SplitVersion[0] # Does this ever change?
				RawVersion = $RawDokuVersion
				ReleaseDate = $SplitVersion[1] # TODO: Convert to date time - replace letter(s)?
				ReleaseName = $CodeName
			}
			$VersionObject
		} elseif ($null -eq $APIResponse.ExceptionMessage) {
			Write-Error "Fault code: $($APIResponse.FaultCode) - Fault string: $($APIResponse.FaultString)"
		} else {
			Write-Error "Exception: $($APIResponse.ExceptionMessage)"
		}
	} # process

	end {

	} # end
}