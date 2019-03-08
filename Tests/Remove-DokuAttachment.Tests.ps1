Describe 'Remove-DokuAttachment' {
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
            Remove-DokuAttachment -FullName 'rootns:nsattachment.txt' -Confirm:$false -ErrorAction SilentlyContinue -ErrorVariable DokuErrorVariable
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
            Remove-DokuAttachment -FullName 'rootns:nsattachment.txt' -Confirm:$false -ErrorAction SilentlyContinue -ErrorVariable DokuErrorVariable
            $DokuErrorVariable.exception.message | Should -Be 'Fault code: 12345 - Fault string: Fault String'
        }
    }
    Context 'When one attachment is removed' {
        Mock Invoke-DokuApiCall -ModuleName PSDokuWiki  {
            return (
                [PSCustomObject]@{
                    CompletedSuccessfully = $true
                    XMLPayloadResponse = '<?xml version="1.0"?><methodResponse><params></param></params></methodResponse>'
                }
            )
        }

        It 'Should return nothing' {
            Remove-DokuAttachment -FullName 'rootns:nsattachment.txt' -Confirm:$false | Should -BeNullOrEmpty
        }
        It 'Should not throw with ErrorAction Stop' {
            { Remove-DokuAttachment -FullName 'rootns:nsattachment.txt' -Confirm:$false -ErrorAction Stop } | Should -Not -Throw
        }
    }
    Context 'When two attachments are removed' {
        Mock Invoke-DokuApiCall -ModuleName PSDokuWiki  {
            return (
                [PSCustomObject]@{
                    CompletedSuccessfully = $true
                    XMLPayloadResponse = '<?xml version="1.0"?><methodResponse><params></param></params></methodResponse>'
                }
            )
        }

        It 'Should return nothing' {
            Remove-DokuAttachment -FullName 'rootns:nsattachment.txt','rootns:nsattachment2.txt' -Confirm:$false | Should -BeNullOrEmpty
        }
        It 'Should not throw with ErrorAction Stop' {
            { Remove-DokuAttachment -FullName 'rootns:nsattachment.txt','rootns:nsattachment2.txt' -Confirm:$false -ErrorAction Stop } | Should -Not -Throw
        }
        It 'Should call Invoke-DokuApiCall twice' {
            Remove-DokuAttachment -FullName 'rootns:nsattachment.txt','rootns:nsattachment2.txt' -Confirm:$false
            Assert-MockCalled -CommandName Invoke-DokuApiCall -ModuleName PSDokuWiki -Exactly -Times 2 -Scope It
        }
    }
    Context 'When two attachments are piped to it' {
        Mock Invoke-DokuApiCall -ModuleName PSDokuWiki  {
            return (
                [PSCustomObject]@{
                    CompletedSuccessfully = $true
                    XMLPayloadResponse = '<?xml version="1.0"?><methodResponse><params></param></params></methodResponse>'
                }
            )
        }

        It 'Should return nothing' {
            'rootns:nsattachment.txt','rootns2:ns2attachment.txt2' | Remove-DokuAttachment -Confirm:$false | Should -BeNullOrEmpty
        }
        It 'Should not throw with ErrorAction Stop' {
            { 'rootns:nsattachment.txt','rootns2:ns2attachment.txt2' | Remove-DokuAttachment -Confirm:$false -ErrorAction Stop } | Should -Not -Throw
        }
        It 'Should call Invoke-DokuApiCall twice' {
            'rootns:nsattachment.txt','rootns2:ns2attachment.txt2' | Remove-DokuAttachment -Confirm:$false
            Assert-MockCalled -CommandName Invoke-DokuApiCall -ModuleName PSDokuWiki -Exactly -Times 2 -Scope It
        }
    }
}