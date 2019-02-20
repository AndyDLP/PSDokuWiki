function Add-DokuAclRule {
    <#
	.SYNOPSIS
		Add an ACL to a namespace or page

	.DESCRIPTION
		Add an ACL to a namespace or page. Use @groupname instead of user to add an ACL rule for a group.

	.PARAMETER FullName
		The full name of the scope to apply to ACL to, can be one or more namespaces or a pages.

	.PARAMETER Principal
		The username or @groupname to add to the ACL

	.PARAMETER Acl
		The permission level to apply to the user or @group
		Pages / Namespaces: 0 = None, 1 = Read, 2 = Edit
		Namespaces only:    4 = Create, 8 = Upload, 16 = Delete

	.EXAMPLE
		PS C:\> Add-DokuAclRule -FullName 'study:home' -Principal 'testuser' -Acl 2
		Add the Edit permission to testuser to the page home in the namespace study

	.EXAMPLE
		PS C:\> "User1","User2","@group1" | Add-DokuAclRule -FullName "namespace:page1","namespace:page2","namespace2:page1" -Acl 2
		Add edit permissions for User1, User2 & group1 to the three pages; namespace:page1, namespace:page2 & namespace2:page1

	.EXAMPLE
		PS C:\> Add-DokuAclRule -FullName "namespace:page1","namespace:page2","namespace2:page1" -Acl 8 -Debug -Principal "User1","User2","@group1"
		Same as above, but with an array of usernames (strings) for the parameter 'Principal'

	.OUTPUTS
		None

	.NOTES
		AndyDLP - 2018-05-26

	.LINK
		https://github.com/AndyDLP/PSDokuWiki
#>

    [CmdletBinding(PositionalBinding = $true)]
    param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
			ValueFromPipelineByPropertyName=$true,
            Position = 1,
            HelpMessage = 'The full name of the scope to apply to ACL to')]
        [ValidateNotNullOrEmpty()]
        [string[]]$FullName,
        [Parameter(Mandatory = $true,
            Position = 2,
            HelpMessage = 'The username or @groupname to add to the ACL')]
        [ValidateNotNullOrEmpty()]
        [string[]]$Principal,
        [Parameter(Mandatory = $true,
            Position = 3,
            HelpMessage = 'The permission level to apply to the ACL as an integer')]
        [ValidateNotNullOrEmpty()]
        [int]$Acl
    )

    begin {
        
    } # begin

    process {
        foreach ($page in $FullName) {
            Write-Verbose "Page name: $page"
            foreach ($Name in $Principal) {
                Write-Verbose "Principal name: $Name"
                $APIResponse = Invoke-DokuApiCall -MethodName 'plugin.acl.addAcl' -MethodParameters @($page,$Name,$Acl) -ErrorAction 'Stop'
                if ($APIResponse.CompletedSuccessfully -eq $true) {
                    [bool]$ReturnValue = ($APIResponse.XMLPayloadResponse | Select-Xml -XPath "//value/boolean").Node.InnerText
                    if ($ReturnValue -eq $false) {
                        # error code generated = Fail
                        Write-Error "Failed to apply Acl: $Acl for user: $Principal to entity: $Fullname"
                    } else {
                        # it worked! no news = good news
                        Write-Verbose "Successfully applied Acl: $Acl for user: $Principal to entity: $Fullname"
                    }
                } elseif ($null -eq $APIResponse.ExceptionMessage) {
                    Write-Error "Fault code: $($APIResponse.FaultCode) - Fault string: $($APIResponse.FaultString)"
                } else {
                    Write-Error "Exception: $($APIResponse.ExceptionMessage)"
                }
            } # foreach principal
        } # foreach page
    } # process

    end {
        
    } # end
}
