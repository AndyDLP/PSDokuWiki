﻿function Search-DokuWiki {
<#
	.SYNOPSIS
		Search DokuWiki instance for matching pages

	.DESCRIPTION
		Returns an array of matching pages similar to what is returned by Get-DokuPageList, snippets are provided for the first 15 results

	.PARAMETER SearchString
		The search string to match pages against, see 'https://www.dokuwiki.org/search' for syntax details

	.EXAMPLE
		PS C:\> $MatchingPages = Search-DokuWiki -SearchString "VSS Admin"

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
				   ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
				   HelpMessage = 'The search string to match pages against')]
		[ValidateNotNullOrEmpty()]
		[string[]]$SearchString
	)

	begin {

	} # begin

	process {
		foreach ($string in $SearchString) {
			$APIResponse = Invoke-DokuApiCall -MethodName 'dokuwiki.search' -MethodParameters @($string)
			if ($APIResponse.CompletedSuccessfully -eq $true) {
				$MemberNodes = ($APIResponse.XMLPayloadResponse | Select-Xml -XPath "//struct").Node
				Write-Verbose $APIResponse.XMLPayloadResponse
				foreach ($node in $MemberNodes) {
					$PageObject = New-Object PSObject -Property @{
						FullName = (($node.member)[0]).value.string
						Score = (($node.member)[1]).value.int
						Revision = (($node.member)[2]).value.int
						ModifiedTime = (($node.member)[3]).value.int
						Size = (($node.member)[4]).value.int
						Snippet = (($node.member)[5]).value.string
						Title = (($node.member)[6]).value.string
						PageName = (((($node.member)[0]).value.string) -split ":")[-1]
						ParentNamespace = (((($node.member)[0]).value.string) -split ":")[-2]
						RootNamespace = (((($node.member)[0]).value.string) -split ":")[0]
					}
					$PageObject
				}
			} elseif ($null -eq $APIResponse.ExceptionMessage) {
				Write-Error "Fault code: $($APIResponse.FaultCode) - Fault string: $($APIResponse.FaultString)"
			} else {
				Write-Error "Exception: $($APIResponse.ExceptionMessage)"
			}
		} # foreach string in array of searchstrings
	} # process

	end {

	} # end
}