function Get-DokuServerVersion {
	[CmdletBinding(SupportsShouldProcess=$True, ConfirmImpact='Low')]
	[OutputType([psobject])]
	param
	(
	)

	begin {

	} # begin

	process {
		if ($PSCmdlet.ShouldProcess("Query DokuServer for current DokuWiki version")) {
			$APIResponse = Invoke-DokuApiCall -MethodName 'dokuwiki.getVersion' -MethodParameters @()
			if ($APIResponse.CompletedSuccessfully -eq $true) {
				$RawDokuVersion = [string]($APIResponse.XMLPayloadResponse | Select-Xml -XPath "//value/string").node.InnerText
				$CodeName = $RawDokuVersion | ForEach-Object -Process { [regex]::match($_, '(?<=")(.+)(?=")') } | Select-Object -ExpandProperty value
				$SplitVersion = $RawDokuVersion -split " "
				$VersionObject = [PSCustomObject]@{
					Server = $Script:DokuServer.Server
					Type = $SplitVersion[0] # Does this ever change?
					RawVersion = $RawDokuVersion
					ReleaseDate = $SplitVersion[1] # TODO: Convert to date time - replace letter(s)?
					ReleaseName = $CodeName
				}
				$VersionObject.PSObject.TypeNames.Insert(0, "DokuWiki.Server.Version")
				$VersionObject
			} elseif ($null -eq $APIResponse.ExceptionMessage) {
				Write-Error "Fault code: $($APIResponse.FaultCode) - Fault string: $($APIResponse.FaultString)"
			} else {
				Write-Error "Exception: $($APIResponse.ExceptionMessage)"
			}
		} # should process
	} # process

	end {

	} # end
}