Describe 'Add-DokuAclRule' {
    Context 'When the Invoke-DokuApiCall command fails' {
        Set-StrictMode -Version latest
        InModuleScope PSDokuWiki {
            It 'Should display the exception message' {
                Mock Invoke-DokuApiCall {
                    return (
                        [PSCustomObject]@{
                            CompletedSuccessfully = $false
                            ExceptionMessage = 'Test Exception'
                        }
                    )
                }
                Add-DokuAclRule -FullName "namespace:pagename" -Principal "username" -Acl 2 -ErrorAction SilentlyContinue -ErrorVariable DokuErrorVariable
                $DokuErrorVariable.exception.message | Should -Be 'Exception: Test Exception'
            }
            It 'Should display the fault code & string' {
                Mock Invoke-DokuApiCall {
                    return (
                        [PSCustomObject]@{
                            CompletedSuccessfully = $false
                            FaultCode = 12345
                            FaultString = 'Fault String'
                        }
                    )
                }
                Add-DokuAclRule -FullName "namespace:pagename" -Principal "username" -Acl 2 -ErrorAction SilentlyContinue -ErrorVariable DokuErrorVariable
                $DokuErrorVariable.exception.message | Should -Be 'Fault code: 12345 - Fault string: Fault String'
            }
            It 'Should identify if the method call failed' {
                Mock Invoke-DokuApiCall {
                    return (
                        [PSCustomObject]@{
                            CompletedSuccessfully = $true
                            XMLPayloadResponse = [xml]'<?xml version="1.0"?><methodResponse><value><boolean>0</boolean></value></methodResponse>'
                        }
                    )
                }
                Add-DokuAclRule -FullName "namespace:pagename" -Principal "username" -Acl 2 -ErrorAction SilentlyContinue -ErrorVariable DokuErrorVariable
                $DokuErrorVariable.exception.message | Should -Be 'Failed to apply Acl: 2 for user: username to entity: namespace:pagename'
            }
        }
    }
    Context 'When one user is passed to one page' {
        Set-StrictMode -Version latest
        InModuleScope PSDokuWiki {
            It 'Should make one call to Invoke-DokuApiCall' {
                Mock Invoke-DokuApiCall {
                    return (
                        [PSCustomObject]@{
                            CompletedSuccessfully = $true
                            XMLPayloadResponse = [xml]'<?xml version="1.0"?><methodResponse><value><boolean>1</boolean></value></methodResponse>'
                        }
                    )
                }
                Add-DokuAclRule -FullName "namespace:pagename" -Principal "username" -Acl 2
                Assert-MockCalled -CommandName Invoke-DokuApiCall -Exactly -Times 1
            }
        }
    }
    Context 'When one user is passed to two pages' {
        Set-StrictMode -Version latest
        InModuleScope PSDokuWiki {
            It 'Should make one call to Invoke-DokuApiCall' {
                Mock Invoke-DokuApiCall {
                    return (
                        [PSCustomObject]@{
                            CompletedSuccessfully = $true
                            XMLPayloadResponse = [xml]'<?xml version="1.0"?><methodResponse><value><boolean>1</boolean></value></methodResponse>'
                        }
                    )
                }
                Add-DokuAclRule -FullName 'namespace:pagename','pagename' -Principal 'username' -Acl 2
                Assert-MockCalled -CommandName Invoke-DokuApiCall -Exactly -Times 2
            }
        }
    }
    Context 'When two users are passed to one page' {
        Set-StrictMode -Version latest
        InModuleScope PSDokuWiki {
            It 'Should make two calls to Invoke-DokuApiCall' {
                Mock Invoke-DokuApiCall {
                    return (
                        [PSCustomObject]@{
                            CompletedSuccessfully = $true
                            XMLPayloadResponse = [xml]'<?xml version="1.0"?><methodResponse><value><boolean>1</boolean></value></methodResponse>'
                        }
                    )
                }
                Add-DokuAclRule -FullName 'namespace:pagename' -Principal 'username','username2' -Acl 2
                Assert-MockCalled -CommandName Invoke-DokuApiCall -Exactly -Times 2
            }
        }
    }
    Context 'When two users are passed to two pages' {
        Set-StrictMode -Version latest
        InModuleScope PSDokuWiki {
            It 'Should make four calls to Invoke-DokuApiCall' {
                Mock Invoke-DokuApiCall {
                    return (
                        [PSCustomObject]@{
                            CompletedSuccessfully = $true
                            XMLPayloadResponse = [xml]'<?xml version="1.0"?><methodResponse><value><boolean>1</boolean></value></methodResponse>'
                        }
                    )
                }
                Add-DokuAclRule -FullName 'namespace:pagename','pagename' -Principal 'username','username2' -Acl 2
                Assert-MockCalled -CommandName Invoke-DokuApiCall -Exactly -Times 4
            }
        }
    }
}