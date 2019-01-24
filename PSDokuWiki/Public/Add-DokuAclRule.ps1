function Add-DokuAclRule {
    <#
	.SYNOPSIS
		Add an ACL to a namespace or page

	.DESCRIPTION
		Add an ACL to a namespace or page. Use @groupname instead of user to add an ACL rule for a group.

	.PARAMETER DokuSession
		The DokuSession in which to make the ACL changes

	.PARAMETER FullName
		The full name of the scope to apply to ACL to, can be one or more namespaces or a pages.

	.PARAMETER Principal
		The username or @groupname to add to the ACL

	.PARAMETER Acl
		The permission level to apply to the user or @group
		Pages / Namespaces: 0 = None, 1 = Read, 2 = Edit
		Namespaces only:    4 = Create, 8 = Upload, 16 = Delete

	.EXAMPLE
		PS C:\> Add-DokuAclRule -DokuSession $DokuSession -FullName 'study:home' -Principal 'testuser' -Acl 2
		Add the Edit permission to testuser to the page home in the namespace study

	.EXAMPLE
		PS C:\> "User1","User2","@group1" | Add-DokuAclRule -DokuSession $DokuSession -FullName "namespace:page1","namespace:page2","namespace2:page1" -Acl 2
		Add edit permissions for User1, User2 & group1 to the three pages; namespace:page1, namespace:page2 & namespace2:page1

	.EXAMPLE
		PS C:\> Add-DokuAclRule -DokuSession $dokuSesson -FullName "namespace:page1","namespace:page2","namespace2:page1" -Acl 8 -Debug -Principal "User1","User2","@group1"
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
            Position = 1,
            HelpMessage = 'The DokuSession in which to make the ACL changes')]
        [ValidateNotNullOrEmpty()]
        [psobject]$DokuSession,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
			ValueFromPipelineByPropertyName=$true,
            Position = 2,
            HelpMessage = 'The full name of the scope to apply to ACL to')]
        [ValidateNotNullOrEmpty()]
        [string[]]$FullName,
        [Parameter(Mandatory = $true,
            Position = 3,
            HelpMessage = 'The username or @groupname to add to the ACL')]
        [ValidateNotNullOrEmpty()]
        [string[]]$Principal,
        [Parameter(Mandatory = $true,
            Position = 4,
            HelpMessage = 'The permission level to apply to the ACL as an integer')]
        [ValidateNotNullOrEmpty()]
        [int]$Acl
    )

    begin {

    } # begin

    process {
        foreach ($page in $FullName) {
            Write-Debug "Page name: $page"
            foreach ($Name in $Principal) {
                Write-Debug "Principal name: $Name"
                $httpResponse = Invoke-DokuApiCall -DokuSession $DokuSession -MethodName plugin.acl.addAcl -MethodParameters @($page,$Name,$Acl)

                [bool]$ReturnValue = ([xml]$httpResponse.Content | Select-Xml -XPath "//value/boolean").Node.InnerText
                if ($ReturnValue -eq $false) {
                    # error code generated = Fail
                    Write-Error "Error: $ReturnValue - $($httpResponse.content)"
                } else {
                    # it worked!
                }
            } # foreach principal
        } # foreach page
    } # process

    end {

    } # end
}
