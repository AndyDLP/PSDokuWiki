function Get-DokuPageAcl {
	[CmdletBinding(SupportsShouldProcess=$True, ConfirmImpact='Low')]
	[OutputType([psobject])]
	param
	(
		[Parameter(Mandatory = $true,
				   Position = 1,
				   ValueFromPipeline = $true,
				   ValueFromPipelineByPropertyName = $true,
				   HelpMessage = 'The full page name for which to return the ACL')]
		[ValidateNotNullOrEmpty()]
		[string[]]$FullName
	)

	begin {

	} # begin

	process {
		foreach ($PageName in $FullName) {
			if ($PSCmdlet.ShouldProcess("Get ACLs for page: $PageName")) {
				$APIResponse = Invoke-DokuApiCall -MethodName 'wiki.aclCheck' -MethodParameters @($PageName)
				if ($APIResponse.CompletedSuccessfully -eq $true) {
					$PageObject = [PSCustomObject]@{
						FullName = $PageName
						Acl = [int]($APIResponse.XMLPayloadResponse  | Select-Xml -XPath "//value/int").Node.InnerText
						PageName = ($PageName -split ":")[-1]
						ParentNamespace = ($PageName -split ":")[-2]
						RootNamespace = ($PageName -split ":")[0]
					}
					$PageObject.PSObject.TypeNames.Insert(0, "DokuWiki.Page")
					$PageObject.PSObject.TypeNames.Insert(0, "DokuWiki.Page.Acl")
					$PageObject
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