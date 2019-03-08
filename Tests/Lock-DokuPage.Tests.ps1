Describe 'Lock-DokuPage' {
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
            Lock-DokuPage -FullName 'rootns:ns:pagename' -ErrorAction SilentlyContinue -ErrorVariable DokuErrorVariable
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
            Lock-DokuPage -FullName 'rootns:ns:pagename' -ErrorAction SilentlyContinue -ErrorVariable DokuErrorVariable
            $DokuErrorVariable.exception.message | Should -Be 'Fault code: 12345 - Fault string: Fault String'
        }
    }
    Context 'When a page fails to lock' {
        Mock Invoke-DokuApiCall -ModuleName PSDokuWiki {
            return (
                [PSCustomObject]@{
                    CompletedSuccessfully = $true
                    XMLPayloadResponse = '<?xml version="1.0"?><methodResponse><params><param><value><struct><member><name>locked</name><value><array><data></data></array></value></member><member><name>lockfail</name><value><array><data><value><string>start:testpage</string></value></data></array></value></member><member><name>unlocked</name><value><array><data></data></array></value></member><member><name>unlockfail</name><value><array><data></data></array></value></member></struct></value></param></params></methodResponse>'
                }
            )
        }
        It 'Should throw an error' {
            { Lock-DokuPage -FullName 'rootns:ns:pagename' -ErrorAction Stop } | Should -Throw
        }
    }
    Context 'When a page is locked successfully' {
        Mock Invoke-DokuApiCall -ModuleName PSDokuWiki {
            return (
                [PSCustomObject]@{
                    CompletedSuccessfully = $true
                    XMLPayloadResponse = '<?xml version="1.0"?><methodResponse><params><param><value><struct><member><name>locked</name><value><array><data><value><string>start:testpage</string></value></data></array></value></member><member><name>lockfail</name><value><array><data></data></array></value></member><member><name>unlocked</name><value><array><data></data></array></value></member><member><name>unlockfail</name><value><array><data></data></array></value></member></struct></value></param></params></methodResponse>'
                }
            )
        }
        It 'Should not throw' {
            { Lock-DokuPage -FullName 'rootns:ns:pagename' -ErrorAction Stop } | Should -Not -Throw
        }
    }
    Context 'When two pages are locked successfully' {
        Mock Invoke-DokuApiCall -ModuleName PSDokuWiki {
            return (
                [PSCustomObject]@{
                    CompletedSuccessfully = $true
                    XMLPayloadResponse = '<?xml version="1.0"?><methodResponse><params><param><value><struct><member><name>locked</name><value><array><data><value><string>start:testpage</string></value><value><string>start:testpage</string></value></data></array></value></member><member><name>lockfail</name><value><array><data></data></array></value></member><member><name>unlocked</name><value><array><data></data></array></value></member><member><name>unlockfail</name><value><array><data></data></array></value></member></struct></value></param></params></methodResponse>'
                }
            )
        }
        It 'Should only call Invoke-DokuApiCall once' {
            Lock-DokuPage -FullName 'rootns:ns:pagename','rootns:ns:pagename'
            Assert-MockCalled -CommandName Invoke-DokuApiCall -ModuleName PSDokuWiki -Exactly -Times 1
        }
    }
}