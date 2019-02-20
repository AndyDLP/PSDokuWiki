function Get-DokuTitle {
<#
	.SYNOPSIS
		Returns the title of the wiki

	.DESCRIPTION
		Returns the title of the wiki

	.EXAMPLE
		PS C:\> $DokuTitleObj = Get-DokuTitle

	.OUTPUTS
		System.Management.Automation.PSObject

	.NOTES
		AndyDLP - 2018-05-26
#>

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