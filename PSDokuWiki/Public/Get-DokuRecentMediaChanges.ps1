function Get-DokuRecentMediaChanges {
<#
	.SYNOPSIS
		Returns a list of recently changed media since given timestamp

	.DESCRIPTION
		Returns a list of recently changed media since given timestamp

	.PARAMETER VersionTimestamp
		Get all media / attachment changes since this timestamp

	.EXAMPLE
		PS C:\> Get-DokuRecentMediaChanges -VersionTimestamp $VersionTimestamp

	.OUTPUTS
		System.Management.Automation.PSObject[]

	.NOTES
		AndyDLP - 2018-05-26
#>

	[CmdletBinding(PositionalBinding = $true)]
	[OutputType([psobject[]])]
	param
	(
		[Parameter(Mandatory = $true,
				   Position = 2,
				   ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
				   HelpMessage = 'Get all media / attachment changes since this timestamp')]
		[ValidateNotNullOrEmpty()]
		[int]$VersionTimestamp
	)

	begin {

	} # begin

	process {
		$APIResponse = Invoke-DokuApiCall -MethodName 'wiki.getRecentMediaChanges' -MethodParameters @($VersionTimestamp)
		if ($APIResponse.CompletedSuccessfully -eq $true) {
			$MemberNodes = ($APIResponse.XMLPayloadResponse | Select-Xml -XPath "//struct").Node
			foreach ($node in $MemberNodes) {
				$ChangeObject = New-Object PSObject -Property @{
					FullName = (($node.member)[0]).value.innertext
					LastModified = Get-Date -Date ((($node.member)[1]).value.innertext)
					Author = (($node.member)[2]).value.innertext
					VersionTimestamp = (($node.member)[3]).value.innertext
					Permissions = (($node.member)[4]).value.innertext
					Size = (($node.member)[5]).value.innertext
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