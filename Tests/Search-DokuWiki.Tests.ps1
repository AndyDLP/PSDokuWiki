Describe 'Search-DokuWiki' {
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
            Search-DokuWiki -SearchString 'TestPhrase' -ErrorAction SilentlyContinue -ErrorVariable DokuErrorVariable
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
            Search-DokuWiki -SearchString 'TestPhrase' -ErrorAction SilentlyContinue -ErrorVariable DokuErrorVariable
            $DokuErrorVariable.exception.message | Should -Be 'Fault code: 12345 - Fault string: Fault String'
        }
    }
    Context 'When one hit is returned' {
        Mock Invoke-DokuApiCall -ModuleName PSDokuWiki {
            return (
                [PSCustomObject]@{
                    CompletedSuccessfully = $true
                    XMLPayloadResponse = '<?xml version="1.0"?><methodResponse><params><param><value><array><data><value><struct><member><name>id</name><value><string>rootns:ns:pagename</string></value></member><member><name>score</name><value><int>2</int></value></member><member><name>rev</name><value><int>1509909597</int></value></member><member><name>mtime</name><value><int>1509909597</int></value></member><member><name>size</name><value><int>17476</int></value></member><member><name>snippet</name><value><string>&lt;strong class="search_hit"&gt;TestPhrase&lt;/strong&gt;</string></value></member><member><name>title</name><value><string>PageTitle</string></value></member></struct></value></data></array></value></param></params></methodResponse>'
                }
            )
        }
        $ResponseObject = Search-DokuWiki -SearchString 'TestPhrase'

        It 'Should return an object with all properties defined' {
            @('FullName','Score','Revision','ModifiedTime','Size','Snippet','Title','PageName','ParentNamespace','RootNamespace') | Where-Object -FilterScript { (($ResponseObject).PSObject.Properties.Name) -notcontains $PSItem } | Should -BeNullOrEmpty
        }
        It 'Should return an object with the correct value for FullName' {
            $ResponseObject.FullName | Should -Be 'rootns:ns:pagename'
        }
        It 'Should return an object with the correct value for Score' {
            $ResponseObject.Score | Should -Be '2'
        }
        It 'Should return an object with the correct value for Revision' {
            $ResponseObject.Revision | Should -Be 1509909597
        }
        It 'Should return an object with the correct value for ModifiedTime' {
            $ResponseObject.ModifiedTime | Should -Be 1509909597
        }
        It 'Should return an object with the correct value for Size' {
            $ResponseObject.Size | Should -Be 17476
        }
        It 'Should return an object with the correct value for Snippet' {
            $ResponseObject.Snippet | Should -Be '<strong class="search_hit">TestPhrase</strong>'
        }
        It 'Should return an object with the correct value for Title' {
            $ResponseObject.Title | Should -Be 'PageTitle'
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
        It 'Should call Invoke-DokuApiCall once' {
            Assert-MockCalled -CommandName Invoke-DokuApiCall -ModuleName PSDokuWiki -Exactly -Times 1
        }
    }
    Context 'When no hits are returned' {
        Mock Invoke-DokuApiCall -ModuleName PSDokuWiki {
            return (
                [PSCustomObject]@{
                    CompletedSuccessfully = $true
                    XMLPayloadResponse = '<?xml version="1.0"?><methodResponse><params><param><value><array><data></data></array></value></param></params></methodResponse>'
                }
            )
        }
        It 'Should return nothing' {
            Search-DokuWiki -SearchString 'TestPhrase' | Should -BeNullOrEmpty
        }
        It 'Should call Invoke-DokuApiCall once' {
            Assert-MockCalled -CommandName Invoke-DokuApiCall -ModuleName PSDokuWiki -Exactly -Times 1
        }
    }
    Context 'When searching for two strings' {
        Mock Invoke-DokuApiCall -ModuleName PSDokuWiki {
            return (
                [PSCustomObject]@{
                    CompletedSuccessfully = $true
                    XMLPayloadResponse = '<?xml version="1.0"?><methodResponse><params><param><value><array><data></data></array></value></param></params></methodResponse>'
                }
            )
        }
        It 'Should call Invoke-DokuApiCall twice' {
            Search-DokuWiki -SearchString 'Phrase1','Phrase2'
            Assert-MockCalled -CommandName Invoke-DokuApiCall -ModuleName PSDokuWiki -Exactly -Times 2 -Scope It
        }
    }
    Context 'When two strings are piped to it' {
        Mock Invoke-DokuApiCall -ModuleName PSDokuWiki {
            return (
                [PSCustomObject]@{
                    CompletedSuccessfully = $true
                    XMLPayloadResponse = '<?xml version="1.0"?><methodResponse><params><param><value><array><data></data></array></value></param></params></methodResponse>'
                }
            )
        }
        It 'Should call Invoke-DokuApiCall twice' {
            'Phrase1','Phrase2' | Search-DokuWiki
            Assert-MockCalled -CommandName Invoke-DokuApiCall -ModuleName PSDokuWiki -Exactly -Times 2 -Scope It
        }
    }
}