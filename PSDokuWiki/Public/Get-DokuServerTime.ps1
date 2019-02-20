function Get-DokuServerTime {
<#
	.SYNOPSIS
		Returns the current time from the remote wiki server as Unix timestamp

	.DESCRIPTION
		Returns the current time from the remote wiki server as Unix timestamp

	.PARAMETER Raw
		Output the raw response from the server in UNIX time rather than a DateTime

	.EXAMPLE
		PS C:\> $serverTime = Get-DokuServerTime

	.EXAMPLE
		PS C:\> $UnixserverTime = Get-DokuServerTime -Raw

	.OUTPUTS
		System.DateTime, System.Int32

	.NOTES
		AndyDLP - 2018-05-26
#>

	[CmdletBinding()]
	[OutputType([datetime], [int])]
	param
	(
		[Parameter(Position = 1,
				   HelpMessage = 'Output the raw response from the server in UNIX time')]
		[switch]$Raw
	)

	begin {

	} # begin

	process {
		$APIResponse = Invoke-DokuApiCall -MethodName 'dokuwiki.getTime' -MethodParameters @()
		if ($APIResponse.CompletedSuccessfully -eq $true) {			
			[int]$RawDokuTime = ($APIResponse.XMLPayloadResponse | Select-Xml -XPath "//value/int").Node.InnerText
			if ($Raw) {
				$RawDokuTime
			} else {
				[datetime]$RawDokuTime
			}
		} elseif ($null -eq $APIResponse.ExceptionMessage) {
			Write-Error "Fault code: $($APIResponse.FaultCode) - Fault string: $($APIResponse.FaultString)"
		} else {
			Write-Error "Exception: $($APIResponse.ExceptionMessage)"
		}
	} # process

	end {

	} # end
}