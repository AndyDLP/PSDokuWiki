Describe 'Unlock-DokuPage' {
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
            Unlock-DokuPage -FullName 'rootns:ns:pagename' -ErrorAction SilentlyContinue -ErrorVariable DokuErrorVariable
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
            Unlock-DokuPage -FullName 'rootns:ns:pagename' -ErrorAction SilentlyContinue -ErrorVariable DokuErrorVariable
            $DokuErrorVariable.exception.message | Should -Be 'Fault code: 12345 - Fault string: Fault String'
        }
    }
    Context 'When a page fails to unlock' {
        Mock Invoke-DokuApiCall -ModuleName PSDokuWiki {
            return (
                [PSCustomObject]@{
                    CompletedSuccessfully = $true
                    XMLPayloadResponse = '<?xml version="1.0"?><methodResponse><params><param><value><struct><member><name>locked</name><value><array><data></data></array></value></member><member><name>lockfail</name><value><array><data></data></array></value></member><member><name>unlocked</name><value><array><data></data></array></value></member><member><name>unlockfail</name><value><array><data><value><string>rootns:ns:pagename</string></value></data></array></value></member></struct></value></param></params></methodResponse>'
                }
            )
        }
        It 'Should throw an error' {
            { Unlock-DokuPage -FullName 'rootns:ns:pagename' -ErrorAction Stop } | Should -Throw
        }
    }
    Context 'When a page is unlocked successfully' {
        Mock Invoke-DokuApiCall -ModuleName PSDokuWiki {
            return (
                [PSCustomObject]@{
                    CompletedSuccessfully = $true
                    XMLPayloadResponse = '<?xml version="1.0"?><methodResponse><params><param><value><struct><member><name>locked</name><value><array><data></data></array></value></member><member><name>lockfail</name><value><array><data></data></array></value></member><member><name>unlocked</name><value><array><data><value><string>rootns:ns:pagename</string></value></data></array></value></member><member><name>unlockfail</name><value><array><data></data></array></value></member></struct></value></param></params></methodResponse>'
                }
            )
        }
        It 'Should not throw' {
            { Unlock-DokuPage -FullName 'rootns:ns:pagename' -ErrorAction Stop } | Should -Not -Throw
        }
    }
    Context 'When two pages are unlocked successfully' {
        Mock Invoke-DokuApiCall -ModuleName PSDokuWiki {
            return (
                [PSCustomObject]@{
                    CompletedSuccessfully = $true
                    XMLPayloadResponse = '<?xml version="1.0"?><methodResponse><params><param><value><struct><member><name>locked</name><value><array><data></data></array></value></member><member><name>lockfail</name><value><array><data></data></array></value></member><member><name>unlocked</name><value><array><data><value><string>rootns:ns:pagename</string></value><value><string>rootns:ns:pagename</string></value></data></array></value></member><member><name>unlockfail</name><value><array><data></data></array></value></member></struct></value></param></params></methodResponse>'
                }
            )
        }
        It '' {
            Unlock-DokuPage -FullName 'rootns:ns:pagename','rootns:ns:pagename'
            Assert-MockCalled -CommandName Invoke-DokuApiCall -ModuleName PSDokuWiki -Exactly -Times 1
        }
    }
    Context 'When two pages are unlocked successfully by piping' {
        Mock Invoke-DokuApiCall -ModuleName PSDokuWiki {
            return (
                [PSCustomObject]@{
                    CompletedSuccessfully = $true
                    XMLPayloadResponse = '<?xml version="1.0"?><methodResponse><params><param><value><struct><member><name>locked</name><value><array><data></data></array></value></member><member><name>lockfail</name><value><array><data></data></array></value></member><member><name>unlocked</name><value><array><data><value><string>rootns:ns:pagename</string></value></data></array></value></member><member><name>unlockfail</name><value><array><data></data></array></value></member></struct></value></param></params></methodResponse>'
                }
            )
        }
        It 'Should only call Invoke-DokuApiCall onceShould call Invoke-DokuApiCall twice' {
            'rootns:ns:pagename','rootns:ns:pagename' | Unlock-DokuPage
            Assert-MockCalled -CommandName Invoke-DokuApiCall -ModuleName PSDokuWiki -Exactly -Times 2
        }
    }
}