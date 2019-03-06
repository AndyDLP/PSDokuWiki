Describe 'Get-DokuPageLink' {
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
            Get-DokuPageLink -FullName 'rootns:ns:pagename' -ErrorAction SilentlyContinue -ErrorVariable DokuErrorVariable
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
            Get-DokuPageLink -FullName 'rootns:ns:pagename' -ErrorAction SilentlyContinue -ErrorVariable DokuErrorVariable
            $DokuErrorVariable.exception.message | Should -Be 'Fault code: 12345 - Fault string: Fault String'
        }
    }
    Context 'When links on one page are returned' {
        Mock Invoke-DokuApiCall -ModuleName PSDokuWiki {
            return (
                [PSCustomObject]@{
                    CompletedSuccessfully = $true
                    XMLPayloadResponse = '<?xml version="1.0"?><methodResponse><value><array><data><value><struct><member><name>Type</name><value><string>internal</string></value></member><member><name>TargetPage</name><value><string>rootns2:ns2:pagename2</string></value></member><member><name>URL</name><value><string>http://wiki.example.com/doku.php?page=rootns2:ns2:pagename2</string></value></member></struct></value></data></array></value></methodResponse>'
                }
            )
        }
        $ResponseObject = Get-DokuPageLink -FullName 'rootns:ns:pagename'

        It 'Should return an object with all properties defined' {
            @('FullName','Type','TargetPageName','URL') | Where-Object -FilterScript { (($ResponseObject).PSObject.Properties.Name) -notcontains $PSItem } | Should -BeNullOrEmpty
        }
        It 'Should return an object with the correct value for FullName' {
            $ResponseObject.FullName | Should -Be 'rootns:ns:pagename'
        }
        It 'Should return an object with the correct value for Type' {
            $ResponseObject.Type | Should -Be 'internal'
        }
        It 'Should return an object with the correct value for TargetPageName' {
            $ResponseObject.TargetPageName | Should -Be 'rootns2:ns2:pagename2'
        }
        It 'Should return an object with the correct value for URL' {
            $ResponseObject.URL | Should -Be 'http://wiki.example.com/doku.php?page=rootns2:ns2:pagename2'
        }
        It 'Should call Invoke-DokuApiCall once' {
            Assert-MockCalled -CommandName Invoke-DokuApiCall -ModuleName PSDokuWiki -Exactly -Times 1
        }
    }
    Context 'When two links are returned' {
        Mock Invoke-DokuApiCall -ModuleName PSDokuWiki {
            return (
                [PSCustomObject]@{
                    CompletedSuccessfully = $true
                    XMLPayloadResponse = '<?xml version="1.0"?><methodResponse><value><array><data><value><struct><member><name>Type</name><value><string>internal</string></value></member><member><name>TargetPage</name><value><string>rootns2:ns2:pagename2</string></value></member><member><name>URL</name><value><string>http://wiki.example.com/doku.php?page=rootns2:ns2:pagename2</string></value></member></struct></value><value><struct><member><name>Type</name><value><string>external</string></value></member><member><name>TargetPage</name><value><string></string></value></member><member><name>URL</name><value><string>https://www.google.com</string></value></member></struct></value></data></array></value></methodResponse>'
                }
            )
        }
        $ResponseObject = (Get-DokuPageLink -FullName 'rootns:ns:pagename')

        It 'Should return an object with all properties defined' {
            @('FullName','Type','TargetPageName','URL') | Where-Object -FilterScript { (($ResponseObject[1]).PSObject.Properties.Name) -notcontains $PSItem } | Should -BeNullOrEmpty
        }
        It 'Should return an object with the correct value for FullName' {
            $ResponseObject[1].FullName | Should -Be 'rootns:ns:pagename'
        }
        It 'Should return an object with the correct value for Type' {
            $ResponseObject[1].Type | Should -Be 'external'
        }
        It 'Should return an object with the correct value for TargetPageName' {
            $ResponseObject[1].TargetPageName | Should -BeNullOrEmpty
        }
        It 'Should return an object with the correct value for URL' {
            $ResponseObject[1].URL | Should -Be 'https://www.google.com'
        }
        It 'Should call Invoke-DokuApiCall once' {
            Assert-MockCalled -CommandName Invoke-DokuApiCall -ModuleName PSDokuWiki -Exactly -Times 1
        }
        It 'Should return an array of two' {
            $ResponseObject.Count | Should -Be 2
        }
    }
}