function Get-DokuTitle {
	[CmdletBinding(PositionalBinding = $true)]
	[OutputType([psobject])]
	param
	(
	)

	begin {

	} # begin

	process {
		$APIResponse = Invoke-DokuApiCall -MethodName 'dokuwiki.getTitle' -MethodParameters @()
		if ($APIResponse.CompletedSuccessfully -eq $true) {
			[string]$DokuTitle = ($APIResponse.XMLPayloadResponse | Select-Xml -XPath "//value/string").node.InnerText
			$TitleObject = New-Object PSObject -Property @{
				Server = $Script:DokuServer.Server
				Title = $DokuTitle
			}
			$TitleObject
		} elseif ($null -eq $APIResponse.ExceptionMessage) {
			Write-Error "Fault code: $($APIResponse.FaultCode) - Fault string: $($APIResponse.FaultString)"
		} else {
			Write-Error "Exception: $($APIResponse.ExceptionMessage)"
		}
	} # process

	end {

	} # end
}