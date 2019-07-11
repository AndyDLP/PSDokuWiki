function Add-DokuAclRule {
    [CmdletBinding(PositionalBinding = $true, SupportsShouldProcess=$True, ConfirmImpact='Medium')]
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
        [Parameter(Mandatory = $false,
            Position = 4,
            HelpMessage = 'Bypass confirmations of calls during this connect/disconnect session')]
        [ValidateNotNullOrEmpty()]
        [switch]$BypassConfirm
    )

    begin {}

    process {
        foreach ($page in $FullName) {
            Write-Verbose "Page name: $page"
            foreach ($Name in $Principal) {
                if ($BypassConfirm -or $PSCmdlet.ShouldProcess("Give user: $Name a permission level of: $Acl to page: $Page")) {
                    Write-Verbose "Principal name: $Name"
                    $APIResponse = Invoke-DokuApiCall -MethodName 'plugin.acl.addAcl' -MethodParameters @($page,$Name,$Acl) -ErrorAction 'Stop'
                    if ($APIResponse.CompletedSuccessfully -eq $true) {
                        # Doesn't want to cast (string) '1' to true... so we cast to int to bool
                        [bool]$ReturnValue = [int](($APIResponse.XMLPayloadResponse | Select-Xml -XPath "//value/boolean").Node.InnerText)
                        if ($ReturnValue -eq $false) {
                            Write-Error "Failed to apply Acl: $Acl for user: $Principal to entity: $Fullname"
                        } else {
                            Write-Verbose "Successfully applied Acl: $Acl for user: $Principal to entity: $Fullname"
                        }
                    } elseif ($null -eq $APIResponse.ExceptionMessage) {
                        Write-Error "Fault code: $($APIResponse.FaultCode) - Fault string: $($APIResponse.FaultString)"
                    } else {
                        Write-Error "Exception: $($APIResponse.ExceptionMessage)"
                    }
                }
            } # foreach principal
        } # foreach page
    } # process

    end {}
}
