Describe 'Remove-DokuAclRule' {
    Set-StrictMode -Version latest
    Context 'When the Invoke-DokuApiCall command fails' {
        It 'Should display the exception message' {
            Mock Invoke-DokuApiCall -ModuleName PSDokuWiki {
                return (
                    [PSCustomObject]@{
                        CompletedSuccessfully = $false
                        ExceptionMessage = 'Test Exception'
                    }
                )
            }
            Remove-DokuAclRule -FullName 'rootns:ns:pagename' -Principal 'User1' -Confirm:$false -ErrorAction SilentlyContinue -ErrorVariable DokuErrorVariable
            $DokuErrorVariable.exception.message | Should -Be 'Exception: Test Exception'
        }
        It 'Should display the fault code & string' {
            Mock Invoke-DokuApiCall -ModuleName PSDokuWiki {
                return (
                    [PSCustomObject]@{
                        CompletedSuccessfully = $false
                        FaultCode = 12345
                        FaultString = 'Fault String'
                    }
                )
            }
            Remove-DokuAclRule -FullName 'rootns:ns:pagename' -Principal 'User1' -Confirm:$false -ErrorAction SilentlyContinue -ErrorVariable DokuErrorVariable
            $DokuErrorVariable.exception.message | Should -Be 'Fault code: 12345 - Fault string: Fault String'
        }
    }
    Context 'When the ACL is removed from one page for one user' {
        Mock Invoke-DokuApiCall -ModuleName PSDokuWiki  {
            return (
                [PSCustomObject]@{
                    CompletedSuccessfully = $true
                    XMLPayloadResponse = '<?xml version="1.0"?><methodResponse><params><param><value><boolean>1</boolean></value></param></params></methodResponse>'
                }
            )
        }

        It 'Should return nothing' {
            Remove-DokuAclRule -FullName 'rootns:ns:pagename' -Principal 'User1' -Confirm:$false | Should -BeNullOrEmpty
        }
        It 'Should not throw with ErrorAction Stop' {
            { Remove-DokuAclRule -FullName 'rootns:ns:pagename' -Principal 'User1' -Confirm:$false -ErrorAction Stop } | Should -Not -Throw
        }
    }
    Context 'When the ACL is removed from one page for two users' {
        Mock Invoke-DokuApiCall -ModuleName PSDokuWiki  {
            return (
                [PSCustomObject]@{
                    CompletedSuccessfully = $true
                    XMLPayloadResponse = '<?xml version="1.0"?><methodResponse><params><param><value><boolean>1</boolean></value></param></params></methodResponse>'
                }
            )
        }

        It 'Should return nothing' {
            Remove-DokuAclRule -FullName 'rootns:ns:pagename' -Principal 'User1','User2' -Confirm:$false | Should -BeNullOrEmpty
        }
        It 'Should not throw with ErrorAction Stop' {
            { Remove-DokuAclRule -FullName 'rootns:ns:pagename' -Principal 'User1','User2' -Confirm:$false -ErrorAction Stop } | Should -Not -Throw
        }
        It 'Should call Invoke-DokuApiCall twice' {
            Remove-DokuAclRule -FullName 'rootns:ns:pagename' -Principal 'User1','User2' -Confirm:$false
            Assert-MockCalled -CommandName Invoke-DokuApiCall -ModuleName PSDokuWiki -Exactly -Times 2 -Scope It
        }
    }
    Context 'When the ACL is removed from two pages for two users' {
        Mock Invoke-DokuApiCall -ModuleName PSDokuWiki  {
            return (
                [PSCustomObject]@{
                    CompletedSuccessfully = $true
                    XMLPayloadResponse = '<?xml version="1.0"?><methodResponse><params><param><value><boolean>1</boolean></value></param></params></methodResponse>'
                }
            )
        }

        It 'Should return nothing' {
            Remove-DokuAclRule -FullName 'rootns:ns:pagename','rootns2:ns2:pagename2' -Principal 'User1','User2' -Confirm:$false | Should -BeNullOrEmpty
        }
        It 'Should not throw with ErrorAction Stop' {
            { Remove-DokuAclRule -FullName 'rootns:ns:pagename','rootns2:ns2:pagename2' -Principal 'User1','User2' -Confirm:$false -ErrorAction Stop } | Should -Not -Throw
        }
        It 'Should call Invoke-DokuApiCall four times' {
            Remove-DokuAclRule -FullName 'rootns:ns:pagename','rootns2:ns2:pagename2' -Principal 'User1','User2' -Confirm:$false
            Assert-MockCalled -CommandName Invoke-DokuApiCall -ModuleName PSDokuWiki -Exactly -Times 4 -Scope It
        }
    }
}