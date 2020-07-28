Describe 'Remove-DokuPage' {
    Set-StrictMode -Version latest
    Context 'When the Invoke-DokuApiCall command fails' {
        It 'Should display the exception message' {
            Mock Invoke-DokuApiCall -ModuleName PSDokuWiki {
                return (
                    [PSCustomObject]@{
                        CompletedSuccessfully = $false
                        ExceptionMessage      = 'Test Exception'
                    }
                )
            }
            Remove-DokuPage -FullName 'rootns:ns:pagename' -SummaryText 'Summary' -Confirm:$False -ErrorAction SilentlyContinue -ErrorVariable DokuErrorVariable
            $DokuErrorVariable.exception.message | Should -Be 'Exception: Test Exception'
        }
        It 'Should display the fault code & string' {
            Mock Invoke-DokuApiCall -ModuleName PSDokuWiki {
                return (
                    [PSCustomObject]@{
                        CompletedSuccessfully = $false
                        FaultCode             = 12345
                        FaultString           = 'Fault String'
                    }
                )
            }
            Remove-DokuPage -FullName 'rootns:ns:pagename'  'Summary' -Confirm:$False -ErrorAction SilentlyContinue -ErrorVariable DokuErrorVariable
            $DokuErrorVariable.exception.message | Should -Be 'Fault code: 12345 - Fault string: Fault String'
        }
    }
    Context 'When the Invoke-DokuApiCall method works, but fails for another reason' {
        InModuleScope PSDokuWiki {
            $Script:DokuServer = [PSCustomObject]@{ Server = 'wiki.example.com' }
            Mock Invoke-DokuApiCall {
                return (
                    [PSCustomObject]@{
                        CompletedSuccessfully = $true
                        XMLPayloadResponse    = '<?xml version="1.0"?><methodResponse><params><param><value><boolean>0</boolean></value></param></params></methodResponse>'
                    }
                )
            }
            It 'Should generate an error' {
                Remove-DokuPage -FullName 'rootns:ns:pagename' -SummaryText 'Summary' -Confirm:$False -ErrorAction SilentlyContinue -ErrorVariable DokuErrorVariable
                $DokuErrorVariable.exception.message | Should -Be 'Failed to set page data'
            }
        }
    }
    Context 'When the page data is removed successfully' {
        InModuleScope PSDokuWiki {
            $Script:DokuServer = [PSCustomObject]@{ Server = 'wiki.example.com' }
            Mock Invoke-DokuApiCall {
                return (
                    [PSCustomObject]@{
                        CompletedSuccessfully = $true
                        XMLPayloadResponse    = '<?xml version="1.0"?><methodResponse><params><param><value><boolean>1</boolean></value></param></params></methodResponse>'
                    }
                )
            }
            It 'Should not throw' {
                { Remove-DokuPage -FullName 'rootns:ns:pagename' -SummaryText 'Summary' -Confirm:$False } | Should -Not -Throw
            }
            It 'Should not return anything' {
                Remove-DokuPage -FullName 'rootns:ns:pagename'  -SummaryText 'Summary' -Confirm:$False | Should -BeNullOrEmpty
            }
        }
    }
    Context 'When page data is removed for two pages' {
        InModuleScope PSDokuWiki {
            $Script:DokuServer = [PSCustomObject]@{ Server = 'wiki.example.com' }
            Mock Invoke-DokuApiCall {
                return (
                    [PSCustomObject]@{
                        CompletedSuccessfully = $true
                        XMLPayloadResponse    = '<?xml version="1.0"?><methodResponse><params><param><value><boolean>1</boolean></value></param></params></methodResponse>'
                    }
                )
            }
            It 'Should call Invoke-DokuApiCall twice' {
                Remove-DokuPage -FullName 'rootns:ns:pagename', 'rootns2:ns2:pagename2' -SummaryText 'Summary' -Confirm:$False
                Assert-MockCalled -CommandName Invoke-DokuApiCall -ModuleName PSDokuWiki -Exactly -Times 2
            }
        }
    }
}