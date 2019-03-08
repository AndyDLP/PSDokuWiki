Describe 'Remove-DokuUser' {
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
            Remove-DokuUser -Username 'User1'  -Confirm:$false -ErrorAction SilentlyContinue -ErrorVariable DokuErrorVariable
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
            Remove-DokuUser -Username 'User1'  -Confirm:$false -ErrorAction SilentlyContinue -ErrorVariable DokuErrorVariable
            $DokuErrorVariable.exception.message | Should -Be 'Fault code: 12345 - Fault string: Fault String'
        }
    }
    Context 'When one user is removed' {
        Mock Invoke-DokuApiCall -ModuleName PSDokuWiki  {
            return (
                [PSCustomObject]@{
                    CompletedSuccessfully = $true
                    XMLPayloadResponse = '<?xml version="1.0"?><methodResponse><params><param><value><boolean>1</boolean></value></param></params></methodResponse>'
                }
            )
        }

        It 'Should return nothing' {
            Remove-DokuUser -Username 'User1'  -Confirm:$false | Should -BeNullOrEmpty
        }
        It 'Should not throw with ErrorAction Stop' {
            { Remove-DokuUser -Username 'User1'  -Confirm:$false -ErrorAction Stop } | Should -Not -Throw
        }
    }
    Context 'When two users are removed' {
        Mock Invoke-DokuApiCall -ModuleName PSDokuWiki  {
            return (
                [PSCustomObject]@{
                    CompletedSuccessfully = $true
                    XMLPayloadResponse = '<?xml version="1.0"?><methodResponse><params><param><value><boolean>1</boolean></value></param></params></methodResponse>'
                }
            )
        }

        It 'Should return nothing' {
            Remove-DokuUser -Username 'User1','User2' -Confirm:$false | Should -BeNullOrEmpty
        }
        It 'Should not throw with ErrorAction Stop' {
            { Remove-DokuUser -Username 'User1' ,'User2' -Confirm:$false -ErrorAction Stop } | Should -Not -Throw
        }
        It 'Should call Invoke-DokuApiCall twice' {
            Remove-DokuUser -Username 'User1' ,'User2' -Confirm:$false
            Assert-MockCalled -CommandName Invoke-DokuApiCall -ModuleName PSDokuWiki -Exactly -Times 2 -Scope It
        }
    }
    Context 'When two users are piped to it' {
        Mock Invoke-DokuApiCall -ModuleName PSDokuWiki  {
            return (
                [PSCustomObject]@{
                    CompletedSuccessfully = $true
                    XMLPayloadResponse = '<?xml version="1.0"?><methodResponse><params><param><value><boolean>1</boolean></value></param></params></methodResponse>'
                }
            )
        }

        It 'Should return nothing' {
            'User1', 'User2' | Remove-DokuUser -Confirm:$false | Should -BeNullOrEmpty
        }
        It 'Should not throw with ErrorAction Stop' {
            { 'User1', 'User2' | Remove-DokuUser -Confirm:$false -ErrorAction Stop } | Should -Not -Throw
        }
        It 'Should call Invoke-DokuApiCall twice' {
            'User1', 'User2' | Remove-DokuUser -Confirm:$false
            Assert-MockCalled -CommandName Invoke-DokuApiCall -ModuleName PSDokuWiki -Exactly -Times 2 -Scope It
        }
    }
}