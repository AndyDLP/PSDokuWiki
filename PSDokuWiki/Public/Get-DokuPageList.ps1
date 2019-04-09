function Get-DokuPageList {
	[CmdletBinding()]
	[OutputType([psobject[]])]
	param ()

	begin {

	} # begin

	process {
		$APIResponse = Invoke-DokuApiCall -MethodName 'dokuwiki.getPagelist' -MethodParameters @()
		if ($APIResponse.CompletedSuccessfully -eq $true) {
			$MemberNodes = ($APIResponse.XMLPayloadResponse | Select-Xml -XPath "//struct").Node
			foreach ($node in $MemberNodes) {
				$PageObject = [PSCustomObject]@{
					FullName = (($node.member)[0]).value.string
					Revision = (($node.member)[1]).value.int
					LastModified = (($node.member)[2]).value.int
					Size = (($node.member)[3]).value.int
					PageName = (((($node.member)[0]).value.string) -split ":")[-1]
					ParentNamespace = (((($node.member)[0]).value.string) -split ":")[-2]
					RootNamespace = (((($node.member)[0]).value.string) -split ":")[0]
				}
                $PageObject.PSObject.TypeNames.Insert(0, "DokuWiki.Page")
				$PageObject
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