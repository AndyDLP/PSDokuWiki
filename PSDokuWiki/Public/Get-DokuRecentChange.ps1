function Get-DokuRecentChange {
	[CmdletBinding(PositionalBinding = $true)]
	[OutputType([psobject[]])]
	param
	(
		[Parameter(Mandatory = $true,
				   Position = 1,
				   ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
				   HelpMessage = 'Get all pages since this timestamp')]
		[ValidateNotNullOrEmpty()]
		[int]$VersionTimestamp
	)

	begin {

	} # begin

	process {
		$APIResponse = Invoke-DokuApiCall -MethodName 'wiki.getRecentChanges' -MethodParameters @($VersionTimestamp)
		if ($APIResponse.CompletedSuccessfully -eq $true) {
			$MemberNodes = ($APIResponse.XMLPayloadResponse | Select-Xml -XPath "//struct").Node
			foreach ($node in $MemberNodes) {
				$ChangeObject = New-Object PSObject -Property @{
					FullName = (($node.member)[0]).value.innertext
					LastModified = Get-Date -Date ((($node.member)[1]).value.innertext)
					Author = (($node.member)[2]).value.innertext
					VersionTimestamp = (($node.member)[3]).value.innertext
				}
				$ChangeObject
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