function Get-DokuServerTime {
	[CmdletBinding()]
	[OutputType([datetime], [int])]
	param()

	begin {}

	process {
		$APIResponse = Invoke-DokuApiCall -MethodName 'dokuwiki.getTime' -MethodParameters @()
		if ($APIResponse.CompletedSuccessfully -eq $true) {			
			[int]$RawDokuTime = ($APIResponse.XMLPayloadResponse | Select-Xml -XPath "//value/int").Node.InnerText
			$DateObject = New-Object PSObject -Property @{
				Server = $Script:DokuServer.Server
				UNIXTimestamp = $RawDokuTime
				ServerTime = ([datetime]'1970-01-01 00:00:00').AddSeconds($RawDokuTime)
			}
			$DateObject
		} elseif ($null -eq $APIResponse.ExceptionMessage) {
			Write-Error "Fault code: $($APIResponse.FaultCode) - Fault string: $($APIResponse.FaultString)"
		} else {
			Write-Error "Exception: $($APIResponse.ExceptionMessage)"
		}
	} # process

	end {}
}