Describe 'Set-DokuPageData' {
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
            Set-DokuPageData -FullName 'rootns:ns:pagename' -RawWikiText 'Test Data' -MinorChange -SummaryText 'Summary' -Confirm:$False -PassThru -ErrorAction SilentlyContinue -ErrorVariable DokuErrorVariable
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
            Set-DokuPageData -FullName 'rootns:ns:pagename' -RawWikiText 'Test Data' -MinorChange -SummaryText 'Summary' -Confirm:$False -PassThru -ErrorAction SilentlyContinue -ErrorVariable DokuErrorVariable
            $DokuErrorVariable.exception.message | Should -Be 'Fault code: 12345 - Fault string: Fault String'
        }
    }
    Context 'When the Invoke-DokuApiCall method works, but fails for another reason' {
        InModuleScope PSDokuWiki {
            $Script:DokuServer = [PSCustomObject]@{ Server = 'wiki.example.com' }
            Mock Invoke-DokuApiCall  {
                return (
                    [PSCustomObject]@{
                        CompletedSuccessfully = $true
                        XMLPayloadResponse = '<?xml version="1.0"?><methodResponse><params><param><value><boolean>0</boolean></value></param></params></methodResponse>'
                    }
                )
            }
            It 'Should generate an error' {
                Set-DokuPageData -FullName 'rootns:ns:pagename' -RawWikiText 'Test Data' -MinorChange -SummaryText 'Summary' -Confirm:$False -PassThru -ErrorAction SilentlyContinue -ErrorVariable DokuErrorVariable
                $DokuErrorVariable.exception.message | Should -Be 'Failed to set page data'
            }
        }
    }
    Context 'When the page data is set successfully' {
        InModuleScope PSDokuWiki {
            $Script:DokuServer = [PSCustomObject]@{ Server = 'wiki.example.com' }
            Mock Invoke-DokuApiCall  {
                return (
                    [PSCustomObject]@{
                        CompletedSuccessfully = $true
                        XMLPayloadResponse = '<?xml version="1.0"?><methodResponse><params><param><value><boolean>1</boolean></value></param></params></methodResponse>'
                    }
                )
            }
            It 'Should not throw' {
                { Set-DokuPageData -FullName 'rootns:ns:pagename' -RawWikiText 'Test Data' -MinorChange -SummaryText 'Summary' -Confirm:$False } | Should -Not -Throw
            }
            It 'Should not return anything' {
                Set-DokuPageData -FullName 'rootns:ns:pagename' -RawWikiText 'Test Data' -MinorChange -SummaryText 'Summary' -Confirm:$False | Should -BeNullOrEmpty
            }
        }
    }
    Context 'When page data is set for two pages' {
        InModuleScope PSDokuWiki {
            $Script:DokuServer = [PSCustomObject]@{ Server = 'wiki.example.com' }
            Mock Invoke-DokuApiCall  {
                return (
                    [PSCustomObject]@{
                        CompletedSuccessfully = $true
                        XMLPayloadResponse = '<?xml version="1.0"?><methodResponse><params><param><value><boolean>1</boolean></value></param></params></methodResponse>'
                    }
                )
            }
            It 'Should call Invoke-DokuApiCall twice' {
                Set-DokuPageData -FullName 'rootns:ns:pagename','rootns2:ns2:pagename2' -RawWikiText 'Test Data' -MinorChange -SummaryText 'Summary' -Confirm:$False
                Assert-MockCalled -CommandName Invoke-DokuApiCall -ModuleName PSDokuWiki -Exactly -Times 2
            }
        }
    }
    Context 'When the page data is set successfully & PassThru is used' {
        InModuleScope PSDokuWiki {
            $Script:DokuServer = [PSCustomObject]@{ Server = 'wiki.example.com' }
            Mock Invoke-DokuApiCall  {
                return (
                    [PSCustomObject]@{
                        CompletedSuccessfully = $true
                        XMLPayloadResponse = '<?xml version="1.0"?><methodResponse><params><param><value><boolean>1</boolean></value></param></params></methodResponse>'
                    }
                )
            }
            $ResponseObject = Set-DokuPageData -FullName 'rootns:ns:pagename' -RawWikiText 'Test Data' -MinorChange -SummaryText 'Summary' -PassThru -Confirm:$False
            It 'Should return an object with all properties defined' {
                @('FullName','AddedText','MinorChange','SummaryText','PageName','ParentNamespace','RootNamespace') | Where-Object -FilterScript { (($ResponseObject).PSObject.Properties.Name) -notcontains $PSItem } | Should -BeNullOrEmpty
            }
            It 'Should return an object with the correct value for FullName' {
                $ResponseObject.FullName | Should -Be 'rootns:ns:pagename'
            }
            It 'Should return an object with the correct value for AddedText' {
                $ResponseObject.AddedText | Should -Be 'Test Data'
            }
            It 'Should return an object with the correct value for MinorChange' {
                $ResponseObject.MinorChange | Should -Be $true
            }
            It 'Should return an object with the correct value for SummaryText' {
                $ResponseObject.SummaryText | Should -Be 'Summary'
            }
            It 'Should return an object with the correct value for PageName' {
                $ResponseObject.PageName | Should -Be 'pagename'
            }
            It 'Should return an object with the correct value for ParentNamespace' {
                $ResponseObject.ParentNamespace | Should -Be 'ns'
            }
            It 'Should return an object with the correct value for RootNamespace' {
                $ResponseObject.RootNamespace | Should -Be 'rootns'
            }
        }
    }
}