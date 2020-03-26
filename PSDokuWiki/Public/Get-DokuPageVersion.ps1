function Get-DokuPageVersion {
	[CmdletBinding(PositionalBinding = $true,SupportsShouldProcess=$True, ConfirmImpact='Low')]
	[OutputType([psobject[]])]
	param
	(
		[Parameter(Mandatory = $true,
				   Position = 1,
				   ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
				   HelpMessage = 'The full page name for which to return the data')]
		[ValidateNotNullOrEmpty()]
		[string[]]$FullName,
		[Parameter(Position = 2,
				   HelpMessage = 'Used to list earlier versions in the history')]
		[ValidateNotNullOrEmpty()]
		[int]$Offset = 0
	)

	begin {

	} # begin

	process {
		foreach ($PageName in $FullName) {
			if ($PSCmdlet.ShouldProcess("Get version of page: $PageName")) {
				$APIResponse = Invoke-DokuApiCall -MethodName 'wiki.getPageVersions' -MethodParameters @($PageName,$Offset)
				if ($APIResponse.CompletedSuccessfully -eq $true) {
					$MemberNodes = ($APIResponse.XMLPayloadResponse  | Select-Xml -XPath "//struct").Node
					foreach ($node in $MemberNodes) {
						$PageObject = [PSCustomObject]@{
							FullName = $PageName
							User = (($node.member)[0]).value.string
							IpAddress = (($node.member)[1]).value.string
							Type = (($node.member)[2]).value.string
							Summary = (($node.member)[3]).value.string
							LastModified = ([datetime]'1970-01-01 00:00:00').AddSeconds([bigint]((($node.member)[4]).value.InnerText))
							VersionTimestamp = (($node.member)[5]).value.int
							PageName = ($PageName -split ":")[-1]
							ParentNamespace = ($PageName -split ":")[-2]
							RootNamespace = ($PageName -split ":")[0]
						}
						$PageObject.PSObject.TypeNames.Insert(0, "DokuWiki.Page")
						$PageObject.PSObject.TypeNames.Insert(0, "DokuWiki.Page.Version")
						$PageObject
					}
				} elseif ($null -eq $APIResponse.ExceptionMessage) {
					Write-Error "Fault code: $($APIResponse.FaultCode) - Fault string: $($APIResponse.FaultString)"
				} else {
					Write-Error "Exception: $($APIResponse.ExceptionMessage)"
				}
			} # should process
		} # foreach
	} # process

	end {

	} # end
}