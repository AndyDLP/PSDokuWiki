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
    Context 'When a page is locked successfully' {
        Mock Invoke-DokuApiCall -ModuleName PSDokuWiki {
            return (
                [PSCustomObject]@{
                    CompletedSuccessfully = $true
                    XMLPayloadResponse = '<?xml version="1.0"?><methodResponse><params><param><value><array><data><value><array><data><value><string>rootns:ns:pagename</string></value></data></array><array><data></data></array><array><data></data></array><array><data></data></array><array><data></data></array></value></data></array></value></param></params></methodResponse>'
                }
            )
        }
        It 'Should not throw' {
            { Lock-DokuPage -FullName 'rootns:ns:pagename' -ErrorAction Stop -Verbose} | Should -Not -Throw
        }
    }
    Context 'When a page fails to lock' {
        Mock Invoke-DokuApiCall -ModuleName PSDokuWiki {
            return (
                [PSCustomObject]@{
                    CompletedSuccessfully = $true
                    XMLPayloadResponse = '<?xml version="1.0"?><methodResponse><params><param><value><array><data><value><array><data></data></array><array><data><value><string>rootns:ns:pagename</string></value></data></array><array><data></data></array><array><data></data></array><array><data></data></array></value></data></array></value></param></params></methodResponse>'
                }
            )
        }
        It 'Should throw an error' {
            { Lock-DokuPage -FullName 'rootns:ns:pagename' -ErrorAction Stop -Verbose} | Should -Not -Throw
        }
    }
}